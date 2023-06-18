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

fwrite(DT, file = "output/accident.csv")
