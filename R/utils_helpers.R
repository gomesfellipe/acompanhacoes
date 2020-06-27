

porcentagem <- function(x) {
  paste0(round(x, 2), "%")
}

moeda_real <- function(x) {
  paste0("R\\$", format(x,
    big.mark = ".", decimal.mark = ",",
    nsmall = 2, digits = 2
  ))
}
