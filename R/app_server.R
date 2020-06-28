#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  
  # Leitura dos dados -------------------------------------------------------
  
  portifolio <- reactive({
    
    read.csv(input$portifolio_file$datapath, stringsAsFactors = F) %>% 
      as_tibble() %>% 
      mutate_all(~ .x %>% str_trim() %>% str_squish()) %>% 
      mutate_at(c("cot_ini", "qtd"), as.numeric)  
    
  })
  
  output$selecionar_stock <-  renderUI({
    req(input$portifolio_file$datapath)
    selectInput('stock', 'Stocks', unique(portifolio()$symbol))
  })
  
  
  # Requisicao  -------------------------------------------------------------
  
  stocks <-
    reactive({
      req(input$portifolio_file)
      
      first_day_year <- Sys.Date() %>% `day<-`(1) %>% `month<-`(1)
      
      request <- tryCatch({
        map_df(unique(portifolio()$symbol),
               ~tq_get(.x, get = "stock.prices", from = first_day_year))  
      }, error = function(e){
        Sys.sleep(2)
        map_df(unique(portifolio()$symbol),
               ~tq_get(.x, get = "stock.prices", from = first_day_year))  
      })
      
    })
  
  # Selecionar acao ---------------------------------------------------------
  
  output$plot1 <- renderHighchart({
    req(input$portifolio_file)
    
    stocks() %>% 
      filter(symbol == input$stock) %>%
      timetk::tk_xts(date_var = date) %>% 
      highcharter::hchart() 
    
  })
  
  # Tabela financeira -------------------------------------------------------
  
  # converter para tsibble
  tbl_stocks <- reactive({
    req(input$portifolio_file)
    
    stocks() %>%
      as_tsibble(key = symbol, index = date) %>% 
      fill_gaps() %>% 
      tidyr::fill(c(open, high, low, close, volume, adjusted),
                  .direction = "down") 
  })
  
  # obter dados do ultimo dia
  fechamento_ultimo_dia <- 
    reactive({
      req(input$portifolio_file)
      
      tbl_stocks() %>% 
        filter(date == case_when(wday(Sys.Date()) == 7 ~ Sys.Date()-1,
                                 wday(Sys.Date()) == 1 ~ Sys.Date()-2,
                                 T ~ Sys.Date())) %>% 
        select(symbol, cot_atual = close)
      
    })
  
  # Criar tabela financeita
  tab_financeira <- 
    reactive({
      left_join(portifolio(), fechamento_ultimo_dia()) %>% 
        select(date, everything()) %>% 
        mutate(cot_atual = if_else(symbol == "BTC-USD",
                                   cot_atual * quantmod::getQuote("USDBRL=X")[1,"Open"], 
                                   cot_atual) ) %>% 
        mutate(vol_ini = cot_ini * qtd,
               vol_atual = cot_atual * qtd,
               ganho_perda = vol_atual - vol_ini,
               resultado_bruto = round(ganho_perda / vol_ini * 100, 2)) %>% 
        select(symbol, cot_ini, qtd, vol_ini, cot_atual, qtd, vol_atual, 
               ganho_perda, resultado_bruto) 
      
    })
  
  # Tabela financeira
  output$tab_financeira <- function(){
    req(input$portifolio_file)
    
    tab_financeira() %>%
      mutate(
        cot_ini = moeda_real(cot_ini),
        cot_atual = moeda_real(cot_atual),
        vol_ini = moeda_real(vol_ini),
        vol_atual = moeda_real(vol_atual),
        qtd = round(qtd,4),
        ` ` = ifelse(ganho_perda > 0,"\u2713", "\u2718") ,
        cot_atual = cell_spec(cot_atual, "html", color = "blue"),
        ganho_perda = cell_spec(moeda_real(ganho_perda), "html",
                                color = ifelse(ganho_perda > 0, 
                                               "green", "red")),
        resultado_bruto = cell_spec(porcentagem(resultado_bruto), "html",
                                    color = ifelse(resultado_bruto > 0, 
                                                   "green", "red"))) %>% 
      `colnames<-`(c("Ativo", "Cotação inicio", "Quantidade",
                     "Volume Inicio", "Cotação atual", "Voluma atual",
                     "Ganho/Perda", "Resutado Bruto", "Status")) %>% 
      kable(format = "html", escape = F) %>%
      kable_styling(c("bordered", "hover", "responsive"), 
                    full_width = T, font_size = 12) %>%
      add_header_above(c(" ", "Montagem" = 3,
                         "Desmontagem / Atual" = 2, "Resultado" = 3))
  }
  
  # Download exemplo de input -----------------------------------------------
  
  output$input_test <- downloadHandler(
    filename = function() {
      "input_test.txt"
    },
    content = function(con) {
      read.csv("inst/app/www/input_test.txt") %>% write.csv(con, row.names = F)
    }
  )
  
}
