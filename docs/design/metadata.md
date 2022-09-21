# メタデータ設計

2022.09.13 NEC

## 相関関係

- table
  - column
    - constraint
    - index
  - constraint

## メタデータ構造

- `table`
  - `columns`
  - `indexes`
  - `constraints`

## データベース

- `table`テーブル
- `column`テーブル
- `index`テーブル
- `constraint`テーブル

## カラム制約とテーブル制約の差分

| # | 制約名			| カラム制約	| テーブル制約	| 仕様差分	|	備考	|
|---|---				|---			|---			|---		|---		|
| 1.| 制約名			| o				| o				| -			| SQL標準はスキーマ中で一意、PGは制約の中で一値である必要がある。|
| 2.| NOT NULL			| o				| -				| -			| -			|
| 3.| CHECK				| o				| o				| - 		| 標準SQLでは複数の列を参照できるのはテーブル制約のみ。		|
| 4.| DEFAULT			| o				| -				| -			| デフォルト値の指定がない場合、デフォルト値はNULL。 |
| 5.| GENERATED	ALWAYS AS STORED	| o	| -				| -			| -			|
| 6.| GENERATED	AS IDENTITY			| o	| -				| -			| PGは複数のIDENTITY列が可能。標準SQLは1列のみ。| 
| 7.| UNIQUE			| o				| o				| テーブル制約は複数列を指定可能。	|-|
| 8.| PRIMARY KEY		| o				| o				| テーブル制約は複数列とINCLUDE句を指定可能。	|-|
| 9.| EXCLUDE			| -				| o				| -			| PostgreSQL固有。		|
|10.| REFERENCES		| o				| -				| -			| 外部制約	|
|11.| FOREIGN KEY REFERENCES	| -		| o				| 複数列を指定可能。	| 外部制約	|

DEFERRABLE句, INITIALY句は制約ではなく、各制約のオプションという認識。

- 番外
	- PostgreSQLは列を持たないテーブルを作成できる。標準SQLでは許されない。

## メタデータ設計思想

PostgreSQLは、テーブルとその他に列を持つもの、あるいはテーブルに似たすべてのものを`pg_class`テーブルで管理している。
その中には、インデックス、シーケンス、ビュー、マテリアライズドビュー、複合型およびTOASTテーブルが含まれる。インデックスは別途`pg_index`、シーケンスは別途`pg_sequence`を参照する。

推測するに、PostgreSQLは各データベースオブジェクトが共通して持っている属性（名前や名前空間、オーナー、ACLなど）を`pg_class`テーブルにまとめようという設計思想と思われる。そして、差分情報は別テーブル（`pg_index`など）にまとめる手法をとっている。ただ、`pg_class`テーブルはインデックスのアクセスメソッド属性などの各データベースオブジェクト固有の属性もそれなりに持っている。

一方、統合メタデータ管理基盤は、テーブル、インデックス、ビューなどを別々のテーブルで管理する設計思想である。また、統合メタデータ管理基盤におけるDDLメタデータの管理対象はDDL文の構成要素に絞られるため、各データベースオブジェクトの状態に関するメータデータは省くものとする（それらのメタデータはOLTP側で管理されることを想定する）。ただし、OLTPからそれらのメタデータの永続化を依頼された場合は、統合メタデータ管理基盤でそれらのメタデータも管理する。

### テーブルメタデータ

管理用メタデータは除く。

| # | メタデータ名	| 備考	|
|---|---			|---	|
| 1.| id 			| -		|
| 2.| name			| -		|
| 3.| namespace		| -		|
| 4.| owner_id		| -		|
| 5.| acl			| -		|
| 6.| tuples		| -		|

将来的に追加される可能性のある属性。

| # | メタデータ名	| 備考  |
|---|---			|---	|
| 1.| has_trigger	|
| 2.| row_security	|

---

### カラムメタデータ

管理用メタデータは除く。

| # | メタデータ名		| 備考	|
|---|---				|---	|
| 1.| id 				| -		|
| 2.| name				| -		|
| 3.| data_type_id		| -		|
| 4.| ordinal_position	| -		|
| 5.| not_null			| nullable		|
| 6.| varying			| -		|
| 7.| data_length		| -		|

将来的に追加される可能性のある属性。

| # | メタデータ名		| 備考 		|
|---|---				|---	|
| 1.| dims				| 配列の次元数。	|
| 2.| identity			| 		|
| 3.| generated			|		|
| 4.| is_dropped		|		|
| 5.| collation			| 		|
| 6.| acl				| -		|

---

### インデックスメタデータ

管理用メタデータは除く。

| # | メタデータ名		| 備考	|
|---|---				|---	|
| 1.| id 				| -		|
| 2.| name				| -		|
| 3.| namespace			| -		|
| 4.| owner_id			| -		|
| 5.| access_method		| -		|
| 6.| acl				| -		|
| 7.| number_of_columns			| インデックス内の列数		|
| 8.| number_of_key_columns		| include列を除いた列数		|
| 9.| is_unique			| -		|
|10.| is_primary		| -		|
|11.| keys				| 列番号の配列（非キー（include列）を含む）		|
|12.| option			| ASC/DESC, NULLS_LAST/FIRST ※キーのみ値を持つ		|

将来的に追加される可能性のある属性。

| # | メタデータ名		| 備考	|
|---|---				|---	|
| 1.| collation 		| -		|

---

### 制約メタデータ

管理用メタデータは除く。

| # | メタデータ名		| 備考	|
|---|---				|---	|
| 1.| id 				| -		|
| 2.| name				| -		|
| 3.| namespace			| -		|
| 4.| type				| -		|
| 5.| table_id			| -		|
| 6.| index_id			| -		|
| 7.| keys				| 制約の対象となる列番号のリスト		|
| 8.| expression		| チェック制約の式	|

将来的に追加される可能性のある属性。

| # | メタデータ名		| 備考	|
|---|---				|---	|
| 1.| deferrable		| -		|
| 2.| deferred			| -		|
| 3.| foreign_table_id	| -		|
| 4.| foreign_update_type	| -		|
| 5.| foreign_delete_type	| -		|
| 6.| foreign_match_type	| -		|

以上
