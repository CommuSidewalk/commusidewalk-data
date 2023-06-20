library(DBI)

source("R/utils/get_db_conn.R")

conn <- get_db_conn(dbname = "accident")

# CONSTANT
OUTPUT_PATH <- file.path('output', 'accident')

# util function that drop accidents table
drop_table <- function (sure = FALSE) {
  if (sure) {
    dbSendQuery(conn, "DROP TABLE detail_events CASCADE")
    dbSendQuery(conn, "DROP TABLE general_events CASCADE")
  }
}
drop_table(F);

write_table <- function (name, DT = NULL) {
  if (is.null(DT)) {
    DT <- fread(file.path(OUTPUT_PATH, paste0(name, '.csv')))
  }
  dbAppendTable(conn, name, DT)
}

# create table
if (!dbExistsTable(conn, "general_events")) {
  sql <- readLines('R/accident/create_general_events.sql')
  dbSendQuery(conn, paste(sql, collapse = "\n"))
}
if (!dbExistsTable(conn, "detail_events")) {
  sql <- readLines('R/accident/create_detail_events.sql')
  dbSendQuery(conn, paste(sql, collapse = "\n"))
}

# write table "field_name_mapping"
if (!dbExistsTable(conn, "field_name_mapping")) {
  field_name_mapping <- fread("R/accident/field_name_mapping.txt")
  dbWriteTable(conn, "field_name_mapping", field_name_mapping)
}

write_table("general_events")
write_table("detail_events")
