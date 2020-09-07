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
* CREATE TABLE構文でテーブル定義を行ったあと、INSERT/SELECTを発行することで、正常にテーブル定義が動作したことを確認する。
* DML文の構文自体は簡単な内容。ただし、CREATE TABLEに関係する要素(カラム数やデータ型など)については考慮した構文にする。
	* 可能であれば、v1をベースに組み合わせや網羅性を向上させる。

## テスト全体の流れ
### CREATE TABLEに関するテスト
1. シナリオテスト
	* テスト確認観点
		* ユーザーが行う業務を想定したシナリオが正常に動作するか。
	* 主なテスト項目
		* CH-benCHmarkのテーブルが正常に定義されるか。
			
1. CREATE TABLE構文・型テスト
	* テスト確認観点
		* サポートされる構文・型を入力したときに、仕様通りテーブル定義できるか。
		* サポートされる構文以外・型以外を入力したときに、仕様通りの動作となるか。
	* 主なテスト項目
		* CREATE TABLE構文を発行してテーブル定義
		* サポート対象外の構文・型が入力された場合、エラーメッセージが出力されるか。
		
1. 制約の直行表テーブルに関するテスト
	* テスト確認観点
		* 表制約のPRYMARY KEY制約、列制約のNOT NULL/PRYMARY KEY制約それぞれの組み合わせのテーブルが、正常に定義できるか。制約の仕様を満たした動作となるか。
	* 主なテスト項目
		* [制約の直交表](#制約の直交表)の全テーブルをCREATE TABLE
		* [制約の直交表](#制約の直交表)の全テーブルに対して、INSERT/SELECT
		* 「NULL」、「NOT UNIQUEな値」をINSERT
		
### INSERT/SELECTに関するテスト
* テスト確認観点
	* INSERT/SELECTが正常に動作するか。
* 主なテスト項目
	* 境界値テスト

### UPDATE/DELETEに関するテスト
* テスト確認観点
	* UPDATE/DELETEが正常に動作するか。
* 主なテスト項目
	* UPDATE
		* 境界値テスト
	* DELETE
		* カラム名の存在有無により、DELETEが正常に動作するか

### frontend以外のコンポーネント異常テスト
* テスト確認観点
	* frontend以外のコンポーネントでエラーが発生した場合、仕様通りの動作となるか。
* 主なテスト項目
	* ogawayama-serverが起動していない場合
	* メタデータのロードが失敗した場合

## テスト項目一覧
### CREATE TABLEに関するテスト
1. シナリオテスト
	* テスト確認観点
		* ユーザーが行う業務を想定してシナリオを作成し、そのシナリオが正常に動作するか。
	* 内容
		* CH-benCHmarkを測定するためのテーブルが正常に定義できるか。
			* CH-benCHmarkの公式サイト
				* https://db.in.tum.de/research/projects/CHbenCHmark/?lang=en
	* SQL例
		* [ch-benchmark-ddl.sql](../../sql/ch-benchmark-ddl.sql)
			* 参考：https://github.com/citusdata/ch-benchmark.git）

1. 制約の直行表テーブルに関するテスト
	* テスト確認観点
		* 表制約・列のNOT NULL制約・列のPRYMARY KEY制約それぞれの組み合わせのテーブルが、正常に定義できるか。
		* [制約の直交表](#制約の直交表)の全テーブルに対して、INSERT/SELECT可能かどうか。
		* NOT NULL/PRIMARY KEY制約があるカラムにはNULLをINSERTできない、PRIMARY KEY制約があるカラムにはUNIQUEではない値をINSERTできないことを確認する。
	* 内容
		* CREATE TABLE
			* 表制約（なし・単主キーあり・複合主キーあり）、列制約NOT NULL（なし・あり）、列制約PRYMARY KEY（なし・あり）の組み合わせのテスト。制約の正常系・異常系両方のテスト。
				* 各制約の組み合わせは、[制約の直交表](#制約の直交表)を参照
		* INSERT/SELECT
			* 正常
				* 全カラムに値をINSERTし、SELECTした結果が正しいかどうか。
				* PRIMARY KEY制約のカラムにUNIQUEな値をINSERT
				* NOT NULL制約のカラムはNULL以外の値、NOT NULL制約のカラムはNULLをINSERT
			* 異常
				* PRIMARY KEY制約のカラムに、NULLをINSERT
				* PRIMARY KEY制約のカラムにUNIQUEではない値をINSERT
				* NOT NULL制約のカラムに、NULLをINSERT
	* SQL例
		* [otable_of_constr.sql](../../sql/otable_of_constr.sql)

1. 構文テスト
	* テスト確認観点
		* CREATE TABLE構文で、サポートされる構文が正常に動作するか。
		* サポートする構文以外を入力すると、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
	* 内容
		* 正常系
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
			* SQL例
				* [happy.sql](../../sql/happy.sql)
		* 異常系
			* [サポートするCREATE_TABLE構文](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートすcreate-table構文)以外を入力
				* SQL例
					* [alternative.sql](../../sql/alternative.sql)
			* その他サポートしないCREATE TABLE構文を入力
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
				* SQL例
					* [unhappy.sql](../../sql/unhappy.sql)

1. 型テスト
	* テスト確認観点
		* CREATE TABLE構文で、サポートされる型が正常に動作するか。
		* サポートする型以外を入力すると、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
	* 内容
		* 正常系
			* [サポートする型](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートする型)すべてを利用して、CREATE TABLE構文を入力する。
			* varchar
				* varchar(1)
				* varchar(1000)
			* char
				* char(1)
				* char(1000)
				* (n)を省略する。
		* 異常系
			* [サポートする型](../../docs/design/frontend_V2_CREATE_TABLE_functional_design.md#サポートする型)以外を入力
				* SQL例：[alternative.sql](../../sql/alternative.sql)
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
		
### INSERT/SELECTに関するテスト
* テスト確認観点
	* 値の範囲内でINSERTして、SELECTした結果が正しいかどうか。
	* 値の範囲外でINSERTして、エラーメッセージが出力されるか。
* 内容
	* int
		* 正常
			* 次の範囲内の値をINSERT/SELECTする。
				* 最小値：-2147483648
				* 最大値：2147483647
		* 異常
			* 次の範囲外の値をINSERTする。
				* 最小値-1:-2147483649
				* 最大値+1:2147483648
	* bigint
		* 正常
			* 次の範囲内の値をINSERT/SELECTする。
				* 最小値：-9223372036854775808
				* 最大値：9223372036854775807
		* 異常
			* 次の範囲外の値をINSERTする。
				* 最小値-1:-9223372036854775809
				* 最大値+1:9223372036854775808			
	* real
		* 正常
			* 次の範囲内の値をINSERT/SELECTする。
				* 二進数で正確に表現できない十進数：0.1、1.1
		* V2では実施しない項目
			* realの値の範囲の仕様が不明であるため、次のテストは実施しない。
				* 正常
					* 次の範囲内の値をINSERT/SELECTする。
						* 最大値
						* 最小値
				* 異常
					* 次の範囲外の値をINSERTする。
						* 最大値+1
						* 最小値-1
	* double precision
		* 正常
			* 次の範囲内の値をINSERT/SELECTする。
				* 二進数で正確に表現できない十進数：0.1、1.1
		* V2では実施しない項目
			* double precisionの値の範囲の仕様が不明であるため、次のテストは実施しない。
				* 正常
					* 次の範囲内の値をINSERT/SELECTする。
						* 最大値
						* 最小値
						* 15桁の精度　例）0.987654E+37
				* 異常
					* 次の範囲外の値をINSERTする。
						* 最大値+1
						* 最小値-1
	* char(1)
		* 正常
			* 次の文字数をINSERT/SELECTする。
				* 1文字
		* 異常
			* 次の文字数をINSERTする。
				* 2文字
	* char(10)
		* 正常
			* 次の文字数をINSERT/SELECTする。
				* 10文字
		* 異常
			* 次の文字数をINSERTする。
				* 11文字
	* char(1000)
		* 正常
			* 1000文字をINSERT/SELECTする。
	* varchar(1000)
		* 正常
			* 次の文字数をINSERT/SELECTする。
				* 1文字
				* 10文字
				* 1000文字

### UPDATE/DELETEに関するテスト
* テスト確認観点
	* UPDATE/DELETEが正常に動作するか。
* 内容
	* UPDATE
		* 境界値テストを実施する。
			* 正常系
				* INSERTと同様に範囲内の値でUPDATEし、SELECT結果が正しいかどうか確認する。
			* 異常系
				* INSERTと同様に範囲外の値でUPDATEし、エラーメッセージが出力されることを確認する。
	* DELETE
		* カラム名の存在有無により、DELETEが正常に動作するか。
			* 正常系
				* 存在するカラム名の値を削除し、SELECT結果が正しいかどうか確認する。
			* 異常系
				* 存在しないカラムを指定し、エラーメッセージが出力されることを確認する。

### frontend以外のコンポーネント異常テスト
* テスト確認観点
	* frontend以外のコンポーネントでエラーが発生した場合、frontendでエラーメッセージが出力され、Tsurugiでテーブルが定義されない、かつ定義要求したテーブルメタデータがTsurugiで保存されないことを確認する。
* 内容
	* ogawayama異常
		* ogawayama-serverが起動していない状態で、ユーザーがCREATE TABLE構文を入力する。この場合、ogawayamaのstubでエラーが発生する。
	* metadata-manager異常
		* 次の操作を行ったあとで、ユーザーがCREATE TABLE構文を入力する。この場合、metadata-managerがメタデータのロードに失敗し、metadata-managerでエラーが発生する。
			* ~/.local/tsurugi/metadata/datatypes.jsonのみ所有権をroot:rootに変更
			* ~/.local/tsurugi/metadata/tables.jsonのみ所有権をroot:rootに変更
			* ~/.local/tsurugi/metadata/oidのみ所有権をroot:rootに変更

