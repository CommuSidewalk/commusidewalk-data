#' Rename A1 or A2 table columns from zh-TW to English
#'
#' `cols_zh_to_eng` will rename columns using
#' `R/accident/field_name_mapping.txt` and return copied DT
cols_zh_to_eng <- function (DT) {
  dt <- copy(DT)
  mapping <- fread("R/accident/field_name_mapping.txt")
  name_map <- setNames(mapping$english_name, mapping$chinese_name)
  setnames(dt, names(dt), name_map[names(dt)])
  return (dt)
}
