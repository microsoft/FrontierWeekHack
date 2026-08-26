# Laboratório — Crie agentes de IA com o Microsoft Foundry
Boas-vindas ao laboratório prático do **Hackathon Microsoft Cloud & AI Frontier Week** — onde ideias se transformam em soluções reais.

Ao longo da Frontier Week, você explorou como a IA está transformando as organizações. Aqui você colocará esse conhecimento em prática.

Neste laboratório, você **criará, monitorará, avaliará e orquestrará agentes de IA** usando o SDK do Microsoft Foundry — seguindo uma experiência guiada e baseada em cenários, projetada para levar você do conceito a um sistema multiagente funcional e pronto para empresas.

Ao final, você não apenas entenderá como os agentes funcionam: terá criado um agente que pode **rastrear, avaliar e implantar**.

## Escolha seu cenário

Os três cenários usam a mesma estrutura de cinco desafios. Escolha o setor que mais combina com seus interesses.

| Cenário | Domínio | O que você criará |
|----------|--------|----------------|
| [🏭 Fábrica](./factory/README.md) | Manutenção preditiva | Agentes de detecção de anomalias e diagnóstico de falhas |
| [📋 Sinistros](./claims/README.md) | Processamento de seguros | Agentes de triagem de sinistros e decisão sobre sinistros |
| [📞 Central de atendimento](./callcenter/README.md) | Suporte ao cliente | Agentes de classificação de intenção e orientação de resolução |

## Estrutura dos desafios

Todos os cenários seguem os mesmos cinco desafios:

| # | Desafio | Duração |
|---|-----------|----------|
| 0 | **Configuração** — Implantar a infraestrutura do Azure AI Foundry | 20 min |
| 1 | **Criar agentes** — Criar dois agentes de IA com ferramentas | 30 min |
| 2 | **Monitorar** — Habilitar o rastreamento de GenAI com o Application Insights | 20 min |
| 3 | **Avaliar** — Executar avaliações sistemáticas de qualidade | 30 min |
| 4 | **Workflow** — Orquestração multiagente pelo portal do Foundry | 20 min |

## Pré-requisitos

- Assinatura do Azure com acesso de Colaborador
- Python 3.10 ou posterior
- Azure CLI (`az`) instalada e autenticada (`az login`)
- Azure Developer CLI (`azd`) instalada
- Um terminal (bash, PowerShell ou WSL)

## Primeiros passos

1. Clone este repositório e autentique-se com `az login` e `azd auth login`
2. Para provisionar o cenário padrão da central de atendimento, execute `azd up` na raiz do repositório
3. Para um cenário específico, entre em `factory/`, `claims/` ou `callcenter/` e execute `azd up`
4. Percorra os desafios 1–4 na ordem; cada um se baseia no anterior
5. Os scripts `agents.py` e `deploy.py` estão prontos para execução — leia o README em cada pasta de desafio para saber o que fazer
