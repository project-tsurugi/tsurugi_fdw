# [リファレンス（SQL）](../sql_reference.md)

## GRANT

  GRANT － Tsurugi OLTPのアクセス権を定義する。

### 概要

  ~~~sql
  GRANT { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
      [, ...] | ALL [ PRIVILEGES ] }
      ON { [ TABLE ] table_name [, ...]
          | ALL TABLES IN SCHEMA schema_name [, ...] }
      TO role_specification [, ...] [ WITH GRANT OPTION ]

  GRANT role_name [, ...] TO role_specification [, ...]
      [ WITH ADMIN OPTION ]
      [ GRANTED BY role_specification ]

  ここでrole_specificationは以下の通りです。

      [ GROUP ] role_name
    | PUBLIC
    | CURRENT_USER
    | SESSION_USER
  ~~~

### 説明

  GRANTはTsurugi OLTPのテーブルに対する権限、または、データベースロールに対する権限を付与します。  
  テーブル以外のデータベースオブジェクトに対する権限付与は非サポートとなります。

  GRANTのリファレンスは、PostgreSQLのGRANTに準じます。  
  概要・パラメータ・例などの詳細は、[PostgreSQLのマニュアル](https://www.postgresql.jp/document/12/html/sql-grant.html)を参照してください。
