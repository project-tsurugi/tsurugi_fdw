# message-broker API
## クラス図
![](img/out/Command_detail/Command_detail.png)

## 各クラスの説明
### MessageBroker
#### 説明
* メッセージを送信する。
#### メソッド
* Status send_message(Message* message)
  * 処理内容：MessageクラスにセットされたすべてのReceiverに対して、メッセージを送信する。
  * 条件
    * 事前条件：Messageクラスのすべてのフィールドがセットされている。
    * 事後条件：
      * メッセージを受信したコンポーネントが返したエラーコードが「FAILURE」である場合、概要エラーコード・詳細エラーコードを返す。
        * 概要エラーコード：メッセージに対応する処理が成功したか失敗したか
        * 詳細エラーコード：各コンポーネントで定義されているエラーコード
      * すべてのコンポーネントが返したエラーコードが「SUCCESS」である場合、AllComponentsSuccessStatusを返す。
      * 詳細は[Statusクラス](#statusクラス)を参照。

### Message
#### 説明
* メッセージの内容、メッセージのReceiverリストを保持する。

#### フィールド
|変数名|説明|
|---|---|
|id|ユーザーが入力した構文を伝えるためのID|
|object_id|追加・更新・削除される対象のオブジェクトID 例）テーブルメタデータのオブジェクトID|
|receivers|メッセージのReceiverのリスト。例）OltpReceiver、OlapReceiver|
|message_type_name|エラーメッセージ出力用の文字列　例）"CREATE TABLE"|

* id
  * 列挙型(enum class)
    * 規定型:int
    * 次の通り管理する。
      * コンポーネント名：manager/message-broker
      * 名前空間：manager::message 
    * メッセージID一覧
      * ユーザーが入力した構文に応じて、各コンポーネントにその構文に対応するメッセージIDを伝える。

        |メッセージID|ユーザーが入力した構文|
        |---|---|
        |CREATE_TABLE|CREATE TABLE構文|

#### メソッド
* void set_receiver(Receiver *receiver_)
  * メッセージのReceiverをセットする。

#### Message派生クラス一覧

|クラス名|ユーザーが入力した構文|
|---|---|
|CreateTableMessage|CREATE TABLE構文|

### Receiver
#### 説明
* メッセージを受信する。
#### メソッド
* Status receive_message(Message* message)
  * 処理内容：メッセージを受信する。
  * 条件
    * 事前条件：なし
    * 事後条件：
      * メッセージを受信したコンポーネントは、概要エラーコード・詳細エラーコードを返す。
        * 概要エラーコード：メッセージに対応する処理が成功した場合「SUCCESS」。失敗した場合「FAILURE」
        * 詳細エラーコード：各コンポーネントで定義されているエラーコード
      * 詳細は[Statusクラス](#statusクラス)を参照。

### Status
#### 説明
* send_message()やreceive_message()の戻り値

#### クラス図
  ![](img/out/Status/Status.png)

#### フィールド
* 概要エラーコード・コンポーネントIDは、次の通り管理する。
  * コンポーネント名：manager/message-broker
  * 名前空間：manager::message  
* 詳細エラーコードは、各コンポーネントが管理する。名前空間は各コンポーネントが決定する。
* 概要エラーコードと対応する詳細エラーコード

|error_code|sub_error_code|
|---|---|
|SUCCESS|各コンポーネントで管理される成功したときのエラーコード 例)ogawayama::stub::ErrorCode::OK|
|FAILURE|各コンポーネントで管理される成功以外のエラーコード 例)ogawayama::stub::ErrorCode::UNKNOWN,ogawayama::stub::ErrorCode::SERVER_FAILUREなど|

* component_id
  * エラーコードを返すコンポーネントに対して、コンポーネントを一意に特定するためID
  * 列挙型(enum class)で作成する。
    * 規定型:int
    * コンポーネントID一覧

      |コンポーネントID|コンポーネント|
      |---|---|
      |ALL_COMPONENTS|すべてのコンポーネント|
      |OGAWAYAMA|ogawayama|
      |OLAP|olap|

#### AllComponentsSuccessStatus
* send_message()の戻り値。すべてのコンポーネントが、受信したメッセージに対応する処理を成功した場合返される。
* 各フィールドに格納される値
  |フィールド名| 値|
  |---|---|
  | error_code | SUCCESS | 
  | sub_error_code | SUCCESS |
  | component_id |  ALL_COMPONENTS |
