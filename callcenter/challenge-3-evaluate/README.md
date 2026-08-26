# Desafio 3: Avaliar

Tempo: ~30 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ Executado uma avaliação sistemática dos seus agentes com um conjunto de dados de teste
- ✅ Usado avaliadores integrados (coerência e fluência) para medir a qualidade
- ✅ Interpretado métricas de avaliação e identificado áreas de melhoria
- ✅ Compreendido como integrar avaliações a um pipeline de CI/CD

![evaluate](./images/evaluate.png)

## Contexto

O monitoramento informa **o que está acontecendo** (latência, erros e uso de tokens). A avaliação informa **se as classificações estão realmente corretas**.

Você tem um conjunto de dados com 10 casos de teste — cada um com um cenário de chamada e a classificação correta esperada (intenção, prioridade, sentimento e ação recomendada). Você executará seus agentes com esses casos de teste e medirá o desempenho usando pontuação LLM-as-judge.

## Por que avaliar?

O monitoramento informa que seus agentes estão *executando* — a avaliação informa se estão fazendo a *coisa certa*. São perguntas fundamentalmente diferentes.

O monitoramento captura **sinais operacionais**: latência, contagem de tokens, taxas de erro e disponibilidade. Eles informam *como* o sistema se comporta mecanicamente. A avaliação captura **sinais de qualidade**: as saídas do agente são corretas, relevantes, coerentes e consistentes com os resultados esperados? Eles informam *se* o sistema está realmente cumprindo sua função.

Sem uma avaliação sistemática, você depende de verificações pontuais — lê algumas respostas e as julga subjetivamente. Isso não escala, não é repetível e não detecta regressões quando você atualiza um prompt ou troca de modelo. A avaliação fornece uma linha de base mensurável: uma pontuação que pode ser acompanhada ao longo do tempo e comparada entre versões.

A avaliação também revela problemas que o monitoramento não consegue detectar. Um agente que sempre responde rapidamente e sem erros, mas classifica intenções de forma incorreta ou fornece resoluções roteirizadas que não correspondem à situação real do cliente, parece perfeitamente saudável para o monitoramento. A avaliação detecta isso imediatamente.

Para IA em produção, as avaliações devem ser executadas:

- **Antes da implantação** — estabelecer uma linha de base de qualidade e controlar versões com pontuações mínimas
- **Depois de qualquer alteração** — em prompts do sistema, modelos, ferramentas ou dados de recuperação
- **Em uma agenda** — detectar desvios à medida que o modelo subjacente é atualizado ou os padrões de chamadas mudam

Especificamente para a central de atendimento da NovaTel: um agente que classifica a CALL-007 (suspeita de invasão da conta) como uma contestação de cobrança é perigoso — trata-se de um incidente de segurança que precisa ser encaminhado imediatamente. O monitoramento vê uma resposta bem-sucedida e de baixa latência. Somente a avaliação — comparando a saída com a classificação esperada — detecta o erro.

## O conjunto de dados de avaliação

O conjunto de dados está em [challenge-4-deploy/evaluation_dataset.json](../challenge-4-deploy/evaluation_dataset.json) — ele contém:

- 10 cenários de chamadas cobrindo os 6 tipos de intenção
- Cada um tem um `input` (resumo da chamada enviado ao agente)
- Cada um tem um `expected_output` (a classificação e ação corretas)

## Sobre os avaliadores

O Microsoft Foundry usa uma abordagem **LLM-as-judge** — um modelo separado lê cada resposta do agente junto com a entrada e a verdade de referência, depois atribui uma pontuação de 1 a 5. Você usará dois avaliadores integrados:

- **Coerência** — mede se a resposta do agente é estruturada logicamente e consistente internamente. Uma pontuação 5 significa que a saída é clara, bem organizada e flui naturalmente. Uma pontuação baixa significa que a resposta é contraditória, confusa ou difícil de acompanhar. Para um agente de central de atendimento, isso detecta situações como recomendar um upsell enquanto classifica simultaneamente a intenção como risco de cancelamento.

- **Fluência** — mede a qualidade gramatical e linguística da resposta do agente. Uma pontuação 5 significa que a saída é bem escrita, natural e fácil de ler. Uma pontuação baixa significa que a resposta é formulada de maneira estranha, apresenta problemas gramaticais ou é difícil de interpretar — o que reduz a confiança na classificação mesmo quando a decisão subjacente está correta.

Juntas, essas duas pontuações fornecem um sinal rápido da qualidade da saída. Ao ver uma pontuação baixa de coerência, examine a estrutura do prompt do sistema do agente. Ao ver uma pontuação baixa de fluência, observe como o agente formula sua saída e se o prompt do sistema incentiva respostas claras e bem estruturadas.

## Comece agora

O conjunto de dados de avaliação já foi preparado para você em [eval_portal.jsonl](./eval_portal.jsonl) — são 10 cenários de chamadas prontos para upload.

---

### Etapa 1: Abrir a guia de avaliação

1. Acesse o [portal do Microsoft Foundry](https://ai.azure.com/nextgen) → seu projeto
2. Na barra superior → **Build** → **Evaluations** → **Create**

### Etapa 2: Configurar a avaliação

3. Selecione **Agent** como destino da avaliação
4. Escolha `intent-classification-agent` no menu suspenso
5. Selecione **Individual Turns** e depois **Existing Dataset**
6. Clique em **Upload new dataset**. Primeiro, você precisa inserir um nome para o conjunto de dados — o upload permanecerá desabilitado até que você faça isso. Digite um nome (por exemplo, `callcenter-eval`), depois adicione o arquivo localizado em `callcenter/challenge-3-evaluate/eval_portal.jsonl` e confirme o upload.
7. Deixe os campos **Field Mapping** e **Configure Agents** como estão.
8. Na etapa **Criteria**, mantenha apenas **Coherence** e **Fluency**. Remova todos os outros avaliadores — em especial **desmarque Tool Call Accuracy**, pois os agentes não conseguem executar as ferramentas locais durante a avaliação e sempre terão uma pontuação baixa nesse item. Reduzir a lista de avaliadores também torna a execução significativamente mais rápida.
9. Mantenha o nome da avaliação como está ou configure-o como preferir.
10. Envie sua avaliação. A execução levará algum tempo.

### Etapa 3: Ver os resultados

Os resultados aparecem na guia **Evaluate** em alguns minutos. Clique no nome da execução para abrir os resultados.

Há duas maneiras de ler os resultados, e elas respondem a perguntas diferentes:

- **Métricas agregadas** — a pontuação média de cada avaliador nos 10 casos de teste (por exemplo, uma Coerência geral de 4,2). Essa é sua linha de base de qualidade em um único número — o indicador principal que você acompanha ao longo do tempo e compara entre versões dos agentes.
- **Análise por linha** — a pontuação de cada caso de teste individual, para que você veja *quais cenários específicos* reduziram a média. O agregado informa *se* existe um problema; a exibição por linha informa *onde* ele está. Ordene pelas pontuações mais baixas para encontrar os casos que merecem investigação.

---

## Critérios de sucesso

- [ ] A avaliação é executada nos 10 casos de teste sem erros
- [ ] Você consegue ver as pontuações por linha de coerência e fluência
- [ ] Você identificou pelo menos um caso em que o agente pode melhorar
- [ ] Você entende a diferença entre métricas agregadas e análise por linha
