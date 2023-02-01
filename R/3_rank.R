library(dplyr)

load('./data/2.RData')
load('./data/1.RData')

source('./R/rank_lookup.R')

df <- df2_with_list

# convert columns to factor (finite set)
col_factor <-
  c('sidewalk', 'protective', 'wheelchair', 'walkRisk', 'riskRate')
df <- mutate(df, across(col_factor, \(x) factor(unlist(x))))


# convert to score based on lookup table
convert_score <- function(df, algo) {
  if (algo == 'a1') {
    lookup <- a1_lookup
    lookup_multi <- a1_lookup_multi
  } else if (algo == 'b1') {
    lookup <- b1_lookup
    lookup_multi <- b1_lookup_multi
  } else if (algo == 'c1') {
    lookup <- c1_lookup
    lookup_multi <- c1_lookup_multi
  }

  for (col in names(lookup)) {
    df[[col]] <- sapply(df[[col]], \(x) {
      value <- lookup[[col]][[as.character(x)]]
      if (length(value) == 0) {
        return <- 0
      } else {
        return <- value
      }
    })
  }

  # for all multi columns
  # for (col in names(lookup_multi)) {
  #   df[[col]] <- sapply(df[[col]], \(x) {
  #     if (!is.null(x)) {
  #       return <-
  #         sapply(x, \(y) lookup_multi[[col]][[y]]) |>
  #         unlist() |>
  #         sum()
  #     } else {
  #       return <- 1
  #     }
  #   })
  # }

  find_small <- TRUE
  df$occupation <- sapply(df$occupation, \(x) {
    if (!is.null(x)) {
      vec <-
        sapply(x, \(y) lookup_multi$occupation[[as.character(y)]]) |> unlist(use.names = FALSE)
      if (is.null(vec)) {
        return <- lookup_multi$occupation$empty
      } else {
        if (find_small) {
          return <- min(vec)
        } else {
          return <- max(vec)
        }
      }
    } else {
      return <- lookup_multi$occupation$empty
    }
  })
  return <- df
}

# remove this column
df$mapName <- NULL

a1 <- function(x) {
  if (x$sidewalk == 0) {
    v <- 0
  } else {
    v <- x$occupation
  }
  rank <-
    0.2 * (x$sidewalk * x$protective * x$wheelchair) +
    0.2 * v + 0.6 * x$walkRisk
  return <- rank * 10
}
b1 <- function(x) {
  if (x$sidewalk == 0) {
    v <- 1
  } else {
    v <- x$occupation
  }
  rank <-
    (0.5 * x$protective) + (0.5 * x$wheelchair) - v - x$walkRisk
  if (rank < -1) {
    rank <- -1
  }
  return <- rank * 10
}
c1 <- function(x) {
  if (x$sidewalk == 0) {
    v <- 0
  } else {
    v <- x$occupation
  }
  rank <-
    x$sidewalk * x$protective * x$wheelchair * v * x$walkRisk
  return <- rank * 10
}

# backup current df
df3_score <- df
df3 <- df

# append rank columns
df <- df2
df$rankA1 <- df3 |>
  convert_score('a1') |>
  apply(1, a1) |>
  as.numeric()
df$rankB1 <- df3 |>
  convert_score('b1') |>
  apply(1, b1) |>
  as.numeric()
df$rankC1 <- df3 |>
  convert_score('c1') |>
  apply(1, c1) |>
  as.numeric()

current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./output/', current_time, '_rank.csv', sep = '')
write.csv(
  df,
  file = fname,
  fileEncoding = 'UTF-8',
  na = '',
  row.names = FALSE
)

df3 <- df
save(df3_score, df3, file = './data/3.RData')


print('3_rank.R done :)')
