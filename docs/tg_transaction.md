# ストプロ(LTx)管理機能 ユーザ定義関数

2023.02.17 NEC  
2023.03.06 NEC  

## tg_transaction

tg_transactionは、Tsurugiのトランザクションを設定します。  

### 概要

~~~ txt
◆ tg_set_transaction ( type [, priority, label [, table [, ...] ] ] )

◆ tg_show_transaction (  )
~~~

Tsurugiのトランザクションは、種別、プライオリティ、ラベル、書き込み予約テーブル（複数指定可）のオプションがあります。  
各オプションのデフォルトは、種別がshort、プライオリティがTsurugiのデフォルト(0)、ラベルがpgsql-transaction、書き込み予約テーブルはなしとなります。  

tg_set_transactionは、Tsurugiのトランザクションを開始する前に実行する必要があります。  
tg_set_transactionを実行しないでTsurugiのトランザクションを開始した場合は、直前に実行した設定（一度も実行していない場合は各オプションのデフォルト）が反映されます。

Tsurugiのlongトランザクションは、トランザクションブロックを開始する前に設定することを推奨します。  
PostgreSQLのトランザクションブロックは、明示的にBEGINコマンドを実行する必要があり、デフォルト（BEGINがない場合）は、各クエリーが個々のトランザクションの中で実行され、クエリーの終わりで暗黙的にコミット（失敗した場合はロールバック）が実行されることに注意してください。

tg_show_transactionは、現在のTsurugiのトランザクション設定を表示します。  

なお、tg_transactionは、PostgreSQLのユーザ定義関数であるため、事前に後述のCREATE FUNCTIONコマンドで登録する必要があり、SELECTコマンドで実行します。

### 説明

#### ◆ tg_set_transaction ( *type*, *priority*, *label*, *table* [, ...] )  

  トランザクションの種別、プライオリティ、ラベル、書き込み予約テーブルを設定する。

#### ◆ tg_set_transaction ( *type*, *priority*, *label* )  

  トランザクションの種別、プライオリティ、ラベルを設定する。  
  書き込み予約テーブルはデフォルトになります。

#### ◆ tg_set_transaction ( *type* )  

  トランザクションの種別を設定する。  
  プライオリティ、ラベル、書き込み予約テーブルはデフォルトになります。  

#### ◆ tg_show_transaction ( )  

  現在のトランザクション設定を表示する。  

### パラメータ

* *type*  

  トランザクションの種別です。以下のいずれかを指定します。  

  * **'default'**  
      use default transaction type.
  * **'short'**  
      short transactions (optimistic concurrency control).
  * **'long'**  
      long transactions (pessimistic concurrency control).
  * **'read_only'**  
      read only transactions (may be abort-free).

  現在のトランザクション設定を表示した場合、defaultが0、shortが1、longが2、read_onlyが3と表示されます。

* *priority*  

  トランザクションのプライオリティです。以下のいずれかを指定します。  

  * **'default'**  
     use default transaction priority.
  * **'interrupt'**  
     halts the running transactions immediately.
  * **'wait'**  
     prevents new transactions and waits for the running transactions will end.
  * **'interrupt_exclude'**  
     halts the running transactions immediately, and keep lock-out until its end.
  * **'wait_exclude'**  
     prevents new transactions and waits for the running transactions will end, and keep lock-out until its end.

  現在のトランザクション設定を表示した場合、defaultが0、interruptが1、waitが2、interrupt_excludeが3、wait_excludeが4と表示されます。

* *label*  

  トランザクションのラベルを指定します。  

* *table*  

  longトランザクションの書き込み予約テーブルを指定します。  

### 例

#### ■ Tsurugiのトランザクションを設定します

  ~~~ sql
  postgres=# select tg_set_transaction('long', 'wait', 'pgsql-long-transaction', 'table1', 'table2', 'table3');
                tg_set_transaction
  --------------------------------------------------
  {                                                +
      "TransactionType": "2",                      +
      "TransactionPriority": "0",                  +
      "TransactionLabel": "pgsql-long-transaction",+
      "WritePreserve": [                           +
          {                                        +
              "TableName": "table1"                +
          },                                       +
          {                                        +
              "TableName": "table2"                +
          },                                       +
          {                                        +
              "TableName": "table3"                +
          }                                        +
      ]                                            +
  }                                                +

  (1 row)

  postgres=#
  ~~~

* TransactionType（2:long）がトランザクションの種別を示しています。
* TransactionPriority（2:wait）がトランザクションのプライオリティを示しています。
* TransactionLabel（pgsql-long-transaction）がトランザクションのラベルを示しています。
* WritePreserveが書き込み予約テーブル(table1, table2, table3)を示しています。

#### ■ トランザクションの種別をread_onlyに設定します

  ~~~ sql
  postgres=# select tg_set_transaction('read_only');
              tg_set_transaction
  ---------------------------------------------
  {                                           +
      "TransactionType": "3",                 +
      "TransactionPriority": "0",             +
      "TransactionLabel": "pgsql-transaction",+
      "WritePreserve": [                      +
          {                                   +
              "TableName": ""                 +
          }                                   +
      ]                                       +
  }                                           +

  (1 row)

  postgres=#
  ~~~

* TransactionType（3:read_only）がトランザクションの種別を示しています。
* TransactionPriority、TransactionLabel、WritePreserveはデフォルトになります。

#### ■ 現在のトランザクション設定を表示します

  ~~~ sql
  postgres=# select tg_show_transaction();
              tg_show_transaction
  ----------------------------------------------
  {                                           +
      "TransactionType": "1",                 +
      "TransactionPriority": "0",             +
      "TransactionLabel": "pgsql-transaction",+
      "WritePreserve": [                      +
          {                                   +
              "TableName": ""                 +
          }                                   +
      ]                                       +
  }                                           +

  (1 row)
  ~~~

* 現在のトランザクション設定が確認できます。

### ユーザ定義関数の登録

  tg_transactionは、PostgreSQLのユーザ定義関数であるため、事前に以下のCREATE FUNCTIONで登録する必要があります。

  ~~~ sql
  CREATE FUNCTION tg_set_transaction(text, text, text, variadic text[]) RETURNS cstring
    AS 'ogawayama_fdw' LANGUAGE C STRICT;

  CREATE FUNCTION tg_set_transaction(text, text, text) RETURNS cstring
    AS 'ogawayama_fdw' LANGUAGE C STRICT;

  CREATE FUNCTION tg_set_transaction(text) RETURNS cstring
    AS 'ogawayama_fdw' LANGUAGE C STRICT;

  CREATE FUNCTION tg_show_transaction() RETURNS cstring
    AS 'ogawayama_fdw' LANGUAGE C STRICT;
  ~~~

以上
