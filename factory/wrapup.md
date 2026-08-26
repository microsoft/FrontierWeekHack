# 🎉 Laboratório Concluído — Manutenção Preditiva (TireForge Industries)

Parabéns — você criou, instrumentou, avaliou e implantou do zero um sistema de IA multiagente pronto para produção. Veja o que você realizou.

---

## Recapitulação

| # | Desafio | O que você criou |
|---|-----------|----------------|
| 0 | **Configuração** | Provisionou um recurso e projeto do Microsoft Foundry, uma implantação de modelo GPT, um workspace do Log Analytics e uma instância do Application Insights usando `azd provision` |
| 1 | **Criar Agentes** | Criou um **Agente de Detecção de Anomalias** (lê telemetria de sensores ao vivo — temperatura, vibração e pressão — e identifica máquinas operando fora dos limites seguros) e um **Agente de Diagnóstico de Falhas** (determina a causa raiz e recomenda ações de manutenção por tipo de máquina) |
| 2 | **Monitorar** | Habilitou o rastreamento GenAI do OpenTelemetry — cada chamada de modelo, invocação de ferramenta e contagem de tokens é capturada como um rastreamento distribuído no Application Insights |
| 3 | **Avaliar** | Executou avaliações sistemáticas com LLM como juiz em todo o conjunto de dados de sensores, produzindo pontuações repetíveis de coerência e fluência que podem ser acompanhadas por versão entre mudanças de prompt |
| 4 | **Fluxo de Produção** | Conectou os dois agentes em um pipeline orquestrado no portal do Foundry — um endpoint estável e testável, com histórico de execuções que os operadores da fábrica podem inspecionar |

### Habilidades praticadas

- Projetar prompts de sistema de agentes com limites claros de função e restrições
- Fundamentar agentes em telemetria real de sensores por meio de chamadas de ferramentas (function calling)
- Rastreamento distribuído de sistemas de IA com OpenTelemetry
- Avaliação com LLM como juiz usando o SDK de Avaliação de IA do Azure
- Orquestração multiagente no portal do Foundry

---

## Próximos Passos

Quer levar o sistema da TireForge adiante? Veja alguns caminhos:

- **Adicione mais agentes** — um agente de Inventário de Peças que verifica se os componentes de reposição estão em estoque antes de recomendar a manutenção, ou um agente de Agendamento que encontra a primeira janela de manutenção com o menor impacto na produção
- **Conecte dados reais** — substitua o `sensor_data.json` estático por um fluxo ativo do IoT Hub ou Azure Event Hub
- **Melhore a avaliação** — adicione avaliadores específicos da tarefa (por exemplo, "o agente identificou corretamente uma falha na Prensa de Cura a partir da combinação de temperatura elevada e pressão anormal?") junto às pontuações genéricas de coerência
- **Configure CI/CD** — execute automaticamente seu conjunto de avaliação a cada mudança de prompt usando o GitHub Actions e faça o build falhar se as pontuações de qualidade caírem abaixo de um limite
- **Explore o ajuste fino** — use seus diagnósticos de falha rastreados como dados de treinamento para ajustar um modelo menor e mais barato para a etapa inicial de detecção de anomalias
- **Experimente outro cenário** — os cenários de [Claims](../claims/README.md) e [Call Center](../callcenter/README.md) abordam processamento de seguros e suporte ao cliente usando o mesmo ciclo de vida

---

## Limpar Recursos do Azure

> **Importante:** Os recursos implantados no Desafio 0 geram custos do Azure enquanto existirem. Exclua-os quando terminar.

### O que será excluído

- O grupo de recursos `foundry-hackathon-rg-<suffix>` e tudo o que estiver dentro dele:
  - Recurso e projeto do Microsoft Foundry
  - Implantação do modelo GPT
  - Workspace do Log Analytics
  - Instância do Application Insights

### Opção 1 — azd down

Na pasta **factory** (onde o ambiente `azd` foi inicializado), execute:

```bash
cd factory
azd down --purge
```

O comando usa o ambiente `azd` criado por `azd provision` para saber exatamente qual grupo de recursos deve atingir. Ele pede confirmação antes de excluir.

### Opção 2 — Portal do Azure

1. Acesse [portal.azure.com](https://portal.azure.com)
2. Pesquise por **Grupos de recursos**
3. Localize `foundry-hackathon-rg-<your-suffix>`
4. Clique em **Excluir grupo de recursos** e confirme

### Opção 3 — CLI do Azure

```bash
# Replace <suffix> with the value shown in your .env file
az group delete --name foundry-hackathon-rg-<suffix> --yes --no-wait
```
