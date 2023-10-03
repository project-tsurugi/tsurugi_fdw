# [リファレンス（SQL）](../sql_reference.md)

## REVOKE

  REVOKE － Tsurugiのアクセス権を取り消す。

### 概要

  ~~~sql
  REVOKE [ GRANT OPTION FOR ]
      { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
      [, ...] | ALL [ PRIVILEGES ] }
      ON { [ TABLE ] table_name [, ...]
          | ALL TABLES IN SCHEMA schema_name [, ...] }
      FROM role_specification [, ...]
      [ CASCADE | RESTRICT ]

  REVOKE [ ADMIN OPTION FOR ]
      role_name [, ...] FROM role_specification [, ...]
      [ GRANTED BY role_specification ]
      [ CASCADE | RESTRICT ]

  ここでrole_specificationは以下の通りです。

      [ GROUP ] role_name
    | PUBLIC
    | CURRENT_USER
    | SESSION_USER
  ~~~

### 説明

  REVOKEは、Tsurugiのテーブルに付与された権限、または、データベースロールに付与された権限を取り消します。

  REVOKEのリファレンスは、PostgreSQLのREVOKEに準じます。  
  概要・パラメータ・例などの詳細は、[PostgreSQLのマニュアル](https://www.postgresql.jp/document/12/html/sql-revoke.html)を参照してください。
