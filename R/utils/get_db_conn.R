library(RPostgres)
library(DBI)
library(dotenv)

get_db_conn <- function (dbname = Sys.getenv("PGDATABASE")) {
   DBI::dbConnect(
    drv = RPostgres::Postgres(),
    dbname = dbname,
    host = Sys.getenv('PGHOST'),
    user = Sys.getenv('PGUSER'),
    password = Sys.getenv('PGPASSWORD'),
    # endpoint config: https://neon.tech/docs/connect/connectivity-issues#a-pass-the-endpoint-id-as-an-option
    options = paste('project=', Sys.getenv('PGENDPOINT'), sep = ""),
    sslmode = 'require'
  )
}
