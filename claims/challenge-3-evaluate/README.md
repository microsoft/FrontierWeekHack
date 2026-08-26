# Desafio 3: Avaliar

Tempo: ~30 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ Executado uma avaliação sistemática dos seus agentes com um conjunto de dados de teste
- ✅ Usado avaliadores integrados (coerência, fluência) para medir a qualidade
- ✅ Interpretado métricas de avaliação e identificado áreas de melhoria
- ✅ Entendido como integrar avaliações a um pipeline de CI/CD

![evaluate](./images/evaluate.png)

## Contexto

O monitoramento informa **o que está acontecendo** (latência, erros, uso de tokens). A avaliação informa **se as decisões estão realmente corretas**.

Você tem um conjunto de dados com 10 casos de teste, cada um com métricas do sinistro e a saída correta esperada (classificação + ação recomendada). Você executará seus agentes nesses casos e medirá o desempenho usando pontuação com LLM como juiz.

## Por que avaliar?

O monitoramento informa que seus agentes estão *executando*; a avaliação informa se estão fazendo a *coisa certa*. Essas são perguntas fundamentalmente diferentes.

O monitoramento captura **sinais operacionais**: latência, contagem de tokens, taxas de erro e disponibilidade. Eles mostram *como* o sistema se comporta mecanicamente. A avaliação captura **sinais de qualidade**: as saídas do agente são corretas, relevantes, coerentes e consistentes com os resultados esperados? Eles mostram *se* o sistema está realmente cumprindo sua função.

Sem avaliação sistemática, você depende de verificações pontuais: lê algumas respostas e as julga subjetivamente. Isso não escala, não é repetível e não detecta regressões quando você atualiza um prompt ou troca de modelo. A avaliação fornece uma linha de base mensurável: uma pontuação que você pode acompanhar ao longo do tempo e comparar entre versões.

A avaliação também revela problemas que o monitoramento não enxerga. Um agente que sempre responde rapidamente e sem erros, mas aprova consistentemente sinistros de alto risco ou sinaliza sinistros legítimos para investigação desnecessária, parece perfeitamente saudável no monitoramento. A avaliação detecta isso imediatamente.

Para IA em produção, as avaliações devem ser executadas:

- **Antes da implantação**: estabeleça uma linha de base de qualidade e condicione as versões a pontuações mínimas
- **Após qualquer alteração**: em prompts de sistema, modelos, ferramentas ou documentos de política na base de conhecimento
- **Em uma programação**: para detectar desvios à medida que os padrões de fraude evoluem ou novos tipos de sinistro surgem

For ClaimSight specifically: an agent that approves CLM-001 (fraud risk score 0.87, document completeness 45%) because it generated a coherent-sounding rationale is a direct financial risk. Monitoring sees a successful response. Only evaluation — comparing the output against the expected "investigate" decision — catches the mistake.

## O conjunto de dados de avaliação

The dataset lives at [challenge-4-deploy/evaluation_dataset.json](../challenge-4-deploy/evaluation_dataset.json) — it contains:

- 10 claims covering normal, warning, and critical scenarios
- Each has an `input` (what you send to the agent)
- Each has an `expected_output` (the correct classification and action)

## Sobre os avaliadores

O Microsoft Foundry usa uma abordagem de **LLM como juiz**: um modelo separado lê cada resposta do agente junto com a entrada e a verdade de referência, e então atribui uma pontuação de 1 a 5. Você usará dois avaliadores integrados:

- **Coerência**: mede se a resposta do agente é logicamente estruturada e internamente consistente. Uma pontuação 5 significa que a saída é clara, bem organizada e flui naturalmente. Uma pontuação baixa indica uma resposta contraditória, confusa ou difícil de acompanhar. Para um agente de sinistros, isso detecta situações como recomendar aprovação e, ao mesmo tempo, sinalizar uma pontuação alta de risco de fraude.

- **Fluência**: mede a qualidade gramatical e linguística da resposta do agente. Uma pontuação 5 significa que a saída é bem escrita, natural e fácil de ler. Uma pontuação baixa indica uma resposta com formulação estranha, erros gramaticais ou difícil de interpretar, o que reduz a confiança na decisão mesmo quando a avaliação subjacente está correta.

These two scores together give you a quick signal on output quality. When you see a low coherence score, look at the agent's system prompt structure. When you see a low fluency score, look at how the agent phrases its output and whether its system prompt encourages clear, well-formed responses.

## Primeiros passos

The evaluation dataset has already been prepared for you as [eval_portal.jsonl](./eval_portal.jsonl) — 10 insurance claim scenarios ready to upload.

---

### Etapa 1: Abrir a guia de avaliação

1. Go to the [Microsoft Foundry portal](https://ai.azure.com/nextgen) → your project
2. On the top bar → **Build** → **Evaluations** → **Create**

### Etapa 2: Configurar a avaliação

3. Select **Agent** as the evaluation target
4. Choose `claims-triage-agent` from the dropdown
5. Select **Individual Turns** and then **Existing Dataset**
6. Click on **Upload new dataset**. 
You must enter a dataset name first — the upload stays disabled until you do. Type a name (e.g. `claims-eval`), then add the file located on `claims/challenge-3-evaluate/eval_portal.jsonl` and confirm the upload.
7. Leave the **Field Mapping** and **Configure Agents** fields as is.
8. In the **Criteria** step, keep only **Coherence** and **Fluency**. Remove every other evaluator — in particular **deselect Tool Call Accuracy**, since the agents can't execute the local tools during evaluation and will always score low on it. Trimming the evaluator list also makes the run significantly faster.
9. Leave the Evaluation Name as is or configure to your liking.
10. Submit your Evaluation. This will take some time to run.

### Etapa 3: Exibir resultados

Results appear in the **Evaluate** tab within a few minutes. Click the run name to open the results.

There are two ways to read the results, and they answer different questions:

- **Aggregate metrics** — the average score for each evaluator across all 10 test cases (e.g. an overall Coherence of 4.2). This is your single-number quality baseline — the headline figure you track over time and compare across agent versions.
- **Per-row analysis** — the score for each individual test case, so you can see *which specific scenarios* dragged the average down. The aggregate tells you *if* there's a problem; the per-row view tells you *where* it is. Sort by the lowest scores to find the cases worth investigating.

---

## Critérios de sucesso

- [ ] A avaliação é executada nos 10 casos de teste sem erros
- [ ] Você consegue ver as pontuações por linha de coerência e fluência
- [ ] Você identificou pelo menos um caso em que o agente pode melhorar
- [ ] Você entende a diferença entre métricas agregadas e análise por linha
