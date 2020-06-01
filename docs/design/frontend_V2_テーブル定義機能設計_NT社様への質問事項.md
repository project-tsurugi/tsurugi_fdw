# frontend V2 テーブル定義機能設計 質問事項 {ignore=True}

## 目次 {ignore=True}
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [開発の目的](#開発の目的)
- [質問事項](#質問事項)
  - [1. V2でサポートする型に、次の型を増やしてもよいか。](#1-v2でサポートする型に-次の型を増やしてもよいか)
  - [2. ogawayamaへのパラメーターの渡し方について](#2-ogawayamaへのパラメーターの渡し方について)
    - [シーケンス概要](#シーケンス概要)
      - [シーケンス図](#シーケンス図)
      - [Commandクラス](#commandクラス)
      - [図中のmessage(Command command)](#図中のmessagecommand-command)
  - [3. metadata-managerに格納する値について](#3-metadata-managerに格納する値について)
      - [Tableメタデータオブジェクト](#tableメタデータオブジェクト)
    - [Columnメタデータオブジェクト](#columnメタデータオブジェクト)
    - [PostgreSQLとカラムのデータ型のID対応表](#postgresqlとカラムのデータ型のid対応表)
    - [データ型ID一覧](#データ型id一覧)
  - [4. 実行エンジンがサポートするロケールは何か](#4-実行エンジンがサポートするロケールは何か)

<!-- /code_chunk_output -->

## 開発の目的

* 2020年4月8日ノーチラス・テクノロジーズ様との打ち合わせから抜粋
    * テキストベースの受け渡しは、PostgreSQLとTsurugiの仕様の相違を吸収しにくい。
    * 今後ALTERコマンド等に対応をしていくことを考えると、もう少しシステマチックで拡張性のある方式を検討したい。
        * V1ではデータ型名を正規表現で置換する方法でクエリーを書き換えている。

## 質問事項

### 1. V2でサポートする型に、次の型を増やしてもよいか。

|大分類|PostgreSQLの型(名)|PostgreSQLの型(別名)|ogawayamaの型（名）|
|-:|:-|:-|:-|
|整数|smallint|int2|INT16|
|文字列|text||TEXT|
|文字列|character [ (n) ]|char [ (n) ]|TEXT|
|文字列|character varying [ (n) ]|varchar [ (n) ]|TEXT|

### 2. ogawayamaへのパラメーターの渡し方について
#### シーケンス概要

##### シーケンス図
![](img/out/CREATE_TABLE_overview/テーブル定義シーケンス概要.png)

##### Commandクラス
![](img/out/Command/Command.png)

##### 図中のmessage(Command command)
* デザインパターンについて
    * V1では、Builderパターンを使用されていると認識している。
        * Builderパターン  
        https://www.techscore.com/tech/DesignPattern/Builder.html/    
    * 【質問】V2では、ogawayamaへのパラメーターの渡し方は、次のように、Builderパターンの中で、Commandクラスを渡してもよいか。
        * こうすることで、ogawayamaと通信するコード量が減るため。
        * パラーメーターの渡し方例

    ~~~C
        CreateTableCommand command{id,name,table_id} //今回追加するCommandクラスの具象クラス

        stub::Transaction* transaction;
        error = StubManager::begin(&transaction);
        if (error != ERROR_CODE::OK) 
        {
            std::cerr << "begin() failed." << std::endl;
            return ret_value;
        }

        error = transaction->message(command); //今回追加するmessage(Command command)関数。引数はCommandクラス

        if (error != ERROR_CODE::OK) 
        {
            elog(ERROR, "transaction::message(%s) failed. (%d)", command.name, (int) error); //エラーメッセージの変更
            return ret_value;
        }

        error = transaction->commit();
        if (error != ERROR_CODE::OK) 
        {
            elog(ERROR, "transaction::commit() failed. (%d)", (int) error);
            return ret_value;
        }
        StubManager::end();

        ret_value = true;

        return ret_value;
    }
    ~~~

    * 岡田(耕)さんのコメント
        * Win32のSendMessage関数のような実装を想定しているが、Tsurugiに最適なのかは確信はない。   
        https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendmessage
        * この方法のいいところは、複数のコンポーネントに向けて同じメッセージをブロードキャストしやすいところだと思っている。
        * 例えば、メタデータの更新を全体に知らせたり、システム停止の開始を要求する、など。
        * ちなみにWindowsでは同期型がSendMessageで非同期型はPostMessageと言う。

### 3. metadata-managerに格納する値について

* メタデータのフォーマットは次を参照
https://github.com/project-tsurugi/manager/blob/df3b3a7a0a7e7e7c3643a9bc00baef50a02e6f27/metadata-manager/docs/table_metadata.md#%E3%83%A1%E3%82%BF%E3%83%87%E3%83%BC%E3%82%BF%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%83%E3%83%88

##### Tableメタデータオブジェクト
* スキーマ名について
    * V1と同様に、keyを作成しない？★ノーチラス・テクノロジーズ様に確認
        * V1では、SELECT/INSERT/UPDATE/DELETE構文で、Tsurugiにスキーマ名を指定するとエラーになるがどうするか？
        * ユーザー管理機能で対応でもよさそう？よく分からない。

|key|valueの型|valueの説明|valueに格納する値|
|----|----|----|----|----|
| "namespace"  | string [+]        | スキーマ名    | **keyを作成しない。**  |

#### Columnメタデータオブジェクト
* Columnメタデータオブジェクトのvalueに格納する値は次の通りでよいか。

|key|valueの型|valueの説明|valueに格納する値|
|----|----|----|----|----|
| "dataTypeId"        | number        [*] | カラムのデータ型のID | smallint以外、V1と同じID。[PostgreSQLとカラムのデータ型のID対応表](#postgresqlとカラムのデータ型のid対応表)を参照 | 
| "varying"         | bool        [+] | **文字列長が可変か否か** | **PostgreSQLの型で、varcharの場合、true。charの場合false。それ以外の場合、keyを作成しない。** |
| "default"           | string        [+] | デフォルト式 | **V1と同様に全カラムに対して常に "(undefined)" を格納** <br> ※V1.0ではDEFAULT制約を指定しない場合、常に"(undefined)"で格納されている |
| "direction"         | number        [+] | 方向（0: DEFAULT, 1: ASCENDANT, 2: DESCENDANT）| **V1と同様に全カラムに対して常に"0"を格納** |

#### PostgreSQLとカラムのデータ型のID対応表

|大分類|PostgreSQLの型(名)|PostgreSQLの型(別名)|カラムのデータ型のID <br>※[データ型ID一覧](#データ型id一覧)を参照|
|-:|:-|:-|:-|
|整数|smallint|int2|2|
|整数|integer|int, int4|4|
|整数|bigint|int8|6|
|浮動小数点|real|float4|8|
|浮動小数点|double precision|float8|9|
|文字列|text||11|
|文字列|character [ (n) ]|char [ (n) ]|11|
|文字列|character varying [ (n) ]|varchar [ (n) ]|11|

#### データ型ID一覧

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

### 4. 実行エンジンがサポートするロケールは何か

|項目|値|
|----|----|
|照合順序(LC_COLLATE) ||
|文字の種類(LC_CTYPE)||
|エンコーディング(ENCODING)||
