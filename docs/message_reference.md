# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## リファレンス（メッセージ）

Tsurugi FDWが異常時に出力するメッセージについて説明します。  
メッセージのSQLSTATE値はすべてinternal_errorを示す `XX000` となります。  
その他のメッセージはPostgreSQLのメッセージ仕様に準じます。

### Tsurugi FDWのエラーメッセージ

PostgreSQLからTsurugiにアクセスした際にエラーが発生すると以下のようなエラーメッセージが出力されます。

```sql
ERROR:  Failed to execute remote SQL.
HINT:  Failed to execute the query on Tsurugi. error: (エラー名、エラー番号)
Tsurugi Error: （Tsurugiからのエラーメッセージ）
CONTEXT:  SQL query: （Tsurugiに送信した実際のSQL文）
```

例）PostgreSQL固有の命令文を実行した場合（`SELECT DISTINCT ON`）

```sql
tsurugi=# SELECT DISTINCT ON (id) id, name FROM test_table1 ORDER BY id;
ERROR:  Failed to execute remote SQL.
HINT:  Failed to execute the query on Tsurugi. error: SERVER_ERROR(13)
Tsurugi Error: SYNTAX_EXCEPTION (SQL-03001: compile failed with message:"appeared unexpected token: "ON", expected one of {(, *, +, -, ?, ...}" region:"region(begin=16, end=18)")
CONTEXT:  SQL query: SELECT DISTINCT ON (id) id, name FROM test_table1 ORDER BY id
```

- **その他メッセージ**

  - **"This database is for Tsurugi, so CREATE TABLE is not supported"**  
    Tsurugi FDWをインストールしたデータベースにPostgreSQLのテーブルは作成できません。  
    PostgreSQLのテーブルは、Tsurugi FDWがインストールされていないデータベースに作成してください。  

  - **"This database is for Tsurugi, so CREATE FOREIGN TABLE for non-Tsurugi foreign table is not supported"**  
    Tsurugi FDWをインストールしたデータベースにTsurugi以外の外部テーブルは作成できません。  
    Tsurugi以外の外部テーブルは、Tsurugi FDWがインストールされていないデータベースに作成してください。  

  - **"tsurugi_fdw extension cannot be installed in the non-empty database. Please make sure there are no tables by using the \\d command."**  
    PostgreSQLのテーブルまたはTsurugi以外の外部テーブルが存在する既存のデータベースにTsurugi FDWをインストールすることはできません。  
    Tsurugiを利用するためのデータベースは新たに作成してください。  
