# [リファレンス（SQL）](../sql_reference.md)

## IMPORT FOREIGN SCHEMA for Tsurugi FDW

本書ではIMPORT FOREIGN SCHEMAについて、Tsurugi FDW固有の仕様について記載します。
  
基本的な事項については[PostgreSQLのドキュメント](https://www.postgresql.jp/document/12/html/sql-commands.html) を参照してください。

### 概要

```sql
IMPORT FOREIGN SCHEMA remote_schema
    [ { LIMIT TO | EXCEPT } ( table_name [, ...] ) ]
    FROM SERVER server_name
    INTO local_schema
    [ OPTIONS ( option 'value' [, ... ] ) ]
```

### パラメータ

#### *remote_schema*
本来はインポート元となるリモートのスキーマを指定します。  
Tsurugiでスキーマに該当する機能がないため、PostgreSQLの構⽂チェックでエラーとならない値("tsurugidb"等)を記述します。  
今後、仕様変更の可能性があります。

#### *OPTIONS ( option 'value' [, ... ] )*
使用できるオプションはありません。  

上記以外のパラメータは
PostgreSQLのSQLコマンド仕様に準じます。
詳細は [PostgreSQLのドキュメント](https://www.postgresql.jp/document/12/html/sql-commands.html) を参照してください。



### 例

- 外部サーバ(tsurugi)上の全テーブルに対応する外部テーブルをPostgreSQLのローカルスキーマ(public)上に作成する

  ```
  postgres=# IMPORT FOREIGN SCHEMA tsurugidb FROM SERVER tsurugi INTO public;
  IMPORT FOREIGN SCHEMA
  postgres=
  ```

- 外部サーバ(tsurugi)上の一部テーブル(テーブル名:t)に対応する外部テーブルをPostgreSQLのローカルスキーマ(public)上に作成する

  ```
  postgres=# import foreign schema tsurugidb LIMIT TO (t) from server tsurugi public;
  IMPORT FOREIGN SCHEMA
  postgres=#
  ``` 

### 外部テーブルの列データ型定義のルール

インポート対象となるTsurugiのテーブルのデータ型は、外部テーブル定義時に以下のPostgreSQLのデータ型に変換します。


  | Tsurugi<br>テーブル列のデータ型 | PostgreSQL<br>外部テーブル列に定義する<br>データ型 |
  | -- | -- |
  | INT | integer |
  | BIGINT | bigint |
  | REAL / FLOAT | real | 
  | DOUBLE /<br> DOUBLE PRECISION | double precision | |
  | DECIMAL / NUMERIC | decimal <br>(*)precision,scaleの指定は省略する |
  | CHAR / CHARACTER /<br> VARCHAR / <br>CHAR  VARYING / <br> CHARACTER VARYING | text  | 
  | DATE | date |
  | TIME | time <br>(*)桁数pの指定は省略する    |
  | TIMESTAMP | timestamp <br>(*)桁数pの指定は省略する |
  | TIME WITH TIME ZONE | time with time zone <br>(*)桁数pの指定は省略する | 
  | TIMESTAMP WITH TIME ZONE | timestamp with time zone <br>(*)桁数pの指定は省略する |

- 上記以外のデータ型を含むTsurugiのテーブルがインポート対象に含まれる場合、IMPORT FOREIGN SCHEMAの実行はエラーになります。LIMIT TO句、またはEXCEPT句で対象テーブルをインポート対象から除外する必要があります。


### 注意事項
- IMPORT FOREIGN SCHEMAを実行する前に、Tsurugiのテーブル名および列名が[PostgreSQLの識別子の長さの上限値以下](https://www.postgresql.jp/document/12/html/limits.html) で設定されていることを確認してください。  
上限値より長いのテーブル名や列名がTsurugiにある場合、IMPORT FOREIGN SCHEMAの実行、および生成した外部テーブルを経由したTsurugiのデータ操作が意図しない動作になる場合があります。
  - 事象例
    - IMPORT FOREIGN SCHEMAの実行時、外部テーブル名がTsurugiのテーブル名からPostgreSQLの上限値まで切り詰められて設定されます。外部テーブル名とTsurugiのテーブル名が不一致になるため、外部テーブルを経由したTsurugiのテーブルの操作ができません。
    - IMPORT FOREIGN SCHEMAの実行時、外部テーブル名がTsurugiのテーブル名からPostgreSQLの上限値まで切り詰められて設定されます。リレーション名の重複が発生する場合、IMPORT FOREIGN SCHEMAの実行はエラーになります。
    - IMPORT FOREIGN SCHEMAの実行時、LIMIT TO句、またはEXCEPT句で指定するテーブル名は内部的にPostgreSQLの上限値まで切り詰められます。そのため、適切に対象のテーブル名を指定または除外することができません。
    - IMPORT FOREIGN SCHEMAの実行時、外部テーブルの列名がTsurugiの列名からPostgreSQLの上限値まで切り詰められて設定されます。外部テーブルの列名とTsurugiのテーブルの列名が不一致になるため、外部テーブルを経由したTsurugiのテーブルの操作ができない場合があります。
    - IMPORT FOREIGN SCHEMAの実行時、外部テーブルの列名がTsurugiの列名からPostgreSQLの上限値まで切り詰められて設定されます。同一外部テーブルで列名の重複が発生する場合、IMPORT FOREIGN SCHEMAの実行はエラーになります。

### Tsurugi対応バージョン
- 1.3.0以降









