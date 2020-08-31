# frontend V2 テーブル定義機能 functional design
2020.07.31 NEC 

## 目次
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [開発の目的](#開発の目的)
- [基本方針](#基本方針)
- [構文・型](#構文型)
  - [サポートするCREATE TABLE構文](#サポートするcreate-table構文)
  - [サポートする型](#サポートする型)
  - [サポートするロケール・文字エンコーディング](#サポートするロケール文字エンコーディング)
  - [構文例](#構文例)
- [metadata-managerに格納する値一覧](#metadata-managerに格納する値一覧)
  - [データベース名](#データベース名)
  - [スキーマ名](#スキーマ名)
  - [Tableメタデータ(root)](#tableメタデータroot)
  - [Tableメタデータオブジェクト](#tableメタデータオブジェクト)
  - [Columnメタデータオブジェクト](#columnメタデータオブジェクト)
    - [PostgreSQLとカラムのデータ型のID対応表](#postgresqlとカラムのデータ型のid対応表)
  - [DataTypeメタデータ(root)](#datatypeメタデータroot)
    - [DataTypeメタデータオブジェクト](#datatypeメタデータオブジェクト)
    - [データ型ID一覧](#データ型id一覧)
- [エラー処理](#エラー処理)
  - [基本方針](#基本方針-1)
  - [メッセージ内容](#メッセージ内容)
    - [構文エラー](#構文エラー)
    - [型エラー](#型エラー)
- [Appendix. PostgreSQLのクエリツリー](#appendix-postgresqlのクエリツリー)

<!-- /code_chunk_output -->


## 開発の目的

* 2020年4月8日ノーチラス・テクノロジーズ様との打ち合わせから抜粋
    * テキストベースの受け渡しは、PostgreSQLとTsurugiの仕様の相違を吸収しにくい。
    * 今後ALTERコマンド等に対応をしていくことを考えると、もう少しシステマチックで拡張性のある方式を検討したい。
        * V1ではデータ型名を正規表現で置換する方法でクエリーを書き換えている。

## 基本方針
* frontend V2の機能は、V1の機能と同じとして、シーケンスの変更およびエラー処理の追加を実施する。
* PostgreSQL互換

* 将来verで検討する機能項目一覧

|将来verで検討する機能項目|V2での実装方針|将来verでの方針|優先度|
|----|----|----|----|
|[サポートする型](#サポートする型)以外の型|エラーメッセージを出力。<br>テーブル定義されない。<br>date、配列がお客様に利用されるため、拡張性ある実装とする。|date、配列の利用あり|高|
|列制約におけるNOT NULL・PRIMARY KEY制約以外の制約<br>表制約におけるPRIMARY KEY制約以外の制約|エラーメッセージを出力。<br>テーブル定義されない。|外部キー制約など性能測定に必要であるため優先？|中|
|スキーマ名|frontendは、PostgreSQLでスキーマ名が入力されても、構文エラーとしないが、<br>スキーマ名はmetadata-managerに格納されない。<br>つまり、スキーマ名の入力は無視して処理する。|性能測定が優先であるため、ユーザー管理機能で検討？|中|
|インデックスの方向(DEFAULT,ASC,DSC)|**V1と同様に、PRIMARY KEY制約のカラムに対して"1"を格納、その他のカラムに対して常に"0"を格納** <br> ||中|
|DEFAULT制約の式の格納|**keyを作成しない。** <br> ※V1.0ではDEFAULT制約を指定しない場合、常に"(undefined)"で格納されている <br> ||低|
|[サポートするロケール・文字エンコーディング](#サポートするロケール文字エンコーディング)以外のロケール|エラーハンドリングしない<br>注意事項として提示||低|
|データ形式フォーマットバージョン、メタデータの世代|"1"固定||低|


## 構文・型
### サポートするCREATE TABLE構文

CREATE TABLE *table_name* ( [  
&nbsp;&nbsp;{ *column_name* *data_type* [ *column_constraint* [ ... ] ]  
&nbsp;&nbsp;&nbsp;&nbsp;| *table_constraint* }  
&nbsp;&nbsp;&nbsp;&nbsp;[, ... ]
] )  
TABLESPACE tsurugi

*column_constraint*には、次の構文が入る。  

[ CONSTRAINT *constraint_name* ]  
{ NOT NULL |   
&nbsp;&nbsp;PRIMARY KEY }  

また、*table_constraint*には、次の構文が入る。 

[ CONSTRAINT *constraint_name* ]  
{ PRIMARY KEY ( *column_name* [, ... ] ) }  

### サポートする型

|大分類|PostgreSQLの型(名)|PostgreSQLの型(別名)|ogawayamaの型（名）|
|-:|:-|:-|:-|
|整数|integer|int, int4|INT32|
|整数|bigint|int8|INT64|
|浮動小数点|real|float4|FLOAT32|
|浮動小数点|double precision|float8|FLOAT64|
|文字列|character [ (n) ]|char [ (n) ]|TEXT|
|文字列|character varying (n) |varchar (n) |TEXT|

※varcharの場合、(n)の省略は未サポート

### サポートするロケール・文字エンコーディング

* 現時点ではPostgreSQLに準拠する方向で検討。

* 実行エンジンがサポートするロケール・文字エンコーディング

|項目|値|
|----|----|
|照合順序(LC_COLLATE) |C|
|文字の種類(LC_CTYPE)|en_US|
|エンコーディング(ENCODING)|UTF-8|

### 構文例

* filmsテーブルを作成します。
    * 列制約にPRIMARY KEY制約・NOT NULL制約
    ~~~sql
    CREATE TABLE films (
        code        char(5) CONSTRAINT firstkey PRIMARY KEY,
        title       varchar(40) NOT NULL,
        did         integer NOT NULL,
        kind        varchar(10),
    ) tablespace tsurugi;
    ~~~
    * 表制約にPRIMARY KEY制約、列制約にNOT NULL制約
    ~~~sql
    CREATE TABLE films (
        code        char(5),
        title       varchar(40),
        did         integer NOT NULL,
        kind        varchar(10),
    PRIMARY KEY (code, title) ) tablespace tsurugi;
    ~~~

## metadata-managerに格納する値一覧

### データベース名
* V1と同様に、keyを作成しない。

### スキーマ名
* V1と同様に、keyを作成しない。

### Tableメタデータ(root)
* valueの型 凡例
```
'*'　:　メタデータ登録時に必須の項目
'+'　:　メタデータ登録時に入力可能な項目
'-'　:　metadata-managerが値を付与する項目
```

|key|valueの型|valueの説明|valueに格納する値|[PostgreSQLのクエリツリー](#appendix-PostgreSQLのクエリツリー)から取得する属性(クラス名.属性)|
|----|----|----|----|----|
|"formatVersion" | number [-]        | データ形式フォーマットバージョン ※V1は"1"固定 | "1"固定 | - |
|"generation"    | number [-]        | メタデータの世代 ※V1は"1"固定                | "1"固定 | - |
|"tables"        | array[object] [*] | Tableメタデータオブジェクト                   | [Tableメタデータオブジェクト](#tableメタデータオブジェクト)  | - |

### Tableメタデータオブジェクト

|key|valueの型|valueの説明|valueに格納する値|[PostgreSQLのクエリツリー](#appendix-PostgreSQLのクエリツリー)から取得する属性(クラス名.属性)|
|----|----|----|----|----|
| "id"         | number [-]        | テーブルID                           | -  | -                   |
| "name"       | string [*]        | テーブル名                           | テーブル名                     | RangeVar.relname    |
| "namespace"  | string [+]        | スキーマ名    | **本keyを作成しない。**  | - |
| "columns"    | array[object] [*] | Columnメタデータオブジェクト          | [Columnメタデータオブジェクト](#columnメタデータオブジェクト)                       | -                   |
| "primaryKey" | array[number] [*] | primaryKeyカラムの"ordinal_position" | **列制約に指定された主キー1つ、表制約に指定された複合主キーのどちらか1つ。**<br>(PostgreSQLと同様に、複数の主キーは設定できない。)| <span>IndexStmt.indexParams.name</span> **xor** ColumnDef.constraints |

### Columnメタデータオブジェクト

|key|valueの型|valueの説明|valueに格納する値|[PostgreSQLのクエリツリー](#appendix-PostgreSQLのクエリツリー)から取得する属性(クラス名.属性)|
|----|----|----|----|----|
| "id"                | number        [-] | カラムID                                              | - | - |
| "tableId"           | number        [-] | カラムが属するテーブルのID                             | - | - |
| "name"              | string        [*] | カラム名                                              | カラム名 | ColumnDef.colname |
| "ordinalPosition"   | number        [*] | カラム番号(1 origin)                                  | カラム番号(1 origin) | CreateStmt.tableEltsリストの並び順 |
| "dataTypeId"        | number        [*] | カラムのデータ型のID | [PostgreSQLとカラムのデータ型のID対応表](#postgresqlとカラムのデータ型のid対応表)を参照 | TypeName.names **xor** TypeName.typeOid |
| "dataLength"        | array[number] [+] | データ長(配列長) varchar(20)など ※NUMERIC(precision,scale)を考慮してarray[number] にしている。               | **char [ (n) ](またはcharacter [ (n) ]), varchar [ (n) ](またはcharacter varying [ (n) ])で(n)が指定された場合、nを格納。<br>(n)が省略された場合、charの場合は1を格納、varcharの場合は本keyを作成しない。<br>char、varchar以外の型の場合、本keyを作成しない。** | TypeName.typmods **xor** TypeName.typmod |
| "varying"         | bool        [+] | **文字列長が可変か否か** | **varchar [ (n) ](またはcharacter varying [ (n) ])の場合、true。<br>char [ (n) ](またはcharacter [ (n) ])の場合false。<br>それ以外の場合、keyを作成しない。**  | TypeName.names **xor** TypeName.typeOid |
| "nullable"          | bool          [*] | NOT NULL制約の有無                                    | NOT NULL制約あり：false、NOT NULL制約なし：true | ColumnDef.is_not_null |
| "default"           | string        [+] | デフォルト式 |**常に本keyを作成しない。** | 取得しない |
| "direction"         | number        [+] | 方向（0: DEFAULT, 1: ASCENDANT, 2: DESCENDANT）| **PRIMARY KEY制約のカラムに対して"1"を格納、その他のカラムに対して常に"0"を格納**  | <span>IndexStmt.indexParams.name</span> **xor** ColumnDef.constraints |

#### PostgreSQLとカラムのデータ型のID対応表

|大分類|PostgreSQLの型(名)|PostgreSQLの型(別名)|カラムのデータ型のID <br>※[データ型ID一覧](#データ型id一覧)を参照|
|-:|:-|:-|:-|
|整数|integer|int, int4|4|
|整数|bigint|int8|6|
|浮動小数点|real|float4|8|
|浮動小数点|double precision|float8|9|
|文字列|character [ (n) ]|char [ (n) ]|**13**|
|文字列|character varying [ (n) ]|varchar [ (n) ]|**14**|

### DataTypeメタデータ(root)
|key|valueの型|valueの説明|valueに格納する値|
|----|----|----|----|
|"formatVersion" | number       | データ形式フォーマットバージョン | "1" 固定 |
|"generation"    | number       | メタデータの世代 | "1" 固定 |
|"dataTypes"     | array[object] | DataTypeメタデータオブジェクト | [DataTypeメタデータオブジェクト](#datatypeメタデータオブジェクト) |

#### DataTypeメタデータオブジェクト
|key|valueの型|valueの説明|valueに格納する値|
|----|----|----|----|
| "id"            | number   | データ型ID | [データ型ID一覧](#データ型id一覧) |
| "name"          | string   | データ型名 |同上|
| "pg_dataType"   | number    | 対応するPostgreSQLのデータ型のOID |同上|
| "pg_dataTypeName"      | string    | ユーザーが入力するPostgreSQLの型名 |同上|
| "pg_dataTypeQualifiedName"      | string    | PostgreSQL内部の修飾型名 |同上|

#### データ型ID一覧

* 太字は変更
* id番号に削除と書いてあるものは、key自体を削除。id番号は変更しない。

|id	| name	   | pg_dataType	    | pg_dataTypeName | pg_dataTypeQualifiedName
|----|----|----|----|----|
|~~1~~ バグのため削除 |~~INT~~   |~~0~~	         | ~~smallint~~  ※これがバグ            | 
|~~2~~ サポートしないため削除| INT16	   | 0	         |smallint              | int2
|~~3~~ 不要なため削除| INT	   | 0	     | integer             | 
|4| INT32	   | 23	                | **integer**           | int4
|~~5~~ 不要なため削除| BIGINT   | 0	                | bigint             | 
|6| INT64	   | 20	                | **bigint**            | int8
|~~7~~ 不要なため削除| FLOAT	   | 0	                | real             | 
|8| FLOAT32  | 700                | **real**             | float4
|9| FLOAT64  | 701                | **double precision**             | float8
|~~10~~ 不要なため削除| DOUBLE   | 0	                | double precision | 
|~~11~~ サポートしないため削除| TEXT	   | 0	                | text             | text
|~~12~~ 不要なため削除| STRING   | 0	                | text          | 
|13| CHAR	   | 1042                | char             | bpchar
|14| VARCHAR  | 1043                | varchar             | varchar

## エラー処理
### 基本方針
* frontendは、Tsurugiでサポートしない構文・型をチェックしてエラーメッセージを出力する。
* frontendは、PostgreSQLでスキーマ名が入力されても、構文エラーとしないが、スキーマ名はmetadata-managerに格納されない。
  * つまり、スキーマ名の入力は無視して処理する。
* PostgreSQLでチェックできないエラー処理のみを、frontendで実施する。
* metadata-manager、ogawayamaで発生したエラーは、呼び出した関数の戻り値でエラーを受け取ってエラーメッセージを出力する。
* PostgreSQLまたはfrontendでエラーが発生した場合、またはfrontendがmetadata-manager、ogawayamaからエラーを受け取った場合、Tsurugiに新しいテーブルは定義されない。また、この場合、metadata-managerに新しいテーブルのメタデータは格納されない。

### メッセージ内容
#### 構文エラー
* Tsurugiでサポートしない構文が実行されたとき、次のエラーメッセージを出力する。
```
ERROR:  Tsurugi does not support this syntax
```

#### 型エラー
* Tsurugiでサポートしない型が指定されたとき、次のエラーメッセージを出力する。
    * %sは、データ型名を出力
```
ERROR:  Tsurugi does not support type %s
```

## Appendix. PostgreSQLのクエリツリー
frontendがPostgreSQLから受け取るクエリツリー
![](img/out/query_tree/query_tree.svg)

以上
