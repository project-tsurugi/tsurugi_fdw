# [リファレンス（UDF）](../udf_reference.md)

## tg_show_tables

tg_show_tables -  Tsurugiのテーブル定義の情報を表示する

### 概要

```sql
tg_show_tables(remote_schema, server_name [, mode [, pretty] ] )
```

### 説明
Tsurugiのスキーマ(`remote_schema`)に配置されたテーブル定義の情報を表示します。

テーブル定義の情報として以下の項目を表示します。

- `remote_schema`は関数実行時に指定したTsurugiのスキーマ名を表示します。
- `server_name`は関数実行時に指定した外部サーバ名を表示します。
- `mode`は関数実行時に指定したテーブル定義情報の情報量を表示します。  
- `tables_on_remote_schema`は指定したTsurugiのスキーマ(`remote_schema`)に配置されたテーブルの情報を表示します。
  - `count`はテーブル数を表示します。
  - `list`はテーブル名のリストを表示します。`mode`で'detail'を指定した時のみ表示します。

`mode`、`pretty`について、引数を指定しない場合は以下のデフォルトの設定が適用されます。
- mode - 'summary'
- pretty - true

### パラメータ
#### remote_schema
テーブル定義情報を表示するTsurugiのスキーマ名を指定します。 

現バージョンではTsurugiでスキーマに該当する機能がないため、"tsurugi_schema"等を記述します。  
今後、仕様変更の可能性があります。

#### server_name
テーブル定義情報を表示するTsurugiに紐づいた外部サーバ名を指定します。  
外部サーバ名としてCREATE SERVERコマンドで定義した値を記述します。


#### mode
表示するテーブル定義情報の情報量を設定します。
以下のいずれかの文字列を記述します。

- **'sumamry'**  
  定義されているテーブルの数のみを表示します。
  

- **'detail'**  
  定義されているテーブルの数、およびテーブル名のリストを表示します。

#### pretty
テーブル定義情報を持つJSONオブジェクトの表示形式を設定します。
以下のいずれかの文字列を記述します。

- **true**  
  JSONオブジェクトを整形表示します。
  
- **false**  
  JSONオブジェクトを非整形表示します。

### 例

#### Tsurugiのテーブル定義情報としてテーブル数のみを表示する

  ```sql
  SELECT tg_show_tables('tsurugi_schema', 'tsurugi', 'summary');
              tg_show_tables
  --------------------------------------------
   {                                         +
       "remote_schema": {                    +
           "remote_schema": "tsurugi_schema",+
           "server_name": "tsurugi",         +
           "mode": "summary",                +
           "tables_on_remote_schema": {      +
               "count": 2                    +
           }                                 +
       }                                     +
   }
  (1 row)
  ```

#### Tsurugiのテーブル定義情報としてテーブル数、およびテーブル名のリストを表示する

  ```sql
  SELECT tg_show_tables('tsurugi_schema', 'tsurugi', 'detail');
              tg_show_tables
  --------------------------------------------
   {                                         +
       "remote_schema": {                    +
           "remote_schema": "tsurugi_schema",+
           "server_name": "tsurugi",         +
           "mode": "detail",                 +
           "tables_on_remote_schema": {      +
               "count": 2,                   +
               "list": [                     +
                   "table_a",                +
                   "table_b"                 +
               ]                             +
           }                                 +
       }                                     +
   }
  (1 row)
  ```

---
