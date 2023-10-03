# [リファレンス（UDF）](../udf_reference.md)

## tg_set_transaction

tg_set_transaction - デフォルトのトランザクション特性を設定する

### 概要

```
tg_set_transaction( transaction_type [, priority [, label ] ] )

transaction_typeには以下のいずれかが入ります。

    { 'short' | 'long' | 'read_only' }

priorityには以下のいずれかが入ります。

    { 'default' | 'interrupt' | 'wait' | 'interrupt_exclude' | 'wait_exclude' }
```

### 説明

`tg_set_transaction`はTsurugiのトランザクション（Tsurugiトランザクション）のトランザクション特性を設定します。このコマンドで設定されたトランザクション特性はコマンド実行以降に開始されるTsurugiトランザクションのデフォルトのトランザクション特性になります。

利用可能なトランザクション特性は、トランザクションの種別、トランザクションの優先度、トランザクションのラベルです。
必須パラメータはトランザクションの種別のみです。２番目のパラメータにはトランザクションの優先度を指定します（省略した場合はTsurugiにおけるデフォルトの優先度が適用されます）。３番目のパラメータではトランザクションに任意のラベル名を指定することができます（省略した場合は'pgsql-transaction'というラベル名が適用されます）。

`tg_set_transaction`は、Tsurugiトランザクションを開始する前に実行する必要があります。`tg_set_transaction`によって一度もトランザクション特性を変更していない場合は、以下のデフォルトの設定が適用されます。

- トランザクション種別 - **'short'**
- 優先度 - **'default'**
- ラベル名 - **'pgsql-transaction'**

### パラメータ

#### *transaction_type*  

トランザクションの種別です。以下のいずれかを文字列を指定します。  
かっこ内の数値は各種別に割り当てられたパラメータ値を示します。

- **'short'**  (1)

    short transactions (optimistic concurrency control).

- **'long'**  (2)

    long transactions (pessimistic concurrency control).

- **'read_only'**  (3)

    read only transactions (may be abort-free).

#### *priority*  

トランザクションの優先度です。以下のいずれかの文字列を指定します。  
かっこ内の数値は各優先度に割り当てられたパラメータ値を示します。

- **'default'** (0)

     use default transaction priority.

- **'interrupt'**  (1)

     halts the running transactions immediately.

- **'wait'**  (2)

     prevents new transactions and waits for the running transactions will end.

- **'interrupt_exclude'**  (3)

     halts the running transactions immediately, and keep lock-out until its end.

- **'wait_exclude'**  (4)

     prevents new transactions and waits for the running transactions will end, and keep lock-out until its end.

#### *label*  

トランザクションのラベル名を文字列で指定します。  
ラベル名はTsurugiトランザクションの実行処理に影響を与えません。

### 注釈

PostgreSQLの`SET transaction`は**実行中の**トランザクションのトランザクション特性を変更しますが、`tg_set_transaction`はtsurugiトランザクションを**開始する前**に実行する必要があります。Tsurugiトランザクションでは、トランザクションの実行中にトランザクション特性を変更することはできません。

### 例

#### デフォルトのトランザクション特性を変更する

  ```sql
  postgres=# select tg_set_transaction('short', 'interrupt', 'pgsql-short-transaction');
                tg_transaction
  --------------------------------------------------
  {                                                +
      "transactionType": "1",                      +
      "transactionPriority": "1",                  +
      "transactionLabel": "pgsql-short-transaction"+
  }                                                +

  (1 row)
  ```

- `transactionType`はトランザクション種別を示します（"`1`"は`short`を意味します）
- `transactionPriority`はトランザクションの優先度を示します（"`1`"は`interrupt`を意味します）
- `transactionLabel`はトランザクションのラベル名を示します

#### Longトランザクションを設定する

  ```sql
  postgres=# select tg_set_transaction('long');
                tg_transaction
  --------------------------------------------------
  {                                                +
      "transactionType": "2",                      +
      "transactionPriority": "0",                  +
      "transactionLabel": "pgsql-transaction",     +
      "writePreserve": [                           +
      ]                                            +
  }                                                +

  (1 row)
  ```

- `transactionType`はトランザクション種別を示します（"`2`"は`long`を意味します）
- `transactionPriority`と`transactionLabel`にはデフォルト値が設定されます
- Longトランザクションを指定した場合のみwritePreserveパラメータが追加されます
  - write Preserveの対象となるテーブルを設定するには[`tg_set_write_preserve`](./tg_set_write_preserve.md)を使用します

---
