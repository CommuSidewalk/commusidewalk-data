library(jsonlite)

# create /data folder
dir.create('data', showWarnings = FALSE)

# create default filename based on timestamp
current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./data/', current_time, '.csv', sep = '')


# save commutag to csv file ---------------------------------------
dataset <- '63528cc34f042e88cc951433'
all_link <-
  'https://commutag.agawork.tw/dataset/list-image?all=1&dataset='
limit_link <-
  'https://commutag.agawork.tw/dataset/list-image?dataset='


is_limit = TRUE
if (is_limit) {
  str_url <- paste(limit_link, dataset, sep = '')
  json <- jsonlite::fromJSON(str_url)
  df_img <- json$data$images
} else {
  str_url <- paste(all_link, dataset, sep = '')
  json <- jsonlite::fromJSON(str_url)
  df_img <- json$data
}

write.csv(df_img, file = fname)
# save end ----------------------------------------------------------


# save into df_img and lst_info into RData --------------------------
str_url <-
  paste('https://commutag.agawork.tw/dataset/view-dataset?id=',
        dataset,
        sep = '')
json <- jsonlite::fromJSON(str_url)
lst_info <- json$data
save(df_img, lst_info, file = './data/raw.RData')
# end ---------------------------------------------------------------