library('sf')
library('dplyr')

load('data/3.RData')
df <- df3

village_nc <- st_read('data/VILLAGE_MOI_1111213.shp')
commu_nc <-
  st_read(
    'output/20230131_rank.csv',
    options = c("X_POSSIBLE_NAMES=lng", "Y_POSSIBLE_NAMES=lat")
  )

# set commu_nc coordinate reference system to village_nc crs
st_crs(commu_nc) <- st_crs(village_nc)

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

df[c('countyName', 'townName', 'villName')] <- NA

w <- st_within(commu_nc, village_nc)
for (i in seq_along(w)) {
  if (!identical(w[[i]], integer(0))) {
    df[i, c('villCode', 'countyName', 'townName', 'villName')] <-
      vill_df[w[[i]], c('villCode', 'countyName', 'townName', 'villName')]
  }
}

print('4_village_classification done :)')
