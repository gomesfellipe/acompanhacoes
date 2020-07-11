#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
# Sys.setenv(TZ='UTC')
Sys.setenv(TZ = "America/Sao_Paulo")
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here
    navbarPage(
      theme = shinythemes::shinytheme("flatly"),
      title = div( "Acompanhamento de Ações", tags$small("por Fellipe Gomes")),
      tabPanel(
        "Tabela Financeira",
        sidebarPanel(
          textOutput("auth"),
          fileInput("portfolio_file", "Insira os dados do portifólio aqui", buttonLabel = "🔎", placeholder = "Buscar arquivos.."),
          awesomeCheckbox(inputId = "start_vip", label = "Usuário vip?", value = FALSE),
          conditionalPanel("input.start_vip",
                           helpText("O usuário VIP possui acesso direto ao seu portfólio fornecendo sua chave de acesso. Para saber como configurar um Dashboard com sua chave de acesso consulte", 
                                    tags$a(href = "https://github.com/gomesfellipe/acompanhacoes", 
                                          "este link"), "."),
                           tags$b("Insira sua chave de acesso:"), br(),
                           fluidRow(
                             column(8, passwordInput("password", NULL)),
                             column(4, actionButton(inputId = "go_vip", label = "Validar"))
                             )
                           
                           ),
          helpText(HTML(
            "<div align='justify'><p>Bem vindo ao Dashboard para acompanhamento 
            automatizado de ações!</p>
            
            <p> A requisição será feita através da api do 
            <a href='https://finance.yahoo.com/'>Yahoo Finance</a>.</p></div>
            
            "),
            fluidRow(
              column(4, br(),div(align = "center", fade_in_down(img(src="https://storage.needpix.com/rsynced_images/stock-exchange-295648_1280.png", width="90%")))),
              column(4, br(), div(align = "center", fade_in_down(img(src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Bovespa.svg/1280px-Bovespa.svg.png", width="90%"))),
                     div(align = "center", fade_in_down(img(src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Yahoo_Finance_Logo_2019.svg/800px-Yahoo_Finance_Logo_2019.svg.png", width="90%")))),
              column(4, div(align = "center", fade_in_down(img(src="https://cdn.pixabay.com/photo/2017/03/12/02/57/bitcoin-2136339_960_720.png", width="90%"))))
            ),
            div(tags$b("Ajuda:"), "É possível baixar um ",downloadLink("input_test", "exemplo de input"), " e substituir os valores conforme a sua carteira"), br()
            
            )
        ),
        mainPanel(
          fluidRow(fade_in_down(h2("Tabela Financeira")), textOutput("ultimo_dia")), br(),
          tableOutput("tab_financeira") %>% withSpinner(), 
          helpText(tags$b("Obs.:"),"Estas ações que aparecem como default não são do meu portfólio 
                   e também não estou sugerindo esta opção de carteira.
                   Para saber a origem deste input consulte" ,
                   tags$a(href = "https://gomesfellipe.github.io/post/2020-03-25-investment-alert/investment-alert/",
                          "este post"), "do meu blog"),br(),
          fade_in_down(h2("Tabela Financeira (Totais)")), br(),
          tableOutput("tab_financeira_total") %>% withSpinner(), br()
        ),
        br(), br()
      ),
      tabPanel(
        "Ações",
        div(
          fluidRow(
            column(8, 
                  fluidRow(
                    column(6, fade_in_down(h2("Série Histórica:")), br()),
                    column(6, br(), uiOutput("selecionar_stock"),br())
                  ),
                   highchartOutput("plot1") %>% withSpinner()),
            column(4, 
                   fade_in_down(h2("Distribuição da diferença:")), br(), br(), br(), 
                   highchartOutput("plot2") %>% withSpinner())
          )
          , 
          fluidRow(
            column(4, 
                   fade_in_down(h2("Distribuição da carteira por ativo:")), br(),
                   prettyRadioButtons(
                     inputId = "vol_t",
                     label = "Momento do montante:", 
                     choices = c(`Volume atual` = "vol_atual", `Volume inicial` = "vol_ini"),
                     inline = TRUE, 
                     status = "primary",
                     fill = TRUE
                   ),
                   
                   highchartOutput("treemap_carteira") %>% withSpinner() ),
            column(4, 
                   fade_in_down(h2("Correlação entre ativos:")), br(),
                   br(), br(), br(),
                   highchartOutput("cor_carteira") %>% withSpinner(),
                   div(style = "text-align: right;", tags$small("Correlação de Spearman"))
                   ),
            column(4, fade_in_down(h2("Assimetria por ativo:")), br(),
                   br(), br(), br(),
                   highchartOutput("assimetria") %>% withSpinner())
          )
        ),
        br(), br()
        
      ),
      tags$footer(HTML("
      <footer class='page-footer font-large indigo'>
      <div class='footer-copyright text-center py-3'>© 2020 Copyright:
      <a href='https://github.com/gomesfellipe/acompanhacoes'> github.com/gomesfellipe</a>
      🚀
      </div>
      </footer>"))
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www", app_sys("app/www")
  )

  tags$head(
    use_vov(),
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "acompanhacoes"
    ),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
    HTML('<a href="https://github.com/gomesfellipe/acompanhacoes" class="github-corner" aria-label="View source on GitHub"><svg width="80" height="80" viewBox="0 0 250 250" style="fill:#151513; color:#fff; position: absolute; top: 60; border: 0; right: 0;" aria-hidden="true"><path d="M0,0 L115,115 L130,115 L142,142 L250,250 L250,0 Z"></path><path d="M128.3,109.0 C113.8,99.7 119.0,89.6 119.0,89.6 C122.0,82.7 120.5,78.6 120.5,78.6 C119.2,72.0 123.4,76.3 123.4,76.3 C127.3,80.9 125.5,87.3 125.5,87.3 C122.9,97.6 130.6,101.9 134.4,103.2" fill="currentColor" style="transform-origin: 130px 106px;" class="octo-arm"></path><path d="M115.0,115.0 C114.9,115.1 118.7,116.5 119.8,115.4 L133.7,101.6 C136.9,99.2 139.9,98.4 142.2,98.6 C133.8,88.0 127.5,74.4 143.8,58.0 C148.5,53.4 154.0,51.2 159.7,51.0 C160.3,49.4 163.2,43.6 171.4,40.1 C171.4,40.1 176.1,42.5 178.8,56.2 C183.1,58.6 187.2,61.8 190.9,65.4 C194.5,69.0 197.7,73.2 200.1,77.6 C213.8,80.2 216.3,84.9 216.3,84.9 C212.7,93.1 206.9,96.0 205.4,96.6 C205.1,102.4 203.0,107.8 198.3,112.5 C181.9,128.9 168.3,122.5 157.7,114.1 C157.9,116.9 156.7,120.9 152.7,124.9 L141.0,136.5 C139.8,137.7 141.6,141.9 141.8,141.8 Z" fill="currentColor" class="octo-body"></path></svg></a><style>.github-corner:hover .octo-arm{animation:octocat-wave 560ms ease-in-out}@keyframes octocat-wave{0%,100%{transform:rotate(0)}20%,60%{transform:rotate(-25deg)}40%,80%{transform:rotate(10deg)}}@media (max-width:500px){.github-corner:hover .octo-arm{animation:none}.github-corner .octo-arm{animation:octocat-wave 560ms ease-in-out}}</style>')
  )
}
