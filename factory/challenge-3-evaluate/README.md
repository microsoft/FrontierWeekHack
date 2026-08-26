# Desafio 3: Avaliar

Tempo: ~30 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ Executado uma avaliação sistemática dos seus agentes com um conjunto de testes
- ✅ Usado avaliadores integrados (coerência e fluência) para medir a qualidade
- ✅ Interpretado métricas de avaliação e identificado áreas de melhoria
- ✅ Entendido como integrar avaliações a um pipeline de CI/CD

![evaluate](./images/evaluate.png)

## Contexto

O monitoramento informa **o que está acontecendo** (latência, erros e uso de tokens). A avaliação informa **se as respostas são realmente boas**.

Você tem um conjunto de dados com 10 casos de teste, cada um com um instantâneo das leituras dos sensores e a saída correta esperada (classificação + ação recomendada). Você executará seus agentes nesses casos e medirá o desempenho usando pontuação com LLM como juiz.

## Por que Avaliar?

O monitoramento informa que seus agentes estão *executando*; a avaliação informa se estão fazendo a *coisa certa*. Essas são perguntas fundamentalmente diferentes.

O monitoramento captura **sinais operacionais**: latência, contagem de tokens, taxas de erro e disponibilidade. Eles informam *como* o sistema se comporta mecanicamente. A avaliação captura **sinais de qualidade**: as saídas do agente estão corretas, relevantes, coerentes e consistentes com os resultados esperados? Esses sinais informam *se* o sistema está realmente cumprindo sua função.

Sem uma avaliação sistemática, você depende de verificações pontuais: lê algumas respostas e as julga subjetivamente. Isso não escala, não é repetível e não detecta regressões quando você atualiza um prompt ou troca de modelo. A avaliação fornece uma linha de base mensurável: uma pontuação que você pode acompanhar ao longo do tempo e comparar entre versões.

A avaliação também revela problemas que o monitoramento não enxerga. Um agente que sempre responde rapidamente e sem erros, mas diagnostica incorretamente as condições de falha de forma recorrente, ou recomenda "agendar manutenção de rotina" para uma máquina que precisa ser desligada imediatamente, parece perfeitamente saudável para o monitoramento. A avaliação detecta isso na hora.

Para IA em produção, as avaliações devem ser executadas:

- **Antes da implantação** — estabelecer uma linha de base de qualidade e controlar versões com pontuações mínimas
- **Após qualquer mudança** — em prompts de sistema, modelos, ferramentas ou dados de limites
- **Em uma programação** — detectar desvios à medida que as configurações das máquinas ou as condições operacionais evoluem

Especificamente para a TireForge: um agente que diagnostique com confiança uma anomalia da CP-003 como "vibração normal" quando os limites foram excedidos pode atrasar uma ação crítica de manutenção por horas. O monitoramento vê uma resposta rápida e sem erros. Somente a avaliação, comparando a saída com a classificação correta conhecida, revela o problema.

## O Conjunto de Dados de Avaliação

O conjunto de dados está em [challenge-4-deploy/evaluation_dataset.json](../challenge-4-deploy/evaluation_dataset.json) e contém:

- 10 cenários que abrangem máquinas normais, em alerta e críticas
- Cada um tem um `input` (o que você envia ao agente)
- Cada um tem um `expected_output` (a classificação e a ação corretas)

## Sobre os Avaliadores

O Microsoft Foundry usa uma abordagem de **LLM como juiz**: um modelo separado lê cada resposta do agente junto com a entrada e a verdade de referência e atribui uma pontuação de 1 a 5. Você usará dois avaliadores integrados:

- **Coerência** — mede se a resposta do agente é logicamente estruturada e internamente consistente. Uma pontuação 5 significa que a saída é clara, bem organizada e flui naturalmente. Uma pontuação baixa significa que a resposta é contraditória, confusa ou difícil de acompanhar. Para um agente de fábrica, isso detecta situações como recomendar "nenhuma ação" enquanto lista anomalias críticas.

- **Fluência** — mede a qualidade gramatical e linguística da resposta do agente. Uma pontuação 5 significa que a saída é bem escrita, natural e fácil de ler. Uma pontuação baixa significa que a resposta tem formulação estranha, erros gramaticais ou é difícil de interpretar, o que reduz a confiança na classificação mesmo quando o diagnóstico subjacente está correto.

Juntas, essas duas pontuações fornecem um sinal rápido da qualidade da saída. Ao ver uma pontuação baixa de coerência, examine a estrutura do prompt de sistema do agente. Ao ver uma pontuação baixa de fluência, examine como o agente formula a saída e se o prompt de sistema incentiva respostas claras e bem construídas.

## Comece Aqui

O conjunto de dados de avaliação já foi preparado para você em [eval_portal.jsonl](./eval_portal.jsonl): são 10 cenários de sensores de máquinas prontos para upload.

---

### Etapa 1: Abrir a guia de avaliação

1. Acesse o [portal do Microsoft Foundry](https://ai.azure.com/nextgen) → seu projeto
2. Na barra superior → **Criar** → **Avaliações** → **Criar**

### Etapa 2: Configurar a avaliação

3. Selecione **Agente** como destino da avaliação
4. Escolha `anomaly-detection-agent` na lista suspensa
5. Selecione **Turnos individuais** e depois **Conjunto de dados existente**
6. Clique em **Carregar novo conjunto de dados**.
Primeiro, você deve inserir um nome para o conjunto de dados; o upload permanecerá desabilitado até isso ser feito. Digite um nome (por exemplo, `factory-eval`), adicione o arquivo localizado em `factory/challenge-3-evaluate/eval_portal.jsonl` e confirme o upload.
7. Deixe os campos **Mapeamento de campos** e **Configurar agentes** como estão.
8. Na etapa **Critérios**, mantenha apenas **Coerência** e **Fluência**. Remova todos os outros avaliadores, especialmente **desmarque Tool Call Accuracy**, pois os agentes não podem executar as ferramentas locais durante a avaliação e sempre terão uma pontuação baixa nesse item. Reduzir a lista de avaliadores também torna a execução significativamente mais rápida.
9. Mantenha o Nome da avaliação como está ou configure-o como preferir.
10. Envie sua avaliação. A execução levará algum tempo.

### Etapa 3: Ver os resultados

Os resultados aparecem na guia **Avaliar** em alguns minutos. Clique no nome da execução para abrir os resultados.

Há duas maneiras de ler os resultados, e elas respondem a perguntas diferentes:

- **Métricas agregadas** — a pontuação média de cada avaliador nos 10 casos de teste (por exemplo, uma Coerência geral de 4,2). Essa é sua linha de base de qualidade em um único número, o principal valor que você acompanha ao longo do tempo e compara entre versões dos agentes.
- **Análise por linha** — a pontuação de cada caso de teste individual, para que você veja *quais cenários específicos* reduziram a média. O agregado informa *se* há um problema; a visualização por linha informa *onde* ele está. Ordene pelas pontuações mais baixas para encontrar os casos que merecem investigação.

---

## Critérios de Sucesso

- [ ] A avaliação é executada nos 10 casos de teste sem erros
- [ ] Você consegue ver as pontuações por linha de coerência e fluência
- [ ] Você identificou pelo menos um caso em que o agente poderia melhorar
- [ ] Você entende a diferença entre métricas agregadas e análise por linha
