library(data.table)
source("R/accident/cols_zh_to_eng.R")
source("R/accident/get_db_conn.R")

# constant ---------------------------------------------------------------------
OUTPUT_PATH <- file.path("output", "accident")
DATA_PATH <- file.path("data", "accident")
# ------------------------------------------------------------------------------

# 每個事件都一樣
GEN_EV_COLS <- c(
  "發生日期",
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
  "死亡人數",
  "受傷人數"
)

dir.create(OUTPUT_PATH, showWarnings = FALSE)

# ------------------------------------------------------------------------------


read_and_merge_csv <- function (data_dir) {
  # 照順序結合A1、A2一月、A2二月...等等
  for (f in sort(list.files(data_dir, full.names = TRUE))) {
    dt <- fread(f)
    dt <- head(dt, -2) # 移除最後兩行的資料提供日期、事故類別
    print(f)
    if (!exists("DT")) {
      DT <- dt
    } else {
      DT <- rbindlist(list(DT, dt), use.names = TRUE, fill = TRUE)
    }
  }
  DT
}

clean_and_transform <- function (DT, gen_ev_padding) {
  # 結合日期與時間 -> POSIXct
  # A2資料的時間格式未知，不是%H%%M%S，因此改為date only
  # datetime <-
  #   as.POSIXct(paste(DT[, 發生日期], DT[, 發生時間]), format = "%Y%m%d %H%M%S")
  date <- as.Date(as.character(DT[, 發生日期]), format = "%Y%m%d")
  DT[, "發生日期" := date]
  DT[, c("發生年度", "發生月份", "發生時間") := NULL]

  # 根據時間和經緯度設定「事件id」
  #   一筆資料是以「當事人」為角度，
  #   然而缺乏當事人之間的聯繫，因此加入事件編號方便識別
  DT[, "事件編號" := .GRP, by = c("發生日期", "經度", "緯度", "發生地點")]
  setcolorder(DT, c("事件編號", "發生日期"))


  # 移除同一事件中重複的當事人
  DT[, dup_rows := duplicated(當事者順位), by = "事件編號"]
  DT <- DT[dup_rows == FALSE]
  DT[, dup_rows := NULL]


  DT[, "死亡人數" := sub("^死亡(\\d+);受傷(\\d+)$", "\\1", 死亡受傷人數)]
  DT[, "受傷人數" := sub("^死亡(\\d+);受傷(\\d+)$", "\\2", 死亡受傷人數)]
  DT[, "死亡受傷人數" := NULL]

  if (gen_ev_padding != 0) {
    last_rown_duplicates_event <- tail(which(DT[, 事件編號 == gen_ev_padding]), 1)
    DT <- DT[last_rown_duplicates_event + 1:.N]
  }

  DT
}

write_cleaned_data_to_csv <- function (DT, output_dir) {
  ev_gen <- unique(DT, by = "事件編號")
  ev_gen <- ev_gen[, append("事件編號", GEN_EV_COLS), with = FALSE]
  ev_detail <- DT[,-..GEN_EV_COLS]

  # 輸出中文版csv
  fwrite(DT, file = file.path(output_dir, "accidents_zh-TW.csv"))
  fwrite(ev_gen, file = file.path(output_dir, "general_events_zh-TW.csv"))
  fwrite(ev_detail, file = file.path(output_dir, "detail_events_zh-TW.csv"))

  # 輸出英文版csv
  DT_en <- cols_zh_to_eng(DT)
  ev_gen_en <- cols_zh_to_eng(ev_gen)
  ev_detail_en <- cols_zh_to_eng(ev_detail)
  fwrite(DT_en, file = file.path(output_dir, "accidents.csv"))
  fwrite(ev_gen_en, file = file.path(output_dir, "general_events.csv"))
  fwrite(ev_detail_en, file = file.path(output_dir, "detail_events.csv"))
}

# 現在想想他不是padding，而是最後一個event_id
get_padding <- function() {
  # general_events_padding
  # event_id會由此開始 +1, e.g. GENERAL_EVENT_PADDING <- 10,
  # 那本次的DT event_id就會從11開始遞增
  # get latest event_id from DB
  conn <- get_db_conn(dbname = "accident")
  result <-
    dbGetQuery(conn,
               "SELECT event_id FROM general_events ORDER BY event_id DESC LIMIT 1;")

  if (length(result$event_id) == 0) {
    padding <- 0
  } else {
    padding <- result$event_id[1]
  }
}

clean_and_write_to_csv <- function (auto_padding = FALSE) {
  print("start clean and write to csv...")
  if (auto_padding) {
    gen_ev_padding <- get_padding()
  } else{
    gen_ev_padding <- 0
  }
  DT <- read_and_merge_csv(DATA_PATH)
  cleaned_DT <- clean_and_transform(DT, gen_ev_padding)
  write_cleaned_data_to_csv(cleaned_DT, OUTPUT_PATH)
  print("done!")
}
