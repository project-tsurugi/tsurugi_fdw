# tg_set_transaction

tg_set_transaction - デフォルトのトランザクション特性を設定する

## 概要

```
tg_set_transaction( transaction_type [, priority [, label ] ] )

transaction_typeには以下のいずれかが入ります。

    { 'short' | 'long' | 'read_only' }

priorityには以下のいずれかが入ります。

    { 'default' | 'interrupt' | 'wait' | 'interrupt_exclude' | 'wait_exclude' }
```

## 説明

`tg_set_transaction`はTsurugiのトランザクション（Tsurugiトランザクション）のトランザクション特性を設定します。このコマンドで設定されたトランザクション特性はコマンド実行以降に開始されるTsurugiトランザクションのデフォルトのトランザクション特性になります。また、トランザクション実行後に再度このコマンドを実行することによってデフォルトのトランザクション特性を上書きすることができます。

利用可能なトランザクション特性は、トランザクションの種別、トランザクションの優先度、トランザクションのラベルです。
必須パラメータはトランザクションの種別のみです。2番目のパラメータにはトランザクションの優先度を指定します（省略した場合はTsurugiにおけるデフォルトの優先度が適用されます）。3番目のパラメータではトランザクションに任意のラベル名を指定することができます（省略した場合は'pgsql-transaction'というラベル名が適用されます）。

`tg_set_transaction`は、Tsurugiトランザクションを開始する前に実行する必要があります。`tg_set_transaction`によってトランザクション特性を設定せずにTsurugiトランザクションを開始した場合は、直前に設定したトランザクション特性（一度も実行していない場合はデフォルトの設定）が反映されます。

## パラメータ

#### *transaction_type*  

トランザクションの種別です。以下のいずれかを文字列を指定します。  
括弧内の数値は各種別に割り当てられたパラメータ値を示します。

* **'short'**  (1)

    short transactions (optimistic concurrency control).

* **'long'**  (2)

    long transactions (pessimistic concurrency control).

* **'read_only'**  (3)

    read only transactions (may be abort-free).

#### *priority*  

トランザクションの優先度です。以下のいずれかの文字列を指定します。  
括弧内の数値は各優先度に割り当てられたパラメータ値を示します。

  * **'default'** (0)

     use default transaction priority.

  * **'interrupt'**  (1)

     halts the running transactions immediately.

  * **'wait'**  (2)

     prevents new transactions and waits for the running transactions will end.

  * **'interrupt_exclude'**  (3)

     halts the running transactions immediately, and keep lock-out until its end.

  * **'wait_exclude'**  (4)

     prevents new transactions and waits for the running transactions will end, and keep lock-out until its end.

#### *label*  

  トランザクションのラベル名を文字列で指定します。  
  ラベル名はTsurugiトランザクションの実行内容に影響を与えません。

## 例

#### ■ Tsurugiトランザクションの特性を設定する

  ```sql
  postgres=# select tg_set_transaction('short', 'interrupt', 'pgsql-short-transaction');
                tg_transaction
  --------------------------------------------------
  {                                                +
      "TransactionType": "1",                      +
      "TransactionPriority": "1",                  +
      "TransactionLabel": "pgsql-short-transaction"+
  }                                                +

  (1 row)
  ```

* `TransactionType`はトランザクション種別を示します（"`1`"は`short`を意味します）
* `TransactionPriority`はトランザクションの優先度を示します（"`1`"は`interrupt`を意味します）
* `TransactionLabel`はトランザクションのラベル名を示します。

#### ■ longトランザクションを設定する

  ```sql
  postgres=# select tg_set_transaction('long');
                tg_transaction
  --------------------------------------------------
  {                                                +
      "TransactionType": "2",                      +
      "TransactionPriority": "0",                  +
      "TransactionLabel": "pgsql-transaction",     +
      "WritePreserve": [                           +
      ]                                            +
  }                                                +

  (1 row)
  ```
* `TransactionType`はトランザクション種別を示します（"`2`"は`long`を意味します）
* `TransactionPriority`と`TransactionLabel`にはデフォルト値が設定されます。
* longトランザクションを指定した場合のみWritePreserveパラメータが追加されます。Write Preserveの対象となるテーブルを設定するには[`tg_set_write_preserve`](./tg_set_write_preserve.md)を使用します。

## 注意事項

PostgreSQLの`SET TRANSACTION`は**実行中の**トランザクションのトランザクション特性を変更しますが、`tg_set_transaction`はtsurugiトランザクションを**開始する前**に実行する必要があります。

---
