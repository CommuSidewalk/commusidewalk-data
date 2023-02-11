library(dplyr)

# get runAll function
source('R/scripts/run_all.R')

# 代碼與中文對照表
df_sc <-
  data.frame(shortform = c('imgName'), ch = c('圖片名稱')) |> rbind(
    c('id', 'id'),
    c('lat', '緯度'),
    c('lng', '經度'),
    c('dataTime', '時間'),
    c('remark', '備註'),
    c('uploader', '上傳者'),
    c('marker', '標註者'),
    c('checker', '驗證者'),
    c('label', '標籤'),
    c('createdAt', '上傳時間'),
    c('updatedAt', '更新時間'),
    c('sidewalk', '原本有無設置人行空間'),
    c('protective', '保護性'),
    c('wheelchair', '原始總寬度是否夠寬讓輪椅通行'),
    c('occupation', '佔用情形導致兩人交會需停讓或淨寬小於1.5米'),
    c('walkRisk', '行人被迫實際行走路徑中會碰到的最大動態風險'),
    c('riskRate', '承受上題風險的頻率'),
    c('purpose', '使用目的'),
    c('mapName', '思源地圖名稱無須填寫'),
    c('imgUrl', '圖片連結')
  )

convert <- function (to) {
  fname <-
    switch(to, 'chinese' = './shortform.csv', 'shortform' = './chinese.csv')

  msg <- paste(
    'Please provide full file location',
    ' (or just press Enter if your file is called `',
    fname,
    '`): ',
    sep = ''
  )
  cat(msg)

  input <- readLines('stdin', n = 1)
  if (input != '') {
    fname <- input
  }
  newfname <- sub('\\.csv', paste('_', to, '.csv', sep = ''), fname)
  read.csv(fname) |>
    rename_with(\(x) switch(
      to,
      'chinese' = df_sc$ch[df_sc$shortform == x],
      'shortform' = df_sc$shortform[df_sc$ch == x]
    )) |>
    write.csv(
      file = newfname,
      fileEncoding = 'UTF-8',
      na = '',
      row.names = FALSE
    )
}

prompt_msg <- paste(
  'Select action and press Enter: ',
  '[1] run all steps to generate csv.',
  '[2] convert shortform to chinese.',
  '[3] convert chinese to shortform.',
  '\nYour selection: ',
  sep = '\n'
)
cat(prompt_msg)

# use readLines instead of readline(prompt = 'xxx'),
# it only works in the interactive mode
readLines("stdin", n = 1) |>
  switch (
    '1' = runAll(),
    '2' = convert('chinese'),
    '3' = convert('shortform')
  )
