# 🎉 Laboratório concluído — Triagem de Central de Atendimento (NovaTel Communications)

Parabéns — você criou, instrumentou, avaliou e implantou do zero um sistema de IA multiagente pronto para produção. Veja o que você realizou.

---

## Recapitulação

| # | Desafio | O que você criou |
|---|-----------|----------------|
| 0 | **Configuração** | Provisionou um recurso do Microsoft Foundry, projeto, implantação de modelo GPT, workspace do Log Analytics e instância do Application Insights usando `azd provision` |
| 1 | **Criar agentes** | Criou um **Agente de Classificação de Intenção** (classifica intenções de cobrança, tecnologia, cancelamento, upsell e segurança com uma ferramenta `lookup_customer`) e um **Agente Consultor de Resolução** (recomenda ofertas de retenção e ações por nível de cliente) |
| 2 | **Monitorar** | Habilitou o tracing de GenAI do OpenTelemetry — cada chamada de modelo, invocação de ferramenta e contagem de tokens é capturada como um trace distribuído no Application Insights |
| 3 | **Avaliar** | Executou avaliações sistemáticas LLM-as-judge em todo o conjunto de chamadas, produzindo pontuações repetíveis de coerência e fluência que podem ser acompanhadas entre versões dos prompts |
| 4 | **Fluxo de produção** | Conectou os dois agentes em um pipeline orquestrado no portal do Foundry — um endpoint estável e testável, com histórico de execuções que os supervisores podem inspecionar |

### Habilidades praticadas

- Projetar prompts de sistema para agentes com limites claros de função e restrições
- Fundamentar agentes em dados reais por meio de chamadas de ferramentas (function calling)
- Tracing distribuído para sistemas de IA com OpenTelemetry
- Avaliação LLM-as-judge com o Azure AI Evaluation SDK
- Orquestração multiagente no portal do Foundry

---

## Próximos passos

Quer levar o sistema da NovaTel além? Veja algumas direções:

- **Adicione mais agentes** — um agente de Análise de Sentimento que pontue o tom da chamada ou um agente de Base de Conhecimento que recupere artigos de solução de problemas antes de o consultor de resolução responder
- **Conecte dados reais** — substitua o `call_data.json` estático por uma consulta ao CRM ao vivo ou por um webhook de telefonia
- **Melhore a avaliação** — adicione avaliadores específicos da tarefa (por exemplo, "o agente ofereceu um desconto de retenção a um cliente Premium com risco de cancelamento?") além das pontuações genéricas de coerência
- **Configure o CI/CD** — execute automaticamente seu conjunto de avaliação a cada alteração de prompt usando o GitHub Actions e faça o build falhar se as pontuações de qualidade caírem abaixo de um limite
- **Explore o fine-tuning** — use suas conversas rastreadas como dados de treinamento para ajustar um modelo menor e mais barato para classificação de intenção
- **Experimente outro cenário** — os cenários de [Factory](../factory/README.md) e [Claims](../claims/README.md) abordam manutenção preditiva e processamento de seguros usando o mesmo ciclo de vida

---

## Limpar recursos do Azure

> **Importante:** os recursos implantados no Desafio 0 geram custos do Azure enquanto existirem. Exclua-os quando terminar.

### O que será excluído

- O grupo de recursos `foundry-hackathon-rg-<suffix>` e tudo dentro dele:
  - Microsoft Foundry Resource + project
  - GPT model deployment
  - Log Analytics workspace
  - Application Insights instance

### Opção 1 — azd down

Na raiz do repositório (onde o ambiente `azd` foi inicializado), execute:

```bash
azd down --purge
```

O comando usa o ambiente `azd` criado por `azd provision` para saber exatamente qual grupo de recursos deve ser excluído. Ele pede confirmação antes da exclusão.

### Opção 2 — Portal do Azure

1. Go to [portal.azure.com](https://portal.azure.com)
2. Pesquise por **Resource groups**
3. Encontre `foundry-hackathon-rg-<your-suffix>`
4. Clique em **Delete resource group** e confirme

### Opção 3 — Azure CLI

```bash
# Replace <suffix> with the value shown in your .env file
az group delete --name foundry-hackathon-rg-<suffix> --yes --no-wait
```
