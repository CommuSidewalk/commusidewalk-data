library(RPostgres)
library(DBI)
library(magrittr)
library(dplyr)
library(dotenv)

source('R/utils/village_shp_downloader.R')

df <- df4

# connect
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

# load CSV
# current_time <- format(Sys.time(), '%Y%m%d')
# fname <- paste('output/20230308_rank.csv', sep = '')
# fname <- paste('output/', current_time, '_rank.csv', sep = '')
# csv_value <- read.csv(paste(getwd(), fname, sep = "/"))
# csv_name <- names(csv_value)
# csv_name[20] <- "_id"
# colnames(csv_value) <- csv_name

# write CSV to DB
dbWriteTable(conn ,
             "info_l2" ,
             df4 ,
             overwrite = TRUE ,
             row.names = FALSE)

print('csv_to_postgresql.R done :)')
