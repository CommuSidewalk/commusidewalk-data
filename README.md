# commu-sidewalk

以 R 做平安走路許願帳戶的資料處理

- [補充文件](https://docs.google.com/document/d/1bOuwkF_0abTdAyhnxUxhxrwExjNR9BnhfFtT7l5Vzc4/edit?usp=sharing)

## Develop

檔案架構：
```text
│  .gitignore
│  commusidewalk.Rproj # RStudio project 檔案
│  main.R
│  README.md
│
├─data # 儲存各階段.RData
│
├─output
│      csv data
│
├─R
│      1_download.R                  # 從commutag下載最新資料
│      2_cleaning.R                  # 資料清洗與欄位重新命名排序
│      3_rank.R                      # 計算分數
│      4_village_classification.R    # 分配村里
│      5_write_to_db.R               # 寫入資料庫
│      rank_lookup.R                 # 3_rank.R 用到的lookuptable
│      testtest.R                    # 測試script用
│
└─tests
    │  testthat.R
    │
    └─testthat
            test-3_rank.R # 測試評分演算法
```

```sh
R
> # 自動安裝 renv...
> renv::restore()     # 安裝所需套件
```

## 資料庫

目前使用 [Neon](https://neon.tech/) 的 PostgreSQL 資料庫，若需要 GIS 功能，應考慮 PostGIS。

連接資料庫所需的變數請儲存在根目錄的`.env`，可複製`.env.example`進行修改。

## 自動化

### main.R

Linux
```sh
# cd to project directory (same floor with .gitignore)
> Rscript main.R
```

Windows
```powershell
> Rscript.exe main.R
```

```sh
> Rscript main.R
> Select action and type Enter:
[1] create new csv from commutag platform. # 跑`/src`底下所有數字編號開頭檔案，匯出資料到`/output`，檔名是`日期.csv`
[2] convert shortform to chinese.          # shortform.csv to shortform_chinese.csv
[3] convert chinese to shortform.          # 同上，功能相反

Your selection: 2
Please provide full file location (or just type Enter if your file is called `./short
form.csv`): ......
```

### run\_all.R

跑所有在R資料夾內有編號的檔案，像1\_download.R, 2\_cleaning.R, ...，依序跑這些scripts。

最後會在output資料夾裡面看到YYYYmmdd_\*.csv。

如果有裝 Raku (Perl6)，可以直接點兩下`runAll.raku`，等於跑`Rscript run_all.R`。


## 關於標頭

read.csv之後發現一些符號如`原始總寬度－是否夠寬讓輪椅通行`會被轉成`原始總寬度.是否夠寬讓輪椅通行`（`佔用情形(多選)-導致兩人交會需停讓或淨寬<1.5米` -> `佔用情形.多選..導致兩人交會需停讓或淨寬.1.5米`），導致shortform和chinese的轉換會失敗，因此現在移除了特殊字元，對照表在`main.R`。
