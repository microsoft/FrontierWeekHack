# 🎉 Laboratório concluído — Processamento de Sinistros (ClaimSight Insurance)

Parabéns: você criou, instrumentou, avaliou e implantou do zero um sistema de IA multiagente pronto para produção. Veja o que você realizou.

---

## Recapitulação

| # | Desafio | O que você criou |
|---|-----------|----------------|
| 0 | **Configuração** | Provisionou um recurso do Microsoft Foundry, um projeto, uma implantação de modelo GPT, um workspace do Log Analytics e uma instância do Application Insights usando `azd provision` |
| 1 | **Criar agentes** | Criou um **Claims Triage Agent** (avalia completude documental, risco de fraude e cobertura da apólice) e um **Claims Decision Agent** (recomenda aprovar, acelerar, sinalizar para investigação ou negar, com justificativa) |
| 2 | **Monitorar** | Habilitou o rastreamento GenAI do OpenTelemetry: cada chamada de modelo, invocação de ferramenta e contagem de tokens é capturada como um trace distribuído no Application Insights |
| 3 | **Avaliar** | Executou avaliações sistemáticas com LLM como juiz em todo o conjunto de dados de sinistros, produzindo pontuações repetíveis de coerência e fluência que podem ser acompanhadas por versão entre alterações de prompt |
| 4 | **Fluxo de produção** | Conectou os dois agentes em um pipeline orquestrado no portal do Foundry, um endpoint estável e testável com histórico de execuções que os reguladores podem inspecionar e auditar |

### Habilidades praticadas

- Projetar prompts de sistema para agentes com limites claros de função e restrições
- Fundamentar agentes em dados reais de sinistros por meio de chamadas de ferramentas (function calling)
- Rastreamento distribuído de sistemas de IA com OpenTelemetry
- Avaliação com LLM como juiz usando o Azure AI Evaluation SDK
- Orquestração multiagente no portal do Foundry

---

## Próximos passos

Quer levar o sistema ClaimSight mais longe? Veja algumas direções:

- **Adicionar mais agentes**: um agente de Extração de Documentos que analise PDFs carregados ou um agente de Padrões de Fraude que cruze o histórico de sinistros dos segurados
- **Conectar dados reais**: substitua o `claims_data.json` estático por um sistema ativo de gerenciamento de apólices ou uma consulta ao armazenamento de documentos
- **Melhorar a avaliação**: adicione avaliadores específicos da tarefa (por exemplo, "o agente sinalizou corretamente um sinistro com pontuação de fraude acima de 0,7?") junto às pontuações genéricas de coerência
- **Configurar CI/CD**: execute seu conjunto de dados de avaliação automaticamente a cada alteração de prompt usando o GitHub Actions e faça o build falhar se as pontuações de qualidade caírem abaixo de um limite
- **Explorar ajuste fino**: use suas decisões de sinistros rastreadas como dados de treinamento para ajustar um modelo menor para a etapa inicial de triagem
- **Experimentar outro cenário**: os cenários de [Fábrica](../factory/README.md) e [Central de atendimento](../callcenter/README.md) abordam manutenção preditiva e suporte ao cliente usando o mesmo ciclo de vida

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

Na pasta **claims** (onde o ambiente `azd` foi inicializado), execute:

```bash
cd claims
azd down --purge
```

O comando usa o ambiente `azd` criado por `azd provision` para saber exatamente qual grupo de recursos deve ser alvo. Ele pede confirmação antes de excluir.

### Opção 2 — Portal do Azure

1. Go to [portal.azure.com](https://portal.azure.com)
2. Pesquise por **Grupos de recursos**
3. Encontre `foundry-hackathon-rg-<your-suffix>`
4. Clique em **Excluir grupo de recursos** e confirme

### Opção 3 — Azure CLI

```bash
# Replace <suffix> with the value shown in your .env file
az group delete --name foundry-hackathon-rg-<suffix> --yes --no-wait
```
