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

# remove column version
df$formReply <- NULL
df <- cbind(df, form)
# keep formReply version
# df$formReply <- form
# end ----------------------------------------------------


# rename other columns -----------------------------------
df$annotation_user <- df$annotation$user


annotateClean <- function(x) {
  if (is.list(x)) {
    indices <- x$value == 'true'
    return <- myPaste(x[indices, 'name'])
  } else {
    return <- NA
  }
}

df$annotation_result <-
  sapply(df$annotation$annotation, annotateClean)


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
df <-
  cbind(df,
        data.frame(verification_user = lst_user, verification_agree = lst_agree))


# delete useless columns
df$annotation <- NULL
df$verification <- NULL

# end ----------------------------------------------------


# invert row order (to asc)
df <- df[order(nrow(df):1), ]

df <- df %>% rename(
  '上傳者' = 'uploader',
  '標註者' = 'annotation_user',
  '標籤' = 'annotation_result',
  '驗證者' = 'verification_user',
  '驗證同意值' = 'verification_agree',
  '原始總寬度－是否夠寬讓輪椅通行' = '原始總寬度－是否夠寬讓輪椅通行',
  '實際行走路徑中會碰到的最大動態風險' = '行人被迫實際行走路徑中會碰到的最大動態風險',
)

empty_cols <- c("imageName",
                "評分a1",
                "評分b1",
                "評分c1",
                "思源地圖類別-無須填寫",
                "imageUrl")

df[, empty_cols] <- NA

col_order <-
  c(
    "imageName",
    "lat",
    "lng",
    "dataTime",
    "remark",
    "上傳者",
    "標註者",
    "驗證者",
    "標籤",
    "createdAt",
    "updatedAt",
    "評分a1",
    "評分b1",
    "評分c1",
    "原本有無設置人行空間",
    "保護性",
    "原始總寬度－是否夠寬讓輪椅通行",
    "佔用情形(多選)-導致兩人交會需停讓或淨寬<1.5米",
    "實際行走路徑中會碰到的最大動態風險",
    "承受上題風險的頻率",
    "使用目的",
    "思源地圖類別-無須填寫",
    "思源地圖名稱-無須填寫",
    "imageUrl"
  )
df <- df[, col_order]



# create default filename based on timestamp
current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./data/', current_time, '.csv', sep = '')
write.csv(
  df,
  file = fname,
  fileEncoding = 'UTF-8',
  na = '',
  row.names = FALSE
)


save(df, file = './data/2.RData')