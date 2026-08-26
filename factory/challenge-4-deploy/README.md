# Desafio 4: Fluxo de Produção

Tempo: ~20 minutos

Crie um fluxo de orquestração multiagente para a TireForge Industries e leve-o à produção.

## Cenário

Os agentes individuais que você criou no Desafio 1 são valiosos, mas em produção os agentes precisam trabalhar
**juntos** como um pipeline automatizado. Neste desafio, você conectará os dois agentes em um
fluxo de saúde da fábrica, executá-lo pelo código e depois criá-lo e testá-lo visualmente no portal do Foundry.

![deploy](./images/deploy.png)

## Objetivos de Aprendizagem

- Implantar agentes de produção persistentes (criar uma vez e reutilizar sempre)
- Orquestrar vários agentes passo a passo em um fluxo Python
- Criar o mesmo fluxo visualmente no portal do Foundry
- Invocar o fluxo do portal pelo Python com streaming ao vivo
- Ver o histórico de execuções e rastreamentos no portal

## O Fluxo

```
ensure_agents_deployed()
        |
        v
run_anomaly_scan()          <-- Anomaly Detection Agent checks all 5 machines
        |
        v (for each machine with anomalies)
run_fault_diagnosis()       <-- Fault Diagnosis Agent diagnoses root cause
        |
        v
print_factory_report()      <-- Consolidated Health Report
```

---

## Parte 1 — SDK: Criar e Executar o Fluxo Python

### Etapa 1: Examinar a implementação

Abra [deploy.py](./deploy.py) e examine:

- **`ensure_agents_deployed()`** — lista os agentes existentes e cria `anomaly-detection-agent` e `fault-diagnosis-agent` se não estiverem presentes
- **`run_anomaly_scan()`** — chama o agente de anomalias e trata o loop de chamada da função `check_thresholds`
- **`run_fault_diagnosis()`** — chama o agente de diagnóstico para cada máquina afetada
- **`run_factory_health_workflow()`** — orquestra todas as etapas e retorna o relatório consolidado

### Etapa 2: Executar o fluxo

```bash
cd factory/challenge-4-deploy
python deploy.py
```

Saída esperada:
```
=== Step 1: Ensure Agents Are Deployed ===
  Found existing: anomaly-detection-agent
  Found existing: fault-diagnosis-agent

=== Step 2a: Anomaly Scan ===
  CP-003 CRITICAL: vibration 143% above max, pressure 13.8% above max, temperature 10.3% above max
  MX-001 WARNING: vibration 6.7% above max, temperature 2.6% above max
  IS-005 WARNING: vibration 30% above max
  ...

=== Step 2b: Fault Diagnosis ===
  Diagnosing CP-003...
  Diagnosing MX-001...
  Diagnosing IS-005...

TIREFORGE FACTORY HEALTH REPORT
  Machines checked   : 5
  Machines affected  : 2
  ...
```

---

## Parte 2 — Portal: Criar e Testar o Fluxo Visual

### Etapa 3: Verificar se os agentes estão implantados no portal

1. Abra o [portal do Microsoft Foundry](https://ai.azure.com/nextgen)
2. Selecione seu projeto
3. Selecione **Criar** → **Agentes** na barra superior
4. Confirme que os dois agentes aparecem:
   - `anomaly-detection-agent`
   - `fault-diagnosis-agent`


### Etapa 4: Criar o fluxo no designer do portal

1. Selecione **Criar** → **Agentes** → **Fluxos de trabalho**
2. Observe que o fluxo criado usando o SDK na Parte 1 está listado. Crie um novo fluxo selecionando **Criar** → **Fluxo em branco**

![Create workflow](./images/create-workflow.png)

3. No designer visual, na caixa de diálogo **Adicionar um nó de fluxo**, escolha **Agente**

   ![add agent](./images/add-agent.png)

4. No seletor **Selecionar um agente**, selecione `anomaly-detection-agent`

   ![select agent](./images/select-agent.png)

5. No seletor **Próximo nó**, selecione **Agente** e clique no botão **Concluído**
   \
    ![next node agent](./images/next-node-agent.png)

6. Selecione o novo nó de agente na tela e, no seletor **Selecionar um agente**, selecione `fault-diagnosis-agent`

   ![select agent 2](./images/select-agent-2.png) 

7. No seletor **Próximo nó**, selecione **Fim** e clique no botão **Concluído**

    ![end node](./images/end-node.png) 

8. Selecione **Salvar** e dê a ele o nome `factory-health-workflow-portal`

![Save agent](./images/save-agent.png) 

### Etapa 5: Testar o fluxo no playground do portal

> **Por que você deve incluir os dados dos sensores na mensagem**
>
> Os agentes usam uma ferramenta `check_thresholds` que lê um arquivo Python local.
> O playground do portal **não consegue executar funções Python**; se você enviar um prompt
> genérico, o agente tentará chamar a ferramenta e ficará aguardando um resultado que nunca
> chegará. Cole as leituras dos sensores diretamente na mensagem para que os agentes
> possam trabalhar sem precisar da ferramenta.

1. Na tela do fluxo **factory-health-workflow-portal**, selecione **Visualizar**

![Preview Agent](./images/preview-agent.png) 

2. Cole a mensagem a seguir (os dados já estão incorporados, portanto não são necessárias chamadas de ferramentas):

   ```
   All sensor readings for today are below — analyse them directly, do not call check_thresholds.

   MX-001 (mixer) — status: warning
     temperature: 92.3°C  [normal 60–90]  ⚠️ ABOVE MAX
     pressure:     3.1 bar [normal 2.0–4.0]
     vibration:    4.8 mm/s [normal 0–4.5]  ⚠️ ABOVE MAX
     rpm:          58 rpm  [normal 40–65]

   EX-002 (extruder) — status: normal
     temperature: 115.0°C [normal 100–130]
     pressure:    12.5 bar [normal 10.0–15.0]
     vibration:    2.1 mm/s [normal 0–3.5]
     rpm:          30 rpm  [normal 20–40]

   CP-003 (curing_press) — status: critical
     temperature: 198.5°C [normal 140–180]  🔴 ABOVE MAX
     pressure:    18.2 bar [normal 12.0–16.0]  🔴 ABOVE MAX
     vibration:    7.3 mm/s [normal 0–3.0]  🔴 ABOVE MAX
     rpm:           0 rpm  [normal 0]

   CU-004 (cooling_unit) — status: normal
     temperature: 35.2°C  [normal 20–45]
     pressure:     1.0 bar [normal 0.8–1.5]
     vibration:    0.8 mm/s [normal 0–2.0]
     rpm:         120 rpm  [normal 80–150]

   IS-005 (inspection_station) — status: warning
     temperature: 28.0°C  [normal 18–30]
     pressure:     1.0 bar [normal 0.8–1.2]
     vibration:    5.2 mm/s [normal 0–4.0]  ⚠️ ABOVE MAX
     rpm:        1800 rpm  [normal 1500–2200]

   Detect all anomalies, then diagnose root causes and recommend remediation for affected machines.
   ```

3. Observe as etapas serem executadas em sequência: primeiro a varredura de anomalias e depois o diagnóstico de falhas
4. Examine o relatório consolidado final


### Etapa 6: Ver o histórico de execuções e rastreamentos

1. No fluxo **factory-health-workflow-portal**, clique em **Rastreamentos**

![Workflow Traces](./images/workflow-traces.png) 

2. Clique na execução mais recente para ver a linha do tempo, cada etapa, duração e saída


---

## Critérios de Sucesso

- [ ] O fluxo Python é executado de ponta a ponta: varredura de anomalias → diagnóstico → relatório da saúde da fábrica
- [ ] Os dois agentes estão visíveis no portal do Foundry como ativos persistentes
- [ ] O fluxo visual foi criado no portal e testado em seu playground

---

## Além do Laboratório: Opções de Implantação em Produção

Você criou e testou seus agentes localmente. Veja como levá-los à produção:

### Opção 1: Agentes Hospedados (o que você já tem)

Seus agentes criados com `agents.create_version()` já são agentes hospedados prontos para produção. Eles permanecem no Foundry indefinidamente; qualquer cliente pode invocá-los pelo nome usando a Responses API. Não há infraestrutura para gerenciar: o Foundry cuida do dimensionamento, versionamento e disponibilidade.

- **Versionamento**: Cada `create_version()` produz uma versão imutável. Reverta referenciando uma versão anterior.
- **Multi-inquilino**: Vários usuários/aplicativos podem chamar o mesmo agente simultaneamente.
- **Visibilidade no portal**: Os agentes aparecem em Criar → Agentes com playground, histórico de execuções e rastreamento.

### Opção 2: Fluxos do Foundry (Orquestração Visual)

O que você criou na Parte 2: conecte vários agentes hospedados em um DAG usando o designer do portal. O fluxo se torna um agente implantável, invocado pela mesma Responses API.

- Sequenciamento de etapas com passagem automática de saída
- Streaming de eventos `workflow_action` mostrando o progresso
- Histórico de execuções com tempo por etapa

### Opção 3: Azure App Service / Container Apps

Envolva seu fluxo Python em um aplicativo FastAPI/Flask para obter middleware personalizado, autenticação ou lógica de negócio:

```python
# Example: FastAPI endpoint that calls your Foundry agents
@app.post("/factory-health-check")
async def health_check():
    report = run_factory_health_workflow(anomaly_agent, diagnosis_agent)
    return report
```

Implante no **App Service** (PaaS gerenciado) ou no **Container Apps** (contêineres com dimensionamento automático).

### Opção 4: Azure Functions (Orientado a Eventos)

Acione fluxos de agentes a partir de eventos:

- **Gatilho de timer**: Execute a verificação da saúde da fábrica a cada hora
- **Gatilho do Service Bus**: Processe cada alerta de anomalia assim que chegar do IoT Hub
- **Gatilho HTTP**: Endpoint sob demanda para as equipes de manutenção

Pagamento por execução, com redução para zero quando ocioso.

### Opção 5: Gates de Qualidade de CI/CD

Integre a avaliação ao seu pipeline de implantação:

- Execute `evaluate.py` em cada PR; bloqueie o merge se a qualidade ficar abaixo do limite
- Promova versões dos agentes: `v1-dev` → `v1-staging` → `v1-prod` depois que a avaliação for aprovada
- Blue/green: implante a nova versão para 10% do tráfego, compare as métricas e depois promova-a

### Resumo

| Padrão | Melhor para |
|---------|----------|
| Agentes hospedados | Sempre ativos, invocação por nome e sem gerenciamento de infraestrutura |
| Fluxos do Foundry | Orquestração multiagente sem código |
| App Service / Contêineres | Autenticação personalizada, middleware e webhooks |
| Azure Functions | Orientado a eventos, pagamento por uso e integração com IoT |
| Gates de CI/CD | Garantia de qualidade automatizada antes da promoção |
