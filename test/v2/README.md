# 機能テスト
## テストツール
[exec_sql.sh](./exec_sql.sh)

### 実行方法

```bash
./exec_sql.sh
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
	* <PostgreSQLのインストールディレクトリ>/data/tsurugi_metadata/{datatypes,tables}.jsonのみ所有権をroot:rootに変更
	* <PostgreSQLのインストールディレクトリ>/data/tsurugi_metadata/配下のファイルすべて、所有権をroot:rootに変更

### tsurugi用のテーブル以外の場合（tablespace tsurugiをつけない場合）
* [wo_tsurugi.sql](./wo_tsurugi/wo_tsurugi.sql)

## カバレッジレポートの生成
* https://www.postgresql.org/docs/12/regress-coverage.html

## 参考

### テストパターン数
|種類|テストケース名|テストパターン数|
| :--- | :--- | ---: |
|正常系|otable_of_constr.sql|12|
|正常系|ch-benchmark-ddl.sql|14|
|正常系|happy.sql|11|
|異常系|alternative.sql|52|
|異常系|unhappy.sql|18|
|異常系|メタデータのロード失敗|3|
|正常系|計|37|
|異常系|計|73|
||総計|110|
