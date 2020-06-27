
# Carregar pacotes:
library(tidyverse)
library(tidyquant)
library(quantmod)
library(tsibble)
library(knitr)
library(kableExtra)
library(timetk)
library(highcharter)
library(tidyr)

porcentagem <- function(x){paste0(round(x,2), "%")} 
moeda_real <- function(x){
  paste0("R\\$", format(x, big.mark = ".", decimal.mark = ",", 
                        nsmall = 2, digits = 2))}

# Acoes do portfolio 
portifolio <- tribble(
  ~symbol, ~cot_ini, ~qtd,
  "PETR4.SA" , 13, 100,
  "GOAU4.SA" , 7.12, 100,
  "MGLU3.SA" , 40.5, 30,
  "TOTS3.SA" , 22.91, 50,
  "CSMG3.SA" , 38.23, 15,
  "ITSA4.SA" , 11.06, 110,
  "PTBL3.SA" , 4.66, 100,
  "BTC-USD"  , 44470, 0.0112,
  "BTC-USD"  , 28000, 0.0036,
  "BTC-USD"  , 35000, 0.002,
  "BTC-USD"  , 27748, 0.01074,
  "BTC-USD"  , 49499.37, 0.0101
)

# request data
stocks <-map_df(unique(portifolio$symbol),
                ~tq_get(.x, get = "stock.prices", from = "2019-01-01"))

dolar2real <- quantmod::getQuote("USDBRL=X")[1,"Open"]

# Grafico -----------------------------------------------------------------
i = 8
stocks %>% 
  filter(symbol == portifolio[i]) %>%
  timetk::tk_xts(date_var = date) %>% 
  highcharter::hchart()

# Analitycs ---------------------------------------------------------------

# arrumar:
tbl_stocks <- 
  stocks %>%
  as_tsibble(key = symbol, index = date) %>% 
  fill_gaps() %>% 
  tidyr::fill(c(open, high, low, close, volume, adjusted),
              .direction = "down") 

# obter dados do ultimo dia
fechamento_ultimo_dia <- 
  tbl_stocks %>% 
  filter(date == case_when(wday(Sys.Date()) == 7 ~ Sys.Date()-1,
                           wday(Sys.Date()) == 1 ~ Sys.Date()-2,
                           T ~ Sys.Date())) %>% 
  select(symbol, cot_atual = close)

# Criar tabela financeita
tab_financeira <- 
  left_join(portifolio, fechamento_ultimo_dia) %>% 
  select(date, everything()) %>% 
  mutate(cot_atual = if_else(symbol == "BTC-USD",
                             cot_atual * dolar2real, 
                             cot_atual) ) %>% 
  mutate(vol_ini = cot_ini * qtd,
         vol_atual = cot_atual * qtd,
         ganho_perda = vol_atual - vol_ini,
         resultado_bruto = round(ganho_perda / vol_ini * 100, 2)) %>% 
  select(symbol, cot_ini, qtd, vol_ini, cot_atual, qtd, vol_atual, 
         ganho_perda, resultado_bruto) 

tab_financeira %>%
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
  kable(format = "html", escape = F) %>%
  kable_styling(c("striped", "bordered", "hover", "responsive"), 
                full_width = T, font_size = 12) %>%
  add_header_above(c(" ", "Montagem" = 3,
                     "Desmontagem / Atual" = 2, "Resultado" = 3))
  