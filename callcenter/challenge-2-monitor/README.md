# Desafio 2: Monitorar com o Application Insights

Tempo: ~20 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ Tracing de GenAI habilitado para seus agentes do Foundry
- ✅ Interações dos agentes visíveis como traces no Application Insights
- ✅ Compreensão de como depurar o comportamento dos agentes em produção

![monitor](./images/monitor.png)

## Contexto

Seus agentes funcionam — mas como saber se estão funcionando **bem**? E se um agente classificar incorretamente uma preocupação de segurança como uma contestação de cobrança? E se as recomendações de resolução demorarem demais para serem geradas nos horários de pico?

O **Application Insights** com **tracing de GenAI** oferece:

- Trace completo de cada interação do agente (mensagem do usuário → chamada do modelo → chamadas de ferramentas → resposta)
- Uso de tokens por solicitação
- Detalhamento da latência (rede, inferência do modelo e execução de ferramentas)
- Rastreamento de erros e alertas

## Por que monitorar?

Agentes de IA se comportam de maneira diferente de softwares tradicionais. Uma API convencional retorna os dados corretos ou lança um erro — você pode testá-la de forma determinística. A saída de um agente é probabilística: a mesma entrada pode produzir respostas sutilmente diferentes a cada execução, chamadas de ferramentas podem ter sucesso e ainda assim retornar dados inesperados, e as falhas podem ser silenciosas (o agente responde com confiança, mas incorretamente). Sem observabilidade, esses problemas ficam invisíveis até que um usuário os relate.

O monitoramento cumpre três funções críticas para agentes de IA:

- **Confiabilidade** — Detectar quando os agentes param de funcionar (falhas nas chamadas de ferramentas, timeouts e respostas vazias) antes dos usuários
- **Desempenho** — Acompanhar latência e uso de tokens ao longo do tempo, detectar regressões ao atualizar um prompt do sistema e dimensionar corretamente suas implantações para obter eficiência de custos
- **Depuração** — Quando algo dá errado, traces distribuídos fornecem um registro completo do raciocínio do modelo, das ferramentas chamadas, do que elas retornaram e de exatamente onde a cadeia foi interrompida

Para sistemas de IA em produção, o monitoramento é a base que torna a melhoria possível. Você não pode corrigir o que não consegue ver.

Especificamente para a central de atendimento da NovaTel: uma preocupação de segurança classificada incorretamente (CALL-007) e encaminhada à fila de cobrança significa que uma conta invadida ficará sem atendimento por horas. Um pico de latência durante o movimento da manhã significa que os agentes não conseguirão acompanhar a fila de chamadas. Sem traces, você nunca saberia qual chamada de ferramenta ou etapa de raciocínio do modelo causou o problema — ou sequer que ele ocorreu.

## Portal ou SDK?

O Microsoft Foundry oferece duas maneiras de monitorar agentes. O **portal do Foundry** ([ai.azure.com/nextgen](https://ai.azure.com/nextgen)) tem uma exibição integrada de **Tracing**, na qual você pode navegar pelas interações dos agentes, inspecionar spans individuais e ver o uso de tokens e a latência — sem precisar escrever código. O **Application Insights** (pelo portal do Azure) fornece análises mais profundas: consultas Kusto, dashboards personalizados e regras de alerta.

Neste desafio usamos o **SDK** — `monitor.py` instrumenta seus agentes para que cada interação seja capturada automaticamente como um trace distribuído. Depois que o script for executado, você explorará esses traces usando as duas opções de portal e verá como cada uma apresenta os mesmos dados de maneira diferente.

## Pré-requisitos

Certifique-se de que seu `.env` tenha:
```
AZURE_EXPERIMENTAL_ENABLE_GENAI_TRACING=true
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=xxx;...
```

## Conectar o Application Insights ao portal

O script de implantação vincula automaticamente o Application Insights ao seu projeto do Foundry. Para confirmar que funcionou, abra o [portal do Microsoft Foundry](https://ai.azure.com/nextgen), navegue até seu projeto e clique em **Tracing** na barra lateral esquerda — você deverá ver o recurso do Application Insights já conectado.

Se você vir um banner **"Create or connect an App Insights resource to get started"**, a conexão automática foi bloqueada por uma política do tenant. Corrija com um clique: clique em **Connect**, selecione o recurso `foundry-hack-insights-<suffix>` no menu suspenso e confirme. Você só precisa fazer isso uma vez.

## Comece agora

Abra [monitor.py](./monitor.py) e revise a configuração do tracing.

```bash
cd callcenter/challenge-2-monitor
python monitor.py
```

Quando o script terminar, seus traces estarão ativos. Explore-os no Portal do Azure.

---

### Etapa 1: Portal do Microsoft Foundry

1. Acesse o [Portal do Microsoft Foundry](https://ai.azure.com/nextgen) → abra seu projeto
2. Clique em `resolution-advisor-agent` -> **Traces**

   - **Painel Traces** — A guia **Conversations** lista cada execução de agente como uma linha, mostrando o ID da conversa, o ID do trace, o ID da resposta, o status, o horário de criação, a duração, os tokens de entrada/saída, o custo estimado, os resultados da avaliação e a versão do agente. Use a caixa de pesquisa e os filtros **Status**, **Duration**, **Tokens** e **Estimated Cost** (além do seletor de intervalo de datas) para restringir os resultados, alterne para a guia **Responses** para ver respostas individuais do modelo ou clique em **Create dataset** para transformar esses traces em um conjunto de dados de avaliação.

   ![traces](./images/traces.png)

3. Você verá uma lista de traces recentes — clique em qualquer linha para abri-la

   ![traces2](./images/traces2.png)

4. Dentro de um trace, você pode ver:
   - Cada **turno do agente** como um span (entrada → saída)
   - **Chamadas de ferramentas** (`lookup_customer`, etc.) como spans filhos com entradas/saídas
   - **Uso de tokens** e **latência** por span
   - O prompt completo do modelo e a conclusão se `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true`
5. Use a **exibição da linha do tempo** para encontrar spans lentos e o **painel de detalhes** para inspecionar mensagens individuais
6. Clique em `resolution-advisor-agent` -> **Monitor**

   - **Painel Monitor** — A guia **Overview** oferece um resumo rápido da saúde, com cartões de **Operational metrics** (custo estimado e uso total de tokens), **Evaluations**, **Scheduled evaluations** e **Scheduled red teaming run issues**. Abaixo, os gráficos de **Operational metrics** mostram **Agent runs** (com que frequência o agente foi chamado) e **Runs and token metrics** (chamadas versus tokens consumidos) no intervalo selecionado. Use a guia **Tools**, os filtros de data, **Settings** ou **Open in Azure Monitor** para uma análise mais profunda.

   ![monitor2](./images/monitor2.png)

### Etapa 2 - Application Insights

1. Acesse [portal.azure.com](https://portal.azure.com) → pesquise por **Application Insights** → abra `foundry-hack-insights-<suffix>`
2. Barra lateral esquerda → **Investigate** → **Search**

![Application Insights Search](./images/screen22.png)

3. Defina o intervalo de tempo como **Last 30 minutes** e clique em **Search** — você verá eventos de trace individuais
4. Procure traces nos quais seus agentes foram invocados.
   Você pode inspecionar o carimbo de data e hora, o ID da operação e o payload da mensagem para confirmar que as chamadas chegaram ao modelo.
5. Clique na instância `Resolution Advisor Agent`.
Você verá o **trace da transação de ponta a ponta**, mostrando:
   - A conversa completa do agente (entrada do usuário com resumos de chamadas → resposta do agente com recomendações de resolução)
   - Spans aninhados para cada chamada de modelo com detalhamento da latência (por exemplo, `gpt-5.4-2026-03-05` levando 5,1 segundos)
   - O prompt exato do sistema e o raciocínio gerado que o agente usou para chegar à conclusão
   - Detalhes do recurso (cluster do AKS e região) onde o agente foi executado
   - Quaisquer bloqueios de filtragem de conteúdo que violaram os padrões padrão de IA Responsável
   - Essa exibição permite inspecionar exatamente o que o agente "viu" e "raciocinou" para entender classificações incorretas ou problemas de desempenho
6. Na barra lateral esquerda → **Investigate** → **Agents (preview)** para abrir o dashboard operacional centrado nos agentes.
![alt text](./images/agentspane.png)
    - Use os filtros **Time range** e **Agent** na parte superior para delimitar a exibição, alterne entre as guias **Dashboard** e **All agents** ou clique em **Explore in Grafana** para uma análise mais profunda.
    - **Métricas operacionais dos agentes**:
       - **Agent Runs** — total de invocações dividido por agente (por exemplo, `resolution-advisor-agent`, `intent-classification-agent`). Clique em **View Traces with Agent Runs** para acessar os traces subjacentes.
       - **Gen AI Errors** — mostra traces com erros de GenAI na janela selecionada; uma marca verde significa que nenhum foi encontrado.
       - **Tool Calls** — uma tabela de cada ferramenta (por exemplo, `multi_tool_use.parallel`) com sua contagem de erros, duração média e número de chamadas, para que você identifique ferramentas lentas ou com falhas.
       - **Models** — detalhamento por modelo (por exemplo, `gpt-5.4-2026-03-05`, `gpt-5.4`) mostrando erros, duração média e contagem de chamadas.
    - **Consumo de tokens**:
       - **Token Consumption by Model** — total de tokens consumidos por modelo (por exemplo, ~22,1K para `gpt-5.4-2026-03-05`).
       - **Input vs Output Tokens** — totais de tokens de entrada versus saída ao longo do tempo (por exemplo, 17K de entrada versus 5,1K de saída), útil para acompanhar os fatores de custo.

---

## Critérios de sucesso

- [ ] O tracing de GenAI está habilitado e `monitor.py` foi executado com sucesso
- [ ] Você consegue navegar pelos traces dos agentes na exibição **Traces** do portal do Foundry e abrir uma conversa
- [ ] Você consegue ler o painel **Monitor** (execuções dos agentes, uso de tokens e custo estimado)
- [ ] Você consegue ver pelo menos um trace de agente no Application Insights e abrir seu trace de transação de ponta a ponta
- [ ] Você consegue usar o dashboard **Agents (preview)** para visualizar execuções de agentes, chamadas de ferramentas, modelos e consumo de tokens
- [ ] Você entende onde procurar quando um agente se comporta mal
