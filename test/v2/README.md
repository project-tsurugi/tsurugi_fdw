# テストパターン一覧
## 制約の直行表

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

### SQL
* [orthogonal_table_of_constraints.sql](./orthogonal_table_of_constraints/orthogonal_table_of_constraints.sql)

## 正常系
### SQL
* [ch-benchmark-ddl.sql](./ch-benchmark-test/ch-benchmark-ddl.sql)
	* 参考：https://github.com/citusdata/ch-benchmark.git

## 異常系
* サポートしない構文エラー、サポートしない型エラー
	* [alternative_path.sql](./alternative_path/alternative_path.sql)

* 同じテーブル名が入力された
	* [orthogonal_table_of_constraints.sql](./orthogonal_table_of_constraints/orthogonal_table_of_constraints.sql)を2回実行する。

## カバレッジレポート
* [カバレッジレポート](./coverage/index.html)
