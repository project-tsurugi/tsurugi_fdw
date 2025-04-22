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
PostgreSQLのエラーとならない値("tsurugi_schema"等)を記述します。  
現バージョンではTsurugiはスキーマ機能をサポートしていません。Tsurugi上のすべてのテーブルがインポート対象になります。  
今後、仕様変更の可能性があります。

#### *OPTIONS ( option 'value' [, ... ] )*
使用できるオプションはありません。  
上記以外のパラメータはPostgreSQLのSQLコマンド仕様に準じます。  
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
### テーブルの定義状況を確認するための手段

IMPORT FOREIGN SCHEMA コマンド実行時に、インポート対象となる`remote_schema`にあるテーブルと同名のリレーションがインポート先となる`local_schema`に存在する場合、コマンドはエラーになります。

そのため、コマンド実行前に`remote_schema`、`local_schema`それぞれのスキーマにおけるテーブルの定義状況を確認することを推奨します。
以下の手段で確認することが可能です。

- [tg_show_tables](../udf_reference/tg_show_tables.md)  
  関数実行実行時に指定する`remote_schema`に配置されているテーブルを確認することができます。

  例えば、「`remote_schema`に配置されているテーブル」の有無を確認し、IMPORT FOREIGN SCHEMA コマンドの実行の要・不要を判断することが可能になります。

- [tg_verify_tables](../udf_reference/tg_verify_tables.md)    
  関数実行実行時に指定する`remote_schema`、`local_schema`それぞれに配置されているテーブルまたは外部テーブルについて、以下の情報を確認をすることができます。
    - `remote_schema`のみに存在するテーブルの情報
    - `local_schema`のみに存在する外部テーブルの情報
    - `remote_schema`と`local_schema`の両方に存在し、列定義が異なるとテーブルまたは外部テーブルの情報
    - `remote_schema`と`local_schema`の両方に存在し、列定義が同じテーブルまたは外部テーブルの情報  

  例えば、「`remote_schema`のみに存在するテーブルの情報」を確認し、インポート対象のテーブルとして`LIMIT TO`句で指定することで、IMPORT FOREIGN SCHEMA コマンドのエラーを回避して実行することが可能になります。

- PostgreSQL システムカタログ等  
  以下のSQLコマンドを実行することで、指定するスキーマに配置されているPostgreSQLの外部テーブルを確認することができます。  

  ```sql
  SELECT relname, relkind FROM pg_class 
    JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid 
    WHERE relkind = 'f' and nspname = 'public';
  ```

  例えば、「`local_schema`に配置されている外部テーブル」の有無を確認し、IMPORT FOREIGN SCHEMA コマンドの実行の要・不要を判断することが可能になります。

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
