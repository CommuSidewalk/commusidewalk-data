library(jsonlite)
library(data.table)

# constant
OUTPUT_PATH <- file.path("output", "accident")
# event_id會由此開始 +1, e.g. GENERAL_EVENT_PADDING <- 10, 那本次的DT event_id就會從11開始遞增
GENERAL_EVENT_PADDING <- 0
dir.create(OUTPUT_PATH, showWarnings = FALSE)

#' Rename data.table columns from zh-TW to English
#'
#' `cols_zh_to_eng` will rename columns using
#' `R/accident/field_name_mapping.txt`.
cols_zh_to_eng <- function (DT) {
  mapping <- fread("R/accident/field_name_mapping.txt")
  name_map <- setNames(mapping$english_name, mapping$chinese_name)
  setnames(DT, names(DT), name_map[names(DT)])
}

fname <- "data/accident/NPA_TMA1_JSON.json"
df <- jsonlite::fromJSON(fname)
df <- df$result$records
DT <- as.data.table(df)

# 結合日期與時間 -> POSIXct
datetime <-
  as.POSIXct(paste(DT[, 發生日期], DT[, 發生時間]), format = "%Y%m%d %H%M%S")
DT[, "發生時間" := datetime]
DT[, c("發生年度", "發生月份", "發生日期") := NULL]

# 根據時間和經緯度設定「事件id」
DT[, "事件編號" := GENERAL_EVENT_PADDING + .GRP, by = c("發生時間", "經度", "緯度")]
setcolorder(DT, c("事件編號", "發生時間"))


# 每個事件都一樣
general_event_cols <- c(
  "發生時間",
  "經度",
  "緯度",
  "事故類別名稱",
  "處理單位名稱警局層",
  "發生地點",
  "天候名稱",
  "光線名稱",
  "道路類別-第1當事者-名稱",
  "速限-第1當事者",
  "道路型態大類別名稱",
  "道路型態子類別名稱",
  "事故位置大類別名稱",
  "事故位置子類別名稱",
  "路面狀況-路面鋪裝名稱",
  "路面狀況-路面狀態名稱",
  "路面狀況-路面缺陷名稱",
  "道路障礙-障礙物名稱",
  "道路障礙-視距品質名稱",
  "道路障礙-視距名稱",
  "號誌-號誌種類名稱",
  "號誌-號誌動作名稱",
  "車道劃分設施-分向設施大類別名稱",
  "車道劃分設施-分向設施子類別名稱",
  "車道劃分設施-分道設施-快車道或一般車道間名稱",
  "車道劃分設施-分道設施-快慢車道間名稱",
  "車道劃分設施-分道設施-路面邊線名稱",
  "事故類型及型態大類別名稱",
  "事故類型及型態子類別名稱",
  "肇因研判大類別名稱-主要",
  "肇因研判子類別名稱-主要",
  "死亡受傷人數"
)
ev_gen <- unique(DT, by = general_event_cols)
ev_gen <- ev_gen[, append("事件編號", general_event_cols), with = FALSE]
ev_detail <- DT[,-..general_event_cols]

fwrite(DT, file = file.path(OUTPUT_PATH, "accidents_zh-TW.csv"))
fwrite(ev_gen, file = file.path(OUTPUT_PATH, "general_events_zh-TW.csv"))
fwrite(ev_detail, file = file.path(OUTPUT_PATH, "detail_events_zh-TW.csv"))

# 輸出英文版csv
cols_zh_to_eng(DT)
cols_zh_to_eng(ev_gen)
cols_zh_to_eng(ev_detail)
fwrite(DT, file = file.path(OUTPUT_PATH, "accidents.csv"))
fwrite(ev_gen, file = file.path(OUTPUT_PATH, "general_events.csv"))
fwrite(ev_detail, file = file.path(OUTPUT_PATH, "detail_events.csv"))


# pack_by_colpattern <- function(DT, pattern, pack_colname) {
#   dt <- DT[, .SD, .SDcols = patterns(pattern)]
#   colnames(dt) <- sub(pattern, "", colnames(dt))
#   DT[, (pack_colname) := list(dt=dt)]
#   DT[, grep(pattern, colnames(DT)) := NULL]
# }
#
# pack_by_colpattern(DT, "^路面狀況-", "路面狀況")
# pack_by_colpattern(DT, "^道路障礙-", "道路障礙")
# pack_by_colpattern(DT, "^號誌-", "號誌")
# pack_by_colpattern(DT, "^車道劃分設施-", "車道劃分設施")
# pack_by_colpattern(DT, "^車輛撞擊部位大類別名稱-", "車輛撞擊部位大類別名稱")
# pack_by_colpattern(DT, "^車輛撞擊部位子類別名稱-", "車輛撞擊部位子類別名稱")
# pack_by_colpattern(DT, "^肇因研判大類別名稱-", "肇因研判大類別名稱")
# pack_by_colpattern(DT, "^肇因研判子類別名稱-", "肇因研判子類別名稱")
#
# View(DT)
# mapping <- fread("R/accident/field_name_mapping.txt")
# name_map <- setNames(mapping$english_name, mapping$chinese_name)
# setnames(DT, names(DT), name_map[names(DT)])
#
# colnames(DT)
# fwrite(DT, file = "output/accident.csv")
