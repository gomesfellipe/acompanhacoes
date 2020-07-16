
# acompanhacoes

**Atenção:** App em desenvolvimento! Para mais informações sobre os próximos passos consulte a aba de [Projects](https://github.com/gomesfellipe/acompanhacoes/projects)

---

O objetivo do pacote `acompanhacoes` é oferecer para a comunidade R de forma gratuita, simples e prática a portabilidade de um dashboard desenvolvido para o acompanhamento de ativos de diferentes naturezas. A idéia deste shiny foi inspirada [neste post](https://gomesfellipe.github.io/post/2020-03-25-investment-alert/investment-alert/) do meu blog. 

O dashboard é uma POC ([proof of concept](https://en.wikipedia.org/wiki/Proof_of_concept)) de uma ferramenta que possibilita o acompanhamento automatizado da tabela financeira de um portifólio com a coleta de dados de cotações em tempo real, cálculo de Ganho/Perda caso decida fazer a desmontagem no tempo atual e análise automatizada do portifólio.

O app shiny foi desenvolvido utilizando o framework [`golem`](https://thinkr-open.github.io/golem/index.html) que trás uma série de configurações e facilitam na hora de implementar o app em produção. O app possui um script [Dockerfile](https://github.com/gomesfellipe/acompanhacoes/blob/master/Dockerfile) que é gerado automaticamente utilizando a função `golem::add_dockerfile()`.

Os dados são obtidos utilizando a função `quantmod::getQuote("<stock>")` para obter dados em tempo real (com defasagem de 15 minutos) e utilizando a função `quantmod::("<stock>", get = "stock.prices", from = first_day_year)` intradiários fornecidos pela api do [Yahoo Finance](https://finance.yahoo.com/) das cotações do dia anterior. 

## Instalação

Para instalar a versão de desenvolvimento do aplicativo execute o comando:

``` r
devtools::install_github("gomesfellipe/acompanhacoes", INSTALL_opts = '--no-lock')
```

## Uso

Após instalar o pacote, execute os comandos para executar o dashboard no R:

``` r
library(acompanhacoes)
run_app()
```
Veja como é a tela inicial do dashboard:

![](inst/app/www/tela_inicial.png)

Para acessar o dashboard no meu servidor consulte: <https://gomes555.shinyapps.io/acompanhacoes/>

Inicialmente será carregado um portfólio __arbitrário__ de exemplo, exibindo **tabelas financeiras** com as seguitnes informações:

| Campo       | Subcampo        | Descrição                            | Operação                    |
|-------------|-----------------|--------------------------------------|-----------------------------|
| Montagem    |                 | Valor no momento da compra           |                             |
|             | Cotação inicio  | Quantidade de lotes comprados        | -                           |
|             | Quantidade      | Volume total da compra               | -                           |
|             | Volume Inicio   |                                      | cot_ini * qtd               |
| Desmontagem |                 |                                      |                             |
|             | Cotacao Atual   | Valor do ativo no momento atual      | Coleta em tempo real        |
|             | Volume Atual    | Volume total atual                   | cot_atual * qtd             |
| Resultado   |                 |                                      |                             |
|             | Ganho/Perda     | Valor de ganho/perda caso venda hoje | vol_atual - vol_ini         |
|             | Resultado Bruno | Porcentagem de lucro                 | ganho_perda / vol_ini * 100 |


## Input

Os dados das cotações serão coletados no momento do input do portfólio do usuário (ou após fornecer a senha de usuário vip)

### Input manual

TODO

### ⭐  **Usuário vip!**

TODO

## Disclaimer

Estes não são meus portfólio e também não estou sugerindo estas opções de carteiras. Para saber a origem deste input consulte o [post do meu blog](https://gomesfellipe.github.io/post/2020-03-25-investment-alert/investment-alert/) onde utilizo estes ativos como exemplo na construção de uma portfólio fictício. A idéia é que o usuário entre com os dados do seu portfólio para cada compra efetuada.


## Próximos passos

Para saber quais serão os próximos passos e saber como voc˜e pode contribuir com o desenvolvimento deste pacote consulte a aba de [Projects](https://github.com/gomesfellipe/acompanhacoes/projects) do github.

O pacote ainda esta em fase de desenvolvimento e quando estiver completo será submetido ao CRAN!

## Licença

Sinta-se a vontade para utilizar, reproduzir e modificar o código respeitando os [termos da licença](https://github.com/gomesfellipe/acompanhacoes/blob/master/LICENSE.md). 
