# 📞 Cenário: Triagem de Central de Atendimento — NovaTel Communications

## Contexto

![scenario](./images/scenario.png)

**NovaTel Communications** é uma operadora de telecomunicações que atende centenas de chamadas de clientes diariamente em sua central de suporte. A fila de hoje tem 7 chamadas ativas, abrangendo diferentes tipos de problemas:

- **CALL-001** — Maria Gonzalez (Premium, 3 years) — Unexpected charge dispute
- **CALL-002** — James Liu (Basic, 4 months) — Internet dropping repeatedly
- **CALL-003** — Priya Sharma (Premium, 18 months) — Wants to cancel (moving)
- **CALL-004** — Robert Chen (Business, 2 years) — Adding 7 phone lines
- **CALL-005** — Sarah Mitchell (Basic, 5 years) — Can't navigate new app
- **CALL-006** — David Park (Premium, 1 year) — Charged for returned device
- **CALL-007** — Emma Wilson (Basic, 8 months) — Suspected account hack



## Sua missão

![agentic-orchestration](./images/agentic-orchestration.png)

Crie um sistema de agentes de IA que:

1. **Classifica a intenção** — Determina o que cada cliente precisa (cobrança, suporte técnico, cancelamento, upsell, suporte, segurança)
2. **Recomenda uma resolução** — Recomenda a melhor estratégia de atendimento com base no contexto do cliente
3. **Produz um relatório do turno** — Triagem consolidada com itens de ação priorizados

## Desafios

| # | Desafio | O que você fará | Tempo |
|---|-----------|---------------|------|
| 0 | [Configuração](./challenge-0-setup/README.md) | Implantar a infraestrutura do Microsoft Foundry | 20 min |
| 1 | [Criar agentes](./challenge-1-build/README.md) | Criar agentes de Classificação de Intenção e Consultoria de Resolução | 30 min |
| 2 | [Monitorar](./challenge-2-monitor/README.md) | Habilitar o tracing de GenAI com o Application Insights | 20 min |
| 3 | [Avaliar](./challenge-3-evaluate/README.md) | Executar avaliações sistemáticas de qualidade | 30 min |
| 4 | [Fluxo de produção](./challenge-4-deploy/README.md) | Orquestração multiagente e fluxo no portal | 20 min |

## Por que os desafios estão nesta ordem

**Crie primeiro.** A classificação de intenção só funciona se o agente tiver instruções precisas e contexto real da conta. Um agente que não consegue distinguir um risco de cancelamento de uma contestação de cobrança encaminhará as chamadas incorretamente — enviando ofertas de retenção a clientes que só têm uma dúvida sobre cobrança e colocando contas de alto valor na fila errada. A ferramenta `lookup_customer` fornece ao Agente de Intenção dados reais da conta: nível, tempo de relacionamento e casos abertos. Sem ela, o agente fica apenas supondo.

**Depois monitore.** Um sistema de triagem de chamadas funciona o dia todo, processando centenas de chamadas. Os traces do Application Insights permitem ver o que o agente realmente fez em cada uma — se chamou `lookup_customer`, quanto tempo levou e exatamente o que recomendou. Quando um supervisor diz "o sistema deu uma orientação errada na CALL-007", é pelos traces que você descobre o motivo.

**Depois avalie.** O conjunto de dados de teste tem respostas corretas conhecidas. Executar os agentes com ele — antes e depois de cada alteração — fornece uma pontuação que mostra se a classificação está melhorando ou se deteriorando silenciosamente. Um ajuste no prompt que parece bom em cinco respostas verificadas pontualmente ainda pode prejudicar a precisão em casos extremos que você não conferiu.

**Depois implante.** O fluxo do portal produz um relatório do turno sobre o qual os supervisores podem agir: fila priorizada, ações recomendadas, contexto do cliente e histórico completo de traces. Essa é a diferença entre um script Python executado manualmente e algo em que a equipe de operações confia no início de cada turno.



## Arquitetura

![architecture](./images/architecture.png)

## Próximos passos

Ao concluir estes desafios, você terá um sistema multiagente funcional, com observabilidade e avaliação configuradas. Veja algumas direções para evoluí-lo:

**Implante como um endpoint de agente hospedado**
O Microsoft Foundry pode hospedar seus agentes como endpoints de API persistentes e escaláveis — sem infraestrutura para gerenciar. Depois de hospedados, sua plataforma de telefonia (Twilio, Genesys, Azure Communication Services) poderá enviar transcrições de chamadas ao vivo diretamente ao Agente de Classificação de Intenção e receber decisões de triagem em tempo real, substituindo a revisão manual da fila.

**Adicione mais ferramentas aos seus agentes**
A função `lookup_customer` deste laboratório usa dados simulados locais. Em produção, você a substituiria por ferramentas que chamam sistemas reais:
- Uma ferramenta `fetch_crm_history` que consulta o Salesforce ou o Dynamics 365 para obter o histórico completo de interações do cliente
- Uma ferramenta `check_active_offers` que busca promoções de retenção atuais e regras de elegibilidade em uma API de preços
- Uma ferramenta `create_case` que abre automaticamente um tíquete no CRM e o atribui à fila correta com base na recomendação do Consultor de Resolução

**Crie uma base de conhecimento**
Carregue o manual de políticas de atendimento ao cliente da NovaTel, os scripts de resolução e a documentação de produtos em uma base de conhecimento do Microsoft Foundry. Anexe-a ao Agente Consultor de Resolução como uma ferramenta de Pesquisa de Arquivos para que seus scripts se baseiem no manual aprovado — e não em uma versão inventada.

**Integre as avaliações ao CI/CD**
Execute automaticamente seu conjunto de avaliação em cada pull request ou implantação. Se a pontuação de coerência ou relevância cair abaixo de um limite (por exemplo, 3,5 de 5), bloqueie a versão. Isso impede que uma edição do prompt do sistema ou uma atualização do modelo reduza silenciosamente a precisão da classificação durante os horários de pico.

**Explore padrões avançados de agentes**
- **Paralelize** a classificação de intenção nas 7 chamadas simultaneamente, em vez de sequencialmente
- **Adicione limites de confiança** — se o Agente de Intenção estiver em dúvida entre cancelamento e cobrança, sinalize a chamada para revisão humana em vez de atribuí-la automaticamente
- **Humano no circuito** — para a CALL-007 (incidentes de segurança), sempre encaminhe a um supervisor humano, independentemente do nível de confiança do agente

**Ajuste para seu domínio**
Use os resultados das avaliações para identificar erros sistemáticos — tipos de intenção que o agente confunde consistentemente ou segmentos de clientes que ele atende mal. Use esses casos para refinar os prompts do sistema, adicionar exemplos few-shot direcionados ou ajustar o modelo subjacente com transcrições de chamadas da NovaTel.
