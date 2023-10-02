# [リファレンス（SQL）](../sql_reference.md)

## PREPARE

  PREPARE － Tsurugiテーブルへのプリペアド文を作成する。

### 説明

  PREPAREは、Tsurugiテーブルへのプリペアド文を作成します。PREPAREを実行すると、指定された問い合わせの構文解析、書き換えが行われます。その後、 EXECUTEが発行された際に、プリペアド文は実行計画が作成され、実行されます。

  PREPAREのリファレンスは、PostgreSQLのPREPAREに準じます。  
  概要・パラメータ・例などの詳細は、[PostgreSQLのマニュアル](https://www.postgresql.jp/document/12/html/sql-prepare.html)を参照してください。  
  また、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。
  