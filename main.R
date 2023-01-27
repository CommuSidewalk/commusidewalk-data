library(tidyverse)

scripts <- list.files("./src", full.names = TRUE)

# the |> flag is called base R pipe
# while %>% is called magrittr
scripts |>
  sort() |>
  str_subset('\\d\\_.*$') |>
  walk(source)