library(RPostgres)
library(DBI)
library(magrittr)
library(dplyr)

# connect
conn <- DBI::dbConnect(
  drv = RPostgres::Postgres(),
  dbname = "postgres",
  host = "localhost",
  user = "postgres",
  password = "sidewalk168",
  port = 5432
)

# load CSV
current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('output/', current_time, '_rank.csv', sep = '')
csv_value<-read.csv(paste(getwd(),fname,sep="/"))
csv_name<-names(csv_value)
csv_name[20]<-"_id"
colnames(csv_value)<-csv_name

# write CSV to DB
dbWriteTable(conn
             # schema and table
             , "info_l2"
             , csv_value
             , overwrite = TRUE # add row to bottom
             , row.names = FALSE
)

# update geom info
dbExecute(conn,"SELECT AddGeometryColumn('info_l2','geom',4326,'POINT','2');")
dbExecute(conn,"UPDATE info_l2 SET geom = ST_MakePoint(lng,lat);")
dbExecute(conn,"CREATE INDEX info_l2_idx ON public.info_l2 USING gist (geom);")

# done
print('csv_to_postgresql.R done :)')

