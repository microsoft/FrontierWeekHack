# 📋 Cenário: Agentes de IA para Processamento de Sinistros

## Cenário

![scenario](./images/scenario.png)

Você trabalha na **ClaimSight Insurance**, uma seguradora de propriedades e automóveis que processa centenas de sinistros diariamente. Cada sinistro tem métricas associadas: completude dos documentos, consistência entre dano e estimativa, pontuação de risco de fraude e correspondência com a cobertura da apólice. Ultimamente, sinistros fraudulentos e atrasos no processamento têm custado milhões à empresa.

Sua missão: **criar agentes de IA usando o Microsoft Foundry** que façam a triagem dos sinistros recebidos e tomem decisões inteligentes de processamento, sinalizando sinistros suspeitos para investigação e acelerando os legítimos.

![orchestration](./images/agentic-orchestration.png)

Você criará dois agentes:

1. **Claims Triage Agent** — Avalia as métricas dos sinistros em relação aos limites aceitáveis e sinaliza anomalias
2. **Claims Decision Agent** — Recebe sinistros sinalizados e recomenda ações (aprovar, investigar, solicitar documentos, negar)

## Os sinistros

| Claim | Type | Claimant | Status |
|-------|------|----------|--------|
| CLM-001 | Auto Collision | Maria Torres | 🔴 Critical |
| CLM-002 | Property Water Damage | James Chen | ✅ Normal |
| CLM-003 | Auto Theft | Robert Kim | ⚠️ Warning |
| CLM-004 | Property Fire | Sarah Williams | ✅ Normal |
| CLM-005 | Auto Collision | David Okafor | ⚠️ Warning |

## Pré-requisitos

- **Assinatura do Azure** com acesso de Colaborador
- **Python 3.10+** instalado localmente
- **Azure CLI** (`az`) installed and logged in (`az login`)
- Um terminal (bash, PowerShell ou WSL)
- Cerca de 20 minutos para provisionar a infraestrutura (execute `azd provision` primeiro na pasta `claims`!)

## Estrutura

Todos os desafios usam o SDK do Python. O Desafio 4 também orienta você pelo portal do Foundry para criar e testar visualmente o Workflow multiagente.

## Desafios

| # | Desafio | Duração | O que você fará |
|---|-----------|----------|----------------|
| 0 | [Configuração](./challenge-0-setup/README.md) | 20 min | Provisionar recursos, verificar autenticação |
| 1 | [Criar agentes](./challenge-1-build/README.md) | 30 min | Criar agentes de triagem e decisão de sinistros |
| 2 | [Monitorar](./challenge-2-monitor/README.md) | 20 min | Habilitar rastreamento, explorar o Application Insights |
| 3 | [Avaliar](./challenge-3-evaluate/README.md) | 30 min | Executar avaliações, interpretar métricas de qualidade |
| 4 | [Workflow](./challenge-4-deploy/README.md) | 20 min | Criar um fluxo multiagente: triagem → decisão → relatório de sinistros |

## Por que os desafios estão nesta ordem

**Crie primeiro.** Sem instruções precisas e dados reais de sinistros, os agentes não conseguem tomar decisões úteis. Sem `assess_claim`, o Claims Triage Agent apenas identifica padrões nas descrições dos sinistros: não há como verificar pontuações reais de fraude, índices de completude dos documentos ou variações entre danos e estimativas. Prompts de sistema ambíguos geram decisões inconsistentes: o mesmo perfil de risco pode ser aprovado em um dia e sinalizado no outro.

**Depois monitore.** Toda decisão tomada pelo Claims Decision Agent precisa ser rastreável. Para sinistros de seguros, isso não é opcional: é uma exigência comercial e regulatória. Os traces do Application Insights fornecem um registro completo: quais dados o agente recebeu, quais ferramentas chamou e exatamente o que recomendou. Quando um auditor perguntar por que CLM-003 foi enviado para investigação, esse trace será sua resposta.

**Depois avalie.** Dois sinistros com a mesma pontuação de fraude e a mesma completude documental devem receber a mesma recomendação. A avaliação oferece uma forma repetível de verificar isso e detecta quando uma atualização do prompt quebra essa consistência, antes que afete sinistros reais.

**Depois implante.** O fluxo do portal conecta a triagem à decisão, processa um lote completo de sinistros e produz um relatório que as equipes de conformidade podem aprovar. Essa é a diferença entre uma demonstração e algo que você colocaria diante de um regulador de sinistros.


## Arquitetura

![architecture](./images/architecture.png)


## Próximos passos

Ao concluir estes desafios, você terá um sistema multiagente funcional, com observabilidade e avaliação configuradas. Veja algumas direções para avançar:

**Implantar como endpoint de agente hospedado**
O Microsoft Foundry pode hospedar seus agentes como endpoints de API persistentes e escaláveis, sem infraestrutura para gerenciar. Depois de hospedado, seu sistema de entrada de sinistros poderá enviar novos sinistros diretamente ao Triage Agent e receber uma decisão estruturada (aprovar / investigar / solicitar documentos / negar), sem uma etapa manual de triagem.

**Adicionar mais ferramentas aos seus agentes**
A função `assess_claim` neste laboratório usa dados simulados locais. Em produção, você a substituiria por ferramentas que chamam sistemas reais:
- Uma ferramenta `fetch_policy` que consulta seu sistema de gerenciamento de apólices em busca dos termos de cobertura, exclusões e limites exatos aplicáveis a um sinistro específico
- Uma ferramenta `check_fraud_database` que consulta um serviço de inteligência contra fraudes em busca de padrões conhecidos correspondentes ao histórico do segurado
- Uma ferramenta `request_documents` que aciona automaticamente um fluxo de solicitação de documentos no seu DMS quando o agente fizer essa recomendação

**Criar uma base de conhecimento**
Carregue os documentos de apólices da ClaimSight, as diretrizes de conformidade regulatória e a biblioteca de padrões de fraude em uma base de conhecimento do Microsoft Foundry. Anexe-a ao Claims Decision Agent como uma ferramenta de File Search para que suas recomendações citem a linguagem real das apólices, produzindo decisões auditáveis e defensáveis perante os órgãos reguladores.

**Integrar avaliações ao CI/CD**
Execute seu conjunto de dados de avaliação automaticamente em cada pull request ou implantação. Se a pontuação de coerência ou relevância cair abaixo de um limite (por exemplo, 3,5 de 5), bloqueie a versão. Em um setor regulado, isso não é apenas uma boa prática: é o tipo de gate de qualidade que as equipes de conformidade e auditoria esperam ver documentado.

**Explorar padrões avançados de agentes**
- **Paralelize** a triagem de todos os sinistros recebidos simultaneamente, em vez de sequencialmente
- **Adicionar limites de confiança**: se a avaliação de risco de fraude do Triage Agent ficar em uma faixa ambígua, encaminhe-a a um regulador sênior em vez de passá-la automaticamente ao Decision Agent
- **Humano no circuito**: para sinistros de alto valor (acima de um limite configurável), sempre exija a aprovação de um regulador humano antes de executar a recomendação do Decision Agent

**Ajustar para seu domínio**
Use os resultados das avaliações para identificar erros sistemáticos, como tipos de sinistro que o agente julga incorretamente com frequência ou indicadores de fraude aos quais atribui pouco peso. Use esses casos para refinar os prompts de sistema, adicionar exemplos few-shot direcionados ou ajustar o modelo subjacente com base nas decisões históricas de sinistros da ClaimSight.
