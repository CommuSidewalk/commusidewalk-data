library(dplyr)

load('./data/2.RData')
load('./data/1.RData')

df <- df2_with_list

# convert columns to factor (finite set)
col_factor <-
  c('sidewalk', 'protective', 'wheelchair', 'walkRisk', 'riskRate')
df <- df |>
  mutate(across(col_factor, \(x) factor(unlist(x))))

lookup <- list(
  # 原本有無設置人行空間
  sidewalk = list(
    "有設置人行道或騎樓" = 1,
    "沒有設置人行道或騎樓" = 0,
    "有人行道或騎樓" = 1,
    "沒有人行道或騎樓" = 0
  ),
  # 保護性
  protective = list(
    "實體人行道(有實體分隔)" =  1,
    "騎樓" = 1,
    "實體人行道(無實體分隔)" =  0.5,
    "標線人行道(無實體分隔)" =  0.4,
    "標線人行道(有實體分隔)" =  1,
    "實體人行道(有實體分隔)" =  1,
    "沒有人行道或騎樓" = 0
    # "" =  0
  ),
  # 原始寬度
  wheelchair = list(
    "輪椅可以通行（寬於100公分）" =  1,
    "輪椅無法通行（窄於100公分）" =  0.5,
    "沒有人行道或騎樓" = 0
  ),
  # 行人被迫碰到的最大動態風險
  walkRisk = list(
    '無車輛行駛' = 1,
    '有自行車行駛' = 0.8,
    '有機車行駛' = 0.4,
    '有汽車行駛' = 0,
    '無人行道或騎樓' = 0
  )
  # riskRate
)

# when one point has multiple values (list)
lookup_multi <- list(
  occupation = list(
    # "" =  1,
    "無佔用或阻礙" = 1,
    "私人佔用（商家、住家）" =  0.3,
    "公共設施阻礙（機電設備）" =  0.3,
    "公共設施阻礙（樹穴）" =  0.3,
    "公共設施阻礙（有停車格）" =  0.3,
    "私人佔用（臨時停車）" =  0.4,
    "沒有人行道或騎樓" = 0
  )
)

for (col in names(lookup)) {
  df[[col]] <- sapply(df[[col]], \(x) {
    value <- lookup[[col]][[x]]
    if (length(value) == 0) {
      return <- 0
    } else {
      return <- value
    }
  })
}
for (col in names(lookup_multi)) {
  df[[col]] <- sapply(df[[col]], \(x) {
    if (!is.null(x)) {
      return <-
        sapply(x, \(y) lookup_multi[[col]][[y]]) |>
        unlist() |>
        sum()
    } else {
      return <- 1
    }
  })
}

# to fix weird value of mapName NANA
df$mapName <- NA

a1 <- function(x) {
  if (x$sidewalk == 0) {
    # v是什麼？
    v <- 0
  } else {
    v <- x$occupation
  }
  return <-
    0.2 * (x$sidewalk * x$protective * x$wheelchair) +
    0.2 * v + 0.6 * x$walkRisk
}
b1 <- function(x) {
  v <- ifelse(x$sidewalk == 0, 1, 0)
  rank <-
    (0.5 * x$protective) + (0.5 * x$wheelchair) - v - x$walkRisk
  return <- ifelse(rank < -1,-1, rank)
}
c1 <- function(x) {
  if (x$sidewalk == 0) {
    # v是什麼？
    v <- 0
  } else {
    v <- x$occupation
  }
  return <-
    x$sidewalk * x$protective * x$wheelchair * v * x$walkRisk
}

# backup current df
df3 <- df
save(df3, file = './data/3.RData')

# append rank columns
df <- df2
df$rankA1 <- as.numeric(apply(df3, 1, a1))
df$rankB1 <- as.numeric(apply(df3, 1, b1))
df$rankC1 <- as.numeric(apply(df3, 1, c1))

current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./output/', current_time, '_rank.csv', sep = '')
write.csv(
  df,
  file = fname,
  fileEncoding = 'UTF-8',
  na = '',
  row.names = FALSE
)


print('3_rank.R done :)')