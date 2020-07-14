## code to prepare `input_exemplo` dataset goes here

input_exemplo <- dplyr::tribble(
  ~symbol, ~cot_ini, ~qtd,
  "TUPY3.SA", 24.42, 200,
  "ELET3.SA", 19.73, 150,
  "BTC-USD", 31747.38, 0.032,
)

usethis::use_data(input_exemplo)


