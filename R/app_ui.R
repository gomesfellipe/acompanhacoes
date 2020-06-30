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
    pageWithSidebar(
      headerPanel("Acompanhamento de Ações"),
      sidebarPanel(
        fileInput("portifolio_file", "Insira os dados do portifólio aqui"),
        uiOutput("selecionar_stock"),
        tags$b("Ajuda:"), downloadLink("input_test", "Exemplo de input"), br(),
        tags$p(tags$b("Código Fonte: "), tags$a(
          href = "https://github.com/gomesfellipe/acompanhacoes",
          "github.com/gomesfellipe/acompanhacoes"
        ))
      ),
      mainPanel(
        h2("Série Histórica:"), br(),
        highchartOutput("plot1") %>% withSpinner(), br(),
        fluidRow(h2("Tabela Financeira"), textOutput("ultimo_dia")), br(),
        tableOutput("tab_financeira") %>% withSpinner()
      )
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
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "acompanhacoes"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
