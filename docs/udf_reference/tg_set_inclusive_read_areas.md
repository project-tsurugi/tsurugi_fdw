# [リファレンス（UDF）](../udf_reference.md)

## tg_set_inclusive_read_areas

- tg_set_inclusive_read_areas - Longトランザクションにおける読み込み予約テーブルを設定する

## 概要

```sql
tg_set_inclusive_read_areas(table name [, ...])
```

### 説明

TsurugiのLongトランザクションでは、トランザクションの実行中に読み込むテーブルをあらかじめ指定することができます。`tg_set_inclusive_read_areas`はLongトランザクションにおいて読み込みを可能とするテーブルをトランザクション特性に追加します。

トランザクション種別が`'long'`以外のトランザクションに対して読み込み予約テーブルを設定してもその値は無視されます。

### パラメータ

#### *table name*

読み込みを可能とするテーブル名を記述します。複数のテーブル名を記述することができます。

### 例

`tg_set_transaction`でLongトランザクションを設定してから読み込み予約テーブルを設定します。

```sql
SELECT tg_set_transaction('long');
              tg_set_transaction
--------------------------------------------------
{                                                +
    "transactionType": "2",                      +
    "transactionPriority": "0",                  +
    "transactionLabel": "pgsql-transaction",     +
    "writePreserve": "",                         +
    "inclusiveReadArea": "",                     +
    "exclusiveReadArea": ""                      +
}                                                +

(1 row)

SELECT tg_set_inclusive_read_areas('tg_table8', 'tg_table9');
          tg_set_inclusive_read_areas
--------------------------------------------------
{                                                +
    "transactionType": "2",                      +
    "transactionPriority": "0",                  +
    "transactionLabel": "pgsql-transaction",     +
    "writePreserve": "",                         +
    "inclusiveReadArea": [                       +
        {                                        +
            "tableName": "tg_table8"             +
        },                                       +
        {                                        +
            "tableName": "tg_table9"             +
        }                                        +
    ],                                           +
    "exclusiveReadArea": ""                      +
}                                                +

(1 row)
```

再度`tg_set_inclusive_read_areas`を実行すると設定内容を更新します。

```sql
SELECT tg_set_inclusive_read_areas('tg_another_table9');
          tg_set_inclusive_read_areas
--------------------------------------------------
{                                                +
    "transactionType": "2",                      +
    "transactionPriority": "0",                  +
    "transactionLabel": "pgsql-transaction",     +
    "writePreserve": "",                         +
    "inclusiveReadArea": [                       +
        {                                        +
            "tableName": "tg_another_table9"     +
        }                                        +
    ],                                           +
    "exclusiveReadArea": ""                      +
}                                                +

(1 row)
```

---
