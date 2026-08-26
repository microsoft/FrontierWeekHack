# 🏭 Cenário: Manutenção Preditiva — TireForge Industries

## Contexto

![scenario](./images/scenario.png)

**TireForge Industries** opera uma fábrica de pneus com 5 máquinas críticas:

- **MX-001** (Misturador) — Mistura compostos de borracha bruta
- **EX-002** (Extrusora) — Molda a borracha nos perfis da banda de rodagem
- **CP-003** (Prensa de Cura) — Vulcaniza pneus sob calor e pressão
- **CU-004** (Unidade de Resfriamento) — Resfria gradualmente os pneus curados
- **IS-005** (Estação de Inspeção) — Garantia de qualidade por análise de vibração

Cada máquina emite dados de sensores em tempo real: temperatura, pressão, vibração e RPM.



## Sua Missão

![agentic-orchestration](./images/agentic-orchestration.png)

Crie um sistema de agentes de IA que:

1. **Detecte anomalias** — Compare as leituras dos sensores com os limites
2. **Diagnostique falhas** — Raciocine sobre as causas raiz a partir dos padrões de anomalia
3. **Relate a saúde** — Produza um relatório consolidado da saúde da fábrica

## Desafios

| # | Desafio | O que você fará | Tempo |
|---|-----------|---------------|------|
| 0 | [Configuração](./challenge-0-setup/README.md) | Implantar a infraestrutura do Microsoft Foundry | 20 min |
| 1 | [Criar Agentes](./challenge-1-build/README.md) | Criar agentes de Detecção de Anomalias + Diagnóstico de Falhas | 30 min |
| 2 | [Monitorar](./challenge-2-monitor/README.md) | Habilitar rastreamento de GenAI com o Application Insights | 20 min |
| 3 | [Avaliar](./challenge-3-evaluate/README.md) | Executar avaliações sistemáticas de qualidade | 30 min |
| 4 | [Fluxo de Produção](./challenge-4-deploy/README.md) | Orquestração multiagente + fluxo no portal | 20 min |

## Por que os Desafios Estão Nesta Ordem

**Crie primeiro.** Um agente com um prompt de sistema vago ou sem ferramentas produzirá diagnósticos plausíveis, mas inventados. Em uma fábrica de pneus, isso não é um problema acadêmico — significa equipes de manutenção perseguindo falhas inexistentes ou não detectando falhas reais até que uma máquina pare no meio do turno. A ferramenta `check_thresholds` fundamenta o Agente de Anomalias nas especificações reais das máquinas, e não no conhecimento geral do LLM sobre como é a vibração "normal" de uma extrusora.

**Depois monitore.** Quando o Agente de Diagnóstico de Falhas recomendar tirar a CP-003 de operação, ele realmente examinou as leituras dos sensores que você forneceu? `check_thresholds` foi chamado ou o agente raciocinou apenas com base no contexto? Os rastreamentos do Application Insights respondem a isso. Sem eles, o único sinal que você tem é uma falha de máquina que deveria ter sido detectada antes.

**Depois avalie.** O rastreamento informa que o agente foi executado. A avaliação informa que ele foi executado corretamente. O conjunto de testes selecionado fornece uma pontuação repetível para comparar antes e depois de qualquer mudança de prompt ou troca de modelo, permitindo detectar regressões antes que cheguem ao chão de fábrica.

**Depois implante.** O fluxo do portal transforma o que você criou em scripts em algo que a equipe de manutenção pode realmente utilizar: um endpoint estável, um relatório da saúde da fábrica por turno e um histórico de rastreamento para cada diagnóstico. Essa é a diferença entre uma demonstração e uma ferramenta em que alguém confiará antes de agendar uma janela de manutenção não planejada.


## Architecture

![architecture](./images/architecture.png)


## Próximos Passos

Ao concluir estes desafios, você terá um sistema multiagente funcional, com observabilidade e avaliação configuradas. Veja alguns caminhos para levá-lo adiante:

**Implante como endpoint de agente hospedado**
O Microsoft Foundry pode hospedar seus agentes como endpoints de API persistentes e escaláveis, sem infraestrutura para gerenciar. Depois de hospedados, qualquer sistema (um painel SCADA, um aplicativo móvel de manutenção ou um bot do Slack) pode enviar um ID de máquina e receber um diagnóstico em tempo real, em vez de executar manualmente um script Python.

**Adicione mais ferramentas aos seus agentes**
A função `check_thresholds` deste laboratório usa dados simulados locais. Em produção, você a substituiria por ferramentas que chamam sistemas reais:
- Uma ferramenta `fetch_maintenance_history` que consulta seu CMMS (por exemplo, SAP PM ou IBM Maximo) em busca de falhas anteriores nessa máquina
- Uma ferramenta `lookup_spare_parts` que verifica a disponibilidade no estoque antes de recomendar uma substituição
- Uma ferramenta `create_work_order` que abre automaticamente um tíquete no ServiceNow quando o Agente de Diagnóstico de Falhas sinaliza um problema crítico

**Crie uma base de conhecimento**
Carregue os manuais das máquinas da TireForge, as fichas de especificações dos fornecedores e os relatórios históricos de incidentes em uma base de conhecimento do Microsoft Foundry. Anexe-a ao Agente de Diagnóstico de Falhas como uma ferramenta de Pesquisa de Arquivos para que suas recomendações se baseiem em procedimentos documentados, e não no conhecimento geral do LLM.

**Integre avaliações ao CI/CD**
Execute automaticamente seu conjunto de avaliação em cada pull request ou implantação. Se a pontuação de coerência ou relevância cair abaixo de um limite (por exemplo, 3,5 de 5), bloqueie a versão. Isso impede que uma edição do prompt de sistema ou uma atualização do modelo degrade silenciosamente a qualidade do diagnóstico em produção.

**Explore padrões avançados de agentes**
- **Paralelize** as verificações de anomalias nas 5 máquinas simultaneamente, em vez de sequencialmente
- **Adicione limites de confiança** — se o Agente de Detecção de Anomalias estiver incerto, encaminhe o caso a um operador humano em vez de passá-lo automaticamente ao Diagnóstico de Falhas
- **Humano no circuito** — para falhas críticas, exija que um engenheiro de manutenção aprove a ação recomendada antes que ela acione uma ordem de serviço

**Faça o ajuste fino para seu domínio**
Use os resultados da avaliação para identificar erros sistemáticos — máquinas que o agente classifica incorretamente de forma recorrente ou tipos de falha que ele trata mal. Use esses casos para refinar os prompts de sistema, adicionar exemplos few-shot direcionados ou fazer o ajuste fino do modelo subjacente com padrões de sensores específicos da TireForge.
