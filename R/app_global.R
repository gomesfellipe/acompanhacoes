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