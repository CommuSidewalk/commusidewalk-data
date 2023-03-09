library(RPostgres)
library(DBI)
library(magrittr)
library(dplyr)
library(dotenv)

source('R/utils/village_shp_downloader.R')

df <- df4

conn <- DBI::dbConnect(
  drv = RPostgres::Postgres(),
  dbname = Sys.getenv('PGDATABASE'),
  host = Sys.getenv('PGHOST'),
  user = Sys.getenv('PGUSER'),
  password = Sys.getenv('PGPASSWORD'),
  # endpoint config: https://neon.tech/docs/connect/connectivity-issues#a-pass-the-endpoint-id-as-an-option
  options = paste('project=', Sys.getenv('PGENDPOINT'), sep = ""),
  sslmode = 'require'
)

# write df4 to DB
dbWriteTable(conn,
             "info_l2",
             df,
             # this will overwrite existing table
             overwrite = TRUE,
             row.names = FALSE)

print('5_write_to_db done :)')
