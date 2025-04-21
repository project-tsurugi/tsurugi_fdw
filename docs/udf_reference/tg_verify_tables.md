# [リファレンス（UDF）](../udf_reference.md)

## tg_verify_tables

tg_verify_tables -  Tsurugiのテーブル定義とPostgreSQLの外部テーブル定義の検証結果を表示する

### 概要

```sql
tg_verify_tables(remote_schema, server_name, local_schema [, mode [, pretty] ] )
```

### 説明
Tsurugiのスキーマ(`remote_schema`)に配置されたテーブルと、  
PostgreSQLのスキーマ(`local_schema`)に配置された外部テーブルについて検証結果を表示します。

検証結果として以下の項目を表示します。

- `remote_schema`は関数実行時に指定したTsurugiのスキーマ名を表示します。
- `server_name`は関数実行時に指定した外部サーバ名を表示します。
- `local_schema`は関数実行時に指定したPostgreSQLのスキーマ名を表示します。
- `mode`は関数実行時に指定したテーブル定義情報の情報量を表示します。  
- `tables_on_only_remote_schema`はTsurugiのスキーマとPostgreSQLのスキーマのうち、Tsurugiのスキーマのみに存在するテーブルの情報を表示します。
  - `count`はテーブル数を表示します。
  - `list`はテーブル名のリストを表示します。`mode`で'detail'を指定した時のみ表示します。
- `foreign_tables_on_only_local_schema`はTsurugiのスキーマとPostgreSQLのスキーマのうち、PostgreSQLのスキーマのみに存在する外部テーブルの情報を表示します。
  - `count`と`list`は上記と同じです。
- `tables_that_need_to_be_altered`はTsurugiのスキーマとPostgreSQLのスキーマの両方に存在するテーブルのうち、列定義が異なると判定したテーブルの情報を表示します。
  - `count`と`list`は上記と同じです
- `available_foreign_tables`はTsurugiのスキーマとPostgreSQLのスキーマの両方に存在するテーブルのうち、列定義が同じと判定したテーブルの情報を表示します。
  - `count`と`list`は上記と同じです

列定義の判定は同名のTsurugiのテーブル、およびPostgreSQLの外部テーブルについて、「列名」・「テーブル内の列の順序」・「列のデータ型」を基準に行います。  
「列のデータ型」は[IMPORT FOREIGN SCHEMA](../sql_reference/import_foreign_schema.md) の [列データ型の変換ルール](../sql_reference/import_foreign_schema.md#列データ型の変換ルール) に基づいて判定します。

`mode`、`pretty`について、引数を指定しない場合は以下のデフォルトの設定が適用されます。
- mode - 'sumamry'
- pretty - true

### パラメータ

#### remote_schema
テーブル定義情報を表示するTsurugiのスキーマ名を指定します。  
現バージョンではTsurugiでスキーマに該当する機能がないため、"tsurugi_schema"等を記述します。  
今後、仕様変更の可能性があります。

#### server_name
テーブルの定義情報を検証するTsurugiに紐づいた外部サーバ名を指定します。  
外部サーバ名としてCREATE SERVERコマンドで定義した値を記述します。

#### local_schema
外部テーブルの定義情報を検証するPostgreSQLのスキーマ名を指定します。 

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

#### 検証結果として対象のテーブル数のみを表示する


  ```sql
  postgres=# select tg_verify_tables('tsurugi_schema', 'tsurugi', 'public', 'sumamry');
                  tg_verify_tables
  ----------------------------------------------------

（★実行イメージは別途）

    (1 row)
  ```

#### 検証結果として対象のテーブル数、およびテーブル名のリストを表示する

  ```sql
  postgres=# select tg_verify_tables('tsurugi_schema', 'tsurugi',　'public', 'detail');
                  tg_verify_tables
  ----------------------------------------------------

（★実行イメージは別途）

    (1 row)
  ```

---
