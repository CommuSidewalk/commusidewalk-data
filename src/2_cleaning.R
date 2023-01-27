# load df as global variable
load('./data/1.RData')

# 謎之quest id xfnxjyq5rrk，或許是編輯表單後遺留下來的，先刪掉
df_img$formReply$xfnxjyq5rrk <- NULL

# rename formReply to rational column names --------------
form <- df_img$formReply
item <- lst_info$form$itemArr # has quest, id
indices <- match(names(form), item$id)
names(form) <- item$quest[indices]
df_img$formReply <- form
# end ----------------------------------------------------



# simplify form reply i.e. remove `value` ----------------
myUnlist <- function(x) {
  l <- unlist(x, recursive = FALSE, use.names = FALSE)
  if (is.list(l)) {
    x <- sapply(l, function(y)
      paste(y, collapse = '|')) # 使用|當作checkbox的多選分隔符號
  } else {
    x <- l
  }
}
form <- df_img$formReply
form <- sapply(form, myUnlist)

# remove column version
df_img$formReply <- NULL
df_img <- cbind(df_img, form)
# keep formReply version
# df_img$formReply <- form
# end ----------------------------------------------------


# rename other columns -----------------------------------
df <- df_img
df$"標註者" <- df$annotation$user


annotateClean <- function(x) {
  if (is.list(x)) {
    indices <- x$value == 'true'
    return <- paste(x[indices, 'name'], collapse = '|')
  } else {
    return <- NA
  }
}

df$"標註結果" <- sapply(df$annotation$annotation, annotateClean)


lst_user <- sapply(df$verification, function(x) {
  if (length(x) != 0) {
    return <- paste(x$user, collapse = '|')
  } else {
    return <- NA
  }
})
lst_agree <- sapply(df$verification, function(x) {
  if (length(x) != 0) {
    return <- paste(x$agree, collapse = '|')
  } else {
    return <- NA
  }
})
df <- cbind(df, data.frame("驗證者" = lst_user, "驗證同意值" = lst_agree))

df$createdAt <- as.POSIXct(df$createdAt)
df$updatedAt <- as.POSIXct(df$updatedAt)

# delete useless columns
df$annotation <- NULL
df$verification <- NULL

# end ----------------------------------------------------


# create default filename based on timestamp
current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./data/', current_time, '.csv', sep = '')
write.csv(df,
          file = fname,
          fileEncoding = 'UTF-8')


save(df, file = './data/2.RData')