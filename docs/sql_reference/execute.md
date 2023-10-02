# [リファレンス（SQL）](../sql_reference.md)

## EXECUTE

  EXECUTE － Tsurugiテーブルへのプリペアド文を実行する。

### 説明

  EXECUTEは、事前に作成されたTsurugiテーブルへのプリペアド文を実行します。  
  プリペアド文はセッション中にしか存在できないため、 事前に同一セッション中のPREPAREによって作成されたものでなければなりません。

  EXECUTEのリファレンスは、PostgreSQLのEXECUTEに準じます。  
  概要・パラメータ・例などの詳細は、[PostgreSQLのマニュアル](https://www.postgresql.jp/document/12/html/sql-execute.html)を参照してください。  
  また、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。
  