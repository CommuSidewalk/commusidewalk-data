library('sf')
library('dplyr')

load('data/3.RData')
df <- df3

# download and unzip village shp files
# unzip one by one because errors might occur with some files
shp_folder <- 'data/village_shp'
shp_fname <- paste(shp_folder, '/VILLAGE_MOI_1111213.shp', sep = '')
if (!file.exists(shp_fname)) {
  temp <- tempfile(fileext = '.zip')
  download.file(
    "https://www.tgos.tw/TGOS/Web/MapData/TGOS_DownLoadMapOpenData.aspx?code=TW-07-301000100G-613995_20121113171335",
    destfil = temp,
    mode = 'wb'# https://stackoverflow.com/questions/29814405/why-do-i-need-to-use-mode-wb-with-download-file-for-this-rds-file
  )
  dir.create(shp_folder, showWarnings = FALSE)
  z <- unzip(temp, list = TRUE)
  for (fname in z$Name) {
    tryCatch(
      unzip(temp, files = fname, exdir = shp_folder),
      error = \(e) {
        msg <- paste('有檔案無法解壓縮：`', fname, '`\n', sep = '')
        message(msg, e)
      }
    )
  }
  unlink(temp)
}

village_nc <- st_read(shp_fname)
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
