# download and unzip village shp files
# unzip one by one because errors might occur with some files
shp_folder <- 'data/village_shp'
shp_fname <- paste(shp_folder, '/VILLAGE_MOI_1111118.shp', sep = '')
if (!file.exists(shp_fname)) {
  temp <- tempfile(fileext = '.zip')
  download.file(
    "https://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx?DATA=923454AB-F2CA-4AA2-BC59-1920215F1ADC",
    destfil = temp,
    mode = 'wb'# https://stackoverflow.com/questions/29814405/why-do-i-need-to-use-mode-wb-with-download-file-for-this-rds-file
  )
  dir.create(shp_folder, showWarnings = FALSE, recursive = TRUE)
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
