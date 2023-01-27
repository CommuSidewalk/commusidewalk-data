# load df as global variable
load('./data/1.RData')

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

cleaned_img <- df_img

# 先不管verification，如果沒有會出現Error in utils::write.table(cleaned_img, file = fname, fileEncoding = "UTF-8",  :
# unimplemented type 'list' in 'EncodeElement'，以後再說
cleaned_img <-
  apply(df, which(names(df) == 'verification'), as.character)

# end ----------------------------------------------------


# create default filename based on timestamp
current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./data/', current_time, '.csv', sep = '')
write.csv(cleaned_img,
          file = fname,
          fileEncoding = 'UTF-8')


save(df_img, file = './data/2.RData')