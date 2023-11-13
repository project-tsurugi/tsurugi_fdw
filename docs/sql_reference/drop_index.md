# [リファレンス（SQL）](../sql_reference.md)

## DROP INDEX

  DROP INDEX － Tsurugiのインデックスを削除する。

### 概要

  ~~~sql
  DROP INDEX [ CONCURRENTLY ] [ IF EXISTS ] name [, ...] [ RESTRICT ]
  ~~~

### 説明

  DROP INDEXはTsurugiのインデックスを削除します。  
  テーブル所有者、スーパーユーザのみがテーブルを削除することができます。

  DROP INDEXのリファレンスは、PostgreSQLのDROP INDEXに準じます。  
  概要・パラメータ・例などの詳細は、[PostgreSQLのマニュアル](https://www.postgresql.jp/document/12/html/sql-dropindex.html)を参照してください。  
  また、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。
