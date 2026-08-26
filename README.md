<img width="990" height="150" alt="Microsoft Agent-a-thon_banner_WEB_990x150" src="https://github.com/user-attachments/assets/5f550061-077d-421c-bba2-4a5820e72fad" />

# Frontier Week Hack
## Microsoft Foundry: Crie, escale, observa e proteja seus agentes de IA 
 
Boas-vindas à experiência de laboratório prático onde ideias se transformam em soluções reais e prontas para empresas. Esta é a mais avançada das três trilhas de criação de agentes. Enquanto a trilha Explorer cria seu primeiro agente sem código e a trilha Maker automatiza tarefas com ferramentas low-code, esta trilha é voltada a desenvolvedores, engenheiros e arquitetos que desejam controle total sobre modelos, orquestração e operações.

Neste laboratório, você criará, monitorará, avaliará e orquestrará agentes de IA usando o SDK do Microsoft Foundry. Você seguirá uma experiência guiada e baseada em cenários, projetada para ajudar a transformar um conceito em um sistema multiagente funcional e pronto para empresas.
 
Ao final, você não apenas entenderá como os agentes funcionam: terá criado um agente que pode rastrear, avaliar e implantar.

## O que você aprenderá

Este laboratório orienta você por todo o ciclo de vida da criação de agentes de IA prontos para produção com o [Microsoft Foundry](https://learn.microsoft.com/azure/ai-foundry/):

- **Design de agentes** — Criar agentes especializados com prompts de sistema, ferramentas e dados específicos do domínio
- **Observabilidade** — Instrumentar agentes com rastreamento de GenAI baseado em OpenTelemetry por meio do Application Insights
- **Avaliação de qualidade** — Executar avaliações com LLM como juiz para medir sistematicamente a qualidade das saídas dos agentes
- **Orquestração multiagente** — Conectar agentes a fluxos de trabalho automatizados usando o SDK do Python e o portal do Foundry

Este é um **hackathon code-first**: você escreverá e executará Python ao longo de todo o percurso. No entanto, vários desafios também exigem interação com o **portal do Microsoft Foundry** para implantar modelos, explorar rastreamentos, revisar avaliações e criar fluxos de trabalho visualmente. Espere alternar regularmente entre seu IDE e o portal.


## Escolha seu cenário

Todas as trilhas ensinam os mesmos conceitos do Foundry — escolha aquela com a qual você mais se identifica:

| Cenário | Descrição | Comece aqui |
|----------|-------------|------------|
| 🏭 **Fábrica** | Detectar anomalias em máquinas e diagnosticar falhas na TireForge Industries | [Laboratório de fábrica](./factory/README.md) |
| 📋 **Sinistros** | Fazer a triagem de sinistros recebidos e recomendar ações na ClaimSight Insurance | [Laboratório de sinistros](./claims/README.md) |
| 📞 **Central de atendimento** | Classificar intenções de chamadas e orientar resoluções na NovaTel Communications | [Laboratório de central de atendimento](./callcenter/README.md) |

Todos os cenários seguem a mesma estrutura de cinco desafios:

| # | Desafio | Duração | O que você aprenderá |
|---|-----------|----------|-------------------|
| 0 | **Configuração** | 20 min | Provisionar o Microsoft Foundry, implantar um modelo e verificar a autenticação |
| 1 | **Criar agentes** | 35 min | Criar dois agentes com ferramentas e prompts de sistema |
| 2 | **Monitorar** | 20 min | Habilitar o rastreamento de GenAI com o Application Insights |
| 3 | **Avaliar** | 25 min | Executar avaliações com LLM como juiz em conjuntos de dados de teste |
| 4 | **Workflow** | 20 min | Orquestrar agentes em um pipeline de várias etapas |

## Pré-requisitos

- **Assinatura do Azure** com acesso de **Colaborador** e **Usuário do Foundry**
- Uma **conta do GitHub**
- **Python 3.10 ou posterior** instalado localmente (pré-instalado ao usar Codespaces)
- **Azure CLI** (`az`) instalada (pré-instalada ao usar Codespaces)
- **Azure Developer CLI** (`azd`) instalada (pré-instalada ao usar Codespaces)

## Implantar pelo diretório raiz

O projeto `azd` na raiz provisiona o cenário da central de atendimento. Depois de autenticar no Azure, execute:

```bash
az login
azd auth login
azd up
```

O comando cria os recursos no grupo de recursos do ambiente `azd` e gera o arquivo `.env` na raiz do repositório. Para alterar o ambiente ou a assinatura, use `azd env set` antes de executar `azd up`.

## Pronto para ampliar seus conhecimentos?

### 1. Aprofunde-se com a documentação

- [O que é o Microsoft Foundry?](https://learn.microsoft.com/azure/foundry/what-is-foundry)
- [Visão geral do Foundry Agent Service](https://learn.microsoft.com/azure/foundry/agents/overview)
- [Rastreie seus agentes com o Microsoft Foundry](https://learn.microsoft.com/azure/foundry/observability/how-to/trace-agent-setup)
- [Avalie fluxos de trabalho agentivos](https://learn.microsoft.com/azure/foundry/observability/how-to/evaluate-agent)
- [Referência do SDK azure-ai-projects](https://learn.microsoft.com/python/api/azure-ai-projects/)

### 2. Continue aprendendo no Microsoft Learn

- [Desenvolva um agente de IA com o Foundry Agent Service](https://learn.microsoft.com/training/modules/develop-ai-agent-azure/) — módulo de 55 min
- [Crie fluxos de trabalho orientados por agentes usando o Microsoft Foundry](https://learn.microsoft.com/training/modules/build-agent-workflows-microsoft-foundry/) — módulo de 1 hora
- [Analise e depure seu aplicativo de IA generativa com rastreamento](https://learn.microsoft.com/training/modules/tracing-generative-ai-app/) — módulo de 1 hora
- [Avalie o desempenho de IA generativa no portal do Microsoft Foundry](https://learn.microsoft.com/training/modules/evaluate-models-azure-ai-studio/) — módulo de 38 min
- [Monitore seu aplicativo de IA generativa](https://learn.microsoft.com/training/modules/monitor-generative-ai-app/) — módulo de 1 hora
- [Desenvolva aplicativos de IA generativa no Azure](https://learn.microsoft.com/training/paths/develop-generative-ai-apps/) — trilha de aprendizagem
- [Monitore cargas de trabalho de IA no Azure](https://learn.microsoft.com/training/paths/monitor-ai-workloads-on-azure/) — trilha de aprendizagem
- [Operacionalize a IA com responsabilidade usando o Azure AI Foundry](https://learn.microsoft.com/training/paths/operationalize-ai-responsibly/) — trilha de aprendizagem
