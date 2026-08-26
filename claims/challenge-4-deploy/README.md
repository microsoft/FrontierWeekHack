# Desafio 4: Fluxo de produção

Tempo: ~20 minutos

Crie um fluxo de orquestração multiagente para a ClaimSight Insurance e leve-o à produção.

## Cenário

The individual agents you built in Challenge 1 are valuable — but in production, agents need to work
**together** as an automated pipeline. In this challenge you wire the two agents into a full
claims processing workflow, run it from code, then build and test it visually in the Foundry portal.

![deploy](./images/deploy.png)

## Objetivos de aprendizagem

- Deploy persistent production agents (create once, reuse forever)
- Orchestrate multiple agents step-by-step in a Python workflow
- Build the same workflow visually in the Foundry portal
- Invoke the portal workflow from Python with live streaming
- View run history and traces in the portal

## O Workflow

```
ensure_agents_deployed()
        |
        v
run_claims_triage()             <-- Claims Triage Agent assesses all 5 claims
        |
        v (for each flagged claim)
run_claims_decision()           <-- Claims Decision Agent recommends action
        |
        v
print_claims_report()           <-- Consolidated Claims Processing Report
```

---

## Parte 1 — SDK: Criar e executar o fluxo Python

### Etapa 1: Revisar a implementação

Abra [deploy.py](./deploy.py) e revise:

- **`ensure_agents_deployed()`** — lists existing agents, creates `claims-triage-agent` and `claims-decision-agent` if not present
- **`run_claims_triage()`** — calls the triage agent, handles the `assess_claim` function call loop
- **`run_claims_decision()`** — calls the decision agent for each flagged claim
- **`run_claims_workflow()`** — orchestrates all steps and returns the consolidated report

### Etapa 2: Executar o fluxo

```bash
cd claims/challenge-4-deploy
python deploy.py
```

Saída esperada:
```
=== Step 1: Ensure Agents Are Deployed ===
  Found existing: claims-triage-agent
  Found existing: claims-decision-agent

=== Step 2a: Claims Triage ===
  CLM-001 CRITICAL: fraud_risk_score 64% above max, damage_vs_estimate_match 25.7% below min
  CLM-003 WARNING: completeness 25% below min
  CLM-005 WARNING: fraud_risk_score 16% above max, damage_vs_estimate_match 8.6% below min
  ...

=== Step 2b: Claims Decisions ===
  Deciding on CLM-001...
  Deciding on CLM-003...
  Deciding on CLM-005...

CLAIMSIGHT INSURANCE — CLAIMS PROCESSING REPORT
  Claims assessed    : 5
  Claims flagged     : 3
  ...
```

---

## Parte 2 — Portal: Criar e testar o fluxo visual

### Etapa 3: Verificar se os agentes estão implantados no portal

1. Open the [Microsoft Foundry portal](https://ai.azure.com/nextgen)
2. Select your project
3. Select **Build** → **Agents** in the top bar
4. Confirm both agents appear:
   - `claims-triage-agent`
   - `claims-decision-agent`


### Etapa 4: Criar o fluxo no designer do portal

1. Select **Build** → **Agents** → **Workflows**
2. Notice that the workflow created using the SDK in Part 1 is listed. Let's create a new workflow by selecting **Create** → **Blank workflow**

![Create workflow](./images/create-workflow.png)

3. In the visual designer **Add a workflow node** dialog choose **Agent**

   ![add agent](./images/add-agent.png)

4. In the **Select an agent** picker select `claims-triage-agent`

   ![select agent](./images/select-agent.png)

5. In the **Next node** picker select **Agent** and click **Done** button
   \
    ![next node agent](./images/next-node-agent.png)

6. Select the new agent node in the canvas and in the **Select and agent** picker select `claims-decision-agent`

   ![select agent 2](./images/select-agent-2.png) 

7. In the **Next node** picker select **End** and click **Done** button

    ![end node](./images/end-node.png) 

8. Select **Save** and name it `claims-processing-workflow-portal`

![Save agent](./images/save-agent.png) 

### Etapa 5: Testar o fluxo no playground do portal

> **Why you must include the claims data in your message**
>
> The agents use an `assess_claim` tool that reads from a local Python file.
> The portal playground **cannot execute Python functions** — if you send a generic
> prompt, the agent will try to call the tool and stall waiting for a result that
> never arrives. Paste the claims data directly into your message so the agents can
> work without needing the tool.

1. Open **claims-processing-workflow-portal** → **Preview**

![Preview Agent](./images/preview-agent.png) 

2. Paste the following message (data is pre-embedded so no tool calls are needed):

   ```
   All claims data for today is below — analyse it directly, do not call assess_claim.

   CLM-001 | Maria Torres | auto_collision | filed 2026-05-01 | status: critical
     completeness: 100%  [min 80%] ✅
     damage_vs_estimate_match: 52%  [min 70%] 🔴 BELOW MIN
     fraud_risk_score: 82  [max 50] 🔴 ABOVE MAX
     policy_coverage_match: 95%  [min 85%] ✅
     documents: police_report, photos, repair_estimate, medical_report

   CLM-002 | James Chen | property_water_damage | filed 2026-04-28 | status: normal
     completeness: 100%  [min 80%] ✅
     damage_vs_estimate_match: 88%  [min 70%] ✅
     fraud_risk_score: 15  [max 50] ✅
     policy_coverage_match: 98%  [min 85%] ✅
     documents: photos, plumber_report, repair_estimate, inventory_list

   CLM-003 | Robert Kim | auto_theft | filed 2026-05-03 | status: warning
     completeness: 60%  [min 80%] ⚠️ BELOW MIN
     damage_vs_estimate_match: 0%  [min 70%] ⚠️ BELOW MIN
     fraud_risk_score: 45  [max 50] ✅
     policy_coverage_match: 90%  [min 85%] ✅
     documents: police_report, vehicle_registration

   CLM-004 | Sarah Williams | property_fire | filed 2026-04-25 | status: normal
     completeness: 100%  [min 80%] ✅
     damage_vs_estimate_match: 91%  [min 70%] ✅
     fraud_risk_score: 12  [max 50] ✅
     policy_coverage_match: 100%  [min 85%] ✅
     documents: fire_department_report, photos, repair_estimate, inventory_list

   CLM-005 | David Okafor | auto_collision | filed 2026-05-05 | status: warning
     completeness: 85%  [min 80%] ✅
     damage_vs_estimate_match: 64%  [min 70%] ⚠️ BELOW MIN
     fraud_risk_score: 58  [max 50] ⚠️ ABOVE MAX
     policy_coverage_match: 92%  [min 85%] ✅
     documents: police_report, photos, repair_estimate

   Triage each claim for completeness and fraud indicators, then make an approval or denial decision for each with clear justification.
   ```

3. Watch the steps execute in sequence — triage first, then decisions
4. Review the approval/denial decisions with justifications

### Etapa 6: Exibir o histórico de execuções e os traces

1. In the **claims-processing-workflow-portal** workflow click **Traces**

![Workflow Traces](./images/workflow-traces.png) 

2. Click the latest run to see the execution timeline — each step, duration, and output

---

## Critérios de sucesso

- [ ] Python workflow runs end-to-end: triage → decisions → claims report
- [ ] Both agents visible in the Foundry portal as persistent assets
- [ ] Visual workflow created in the portal and tested in its playground

---

## Além do laboratório: opções de implantação em produção

You've built and tested your agents locally. Here's how to take them to production:

### Opção 1: Agentes hospedados (o que você já tem)

Your agents created with `agents.create_version()` are already production-ready hosted agents. They live in Foundry indefinitely — any client can invoke them by name via the Responses API. No infrastructure to manage; Foundry handles scaling, versioning, and availability.

- **Versioning**: Each `create_version()` produces an immutable version. Roll back by referencing an older version.
- **Multi-tenant**: Multiple users/apps can call the same agent simultaneously.
- **Portal visibility**: Agents appear under Build → Agents with playground, run history, and tracing.

### Opção 2: Fluxos do Foundry (orquestração visual)

What you built in Part 2 — wire multiple hosted agents into a DAG using the portal designer. The workflow becomes a deployable agent invoked via the same Responses API.

- Step sequencing with automatic output passing
- Streaming `workflow_action` events showing progress
- Run history with per-step timing

### Opção 3: Azure App Service / Container Apps

Wrap your Python workflow in a FastAPI/Flask app for custom middleware, auth, or business logic:

```python
# Example: FastAPI endpoint that calls your Foundry agents
@app.post("/process-claims")
async def process_claims():
    report = run_claims_workflow(triage_agent, decision_agent)
    return report
```

Implante no **App Service** (PaaS gerenciado) ou no **Container Apps** (contêineres com dimensionamento automático).

### Opção 4: Azure Functions (orientado a eventos)

Trigger agent workflows from events:

- **Blob trigger**: Process each new claim document as it's uploaded
- **Service Bus trigger**: Handle claims from a message queue
- **HTTP trigger**: On-demand endpoint for claims adjusters

Pague por execução; o serviço reduz a escala a zero quando está ocioso.

### Opção 5: Gates de qualidade de CI/CD

Integrate evaluation into your deployment pipeline:

- Run `evaluate.py` on every PR — block merge if quality drops below threshold
- Promote agent versions: `v1-dev` → `v1-staging` → `v1-prod` after evaluation passes
- Blue/green: Deploy new version to 10% traffic, compare metrics, then promote

### Resumo

| Pattern | Best For |
|---------|----------|
| Hosted Agents | Always-on, invoke by name, no infra management |
| Foundry Workflows | Multi-agent orchestration without code |
| App Service / Containers | Custom auth, middleware, webhooks |
| Azure Functions | Event-driven, pay-per-use, document processing |
| CI/CD Gates | Automated quality assurance before promotion |

