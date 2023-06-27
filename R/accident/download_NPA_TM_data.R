# CONSTANT ---------------------------------------------------------------------
DATA_PATH <- file.path("data", "accident")
# https://data.gov.tw/dataset/12818
A1_DOWNLOAD_URL <-
  "https://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx?DATA=402E554F-10E7-42C9-BAAF-DF7C431E3F18"
# https://data.gov.tw/dataset/13139
A2_DOWNLOAD_URL <-
  "https://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx?DATA=1B920938-26EA-4A7C-BEFD-1E6503AA5D5E"


# ------------------------------------------------------------------------------
download_A1 <- function () {
    download.file(
      url = A1_DOWNLOAD_URL,
      destfil = file.path(DATA_PATH, "NPA_TMA1.csv"),
      mode = "wb"
    )
}

download_A2 <- function () {
    # download zip
    temp <- tempfile(fileext = ".zip")
    download.file(
      url = A2_DOWNLOAD_URL,
      destfil = temp,
      mode = "wb"
    )

    # unzip files starts with "NPA"
    # i.e. this will drop file.csv, schema.csv, main.csv
    z <- unzip(temp, list = TRUE)
    for (fname in z$Name) {
      if (grepl("^NPA", fname)) {
        print(fname)
        tryCatch(
          unzip(temp, files = fname, exdir = file.path(DATA_PATH)),
          error = \(e) {
            msg <- paste0("有檔案無法解壓縮：`", fname, "`\n")
            message(msg, e)
          }
        )
      }
    }
    unlink(temp)
}

#' Download NPA TM Data
#'
#' `download_NPM_TM_data` will download accident csv from data.gov, extract
#' files to output/accident/ folder.
#'
#' @param type A character string indicating the type of data to download. The
#'   default value is "ALL". Possible values are:
#'   - "ALL": Downloads all available data.
#'   - "A1": Downloads data related to A1 accident type.
#'   - "A2": Downloads data related to A2 accident type.
#'
#' @examples
#' # Download all NPA TM data
#' download_NPA_TM_data()
#'
#' # Download only A1 data
#' download_NPA_TM_data(type = "A1")
#'
#' # Download only A2 data
#' download_NPA_TM_data(type = "A2")
download_NPA_TM_data <- function (type = "ALL") {
  if (type == "ALL") {
    download_A1()
    download_A2()
  } else if (type == "A1") {
    download_A1()
  } else if (type == "A2") {
    download_A2()
  }
}
