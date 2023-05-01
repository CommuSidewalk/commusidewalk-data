library(stringr)

# run all number prefix files inside R folder in order.
runAll <- function() {
  scripts <- list.files("./R", full.names = TRUE)
  # the |> flag is called base R pipe
  # while %>% is called magrittr
  scripts |>
    sort() |>
    stringr::str_subset('\\d\\_.*$') |>
    sapply(source)
}

