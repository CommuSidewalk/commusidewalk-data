# DB best practices: https://solutions.posit.co/connections/db/
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

# dbRemoveTable(conn, 'info_l2')

sql <- paste(
  'CREATE TABLE IF NOT EXISTS info_l2 (',
  '   _id VARCHAR(255),',
  '   imgName INTEGER,',
  '   lat FLOAT,',
  '   lng FLOAT,',
  '   dataTime TIMESTAMP,',
  '   remark TEXT,',
  '   uploader VARCHAR(255),',
  '   marker VARCHAR(255),',
  '   checker VARCHAR(255),',
  '   label VARCHAR(255),',
  '   createdAt TIMESTAMP,',
  '   updatedAt TIMESTAMP,',
  '   sidewalk VARCHAR(255),',
  '   protective VARCHAR(255),',
  '   wheelchair VARCHAR(255),',
  '   occupation VARCHAR(255),',
  '   walkRisk VARCHAR(255),',
  '   riskRate VARCHAR(255),',
  '   purpose VARCHAR(255),',
  '   imgUrl VARCHAR(255),',
  '   rankA1 FLOAT,',
  '   rankB1 FLOAT,',
  '   rankC1 FLOAT,',
  '   countyName VARCHAR(255),',
  '   townName VARCHAR(255),',
  '   villName VARCHAR(255),',
  '   villCode VARCHAR(255)',
  ');'
)

dbSendQuery(conn, sql)

# write df4 to DB
dbWriteTable(conn,
             "info_l2",
             df,
             # this will overwrite existing table
             overwrite = TRUE,
             row.names = FALSE)

print('write_to_db done :)')
