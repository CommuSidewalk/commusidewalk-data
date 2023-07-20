library(DBI)

source("R/utils/get_db_conn.R")

conn <- get_db_conn(dbname = "accident")
SQL_PATH <- file.path("R/accident/sql")

# CONSTANT
OUTPUT_PATH <- file.path('output', 'accident')

# util function that drop accidents table
drop_table <- function () {
  if (dbExistsTable(conn, "general_events") & dbExistsTable(conn, "detail_events")) {
    dbSendQuery(conn, "DROP TABLE detail_events CASCADE;")
    dbSendQuery(conn, "DROP TABLE general_events CASCADE;")
  }
}

delete_table <- function () {
  if (dbExistsTable(conn, "general_events") & dbExistsTable(conn, "detail_events")) {
    print("delete general_events table and detail_events table...")
    dbSendQuery(conn, "DELETE FROM detail_events;")
    dbSendQuery(conn, "DELETE FROM general_events;")
    print("done!")
  }
}

write_table <- function (name, DT = NULL) {
  print("writing new data into table...")
  if (is.null(DT)) {
    DT <- fread(file.path(OUTPUT_PATH, paste0(name, '.csv')))
  }
  dbAppendTable(conn, name, DT)
  print("done!")
}

read_SQL <- function (fname) {
  sql <- readLines(file.path(SQL_PATH, paste0(fname, ".sql")))
  sql <- paste(sql, collapse = "\n")
  sql
}

# create table
if (!dbExistsTable(conn, "general_events")) {
  # table
  dbSendQuery(conn, read_SQL("create_general_events"))
  # view
  dbSendQuery(conn, read_SQL("create_general_events_view"))
}
if (!dbExistsTable(conn, "detail_events")) {
  # table
  dbSendQuery(conn, read_SQL("create_detail_events"))
  # view
  dbSendQuery(conn, read_SQL("create_detail_events_view"))
}

# write table "field_name_mapping"
if (!dbExistsTable(conn, "field_name_mapping")) {
  field_name_mapping <- fread("R/accident/field_name_mapping.txt")
  dbWriteTable(conn, "field_name_mapping", field_name_mapping)
}

write_to_db <- function () {
  write_table("general_events")
  write_table("detail_events")
}
