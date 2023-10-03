# [リファレンス（SQL）](../sql_reference.md)

## DROP TABLE

  DROP TABLE － Tsurugi OLTPのテーブルを削除する。

### 概要

  ~~~sql
  DROP TABLE [ IF EXISTS ] name [, ...] [ RESTRICT ]
  ~~~

### 説明

  DROP TABLEはTsurugi OLTPのテーブルを削除します。  
  テーブル所有者、スーパーユーザのみがテーブルを削除することができます。

  DROP TABLEのリファレンスは、PostgreSQLのDROP TABLEに準じます。  
  PostgreSQLとの差分については「[互換性](#互換性)」を参照してください。  
  また、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。

### パラメータ

* **IF EXISTS**  
  テーブルが存在しない場合でもエラーになりません。 この場合、注意メッセージが出力されます。

* **name**  
  削除するテーブルの名前です。

* **RESTRICT**  
  依存しているオブジェクトがある場合に、テーブルの削除を拒否します。

### 例

* 2つのテーブル、hollywood.filmsとdistributorsを削除します。

  ~~~sql
  DROP TABLE hollywood.films, distributors;
  ~~~

### 互換性

DROP TABLEは、以下に挙げるものを除いて、PostgreSQLに従います。

* **依存関係にあるオブジェクトの削除**  
  Tsurugiでは、依存関係を持つTsurugiテーブルを自動的に削除することができません。  
  PostgreSQLでは、DROP TABLEにCASCADEを指定することで、削除するテーブルに依存するオブジェクトさらにそれらのオブジェクトに依存するすべてのオブジェクトを自動的に削除します。
