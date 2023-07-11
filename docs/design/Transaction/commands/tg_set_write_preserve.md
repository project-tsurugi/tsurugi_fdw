# tg_set_write_preserve

- tg_set_write_preserve - Longトランザクションにおける書き込み予約テーブルを設定する

## 概要

```
tg_set_write_preserve(table name [, ...])
```

## 説明

TsurugiのLongトランザクションでは、トランザクションの実行中に書き込み（挿入、更新、削除）を行うテーブルをあらかじめ指定しておく必要があります。`tg_set_write_preserve`はLongトランザクションにおいて書き込みを行うテーブルをトランザクション特性に追加します。

トランザクション種別が`'long'`以外のトランザクションに対して書き込み予約テーブルを設定してもその値は無視されます。

## パラメータ

#### *table name*

書き込み予約するテーブル名を記述します。複数のテーブル名を記述することができます。

## 例

`tg_set_transaction`でLongトランザクションを設定してから書き込み予約テーブルを設定します。

```sql
SELECT tg_set_transaction('long');
              tg_set_transaction
--------------------------------------------------
{                                                +
    "transactionType": "2",                      +
    "transactionPriority": "0",                  +
    "transactionLabel": "pgsql-transaction",     +
    "writePreserve": [                           +
    ]                                            +
}                                                +

(1 row)

SELECT tg_set_write_preserve('tg_table1', 'tg_table2', 'tg_table3');
              tg_set_write_preserve
--------------------------------------------------
{                                                +
    "transactionType": "2",                      +
    "transactionPriority": "0",                  +
    "transactionLabel": "pgsql-transaction",     +
    "writePreserve": [                           +
        {                                        +
            "tableName": "tg_table1"             +
        },                                       +
        {                                        +
            "tableName": "tg_table2"             +
        },                                       +
        {                                        +
            "tableName": "tg_table3"             +
        }                                        +
    ]                                            +
}                                                +

(1 row)
```

再度`tg_set_write_preserve`を実行すると設定内容を更新します。

```sql
SELECT tg_set_write_preserve('tg_another_table1', 'tg_another_table2');
              tg_set_write_preserve
--------------------------------------------------
{                                                +
    "transactionType": "2",                      +
    "transactionPriority": "0",                  +
    "transactionLabel": "pgsql-transaction",     +
    "writePreserve": [                           +
        {                                        +
            "tableName": "tg_another_table1"     +
        },                                       +
        {                                        +
            "tableName": "tg_another_table2"     +
        }                                        +
    ]                                            +
}                                                +

(1 row)
```

---
