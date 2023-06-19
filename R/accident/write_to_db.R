library(DBI)

source("R/utils/get_db_conn.R")

conn <- get_db_conn(dbname = "accident")

# util function that drop accidents table
drop_table <- function () {
  dbSendQuery(conn, "DROP TABLE accidents")
}

# create table "accidents"
sql <- readLines('R/accident/schema.sql')
dbSendQuery(conn, paste(sql, collapse = "\n"))

# write table "accidents"
DT <- fread("output/accident.csv")
dbAppendTable(conn, "accidents", DT)

# write table "field_name_mapping"
field_name_mapping <- fread("R/accident/field_name_mapping.txt")
dbWriteTable(conn, "field_name_mapping", field_name_mapping)
