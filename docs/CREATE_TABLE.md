# PostgreSQLからのテーブル定義
2020.04.01 NEC

## 概要

* 本文書では、V1におけるPostgreSQLからNEDO DBにテーブルを定義する手順について説明する。
* 本文書はpsqlまたはPL/pgSQLからテーブルを定義することを想定している。

## 事前準備

psqlから以下の手順でFDWを利用可能にする。。

1. FDWのインストール
	* CREATE EXTENSION文を実行する
		```sql
		CREATE EXTENSION ogawayama_fdw;
		```
	* メタコマンド(\dew)で確認する
		```
		postgres=# \dew
                        List of foreign-data wrappers
             Name      |  Owner   |        Handler        | Validator
		---------------+----------+-----------------------+-----------
 		 ogawayama_fdw | postgres | ogawayama_fdw_handler | -
		```

1. 外部サーバの定義
	* CREATE SERVER文を実行する
		```sql
		CREATE SERVER ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;
		```
	* メタコマンド(\des)で確認する
		```
		postgres=# \des
                    List of foreign servers
   		   Name    |  Owner   | Foreign-data wrapper
		-----------+----------+----------------------
 		 ogawayama | postgres | ogawayama_fdw
		```

1. TABLESPACEの定義
	* TABLESPACE用のディレクトリを作成する
		```
		$ mkdir -p (PostgreSQLインストール先)/data/tsurugi
		```
	* CREATE TABLESPACE文を実行する
		```sql
		CREATE TABLESPACE tsurugi LOCATION '(PostgreSQLインストール先)/data/tsurugi';
		```
	* メタコマンド(\db)で確認する
		```
		k-postgres=# \db
                   List of tablespaces
			Name    |  Owner   |             Location
		------------+----------+-----------------------------------
		 pg_default | postgres |
		 pg_global  | postgres |
		 tsurugi    | postgres | /home/postgres/local/pgsql/data/tsurugi
		```

## テーブル定義手順

1. テーブルの定義
	* CREATE TABLE文を実行する
		* "TABLESPACE tsurugi"を付加する
		* **必ず主キー(PRIMARY KEY)を指定する**
			```sql
			CREATE TABLE table1 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
			```
	* PostgreSQLには指定したテーブル名に"_dummy"が付加されたテーブル名で定義される
		* e.g. "table1_dummy"

1. 外部テーブルの定義
	* CREATE FOREIGN TABLE文を実行する
		* 先に定義したテーブルと同じテーブル名、テーブルスキーマで定義する
		* **ただし、主キーは指定しない**
		* 先に定義した外部サーバを指定する
			```sql
			CREATE FOREIGN TABLE table1 (column1 INTEGER NOT NULL) SERVER ogawayama;
			```
	* 外部テーブルは指定したテーブル名で定義される
		* e.g. "table1"

1. DMLの実行
	* DML文は外部テーブルを指定して実行する
		```sql
		SELECT * FROM table1;
		INSERT INTO table1 VALUES (100);
		```

以上
