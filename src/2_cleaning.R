library(dplyr)

# load df as global variable
load('./data/1.RData')

df <- df_img

# 謎之quest id xfnxjyq5rrk，或許是編輯表單後遺留下來的，先刪掉
df$formReply$xfnxjyq5rrk <- NULL


# rename formReply to rational column names --------------
form <- df$formReply
item <- lst_info$form$itemArr # has quest, id
indices <- match(names(form), item$id)
names(form) <- item$quest[indices]
df$formReply <- form
# end ----------------------------------------------------

myPaste <- function(x) {
  return <- paste(x, collapse = '|') # use | as deliminator
}

# simplify form reply i.e. remove `value` ----------------
myUnlist <- function(x) {
  l <- unlist(x, recursive = FALSE, use.names = FALSE)
  if (is.list(l)) {
    x <- sapply(l, myPaste)
  } else {
    x <- l
  }
}

form <- df$formReply
form <- sapply(form, myUnlist)

# df2 contains will keep multivalue in one data point
df2 <- df
form2 <-
  sapply(df$formReply, \(x) unlist(x, recursive = FALSE, use.names = FALSE))
df2 <- cbind(df, form2)
df2$formReply <- NULL
df2$marker <- df$annotation$user
df2$label <- df$annotation$annotation
df2$annotation <- NULL
df2 <- df2 |> rename(
  'id' = '_id',
  # '驗證同意值' = 'verification_agree',
  'sidewalk' = '原本有無設置人行空間',
  'protective' = '保護性',
  'wheelchair' = '原始總寬度－是否夠寬讓輪椅通行',
  'occupation' = '佔用情形(多選)-導致兩人交會需停讓或淨寬<1.5米',
  'walkRisk' = '行人被迫實際行走路徑中會碰到的最大動態風險',
  'riskRate' = '承受上題風險的頻率',
  'purpose' = '使用目的',
  # 5s59fsp6kql doesn't exist in list-image api
  # 'mapType' = '思源地圖類別-無須填寫',
  'mapName' = '思源地圖名稱-無須填寫',
)
# end df2 ------------------------------------------------

# remove column version
df$formReply <- NULL
df <- cbind(df, form)
# end ----------------------------------------------------


# rename other columns -----------------------------------
df$annotation_user <- df$annotation$user
df$annotation_result <- df$annotation$annotation |>
  sapply(\(x) {
    if (is.list(x)) {
      indices <- x$value == 'true'
      return <- myPaste(x[indices, 'name'])
    } else {
      return <- NA
    }
  })


lst_user <- sapply(df$verification, function(x) {
  if (length(x) != 0) {
    return <- myPaste(x$user)
  } else {
    return <- NA
  }
})
lst_agree <- sapply(df$verification, function(x) {
  if (length(x) != 0) {
    return <- myPaste(x$agree)
  } else {
    return <- NA
  }
})
df <- cbind(df,
            data.frame(verification_user = lst_user,
                       verification_agree = lst_agree))


# delete useless columns
df$annotation <- NULL
df$verification <- NULL

# end ----------------------------------------------------


# invert row order (to asc)
df <- df[order(nrow(df):1),]



# generate `imgName`, `imageUrl` column -----------------------------------
id2ImageUrl <- function(image_id) {
  return <-
    paste(
      'https://commutag.agawork.tw/static/upload/dataset/',
      dataset,
      '/image/',
      image_id,
      '.jpg',
      sep = ''
    )
}

df$imgUrl <- sapply(df$`_id`, id2ImageUrl)
df$imgName <- 1:nrow(df)
# end --------------------------------------------------------

df <- df |> rename(
  'id' = '_id',
  'marker' = 'annotation_user',
  'label' = 'annotation_result',
  'checker' = 'verification_user',
  # '驗證同意值' = 'verification_agree',
  'sidewalk' = '原本有無設置人行空間',
  'protective' = '保護性',
  'wheelchair' = '原始總寬度－是否夠寬讓輪椅通行',
  'occupation' = '佔用情形(多選)-導致兩人交會需停讓或淨寬<1.5米',
  'walkRisk' = '行人被迫實際行走路徑中會碰到的最大動態風險',
  'riskRate' = '承受上題風險的頻率',
  'purpose' = '使用目的',
  # 5s59fsp6kql doesn't exist in list-image api
  # 'mapType' = '思源地圖類別-無須填寫',
  'mapName' = '思源地圖名稱-無須填寫',
)

col_order <-
  c(
    "imgName",
    "id",
    "lat",
    "lng",
    "dataTime",
    "remark",
    "uploader",
    "marker",
    "checker",
    "label",
    "createdAt",
    "updatedAt",
    "sidewalk",
    "protective",
    "wheelchair",
    "occupation",
    "walkRisk",
    "riskRate",
    "purpose",
    # "mapType",
    "mapName",
    "imgUrl"
  )
df <- df[, col_order]



# create default filename based on timestamp
current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./output/', current_time, '.csv', sep = '')
write.csv(
  df,
  file = fname,
  fileEncoding = 'UTF-8',
  na = '',
  row.names = FALSE
)

df2_with_list <- df2
df2 <- df

save(df2, df2_with_list, file = './data/2.RData')

print('2_cleaning.R done :)')

