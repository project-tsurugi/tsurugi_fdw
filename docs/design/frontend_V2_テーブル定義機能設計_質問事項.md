# frontend V2 テーブル定義機能設計 質問

## 開発の目的

* 2020年4月8日ノーチラス・テクノロジーズ様との打ち合わせから抜粋
    * テキストベースの受け渡しは、PostgreSQLとTsurugiの仕様の相違を吸収しにくい。
    * 今後ALTERコマンド等に対応をしていくことを考えると、もう少しシステマチックで拡張性のある方式を検討したい。
        * V1ではデータ型名を正規表現で置換する方法でクエリーを書き換えている。

## 将来verで検討する機能項目一覧

|将来verで検討する機能項目|V2での実装方針|将来verでの方針|優先度|
|----|----|----|----|
|[サポートする型](#サポートする型)以外の型|エラーメッセージを出力。<br>テーブル定義されない。<br>date、配列がお客様に利用されるため、拡張性ある実装とする。|date、配列の利用あり|高|
|NOT NULL、PRIMARY KEY制約以外の制約|エラーメッセージを出力。<br>テーブル定義されない。|外部キー制約など性能測定に必要であるため優先？|中|
|スキーマ名|frontendは、PostgreSQLでスキーマ名が入力されても、構文エラーとしないが、<br>スキーマ名はmetadata-managerに格納されない。<br>つまり、スキーマ名の入力は無視して処理する。|性能測定が優先であるため、ユーザー管理機能で検討？|中|
|インデックスの方向(DEFAULT,ASC,DSC)|V1と同様に全カラムに対して常に **"0"** を格納||中|
|DEFAULT制約の式の格納|V1と同様に全カラムに対して常に **"(undefined)"** を格納 <br> ※V1.0ではDEFAULT制約を指定しない場合、常に"(undefined)"で格納されている||低|
|[サポートするロケール](#サポートするロケール)以外のロケール|エラーハンドリングしない<br>注意事項として提示||低|


## 質問事項

1. V2でサポートする型に、smallint、textを増やしても良いか。
2. 

## テーブル定義機能シーケンス

### シーケンス概要

#### シーケンス図
![](img/out/CREATE_TABLE_overview/テーブル定義シーケンス概要.png)

#### 図中のMessage(コマンドの種類, テーブルのスキーマ名, テーブル名, その他パラメーター)
* ogawayamaへのパラメーターの渡し方（関数名・型・パラメーター・デザインパターンなど）については、すべてノーチラス・テクノロジーズ様に決定していただきたい。
* コマンドの種類とは、CREATE TABLEを意味している。
    * ALTER TABLEや、CREATE INDEXなど、他のコマンドに対応するために、コマンドの種類と記載している。
* デザインパターンについて
    * V1では、Builderパターンを使用されていると認識している。例えば、Builderパターンの中で、テーブル名とコマンドの種類などを渡せるようにしてもらってもよいと思っているが、どのデザインパターンを採用するかはノーチラス・テクノロジーズ様に検討していただきたい。
        * Builderパターン  
        https://www.techscore.com/tech/DesignPattern/Builder.html/    

    * 岡田(耕)さんのコメント
        * Win32のSendMessage関数のような実装を想定しているが、Tsurugiに最適なのかは確信はない。   
        https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendmessage
        * この方法のいいところは、複数のコンポーネントに向けて同じメッセージをブロードキャストしやすいところだと思っている。
        * 例えば、メタデータの更新を全体に知らせたり、システム停止の開始を要求する、など。
        * ちなみにWindowsでは同期型がSendMessageで非同期型はPostMessageと言う。

#### metadata-managerに格納する値一覧

##### Columnメタデータオブジェクト

|key|valueの型|valueの説明|valueに格納する値|
|----|----|----|----|----|
| "dataTypeId"        | number        [*] | カラムのデータ型のID | V1と同じID。[PostgreSQLとカラムのデータ型のID対応表](#postgresqlとカラムのデータ型のid対応表)を参照 | 
| "varying"         | bool        [+] | **文字列長が可変か否か** | **PostgreSQLの型で、varcharの場合、true。charの場合false。それ以外の場合、keyを作成しない。** |
| "default"           | string        [+] | デフォルト式 | **V1と同様に全カラムに対して常に "(undefined)" を格納** <br> ※V1.0ではDEFAULT制約を指定しない場合、常に"(undefined)"で格納されている |
| "direction"         | number        [+] | 方向（0: DEFAULT, 1: ASCENDANT, 2: DESCENDANT）| **V1と同様に全カラムに対して常に"0"を格納** |

###### PostgreSQLとカラムのデータ型のID対応表
* カラムのデータ型のIDは、[DataTypeメタデータオブジェクトのvalueに格納する値](#datatypeメタデータオブジェクトのvalueに格納する値)を参照

|大分類|PostgreSQLの型(名)|PostgreSQLの型(別名)|カラムのデータ型のID|
|-:|:-|:-|:-|
|整数|smallint|int2|2|
|整数|integer|int, int4|4|
|整数|bigint|int8|6|
|浮動小数点|real|float4|8|
|浮動小数点|double precision|float8|9|
|文字列|text||11|
|文字列|character [ (n) ]|char [ (n) ]|11|
|文字列|character varying [ (n) ]|varchar [ (n) ]|11|

###### DataTypeメタデータオブジェクトのvalueに格納する値

* 太字は変更
* id番号に削除と書いてあるものは、key自体を削除。id番号は変更しない。

|id	| name	   | pg_dataType	    | pg_dataTypeName | pg_dataTypeQualifiedName
|----|----|----|----|----|
|~~1~~ バグのため削除 |~~INT~~   |~~0~~	         | ~~smallint~~  ※これがバグ            | 
|2| INT16	   | 0	         |**smallint**              | int2
|~~3~~ 不要なため削除| INT	   | 0	     | integer             | 
|4| INT32	   | 0	                | integer           | int4
|~~5~~ 不要なため削除| BIGINT   | 0	                | bigint             | 
|6| INT64	   | 0	                | bigint            | int8
|~~7~~ 不要なため削除| FLOAT	   | 0	                | real             | 
|8| FLOAT32  | 0	                | **real**             | float4
|9| FLOAT64  | 0	                | **double precision**             | float8
|~~10~~ 不要なため削除| DOUBLE   | 0	                | double precision | 
|11| TEXT	   | 0	                | **text**             | text
|~~12~~ 不要なため削除| STRING   | 0	                | text          | 
|13| CHAR	   | 0	                | char             | bpchar
|14| VARCHAR  | 0	                | varchar             | varchar
