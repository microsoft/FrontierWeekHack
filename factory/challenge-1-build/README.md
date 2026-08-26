# Desafio 1: Criar Agentes

Tempo: ~30 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ Um **Agente de Detecção de Anomalias** que monitora dados de sensores e sinaliza leituras anormais
- ✅ Um **Agente de Diagnóstico de Falhas** que analisa anomalias sinalizadas e recomenda ações de manutenção
- ✅ Os dois agentes testados com dados reais de sensores do chão de fábrica

![build](./images/build.png)

## Contexto

A TireForge Industries tem 5 máquinas no chão de fábrica. Cada máquina emite dados de sensores, incluindo temperatura, pressão, vibração e RPM. Seus agentes precisam:

1. **Detecção de Anomalias**: Comparar as leituras atuais com limites conhecidos e sinalizar máquinas fora das especificações
2. **Diagnóstico de Falhas**: Dada uma anomalia, raciocinar sobre o que pode estar errado e recomendar uma ação

Consulte [sensor_data.json](./sensor_data.json) para ver o estado atual de todas as máquinas.

## Portal ou SDK?

O Microsoft Foundry oferece duas maneiras de criar agentes. O **portal do Foundry** ([ai.azure.com/nextgen](https://ai.azure.com/nextgen)) fornece uma interface visual sem código na qual você pode criar agentes, anexar ferramentas e testá-los interativamente em um playground, ideal para exploração e prototipagem rápida. O **SDK de Agentes de IA do Azure** oferece controle programático completo: você define o comportamento dos agentes, as ferramentas e a lógica de orquestração em Python, facilitando o versionamento, os testes e a integração a pipelines automatizados.

![foundry](./images/foundry.png)

Neste desafio usamos o **SDK**. O código em [agents.py](./agents.py) cria os dois agentes, registra suas ferramentas e os executa em cada máquina de `sensor_data.json`, tudo pelo terminal. Depois da execução do script, os dois agentes também estarão visíveis no portal em **Agentes**, para que você possa inspecioná-los, ajustar suas instruções e testá-los interativamente sem tocar no código.

## Agentes e Ferramentas

### O que é um agente?

Um agente no Microsoft Foundry é um assistente de IA persistente e com estado, apoiado por um modelo de linguagem grande. Diferentemente de uma chamada de API simples, na qual você envia um prompt e recebe uma única resposta, um agente mantém uma **thread de conversa**, pode **invocar ferramentas de forma autônoma** e **retém contexto** entre várias interações. Você o configura com:

- Um **nome** e um **modelo** (por exemplo, `gpt-5.4`)
- Um **prompt de sistema** — instruções que definem sua função, personalidade e restrições
- Uma ou mais **ferramentas** que ele pode chamar quando precisa de informações ou ações além dos dados de treinamento

Os agentes são recursos gerenciados no seu projeto do Foundry. Eles persistem entre execuções, aparecem no portal em **Agentes** e podem ser versionados, compartilhados e reutilizados.

### O que são ferramentas?

As ferramentas ampliam as capacidades de um agente para além da geração de linguagem. Quando o modelo decide que precisa de uma informação que não está na janela de contexto, ele emite uma **chamada de ferramenta**, uma solicitação JSON estruturada que especifica o nome da ferramenta e seus argumentos. O SDK intercepta a chamada, executa a função Python correspondente e devolve o resultado ao modelo. Esse ciclo de raciocínio continua até o agente produzir uma resposta final.

Do ponto de vista do modelo, as ferramentas são descritas por um **schema JSON** (nome, descrição e parâmetros). O modelo lê essas descrições e decide de forma autônoma quando e como chamá-las; você nunca codifica a lógica de decisão diretamente.

### Quais ferramentas você pode adicionar?

| Tipo de ferramenta | O que faz | Melhor para |
|-----------|-------------|----------|
| **Função** | Chama uma função Python local definida por você | Qualquer lógica personalizada: consultas a bancos, APIs e cálculos |
| **Interpretador de Código** | Permite que o agente escreva e execute Python em um sandbox | Análise de dados, geração de gráficos e processamento de arquivos |
| **Pesquisa de Arquivos** | Pesquisa semântica em uma base de conhecimento do Microsoft Foundry | Documentos de políticas, manuais e registros históricos |
| **Bing Search** | Pesquisa na web em tempo real | Informações em tempo real e notícias |
| **Azure AI Search** | Consulta um índice do Azure Search | Recuperação fundamentada dos seus dados em escala |

#### Bancos de dados vetoriais e bases de conhecimento do Microsoft Foundry

Quando seu agente precisa responder a perguntas fundamentadas em um grande volume de documentos, como manuais de políticas, especificações de produtos e registros históricos, você precisa de um **banco de dados vetorial**. Diferentemente da pesquisa por palavras-chave, um banco vetorial converte o texto em embeddings numéricos e encontra trechos semanticamente semelhantes no momento da consulta. Assim, o agente pode fazer uma pergunta em linguagem natural e recuperar o conteúdo correto mesmo quando as palavras exatas não aparecem na consulta.

O **Microsoft Foundry** inclui uma base de conhecimento integrada apoiada por um armazenamento vetorial. Você carrega documentos (PDFs, arquivos do Word e texto simples), e o serviço os divide em trechos, gera embeddings e cria o índice automaticamente. Quando você anexa essa base a um agente como ferramenta de **Pesquisa de Arquivos**, o agente a consulta durante a inferência, trazendo trechos relevantes para o contexto antes de gerar uma resposta. Assim, as respostas se baseiam nos seus documentos reais, e não apenas nos dados de treinamento do modelo.

Para a TireForge Industries, bases de conhecimento úteis incluiriam:

- **Manuais de manutenção das máquinas** — procedimentos de reparo, cronogramas de lubrificação, especificações de torque e números de peças de reposição para cada máquina
- **Relatórios históricos de incidentes** — falhas anteriores, suas causas raiz e as ações corretivas que as resolveram
- **Fichas de especificações dos fornecedores** — tolerâncias operacionais aceitáveis, condições de garantia e limites de sensores recomendados por modelo de máquina

Com isso, o **Agente de Diagnóstico de Falhas** poderia consultar "quais são os modos de falha conhecidos da prensa de cura CP-003 quando a vibração excede 9,0 mm/s?" e recuperar o histórico de manutenção relevante, fundamentando sua recomendação em precedentes documentados, e não no conhecimento geral do LLM.

Neste desafio, os agentes usam **ferramentas de função**. O **Agente de Detecção de Anomalias** usa `check_thresholds` para consultar as faixas operacionais aceitáveis de cada máquina e compará-las com as leituras ao vivo dos sensores. Sem essa ferramenta, o agente teria de raciocinar apenas com base na memória; com ela, cada verificação de limite se fundamenta em dados reais das especificações da máquina.

## Comece Aqui

Abra [agents.py](./agents.py) e examine a implementação dos dois agentes.

```bash
cd factory/challenge-1-build
python agents.py
```

Enquanto o script é executado, observe o terminal: você verá cada agente sendo criado e, em seguida, cada máquina de `sensor_data.json` passando primeiro pelo **Agente de Detecção de Anomalias**, com sua saída encaminhada ao **Agente de Diagnóstico de Falhas**. As respostas brutas dos agentes serão impressas para cada máquina, oferecendo uma visão ao vivo de como os dois agentes colaboram. Quando terminar, acesse o [portal do Microsoft Foundry](https://ai.azure.com/nextgen), abra seu projeto e navegue até **Agentes** na barra lateral esquerda. Clique em **Atualizar** se os agentes não aparecerem imediatamente, pois pode levar alguns segundos para que agentes recém-criados apareçam no portal.

## Critérios de Sucesso

- [ ] O Agente de Detecção de Anomalias identifica corretamente as 2 máquinas em alerta e a 1 crítica
- [ ] O Agente de Diagnóstico de Falhas fornece recomendações de manutenção razoáveis
- [ ] Os dois agentes respondem de forma coerente quando recebem as leituras dos sensores de uma máquina
