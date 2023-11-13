# [リファレンス（UDF）](../udf_reference.md)

## tg_show_transaction

tg_show_transaction - デフォルトのトランザクション特性の値を表示する

### 概要

```sql
tg_show_transaction([transaction_type [, priority [, label ] ] ])
```

### 説明

tsurugiトランザクションのデフォルトのトランザクション特性として設定されている値を表示します。

### パラメータ

なし

### 例

現在設定されているトランザクション特性の値を表示します。

```sql
SELECT tg_show_transaction();
             tg_show_transaction
----------------------------------------------
 {                                           +
     "transactionType": "1",                 +
     "transactionPriority": "0",             +
     "transactionLabel": "pgsql-transaction",+
     "writePreserve": [                      +
         {                                   +
             "tableName": ""                 +
         }                                   +
     ],                                      +
     "inclusiveReadArea": [                  +
         {                                   +
             "tableName": ""                 +
         }                                   +
     ],                                      +
     "exclusiveReadArea": [                  +
         {                                   +
             "tableName": ""                 +
         }                                   +
     ]                                       +
 }                                           +

(1 row)
```

---
