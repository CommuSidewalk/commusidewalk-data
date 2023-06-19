library(jsonlite)
library(data.table)

fname <- "data/accident/NPA_TMA1_JSON.json"
df <- jsonlite::fromJSON(fname)
df <- df$result$records
DT <- as.data.table(df)

datetime <- as.POSIXct(paste(DT[, 發生日期], DT[, 發生時間]), format = "%Y%m%d %H%M%S")

DT[, "發生時間" := datetime]
DT[, c("發生年度", "發生月份", "發生日期") := NULL]
DT[, "事件編號" := .GRP, by = c("發生時間", "經度", "緯度")]

setcolorder(DT, c("事件編號", "發生時間"))

print("欄位清單：")
print(colnames(DT))

fwrite(DT, file = "output/accident_zh-tw.csv")

mapping <- fread("R/accident/field_name_mapping.txt")
name_map <- setNames(mapping$english_name, mapping$chinese_name)
setnames(DT, names(DT), name_map[names(DT)])

colnames(DT)
fwrite(DT, file = "output/accident.csv")

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
