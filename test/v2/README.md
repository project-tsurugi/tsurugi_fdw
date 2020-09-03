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
### 制約の直交表

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
	* ~/.local/tsurugi/metadata/datatypes.jsonのみ所有権をroot:rootに変更
	* ~/.local/tsurugi/metadata/tables.jsonのみ所有権をroot:rootに変更
	* ~/.local/tsurugi/metadata/oidのみ所有権をroot:rootに変更

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

## テスト全体の流れ
* 正常系
	* テスト確認観点
		* CREATE TABLE構文でテーブル定義を行ったあと、INSERT/SELECTを発行することで、正常にテーブル定義が動作したことを確認する。
		* シナリオテストにおいて、正常にテーブル定義が動作するか。
		* サポートされるCREATE TABLE構文が正常に動作するか。
		* サポートされる型が正常に動作するか。
	* 主なテスト項目
		* シナリオテスト：CH-benCHmarkのCREATE TABLE文が正常に動作するか。
		* サポートされるCREATE TABLE構文が正常に動作するか
			* テーブル定義が正常に動作するか。
			* サポートされる型が正常に動作するか。
			* 制約が正常に動作するか。
		* INSERT/SELECT文が、値の範囲内で、正常に動作するか
		* UPDATE/DELETE文が、正常に動作するか
* 異常系
	* テスト確認観点
		* サポートする構文・型以外を入力する、または、エラーとなる動作を行った場合、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
	* 主なテスト項目
		* 構文エラーテスト
		* 型エラーテスト
		* 仕様上エラーとなるテスト
			* ogawayama-serverが起動していない場合
			* メタデータのロードが失敗した場合
		* 範囲外の値をINSERTしたとき、エラーメッセージが出力されるか確認する。
		* PRIMARY KEY/NOT NULL制約が正常に動作して、NULLまたはUNIQUEではない値を入力したときにエラーメッセージが出力されるか確認する。
		* 最大値を超える値でUPDATEすると、エラーメッセージが出力されるか確認する。
		* UPDATE/DELETE文を実行し、エラーメッセージが出力される確認する。

## 正常系
### CREATE TABLE
#### シナリオテスト：CH-benCHmarkのCREATE TABLE
* 目的：CH-benCHmarkを測定するためのテーブルが、正常に定義できるか確認する。シナリオテストとして行う。
* 内容：CH-benCHmarkの公式サイトを参照すること。
	* https://db.in.tum.de/research/projects/CHbenCHmark/?lang=en
* SQL例：[ch-benchmark-ddl.sql](../../sql/ch-benchmark-ddl.sql)
	* 参考：https://github.com/citusdata/ch-benchmark.git）

#### サポートされるCREATE TABLE構文が正常に動作するか
* 制約の直交表
	* 目的：表制約・列のNOT NULL制約・列のPRYMARY KEY制約それぞれの組み合わせのテーブルが、正常に定義できるか確認する。
	* 内容：表制約（なし・単主キーあり・複合主キーあり）、列制約NOT NULL（なし・あり）、列制約PRYMARY KEY（なし・あり）の組み合わせのテスト
		* 各制約の組み合わせは、[制約の直交表](#制約の直交表)を参照
	* SQL例：[otable_of_constr.sql](../../sql/otable_of_constr.sql)

* サポートされる構文テスト
	* 目的：CREATE TABLE構文で、サポートされる構文が正常に動作するか確認する。
	* 内容：
		* 次の通り、CREATE TABLE構文を入力する。
			* カラムなし
			* sql文がupper caseの場合
				* 表制約PRIMARY KEYを入力する場合
				* 列制約PRIMARY KEYを入力する場合
			* sql文がlower caseの場合
				* 表制約PRIMARY KEYを入力する場合
				* 列制約PRIMARY KEYを入力する場合
			* すべてのカラムがPRIMARY KEY
			* カラム名が次の場合
				* 全角日本語
				* 1文字の半角英語
	* SQL例：[happy.sql](../../sql/happy.sql)

#### CREATE TABLE構文で、サポートされる型が正常に動作するか。
* 目的：CREATE TABLE構文で、サポートされる型が正常に動作するか確認する。
* 内容：次の型すべてを利用して、CREATE TABLE構文を入力する。
	* [サポートする型一覧](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートする型)
	* varchar
		* varchar(1)
		* varchar(1000)
	* char
		* char(1)
		* char(1000)
		* (n)を省略する。

### INSERT/SELECT
#### INSERT/SELECT正常テスト
* 型テスト
	* 目的：範囲内の値を正常にINSERT/SELECTできるか確認する。
	* 内容：
		* int
			* 次の値をINSERT/SELECTする。
				* 最小値：-2147483648
				* 最大値：2147483647
		* bigint
			* 次の値をINSERT/SELECTする。
				* 最小値：-9223372036854775808
				* 最大値：9223372036854775807
		* real
			* 次の天文台のSQLに記載の値をINSERT/SELECTする。
				* 負の数で桁数が大きそうな値：-2.27600002
				* 正の数で桁数が大きそうな値：3.24000001
		* double precision
			* 次の天文台のSQLに記載の値をINSERT/SELECTする。
				* 負の数で桁数が大きそうな値：-0.299999999999999989
				* 正の数で桁数が大きそうな値：25.8000000000000007
		* char(1)
			* 1文字をINSERT/SELECTする。
		* char(10)
			* 10文字をINSERT/SELECTする。
		* char(1000)
			* 1000文字をINSERT/SELECTする。
		* varchar(1000)
			* 次の文字数をINSERT/SELECTする。
				* 1文字
				* 10文字
				* 1000文字

* 制約の直交表テーブルテスト
	* 目的：[制約の直交表](#制約の直交表)の全テーブルに対してINSERT/SELECT可能かどうかテスト
	* 内容：
		* 全カラム値を挿入
		* PRIMARY KEY制約のカラムにUNIQUEな値を挿入
		* NOT NULL制約のカラムはNULL以外の値、NOT NULL制約のカラムはNULLを挿入

### UPDATE/DELETE
####  UPDATE/DELETE正常テスト
* 目的：UPDATE/DELETEが正常に動作するか確認する。
* 内容：
	* すべての型のカラムに対してUPDATEできることを確認する。
	* すべての型のカラムに対してDELETEできることを確認する。

## 異常系
### CREATE TABLE
#### 構文エラーテスト
* 目的：サポートする構文以外を入力すると、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
* 内容：[サポートするCREATE_TABLE構文](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートすcreate-table構文)以外を入力
* SQL例：[alternative.sql](../../sql/alternative.sql)

#### 型エラーテスト
* 目的：サポートする構文以外を入力すると、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
* 内容：
	* [サポートする型](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートする型)以外を入力
	* varchar
		* 次の構文を入力する。
			* (n)を省略する。
			* nを省略　varchar()
			* varchar(0)
	* char
		* 次の構文を入力する。
			* nを省略　char()
			* char(0)
	* カラムに型が指定されていない場合の構文を入力する。
* SQL例：[alternative.sql](../../sql/alternative.sql)

#### その他構文エラーとなるテスト
* 目的：サポートする構文以外を入力すると、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
* 内容：
	* DEFAULT制約
		* 次の構文を入力する。
			* DEFAULT制約のDEFAULT値をダブルクオートで囲む
			* DEFAULT制約のserialを入力

	* PRIMARY KEY制約
		* 次の構文を入力する。
			* 列制約でPRIMARY KEY制約を複数カラム入力
			* 表制約のPRIMARY KEY制約でカラム名が指定されていなかった。例) PRIMARY KEY	()
			* 表制約のPRIMARY KEY制約で、存在しないカラム名を指定。

	* カラム名
		* 次の構文を入力する。
			* 1つのテーブルに同じカラム名を入力
			* カラム名が指定されていない。
			* カラム名が数字のみ　例)1
			* カラム名が数字から始まる　例)1c
			* カラム名が日本語　例) ???

	* テーブル名
		* 次の構文を入力する。
			* すでに存在するテーブル名を入力
				* 同一PostgreSQLデータベース・同一スキーマ名にすでに存在するテーブル名を入力
				* 同一PostgreSQLデータベース・スキーマ名が異なるスキーマにすでに存在するテーブル名を入力
				* 別PostgreSQLデータベース・同一スキーマ名にすでに存在するテーブル名を入力
				* 別PostgreSQLデータベース・別スキーマ名にすでに存在するテーブル名を入力
			* テーブル名が指定されていない。
			* テーブル名が数字のみ　例)1
			* テーブル名が数字から始まる　例)1c
			* テーブル名が日本語　例) ???
* SQL例：[unhappy.sql](../../sql/unhappy.sql)

#### ogawayama-serverが起動していない場合の異常テスト
* 目的：ogawayama-serverが起動していないとき、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
* 内容：
	* ogawayama-serverが起動していない状態で、ユーザーがCREATE TABLE構文を入力する。

#### メタデータのロード失敗の異常テスト
* 目的：メタデータのロードが失敗する場合、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
* 内容：次の操作を行ったあとで、ユーザーがCREATE TABLE構文を入力する。
	* ~/.local/tsurugi/metadata/datatypes.jsonのみ所有権をroot:rootに変更
	* ~/.local/tsurugi/metadata/tables.jsonのみ所有権をroot:rootに変更
	* ~/.local/tsurugi/metadata/oidのみ所有権をroot:rootに変更

### INSERT
#### INSERT異常テスト
* 型の値テスト
	* 目的：範囲外の値をINSERTしたとき、エラーメッセージが出力されるか確認する。
	* 内容：
		* int
			* 次の値をINSERTする。
				* 最小値-1:-2147483649
				* 最大値+1:2147483648
		* bigint
			* 次の値をINSERTする。
				* 最小値-1:-9223372036854775809
				* 最大値+1:9223372036854775808
		* char(10)/varchar(10)
			* 次の文字数をINSERTする。
				* 11文字

* 制約の直交表テーブルテスト
	* 目的：[制約の直交表](#制約の直交表)の全テーブルに対して、制約が正常に動作するか確認する。
	* 内容：
		* NOT NULL/PRIMARY KEY制約があるカラムにはNULLを挿入できない、PRIMARY KEY制約があるカラムにはUNIQUEではない値を挿入できないことを確認する。
			* PRIMARY KEY制約のカラムに、NULLを挿入
			* PRIMARY KEY制約のカラムにUNIQUEではない値を挿入
			* NOT NULL制約のカラムに、NULLを挿入

### UPDATE/DELETE
####  UPDATE/DELETE異常テスト
* 目的：UPDATE/DELETEが正常に動作するか確認する。
* 内容：
	* すべての型のカラムに対してUPDATEを行い、エラーメッセージが出力されることを確認する。
	* すべての型のカラムに対してDELETEを行い、エラーメッセージが出力されることを確認する。
	
