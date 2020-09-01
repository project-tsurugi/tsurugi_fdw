# 単体テスト
## テストツール
[run_test.sh](./run_test.sh)

### 実行方法
#### 前提条件
* 次のREADME「How to build frontend」「How to set up for frontend」を実施済みであること。
	* https://github.com/project-tsurugi/frontend/tree/feature/create_table_v2#frontend-for-ogawayama-postgresql-add-on
* テストを実施したPostgreSQLのバージョン
	* 11.1
	* 12.3

#### 実行手順
1. 次のコードを修正

	```bash
	# Fix below
	# PostgreSQL install directory PGHOME
	PGHOME_FOR_TEST=~/pgsql
	# connection port number
	PORT=5432
	# the cluster's data directory PGDATA
	PGDATA_FOR_TEST=$PGHOME_FOR_TEST/data
	# Fix above
	```

1. 実行

	```bash
	./run_test.sh
	```

## テストパターン
### 制約の直行表

|項番|表制約<br>0=なし<br>1=単主キーあり<br>2=複合主キーあり|列制約NOT NULL<br>0=なし<br>1=あり|列制約PRYMARY KEY<br>0=なし<br>1=あり|
|---|---|---|---|
|1|0| 0| 0|
|2|0| 0| 1|
|3|0| 1| 0|
|4|0| 1| 1|
|5|1| 0| 0|
|6 error|1| 0| 1|
|7|1| 1| 0|
|8 error|1| 1| 1|
|9|2| 0| 0|
|10 error|2| 0| 1|
|11|2| 1| 0|
|12 error|2| 1| 1|

#### SQL
* [otable_of_constr.sql](./otable_of_constr/otable_of_constr.sql)

### 正常系
* [ch-benchmark-ddl.sql](./ch-benchmark-ddl/ch-benchmark-ddl.sql)
	* 参考：https://github.com/citusdata/ch-benchmark.git
* [happy.sql](./happy/happy.sql)

### 異常系
* [alternative.sql](./alternative/alternative.sql)
* [unhappy.sql](./unhappy/unhappy.sql)
* メタデータのロード失敗
	* <PostgreSQLのインストールディレクトリ>/data/tsurugi_metadata/datatypes.jsonのみ所有権をroot:rootに変更
	* <PostgreSQLのインストールディレクトリ>/data/tsurugi_metadata/tables.jsonのみ所有権をroot:rootに変更
	* <PostgreSQLのインストールディレクトリ>/data/tsurugi_metadata/oidのみ所有権をroot:rootに変更

### tsurugi用のテーブル以外の場合（tablespace tsurugiをつけない場合）
* [wo_tsurugi.sql](./wo_tsurugi/wo_tsurugi.sql)

## カバレッジレポート
* [C0カバレッジレポート](./coverage/index.html)

### 生成手順
* https://www.postgresql.org/docs/12/regress-coverage.html

## 参考

### テストパターン数
|種類|テストケース名|テストパターン数|
| :--- | :--- | ---: |
|正常系|otable_of_constr.sql|15|
|正常系|ch-benchmark-ddl.sql|14|
|正常系|happy.sql|11|
|異常系|alternative.sql|89|
|異常系|unhappy.sql|23|
|異常系|メタデータのロード失敗|3|
|正常系|計|40|
|異常系|計|115|
||総計|155|

# 機能テスト(結合テスト)

## 基本方針
* DML文の構文自体は簡単な内容。
	* 例
		* [test_create_table.sql](../v1/test_create_table.sql)
* ただし、CREATE TABLEに関係する要素(カラム数やデータ型など)については考慮した構文にする。
	* 可能であれば、v1をベースに組み合わせや網羅性を向上させる。

## 正常系
* ch-benchmark-ddl
	* [ch-benchmark-ddl.sql](./ch-benchmark-ddl/ch-benchmark-ddl.sql)

* サポートされる構文が正常に動作するか。
	* 制約の直交表
		* [otable_of_constr.sql](./otable_of_constr/otable_of_constr.sql)
		* [制約の直行表](#制約の直行表)

	* [happy.sql](./happy/happy.sql)
		* カラムなし
		* sql文がupper case
			* 表制約PRIMARY KEY
			* 列制約PRIMARY KEY
		* sql文がlower case
			* 表制約PRIMARY KEY
			* 列制約PRIMARY KEY
		* すべてのカラムがPRIMARY KEY
		* カラム名
			* 全角日本語
			* 1文字の半角英語

* サポートされる型が正常に動作するか。
	* サポートする型一覧
		* [サポートする型一覧](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートする型)
	* varchar
		* varchar(1)
		* varchar(1000)
	* char
		* char(1)
		* char(1000)
		* (n)を省略する。

* INSERT/SELLECT
	* int
		* intの範囲内
			* -2147483647
			* 0
			* 2147483646
	* bigint
		* bigintの範囲内
			* -9223372036854775807
			* 0
			* 9223372036854775806
	* real
		* 天文台のSQLに記載の値
			* 3.24000001
			* -2.27600002
	* double precision
		* 天文台のSQLに記載の値
			* -0.299999999999999989
			* 25.8000000000000007
	* char(1000)/varchar(1000)
		* 1文字
		* 10文字
		* 1000文字
	* [制約の直行表](#制約の直行表)
		* 全カラム値を挿入
		* PRIMARY KEY制約のカラムはNULL以外の値、PRIMARY KEY制約以外のカラムはNULLを挿入
		* NOT NULL制約のカラムはNULL以外の値、NOT NULL制約のカラムはNULLを挿入
* UPDATE
	```
	CREATE TABLE t2(c1 INTEGER NOT NULL PRIMARY KEY, c2 BIGINT, c3 DOUBLE PRECISION) TABLESPACE tsurugi;
	INSERT INTO t2 VALUES (1, 100, 1.1);
	UPDATE t2 SET c2 = c2+9223372036854775706;
	UPDATE t2 SET c3 = c3+3.24000001 WHERE c2 = 9223372036854775806;
	```

## 異常系
* 構文エラー
	* [サポートするCREATE_TABLE構文](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートするcreate-table構文)以外を入力
		* [alternative.sql](./alternative/alternative.sql)
* 型エラー
	* [サポートする型](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートする型)以外を入力
		* [alternative.sql](./alternative/alternative.sql)
		* varchar
			* (n)を省略する。
			* nを省略　varchar()
			* varchar(0)
		* char
			* (n)を省略する。
			* nを省略　char()
			* char(0)
		* カラムに型が指定されていない

* [unhappy.sql](./unhappy/unhappy.sql)
	* DEFAULT制約
		* DEFAULT制約のDEFAULT値をダブルクオートで囲む
		* DEFAULT制約のserialを入力

	* PRIMARY KEY制約
		* 列制約でPRIMARY KEY制約を複数カラム入力
		* カラム名が指定されていなかった。例) PRIMARY KEY()
			* 列制約
			* 表制約
		* 表制約のPRIMARY KEY制約で、存在しないカラム名を指定。

	* カラム名
		* 1つのテーブルに同じカラム名を入力
		* カラム名が指定されていない。
		* カラム名が数字のみ　例)1
		* カラム名が数字から始まる　例)1c
		* カラム名が日本語　例) ???

	* テーブル名
		* すでに存在するテーブル名を入力
			* 同一PostgreSQLデータベース・同一スキーマ名にすでに存在するテーブル名を入力
			* 同一PostgreSQLデータベース・スキーマ名が異なるスキーマにすでに存在するテーブル名を入力
			* 別PostgreSQLデータベース・同一スキーマ名にすでに存在するテーブル名を入力
			* 別PostgreSQLデータベース・別スキーマ名にすでに存在するテーブル名を入力
		* テーブル名が指定されていない。
		* テーブル名が数字のみ　例)1
		* テーブル名が数字から始まる　例)1c
		* テーブル名が日本語　例) ???

* ogawayama-serverが起動していない。
* メタデータのロード失敗
	* ~/.local/tsurugi/metadata/datatypes.jsonのみ所有権をroot:rootに変更
	* ~/.local/tsurugi/metadata/tables.jsonのみ所有権をroot:rootに変更
	* ~/.local/tsurugi/metadata/oidのみ所有権をroot:rootに変更

* INSERT
	* int
		* intの範囲外
			* -2147483648
			* 2147483647
	* bigint
		* bigintの範囲内
			* -9223372036854775808
			* 9223372036854775807
	* char(10)/varchar(10)
		* 11文字
	* [制約の直行表](#制約の直行表)
		* PRIMARY KEY制約のカラムに、NULLを挿入
		* NOT NULL制約のカラムに、NULLを挿入
* UPDATE
	```
	CREATE TABLE t2(c1 INTEGER NOT NULL PRIMARY KEY, c2 BIGINT, c3 DOUBLE PRECISION) TABLESPACE tsurugi;
	INSERT INTO t2 VALUES (1, 100, 1.1);
	UPDATE t2 SET c2 = c2+9223372036854775807;
	```
