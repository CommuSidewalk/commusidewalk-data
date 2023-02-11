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
