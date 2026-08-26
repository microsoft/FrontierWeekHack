# Desafio 4: Fluxo de produção

Tempo: ~20 minutos

Crie um fluxo de orquestração multiagente para a NovaTel Communications e leve-o à produção.

## Cenário

Os agentes individuais que você criou no Desafio 1 são valiosos — mas, em produção, os agentes precisam trabalhar
**juntos** como um pipeline automatizado. Neste desafio, você conectará os dois agentes em um fluxo completo
de triagem da central de atendimento, executará o fluxo pelo código e depois o criará e testará visualmente no portal do Foundry.

![deploy](./images/deploy.png)

## Objetivos de aprendizagem

- Implantar agentes de produção persistentes (criar uma vez e reutilizar sempre)
- Orquestrar vários agentes passo a passo em um fluxo Python
- Criar visualmente o mesmo fluxo no portal do Foundry
- Invocar o fluxo do portal pelo Python com streaming ao vivo
- Visualizar o histórico de execuções e traces no portal

## O fluxo

```
ensure_agents_deployed()
        |
        v
run_intent_classification()     <-- Intent Agent classifies all 7 calls
        |
        v (for each high-priority call)
run_resolution_advisory()       <-- Resolution Agent recommends actions
        |
        v
print_shift_report()            <-- Consolidated Shift Report
```

---

## Parte 1 — SDK: criar e executar o fluxo Python

### Etapa 1: Revisar a implementação

Abra [deploy.py](./deploy.py) e revise:

- **`ensure_agents_deployed()`** — lista os agentes existentes e cria `intent-classification-agent` e `resolution-advisor-agent` se não estiverem presentes
- **`run_intent_classification()`** — chama o agente de intenção e trata o loop de chamadas de função `lookup_customer`
- **`run_resolution_advisory()`** — chama o agente de resolução para cada chamada de alta prioridade
- **`run_call_center_workflow()`** — orquestra todas as etapas e retorna o relatório consolidado

### Etapa 2: Executar o fluxo

```bash
cd callcenter/challenge-4-deploy
python deploy.py
```

Saída esperada:
```
=== Step 1: Ensure Agents Are Deployed ===
  Found existing: intent-classification-agent
  Found existing: resolution-advisor-agent

=== Step 2a: Intent Classification ===
  CALL-001: billing_dispute (HIGH) — frustrated, retention risk HIGH
  CALL-002: technical_issue (HIGH) — frustrated, retention risk MEDIUM
  CALL-003: cancellation (HIGH) — neutral, retention risk HIGH
  CALL-004: upsell_opportunity (MEDIUM) — positive, retention risk LOW
  CALL-005: account_support (LOW) — frustrated, retention risk LOW
  CALL-006: billing_dispute (HIGH) — frustrated, retention risk MEDIUM
  CALL-007: security_concern (CRITICAL) — anxious, retention risk MEDIUM

=== Step 2b: Resolution Advisory (High-Priority Calls) ===
  Resolving CALL-007 (security_concern)...
  Resolving CALL-001 (billing_dispute)...
  Resolving CALL-003 (cancellation)...

NOVATEL CALL CENTER — SHIFT REPORT
  Total calls processed  : 7
  Critical priority      : 1
  High priority          : 2
  ...
```

---

## Parte 2 — Portal: criar e testar o fluxo visual

### Etapa 3: Verificar se os agentes estão implantados no portal

1. Abra o [portal do Microsoft Foundry](https://ai.azure.com/nextgen)
2. Selecione seu projeto
3. Selecione **Build** → **Agents** na barra superior
4. Confirme que os dois agentes aparecem:
   - `intent-classification-agent`
   - `resolution-advisor-agent`


### Etapa 4: Criar o fluxo no designer do portal

1. Selecione **Build** → **Agents** → **Workflows**
2. Observe que o fluxo criado usando o SDK na Parte 1 está listado. Vamos criar um novo fluxo selecionando **Create** → **Blank workflow**

![Create workflow](./images/create-workflow.png)

3. No designer visual, na caixa de diálogo **Add a workflow node**, escolha **Agent**

   ![add agent](./images/add-agent.png)

4. No seletor **Select an agent**, selecione `intent-classification-agent`

   ![select agent](./images/select-agent.png)

5. No seletor **Next node**, selecione **Agent** e clique no botão **Done**
   \
    ![next node agent](./images/next-node-agent.png)

6. Selecione o novo nó de agente na tela e, no seletor **Select and agent**, selecione `resolution-advisor-agent`

   ![select agent 2](./images/select-agent-2.png) 

7. No seletor **Next node**, selecione **End** e clique no botão **Done**

    ![end node](./images/end-node.png) 

8. Selecione **Save** e dê a ele o nome `callcenter-triage-workflow-portal`

![Save agent](./images/save-agent.png) 

### Etapa 5: Testar o fluxo no playground do portal

> **Por que você precisa incluir os dados da chamada na mensagem**
>
> Os agentes usam uma ferramenta `lookup_customer` que lê dados de um arquivo Python local.
> O playground do portal **não consegue executar funções Python** — se você enviar um
> prompt genérico, o agente tentará chamar a ferramenta e ficará parado esperando um resultado que
> nunca chegará. Cole os dados da chamada diretamente na mensagem para que os agentes possam
> trabalhar sem precisar da ferramenta.

1. Abra **callcenter-triage-workflow-portal** → **Preview**

![Preview Agent](./images/preview-agent.png) 

2. Cole a mensagem a seguir (os dados já estão incorporados, portanto não são necessárias chamadas de ferramentas):

   ```
   All call data for today is below — analyse it directly, do not call lookup_customer.

   CALL-001 | Maria Gonzalez | premium | 36 months
   Unexpected $47.99 charge for sports add-on she never subscribed to. Wants refund, threatening to cancel.

   CALL-002 | James Liu | basic | 4 months
   Internet dropping every 20-30 minutes since yesterday. Works from home, presentation tomorrow. 1 open ticket.

   CALL-003 | Priya Sharma | premium | 18 months
   Moving to city without NovaTel coverage, wants to cancel. Asking about ETF and final bill.

   CALL-004 | Robert Chen | business | 24 months
   Wants to expand from 5 to 12 lines for new hires. Asking about bulk pricing and number porting.

   CALL-005 | Sarah Mitchell | basic | 60 months
   Confused by new app UI — cannot find billing or data usage pages. 2 open tickets.

   CALL-006 | David Park | premium | 12 months
   Charged $899 for a device returned 3 weeks ago (has FedEx proof of delivery). 1 open ticket.

   CALL-007 | Emma Wilson | basic | 8 months
   Suspected account breach — unsolicited SMS verification codes, unfamiliar device on account.

   Classify each call by intent, priority, sentiment, and retention risk.
   Then recommend resolution strategies for high-priority and security calls.
   ```

3. Observe as etapas serem executadas em sequência — primeiro a classificação e depois a consultoria de resolução
4. Revise o relatório consolidado final

### Etapa 6: Ver o histórico de execuções e os traces

1. No fluxo **callcenter-triage-workflow-portal**, clique em **Traces**

![Workflow Traces](./images/workflow-traces.png) 

2. Clique na execução mais recente para ver a linha do tempo — cada etapa, duração e saída

---

## Critérios de sucesso

- [ ] O fluxo Python é executado de ponta a ponta: classificação → resolução → relatório do turno
- [ ] Os dois agentes estão visíveis no portal do Foundry como ativos persistentes
- [ ] O fluxo visual foi criado no portal e testado em seu playground

---

## Além do laboratório: opções de implantação em produção

Você criou e testou seus agentes localmente. Veja como levá-los à produção:

### Opção 1: Agentes hospedados (o que você já tem)

Seus agentes criados com `agents.create_version()` já são agentes hospedados prontos para produção. Eles permanecem no Foundry indefinidamente — qualquer cliente pode invocá-los pelo nome usando a Responses API. Não há infraestrutura para gerenciar; o Foundry cuida do dimensionamento, versionamento e disponibilidade.

- **Versionamento**: Cada `create_version()` produz uma versão imutável. Reverta referenciando uma versão anterior.
- **Multi-tenant**: Vários usuários/aplicativos podem chamar o mesmo agente simultaneamente.
- **Visibilidade no portal**: os agentes aparecem em Build → Agents com playground, histórico de execuções e tracing.

### Opção 2: Fluxos do Foundry (orquestração visual)

O que você criou na Parte 2 — conecte vários agentes hospedados em um DAG usando o designer do portal. O fluxo se torna um agente implantável, invocado pela mesma Responses API.

- Sequenciamento de etapas com passagem automática de saídas
- Streaming de eventos `workflow_action` mostrando o progresso
- Histórico de execuções com tempo por etapa

### Opção 3: Azure App Service / Container Apps

Envolva seu fluxo Python em um aplicativo FastAPI/Flask para obter middleware personalizado, autenticação ou lógica de negócio:

```python
# Example: FastAPI endpoint that calls your Foundry agents
@app.post("/triage-calls")
async def triage_calls():
    report = run_call_center_workflow(intent_agent, resolution_agent)
    return report
```

Implante no **App Service** (PaaS gerenciado) ou no **Container Apps** (contêineres com escalonamento automático).

### Opção 4: Azure Functions (orientado a eventos)

Dispare fluxos de agentes a partir de eventos:

- **Gatilho do Service Bus**: classificar e resolver cada chamada quando ela entrar na fila
- **Gatilho de timer**: gerar relatórios do turno a cada hora durante o horário comercial
- **Gatilho HTTP**: endpoint sob demanda para que supervisores solicitem atualizações da triagem

Pagamento por execução, com escala até zero quando ocioso.

### Opção 5: Gates de qualidade no CI/CD

Integre a avaliação ao seu pipeline de implantação:

- Execute `evaluate.py` em cada PR — bloqueie o merge se a qualidade cair abaixo do limite
- Promova versões dos agentes: `v1-dev` → `v1-staging` → `v1-prod` depois que a avaliação for aprovada
- Blue/green: implante a nova versão para 10% do tráfego, compare as métricas e depois promova-a

### Resumo

| Padrão | Melhor para |
|---------|----------|
| Agentes hospedados | Sempre ativos, invocação pelo nome e sem gerenciamento de infraestrutura |
| Fluxos do Foundry | Orquestração multiagente sem código |
| App Service / Contêineres | Autenticação personalizada, middleware e webhooks |
| Azure Functions | Orientado a eventos, pagamento por uso e processamento de filas |
| Gates de CI/CD | Garantia de qualidade automatizada antes da promoção |
