# 更新資料的邏輯尚未完成
# 尚未移除「資料庫已有的資料」
source("R/accident/download_NPA_TM_data.R")
source("R/accident/clean_and_write_to_csv.R")
source("R/accident/write_to_db.R")

download_NPA_TM_data()
delete_table()
clean_and_write_to_csv()
write_to_db()
