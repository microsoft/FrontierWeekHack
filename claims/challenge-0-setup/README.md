# Desafio 0: Configuração e autenticação

Tempo: ~20 minutos

## Objetivos

Ao final deste desafio, você terá:

- ✅ Um projeto do Microsoft Foundry totalmente provisionado com um modelo implantado
- ✅ O Application Insights provisionado e a cadeia de conexão disponível
- ✅ A autenticação da sua máquina local no Foundry verificada
- ✅ A confirmação de que o endpoint do seu agente está funcionando

![setup](./images/setup.png)

## Primeiros passos

> [!NOTE]
> Antes de começar, certifique-se de que você tem:
> - Uma **assinatura do Azure** na qual você tenha as funções de **Colaborador** (para implantar a infraestrutura) e **Usuário do Foundry** (para criar, avaliar e executar agentes nos Desafios 1–4).
> - Uma **conta do GitHub** para criar um fork deste repositório e executá-lo no GitHub Codespaces.
>
> Os direitos de **Proprietário** (ou Colaborador) da assinatura, sozinhos, **não** são suficientes. Eles concedem acesso ao plano de controle para criar e gerenciar recursos, mas criar e executar agentes são operações do plano de dados que exigem a função separada de **Usuário do Foundry** atribuída na conta do Foundry. Um Proprietário pode atribuí-la a si mesmo; um Colaborador deve pedir a um administrador que a atribua após a implantação.

Há duas formas de começar: escolha uma:

> **Primeiro passo para as duas opções:** [crie um fork deste repositório](https://github.com/diegodocs/FrontierWeekHack/fork) na sua conta do GitHub.

### Opção A: GitHub Codespaces (recomendado)

Não é necessário instalar nada localmente. Tudo é executado em um ambiente de desenvolvimento na nuvem.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/diegodocs/FrontierWeekHack)

1. Clique no selo acima (se aplicável, selecione seu fork)
2. Aguarde a criação do Codespace (~2 min)
3. No terminal, entre no Azure:

```bash
az login
```

4. Continue em **Implantar infraestrutura** abaixo.

---

### Opção B: Ambiente local

Execute tudo na sua própria máquina. Requer Python 3.10+ e o Azure CLI.

```bash
# 1. Clone this repo
git clone https://github.com/diegodocs/FrontierWeekHack.git
cd FrontierWeekHack

# 2. Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# 3. Install Python dependencies
pip install -r requirements.txt

# 4. Log in to Azure
az login
```

4. Continue em **Implantar infraestrutura** abaixo.

## Implantar infraestrutura

Na pasta **claims**, inicialize o ambiente `azd` e provisione a infraestrutura:

```bash
cd claims
azd auth login
azd provision
```

Isso provisionará todos os recursos **e** gravará automaticamente seu arquivo `.env` na pasta **claims**. A implantação levará alguns minutos para ser concluída.

## Verificar a criação dos recursos

Vá ao [Portal do Azure](https://portal.azure.com/) e encontre seu grupo de recursos, que agora deve conter recursos semelhantes a estes:

![Azure Portal Resources](./images/azure-portal-resources.png)

> [!NOTE]
> Os prefixos dos nomes dos recursos variam conforme o cenário, e os sufixos são exclusivos para cada implantação

Vá ao [Portal do Microsoft Foundry](https://ai.azure.com/nextgen) e verifique se você consegue acessar o projeto do Foundry.

![Foundry Project](./images/foundry-project.png)

Selecione **Build** na navegação superior, depois **Models**, e verifique se o modelo **gpt-5.4** está implantado.

>[!NOTE]
> Em algumas versões do Portal do Foundry, a guia **Models** aparece como **Deployments**, mas ambas têm a mesma finalidade.

![Foundry Model](./images/foundry-model.png)

Selecione **gpt-5.4**, insira uma mensagem de teste no playground do modelo e verifique se recebe uma resposta.

![Foundry Model Playground](./images/foundry-model-playground.png)


## Critérios de sucesso

- [ ] Você consegue ver seu projeto do Microsoft Foundry no Portal do Azure
- [ ] Uma implantação do modelo gpt-5.4 mostra o status "Succeeded"
- [ ] Você consegue enviar uma mensagem de teste no Playground de Modelos do Foundry
