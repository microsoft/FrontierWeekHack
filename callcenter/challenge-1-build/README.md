# Desafio 1: Criar agentes

Tempo: ~30 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ Um **Agente de Classificação de Intenção** que analisa resumos de chamadas e categoriza a intenção do cliente
- ✅ Um **Agente Consultor de Resolução** que recomenda estratégias ideais de atendimento
- ✅ Os dois agentes testados com dados reais da central de atendimento

![build](./images/build.png)

## Contexto

A NovaTel Communications recebe centenas de chamadas diariamente. Cada chamada tem um resumo, o histórico do cliente e o contexto da conta. Seus agentes precisam:

1. **Classificação de intenção**: analisar a chamada para determinar o que o cliente precisa (contestação de cobrança, problema técnico, risco de cancelamento, oportunidade de upsell etc.)
2. **Consultoria de resolução**: dada uma intenção classificada e o contexto do cliente, recomendar o melhor caminho de resolução com scripts, decisões de encaminhamento e ofertas disponíveis

Consulte [call_data.json](./call_data.json) para ver as chamadas recebidas hoje.

## Portal ou SDK?

O Microsoft Foundry oferece duas maneiras de criar agentes. O **portal do Foundry** ([ai.azure.com/nextgen](https://ai.azure.com/nextgen)) fornece uma interface visual sem código na qual você pode criar agentes, anexar ferramentas e testá-los interativamente em um playground — ideal para exploração e prototipagem rápida. O **Azure AI Agents SDK** oferece controle programático completo: você define o comportamento dos agentes, as ferramentas e a lógica de orquestração em Python, facilitando o versionamento, os testes e a integração a pipelines automatizados.

![foundry](./images/foundry.png)

Neste desafio usamos o **SDK**. O código em [agents.py](./agents.py) cria os dois agentes, registra suas ferramentas e os executa com cada chamada em `call_data.json` — tudo pelo terminal. Depois que o script for executado, os dois agentes também estarão visíveis no portal em **Agents**, para que você possa inspecioná-los, ajustar suas instruções e testá-los interativamente sem alterar código.

## Agentes e ferramentas

### O que é um agente?

Um agente no Microsoft Foundry é um assistente de IA persistente e com estado, apoiado por um modelo de linguagem grande. Diferentemente de uma chamada de API simples — na qual você envia um prompt e recebe uma única resposta — um agente mantém uma **thread de conversa**, pode **invocar ferramentas de forma autônoma** e **mantém o contexto** entre várias interações. Você o configura com:

- Um **nome** e um **modelo** (por exemplo, `gpt-5.4`)
- Um **prompt do sistema** — instruções que definem sua função, personalidade e restrições
- Uma ou mais **ferramentas** que ele pode chamar quando precisa de informações ou ações além dos seus dados de treinamento

Os agentes são recursos gerenciados no seu projeto do Foundry. Eles persistem entre execuções, aparecem no portal em **Agents** e podem ser versionados, compartilhados e reutilizados.

### O que são ferramentas?

As ferramentas ampliam as capacidades de um agente para além da geração de linguagem. Quando o modelo decide que precisa de uma informação que não está na janela de contexto, ele emite uma **chamada de ferramenta** — uma solicitação JSON estruturada que especifica o nome da ferramenta e seus argumentos. O SDK intercepta essa solicitação, executa a função Python correspondente e devolve o resultado ao modelo. Esse ciclo de raciocínio continua até o agente produzir uma resposta final.

Do ponto de vista do modelo, as ferramentas são descritas por um **esquema JSON** (nome, descrição e parâmetros). O modelo lê essas descrições e decide autonomamente quando e como chamá-las — você nunca codifica a lógica de decisão diretamente.

### Quais ferramentas você pode adicionar?

| Tipo de ferramenta | O que ela faz | Melhor para |
|-----------|-------------|----------|
| **Function** | Chama uma função Python local que você define | Qualquer lógica personalizada: consultas a bancos de dados, APIs e cálculos |
| **Code Interpreter** | Permite que o agente escreva e execute Python em um sandbox | Análise de dados, geração de gráficos e processamento de arquivos |
| **File Search** | Pesquisa semântica em uma base de conhecimento do Microsoft Foundry | Documentos de políticas, manuais e registros históricos |
| **Bing Search** | Pesquisa na web em tempo real | Informações em tempo real e notícias |
| **Azure AI Search** | Consulta um índice do Azure Search | Recuperação fundamentada em seus próprios dados em escala |

#### Bancos de dados vetoriais e bases de conhecimento do Microsoft Foundry

Quando seu agente precisa responder a perguntas fundamentadas em um grande conjunto de documentos — manuais de políticas, especificações de produtos e registros históricos — você precisa de um **banco de dados vetorial**. Diferentemente da pesquisa por palavras-chave, um banco vetorial converte texto em embeddings numéricos e encontra trechos semanticamente semelhantes no momento da consulta. Assim, o agente pode fazer uma pergunta em linguagem natural e recuperar o conteúdo correto mesmo quando as palavras exatas não aparecem na consulta.

O **Microsoft Foundry** inclui uma base de conhecimento integrada apoiada por um armazenamento vetorial. Você carrega documentos (PDFs, arquivos do Word e texto simples), e o serviço os divide em trechos, gera embeddings e cria o índice automaticamente. Quando você anexa essa base de conhecimento a um agente como ferramenta de **File Search**, o agente a consulta durante a inferência — trazendo trechos relevantes para o contexto antes de gerar uma resposta, para que suas respostas se baseiem nos seus documentos reais, e não apenas nos dados de treinamento do modelo.

Para a central de atendimento da NovaTel, bases de conhecimento úteis incluiriam:

- **Manual de políticas de atendimento ao cliente** — limites de reembolso, regras de encaminhamento e elegibilidade de ofertas de retenção por nível do plano
- **Documentação de produtos e planos** — recursos por nível, ciclos de cobrança, prazos para devolução de dispositivos e políticas de roaming
- **Scripts de resolução** — linguagem aprovada para contestações de cobrança, retenção em cancelamentos e conversas de upsell

Com isso, o **Agente Consultor de Resolução** poderia consultar “quais ofertas de retenção se aplicam a um cliente Premium com mais de 3 anos que quer cancelar?” e recuperar os detalhes exatos da oferta no manual — em vez de inventar políticas plausíveis, mas potencialmente incorretas.

Neste desafio, os agentes usam **ferramentas de função**. O **Agente de Classificação de Intenção** usa `lookup_customer` para obter o histórico da conta e o nível do cliente antes de decidir a intenção. Sem essa ferramenta, o agente teria de adivinhar apenas a partir do resumo da chamada — com ela, toda classificação se baseia em dados reais da conta.

## Comece agora

Abra [agents.py](./agents.py) e revise a implementação dos dois agentes.

```bash
cd callcenter/challenge-1-build
python agents.py
```

Enquanto o script é executado, observe atentamente o terminal — você verá cada agente sendo criado e, em seguida, cada chamada de `call_data.json` passando primeiro pelo **Agente de Classificação de Intenção**, com sua saída sendo encaminhada ao **Agente Consultor de Resolução**. As respostas brutas dos agentes serão exibidas para cada chamada, oferecendo uma visão ao vivo de como eles colaboram. Quando terminar, acesse o [portal do Microsoft Foundry](https://ai.azure.com/nextgen), abra seu projeto e navegue até **Agents** na barra lateral esquerda — clique em **Refresh** se os agentes não aparecerem imediatamente, pois pode levar alguns segundos para que novos agentes sejam exibidos no portal.


## Critérios de sucesso

- [ ] O Agente de Classificação de Intenção identifica corretamente os 6 tipos de intenção nas 7 chamadas
- [ ] O Consultor de Resolução fornece recomendações acionáveis com scripts e decisões de encaminhamento
- [ ] As preocupações de segurança sempre são encaminhadas; as contestações de cobrança oferecem créditos apropriados
