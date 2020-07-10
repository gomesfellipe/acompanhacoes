#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  
  # Tabela financeira -------------------------------------------------------
  
  auth <- reactive({
    # Se o botao de vip nao for pressionado, nao valide a autenticacao
    if(input$start_vip == F){
      FALSE
    }else{
      req(input$go_vip)
      # Caso contrario, tente ler o arquivo com as senhas: vip.rds
      tryCatch({
        isolate(input$password) %in% readRDS("vip.rds")     
      }, error = function(e){
        sendSweetAlert(
          session = session,
          title = "Erro...",
          text = "Não foi possivel encontrar o arquivo vip.rds com a chave de acesso!",
          type = "error"
        )
        return(FALSE)
      })
    }
  })
  
  # Leitura dos dados
  portfolio <- reactive({
    
    # Se nenhum arquivo de portfolio for informado
    if(is.null(input$portfolio_file$datapath)){
      
      # Se a autenticacao nao for confirmada
      if(auth() == FALSE){
        acompanhacoes::input_exemplo  
      }else{
        # Caso contrario, tente ler o arquivo portfolio.txt localmente
        tryCatch({
          read.csv("portfolio.txt", stringsAsFactors = F) %>% as_tibble()    
        }, error = function(e){
          sendSweetAlert(
            session = session,
            title = "Erro...",
            text = "Não foi possivel encontrar o arquivo portfolio.txt!",
            type = "error"
          )
          acompanhacoes::input_exemplo  
        })
        
      }
      
    }else{
      read.csv(input$portfolio_file$datapath, stringsAsFactors = F) %>%
        as_tibble() %>%
        mutate_all(~ .x %>%
                     str_trim() %>%
                     str_squish()) %>%
        mutate_at(c("cot_ini", "qtd"), as.numeric)  
    }
    
  })
  
  # Obter dados do ultimo dia
  fechamento_ultimo_dia <-
    reactive({
      portfolio()$symbol %>% 
        unique() %>% 
        purrr::map_dfr(~quantmod::getQuote(.x) %>% 
                         tibble::rownames_to_column()) %>% 
        mutate(`Trade Time` = format(`Trade Time`, tz="America/Sao_Paulo"),
               `Trade Time` = ymd_hms(`Trade Time`)) %>% 
        dplyr::select(symbol = rowname, cot_atual = Last, date = `Trade Time`)
    })
  
  # Prrint data do dia
  output$ultimo_dia <- renderText({
    format(as.Date(fechamento_ultimo_dia()$date[1]), format = "%d/%m/%Y")
  })
  
  # Criar tabela financeita
  tab_financeira <-
    reactive({
      left_join(portfolio(), fechamento_ultimo_dia()) %>%
        select(date, everything()) %>%
        mutate(cot_atual = if_else(symbol == "BTC-USD",
                                   cot_atual * quantmod::getQuote("USDBRL=X")[1, "Open"],
                                   cot_atual
        )) %>%
        mutate(
          vol_ini = cot_ini * qtd,
          vol_atual = cot_atual * qtd,
          ganho_perda = vol_atual - vol_ini,
          resultado_bruto = round(ganho_perda / vol_ini * 100, 2),
          date = format(date, "%d/%m/%y %H:%M:%S")
        ) %>%
        select(
          symbol, cot_ini, qtd, vol_ini, cot_atual, qtd, vol_atual,
          ganho_perda, resultado_bruto, date
        )
    })
  
  
  # Formatar tabela financeira
  output$tab_financeira <- function() {
    tab_financeira()  %>% 
      mutate_all(~ ifelse(is.na(.x), 0, .x)) %>%
      mutate(
        cot_ini = moeda_real(cot_ini),
        cot_atual = moeda_real(cot_atual),
        vol_ini = moeda_real(vol_ini),
        vol_atual = moeda_real(vol_atual),
        qtd =  ifelse(symbol == "BTC-USD", 
                      format(qtd, digits = 4), format(qtd, digits = 0)),
        ` ` = ifelse(ganho_perda > 0, "\u2713", "\u2718"),
        cot_atual = cell_spec(cot_atual, "html", color = "blue"),
        ganho_perda = cell_spec(moeda_real(ganho_perda), "html",
                                color = ifelse(ganho_perda > 0,
                                               "green", "red"
                                )
        ),
        resultado_bruto = cell_spec(porcentagem(resultado_bruto), "html",
                                    color = ifelse(resultado_bruto > 0,
                                                   "green", "red"
                                    )
        )
      ) %>%
      `colnames<-`(c(
        "Ativo", "Cotação inicio", "Quantidade",
        "Volume Inicio", "Cotação atual", "Voluma atual",
        "Ganho/Perda", "Resutado Bruto","Coleta", "Status"
      )) %>%
      kable(format = "html", escape = F) %>%
      kable_styling(c("bordered", "hover", "responsive"),
                    full_width = T, font_size = 12
      ) %>%
      add_header_above(c(" ",
                         "Montagem" = 3,
                         "Desmontagem / Atual" = 2, "Resultado" = 4)) %>%
      scroll_box(width = "100%",
                 box_css = "border: 0px solid #ddd; padding: 5px; ")
  }
  
  # Formatar tabela financeira total
  output$tab_financeira_total <- function() {
    
    data <- tab_financeira()
    
    btc <- 
      data %>% 
      filter(symbol == "BTC-USD") %>% 
      summarise(qtd = sum(qtd),
                vol_ini = sum(vol_ini),
                vol_atual = sum(vol_atual) ) %>% 
      mutate(ganho_perda = vol_atual - vol_ini,
             resultado_bruto = round(ganho_perda / vol_ini * 100, 2),
             soma = "BTC-USD")
    
    bovespa <- 
      data %>% 
      filter(symbol != "BTC-USD") %>% 
      summarise(qtd = NA,
                vol_ini = sum(vol_ini),
                vol_atual = sum(vol_atual) ) %>% 
      mutate(ganho_perda = vol_atual - vol_ini,
             resultado_bruto = round(ganho_perda / vol_ini * 100, 2),
             soma = "BOVESPA")
    
    total <- 
      data %>% 
      summarise(qtd = NA,
                vol_ini = sum(vol_ini),
                vol_atual = sum(vol_atual)
      ) %>% 
      mutate(ganho_perda = vol_atual - vol_ini,
             resultado_bruto = round(ganho_perda / vol_ini * 100, 2),
             soma = "Total")
    
    bind_rows(bovespa, btc, total) %>% 
      select(soma, everything()) %>% 
      mutate_all(~ ifelse(is.na(.x), 0, .x)) %>%
      mutate(
        vol_ini = moeda_real(vol_ini),
        vol_atual = moeda_real(vol_atual),
        qtd = ifelse(soma == "BTC-USD", format(qtd, digits = 4), "-"),
        ` ` = ifelse(ganho_perda > 0, "\u2713", "\u2718"),
        ganho_perda = cell_spec(moeda_real(ganho_perda), "html",
                                color = ifelse(ganho_perda > 0,
                                               "green", "red"
                                )
        ),
        resultado_bruto = cell_spec(porcentagem(resultado_bruto), "html",
                                    color = ifelse(resultado_bruto > 0,
                                                   "green", "red"
                                    )
        )
      ) %>%
      `colnames<-`(c(
        "Soma", "Quantidade", "Volume Inicio", "Voluma atual",
        "Ganho/Perda", "Resutado Bruto", "Status"
      )) %>%
      kable(format = "html", escape = F) %>%
      kable_styling(c("bordered", "hover", "responsive"),
                    full_width = T, font_size = 12
      ) %>%
      scroll_box(width = "100%",
                 box_css = "border: 0px solid #ddd; padding: 5px; ")
    
  }
  
  # Geral -------------------------------------------------------------------
  
  # Opcoes de simbolo do portfolio
  output$selecionar_stock <- renderUI({
    selectInput("stock", "Stocks", unique(portfolio()$symbol))
  })
  
  # Serie historica da acao selecionada
  output$plot1 <- renderHighchart({
    
    first_day_year <- Sys.Date() %>% `year<-`(year(Sys.Date())-1)
    
    stocks <- map_df(
      unique(portfolio()$symbol),
      ~ tq_get(.x, get = "stock.prices", from = first_day_year)
    )
    
    stocks %>%
      mutate(date = as.Date(date)) %>% 
      filter(symbol == input$stock) %>%
      timetk::tk_xts(date_var = date) %>%
      highcharter::hchart()
  })
  
  # Download exemplo de input -----------------------------------------------
  
  # fornecer documento de input como exemplo
  output$input_test <- downloadHandler(
    filename = function() {
      "input_test.txt"
    },
    content = function(con) {
      input_exemplo %>% write.csv(con, row.names = F)
    }
  )
  
  
}
