# Tsurugi テーブル管理機能 メタデータ
2022.07.22 NEC  

# Metadata::Tablesクラス
  テーブル管理機能で使用するメタデータを管理する。

## Tableメタデータ(root)  

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

## Tableメタデータオブジェクト

|key|valueの型|valueの説明|valueに格納する値|[PostgreSQLのクエリツリー](#appendix-PostgreSQLのクエリツリー)から取得する属性(クラス名.属性)|
|----|----|----|----|----|
| "id"         | number [-]        | テーブルID                           | -  | -                   |
| "name"       | string [*]        | テーブル名                           | テーブル名                     | RangeVar.relname    |
| "namespace"  | string [+]        | スキーマ名                           | スキーマ名                     | RangeVar.schemaname |
| "columns"    | array[object] [+] | Columnメタデータオブジェクト          | [Columnメタデータオブジェクト](#columnメタデータオブジェクト)                       | -                   |
| "constraints"| array[object] [+] | Constraintメタデータオブジェクト（表制約）      | [Constraintメタデータオブジェクト](#constraintメタデータオブジェクト)                       | -                   |
| "primaryKey" | array[number] [+] | primaryKeyカラムの"ordinal_position" | 列制約に指定された主キー1つ、表制約に指定された複合主キーのどちらか1つ。<br>(PostgreSQLと同様に、複数の主キーは設定できない。)| <span>IndexStmt.indexParams.name</span> **xor** ColumnDef.constraints |

## Columnメタデータオブジェクト

|key|valueの型|valueの説明|valueに格納する値|[PostgreSQLのクエリツリー](#appendix-PostgreSQLのクエリツリー)から取得する属性(クラス名.属性)|
|----|----|----|----|----|
| "id"                | number        [-] | カラムID                                              | - | - |
| "tableId"           | number        [-] | カラムが属するテーブルのID                             | - | - |
| "name"              | string        [*] | カラム名                                              | カラム名 | ColumnDef.colname |
| "ordinalPosition"   | number        [*] | カラム番号(1 origin)                                  | カラム番号(1 origin) | CreateStmt.tableEltsリストの並び順 |
| "dataTypeId"        | number        [*] | カラムのデータ型のID | [PostgreSQLとカラムのデータ型のID対応表](#postgresqlとカラムのデータ型のid対応表)を参照 | TypeName.names **xor** TypeName.typeOid |
| "dataLength"        | array[number] [+] | データ長(配列長) varchar(20)など ※NUMERIC(precision,scale)を考慮してarray[number] にしている。               | char [ (n) ](またはcharacter [ (n) ]), varchar [ (n) ](またはcharacter varying [ (n) ])で(n)が指定された場合、nを格納。<br>(n)が省略された場合、charの場合は1を格納、varcharの場合は本keyを作成しない。<br>char、varchar以外の型の場合、本keyを作成しない。 | TypeName.typmods **xor** TypeName.typmod |
| "varying"         | bool        [+] | 文字列長が可変か否か | varchar [ (n) ](またはcharacter varying [ (n) ])の場合、true。<br>char [ (n) ](またはcharacter [ (n) ])の場合false。<br>それ以外の場合、keyを作成しない。  | TypeName.names **xor** TypeName.typeOid |
| "nullable"          | bool          [*] | NOT NULL制約の有無                                    | NOT NULL制約あり：false、NOT NULL制約なし：true | ColumnDef.is_not_null |
| "direction"         | number        [+] | 方向（0: DEFAULT, 1: ASCENDANT, 2: DESCENDANT）| PRIMARY KEY制約のカラムに対して"1"を格納、その他のカラムに対して常に"0"を格納  | <span>IndexStmt.indexParams.name</span> **xor** ColumnDef.constraints |
| "constraints"| array[object] [+] | Constraintメタデータオブジェクト（列制約）      | [Constraintメタデータオブジェクト](#constraintメタデータオブジェクト)                       | -                   |

## Constraintメタデータオブジェクト

|key|valueの型|valueの説明|valueに格納する値|[PostgreSQLのクエリツリー](#appendix-PostgreSQLのクエリツリー)から取得する属性(クラス名.属性)|
|----|----|----|----|----|
| "id"                | number        [-] | 制約ID                                          | - | - |
| "tableId"           | number        [-] | 制約が属するテーブルのID                          | - | - |
| "columnId"          | number        [-] | 制約が属するカラムのID                            | - | - |
| "contype"           | number        [+] | 制約種別<br>'0':NULL, '1':NOT NULL, '2':DEFAULT, '5':CHECK, '6':PRIMARY KEY, '7':UNIQUE, '9':FOREIGN | 制約種別 | Constraint.contype |
| "conname"           | string        [+] | 制約名                                          | 制約名 | Constraint.conname |
| "expression"        | string        [+] | CHECK制約の検査式 または DEFAULT制約のデータ値    | CHECK制約の検査式 または DEFAULT制約のデータ値 | Constraint.raw_expr **or** Constraint.cooked_expr |
| "keys"              | array[string] [+] | UNIQUE制約の複合キー または PRIMARY KEYの複合キー | UNIQUE制約の複合キー または PRIMARY KEYの複合キー | Constraint.keys |
| "including"         | array[string] [+] | UNIQUE制約の非キー または PRIMARY KEYの非キー     | UNIQUE制約の非キー または PRIMARY KEYの非キー | Constraint.including |
| "secondaryIndex"    | array[object] [+] | Secondary Indexのメタデータオブジェクト     | Secondary Indexのメタデータオブジェクト | - |
| "pktable"           | string        [+] | 外部キー制約 被参照テーブル名                     | 外部キー制約 被参照テーブル名 | Constraint.pktable |
| "pk_attrs"          | array[string] [+] | 外部キー制約 被参照カラム名                         | 外部キー制約 被参照カラム名 | Constraint.pk_attrs |
| "fk_attrs"          | array[string] [+] | 外部キー制約 参照カラム名                         | 外部キー制約 参照カラム名 | Constraint.pk_attrs |
| "fk_matchtype"      | string        [+] | 外部キー制約 被参照テーブルの照合タイプ<br>'f':MATCH FULL, 'p':MATCH PARTIAL, 's':MATCH SIMPLE | 照合タイプ | Constraint.fk_matchtype |
| "fk_upd_action"     | string        [+] | 外部キー制約 被参照行のON UPDATEアクション<br>'a':NO ACTION, 'r':RESTRICT, 'n':SET NULL, 'd':SET DEFALUT | ON IPDATEアクション | Constraint.fk_upd_action |
| "fk_del_action"     | string        [+] | 外部キー制約 被参照行のON DELETEアクション<br>'a':NO ACTION, 'r':RESTRICT, 'n':SET NULL, 'd':SET DEFALUT | ON DELETEアクション | Constraint.fk_del_action |

# Metadata::DataTypesクラス

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

* id番号に削除と書いてあるものは、key自体を削除。id番号は変更しない。

|id	| name	   | pg_dataType	    | pg_dataTypeName | pg_dataTypeQualifiedName
|----|----|----|----|----|
|4| INT32	   | 23	                | integer           | int4
|6| INT64	   | 20	                | bigint            | int8
|8| FLOAT32  | 700                | real             | float4
|9| FLOAT64  | 701                | double precision             | float8
|13| CHAR	   | 1042                | char             | bpchar
|14| VARCHAR  | 1043                | varchar             | varchar

## Appendix. PostgreSQLのクエリツリー
frontendがPostgreSQLから受け取るクエリツリー
![](img/out/query_tree/query_tree.svg)

以上
