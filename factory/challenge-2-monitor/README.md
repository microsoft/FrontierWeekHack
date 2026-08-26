# Desafio 2: Monitorar com o Application Insights

Tempo: ~20 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ O rastreamento GenAI habilitado para seus agentes do Foundry
- ✅ As interações dos agentes visíveis como rastreamentos no Application Insights
- ✅ Entendimento de como depurar o comportamento dos agentes em produção

![monitor](./images/monitor.png)

## Contexto

Seus agentes funcionam, mas como saber se estão funcionando **bem**? E se um agente der uma resposta ruim? E se a latência aumentar? E se uma chamada de ferramenta falhar silenciosamente?

O **Application Insights** com **rastreamento GenAI** oferece:

- Rastreamento completo de cada interação do agente (mensagem do usuário → chamada do modelo → chamadas de ferramentas → resposta)
- Uso de tokens por solicitação
- Detalhamento da latência (rede, inferência do modelo e execução de ferramentas)
- Rastreamento e alertas de erros

## Por que Monitorar?

Os agentes de IA se comportam de maneira diferente do software tradicional. Uma API convencional retorna os dados corretos ou lança um erro, e você pode testá-la de forma determinística. A saída de um agente é probabilística: a mesma entrada pode produzir respostas sutilmente diferentes a cada execução, chamadas de ferramentas podem ter sucesso mas retornar dados inesperados, e as falhas podem ser silenciosas (o agente responde com confiança, mas incorretamente). Sem observabilidade, esses problemas ficam invisíveis até que um usuário os relate.

O monitoramento desempenha três funções críticas para agentes de IA:

- **Confiabilidade** — Detectar quando os agentes param de funcionar (falhas de chamadas de ferramentas, timeouts e respostas vazias) antes dos usuários
- **Desempenho** — Acompanhar a latência e o uso de tokens ao longo do tempo, detectar regressões ao atualizar um prompt de sistema e dimensionar corretamente suas implantações para obter eficiência de custos
- **Depuração** — Quando algo dá errado, os rastreamentos distribuídos fornecem um registro completo do raciocínio do modelo, das ferramentas chamadas, do que elas retornaram e do ponto exato em que a cadeia foi interrompida

Para sistemas de IA em produção, o monitoramento é a base que torna possível a melhoria. Você não pode corrigir o que não consegue ver.

Especificamente para a TireForge: um falso negativo do Agente de Detecção de Anomalias, que informe a CP-003 como saudável quando a pressão estiver se aproximando de uma falha, poderia significar a quebra da prensa de cura durante a produção e a perda de um lote inteiro de pneus. Os rastreamentos mostram exatamente quais valores de sensores o agente viu, o que `check_thresholds` retornou e por que o agente concluiu "normal", para que você possa corrigir o prompt ou os limites antes que isso aconteça novamente.

## Portal ou SDK?

O Microsoft Foundry oferece duas maneiras de monitorar agentes. O **portal do Foundry** ([ai.azure.com/nextgen](https://ai.azure.com/nextgen)) tem uma visualização integrada de **Rastreamento**, na qual você pode navegar pelas interações dos agentes, inspecionar spans individuais e ver o uso de tokens e a latência, sem precisar escrever código. O **Application Insights** (pelo portal do Azure) oferece análises mais profundas: consultas Kusto, painéis personalizados e regras de alerta.

Neste desafio usamos o **SDK** — `monitor.py` instrumenta seus agentes para que cada interação seja capturada automaticamente como um rastreamento distribuído. Depois que o script for executado, você explorará esses rastreamentos usando as duas opções de portal e verá como cada uma apresenta os mesmos dados de maneira diferente.

## Pré-requisitos

Verifique se seu `.env` tem:
```
AZURE_EXPERIMENTAL_ENABLE_GENAI_TRACING=true
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=xxx;...
```

## Conectar o Application Insights ao Portal

O script de implantação vincula automaticamente o Application Insights ao seu projeto do Foundry. Para confirmar que funcionou, abra o [portal do Microsoft Foundry](https://ai.azure.com/nextgen), navegue até seu projeto e clique em **Rastreamento** na barra lateral esquerda. O recurso do Application Insights já deverá aparecer conectado.

Se você vir o banner **"Create or connect an App Insights resource to get started"**, a conexão automática foi bloqueada por uma política do locatário. Corrija com um clique: clique em **Connect**, selecione o recurso `foundry-hack-insights-<suffix>` na lista suspensa e confirme. Você só precisa fazer isso uma vez.

## Comece Aqui

Abra [monitor.py](./monitor.py) e examine a configuração do rastreamento.

```bash
cd factory/challenge-2-monitor
python monitor.py
```

Quando o script terminar, seus rastreamentos estarão ativos. Explore-os no Portal do Azure.

---

### Etapa 1: Portal do Microsoft Foundry

1. Acesse o [Portal do Microsoft Foundry](https://ai.azure.com/nextgen) → abra seu projeto
2. Clique em `anomaly-detection-agent` -> **Traces**

   - **Painel de rastreamentos** — A guia **Conversations** lista cada execução do agente em uma linha, mostrando o ID da conversa, o ID do rastreamento, o ID da resposta, o status, o horário de criação, a duração, os tokens de entrada/saída, o custo estimado, os resultados da avaliação e a versão do agente. Use a caixa de pesquisa e os filtros **Status**, **Duration**, **Tokens** e **Estimated Cost** (além do seletor de intervalo de datas) para restringir os resultados, alterne para a guia **Responses** para ver respostas individuais do modelo ou clique em **Create dataset** para transformar esses rastreamentos em um conjunto de dados de avaliação.

   ![traces](./images/traces.png)

3. Você verá uma lista de rastreamentos recentes; clique em qualquer linha para abri-la

   ![traces2](./images/traces2.png)

4. Dentro de um rastreamento, você pode ver:
   - Cada **turno do agente** como um span (entrada → saída)
   - **Chamadas de ferramentas** (`check_thresholds`, etc.) como spans filhos com entradas/saídas
   - **Uso de tokens** e **latência** por span
   - O prompt completo e a conclusão do modelo se `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true`
5. Use a **visualização da linha do tempo** para localizar spans lentos e o **painel de detalhes** para inspecionar mensagens individuais
6. Clique em `anomaly-detection-agent` -> **Monitor**

   - **Painel Monitor** — A guia **Overview** oferece um resumo rápido da saúde, com cartões para **Operational metrics** (custo estimado e uso total de tokens), **Evaluations**, **Scheduled evaluations** e **Scheduled red teaming run issues**. Abaixo, os gráficos de **Operational metrics** mostram **Agent runs** (com que frequência o agente foi chamado) e **Runs and token metrics** (chamadas versus tokens consumidos) no intervalo de tempo selecionado. Use a guia **Tools**, os filtros de data, **Settings** ou **Open in Azure Monitor** para uma análise mais profunda.

   ![monitor2](./images/monitor2.png)

### Etapa 2 - Application Insights

1. Acesse [portal.azure.com](https://portal.azure.com) → pesquise por **Application Insights** → abra `foundry-hack-insights-<suffix>`
2. Barra lateral esquerda → **Investigate** → **Search**

![Application Insights Search](./images/screen21.png)

3. Defina o intervalo de tempo como **Last 30 minutes** e clique em **Search**; você verá eventos individuais de rastreamento
4. Procure rastreamentos nos quais seus agentes foram invocados.
   Você pode inspecionar o carimbo de data/hora, o ID da operação e o conteúdo da mensagem para confirmar que as chamadas chegaram ao modelo.
5. Clique na instância `Anomaly Detection Agent`.
Você verá o **rastreamento da transação de ponta a ponta**, mostrando:
   - A conversa completa do agente (entrada do usuário com anomalias dos sensores → resposta do agente com diagnóstico)
   - Spans aninhados para cada chamada de modelo com detalhamento da latência (por exemplo, `gpt-5.4-2026-03-05` levando 5,1 segundos)
   - O prompt de sistema exato e o raciocínio gerado pelo agente para chegar à conclusão
   - Detalhes do recurso (cluster AKS e região) onde o agente foi executado
   - Quaisquer bloqueios de filtragem de conteúdo que tenham violado os padrões padrão de IA Responsável
   - Essa visualização permite inspecionar exatamente o que o agente "viu" e "raciocinou" para entender classificações incorretas ou problemas de desempenho
6. Na barra lateral esquerda → **Investigate** → **Agents (preview)** para abrir o painel de operações centrado nos agentes.
![alt text](./images/agentspane.png)
   - Use os filtros **Time range** e **Agent** na parte superior para delimitar a visualização, alterne entre as guias **Dashboard** e **All agents** ou clique em **Explore in Grafana** para uma análise mais profunda.
    - **Métricas Operacionais dos Agentes**:
       - **Agent Runs** — total de invocações dividido por agente (por exemplo, `fault-diagnosis-agent`, `anomaly-detection-agent`). Clique em **View Traces with Agent Runs** para acessar os rastreamentos subjacentes.
       - **Gen AI Errors** — mostra rastreamentos com erros de GenAI na janela selecionada; uma marca verde significa que nenhum foi encontrado.
       - **Tool Calls** — uma tabela de cada ferramenta (por exemplo, `multi_tool_use.parallel`) com sua contagem de erros, duração média e número de chamadas, para que você identifique ferramentas lentas ou com falhas.
       - **Models** — detalhamento por modelo (por exemplo, `gpt-5.4-2026-03-05`, `gpt-5.4`) mostrando erros, duração média e contagens de chamadas.
    - **Consumo de Tokens**:
       - **Token Consumption by Model** — total de tokens consumidos por modelo (por exemplo, ~22,1 mil para `gpt-5.4-2026-03-05`).
       - **Input vs Output Tokens** — totais de tokens de entrada versus saída ao longo do tempo (por exemplo, 17 mil de entrada contra 5,1 mil de saída), útil para acompanhar os fatores de custo.

---

## Critérios de Sucesso

- [ ] O rastreamento GenAI está habilitado e `monitor.py` foi executado com sucesso
- [ ] Você consegue navegar pelos rastreamentos dos agentes na visualização **Traces** do portal do Foundry e abrir uma conversa
- [ ] Você consegue ler o painel **Monitor** (execuções dos agentes, uso de tokens e custo estimado)
- [ ] Você consegue ver pelo menos um rastreamento de agente no Application Insights e abrir seu rastreamento de transação de ponta a ponta
- [ ] Você consegue usar o painel **Agents (preview)** para ver execuções de agentes, chamadas de ferramentas, modelos e consumo de tokens
- [ ] Você entende onde procurar quando um agente se comporta incorretamente
