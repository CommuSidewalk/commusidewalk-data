library('sf')
library('dplyr')

source('R/utils/village_shp_downloader.R')

load('data/3.RData')
df <- df3

village_nc <- st_read('data/village_shp/VILLAGE_MOI_1111213.shp')
# Maybe(?) Android use WGS84, aka EPSG:4326 coordinate reference system
village_nc <- st_transform(village_nc, crs=4326)

vill_df <- st_drop_geometry(village_nc)
vill_df <-
  vill_df |> rename(
    'countyName' = 'COUNTYNAME',
    'townName' = 'TOWNNAME',
    'villName' = 'VILLNAME',
    'villCode' = 'VILLCODE'
  )
vill_df$fullName <-
  paste(vill_df$countyName,
        vill_df$townName,
        vill_df$villName,
        sep = '_')

# remove na columns
indices <- !is.na(df$lat) | !is.na(df$lng)
df <- df[indices,]
commu_nc <- st_as_sf(df, coords = c('lng', 'lat'), crs = 4326)

# add three columns
df[c('countyName', 'townName', 'villName')] <- NA

# classify all image to closet village
if (!exists("w")) {
  w <- st_within(commu_nc, village_nc)
}
# bind columns to original df
for (i in seq_along(w)) {
  if (!identical(w[[i]], integer(0))) {
    df[i, c('villCode', 'countyName', 'townName', 'villName')] <-
      vill_df[w[[i]], c('villCode', 'countyName', 'townName', 'villName')]
  }
}

current_time <- format(Sys.time(), '%Y%m%d')
fname <- paste('./output/', current_time, '_village.csv', sep = '')
write.csv(
  df,
  file = fname,
  fileEncoding = 'UTF-8',
  na = '',
  row.names = FALSE
)

df4 <- df
save(df4, file = './data/4.RData')

print('4_village_classification done :)')
