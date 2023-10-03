# [リファレンス（UDF）](../udf_reference.md)

## tg_start_transaction

tg_start_transaction - 新しいトランザクションブロックを開始する

## 概要

```sql
tg_start_transaction( [transaction_type [, priority [, label] ] ] )

transaction_typeには以下のいずれかが入ります。

    { 'short' | 'long' | 'read_only' }

priorityには以下のいずれかが入ります。

    { 'default' | 'interrupt' | 'wait' | 'interrupt_exclude' | 'wait_exclude' }
```

## 説明

このコマンドは新しいトランザクションブロックを開始します。トランザクション種別や優先度、ラベル名を指定すると、[`tg_set_transaction`](./tg_set_transaction.md)が実行されたときのように、新しいトランザクションブロックはそれらの特性を持ちます。ただし、それらのトランザクションブロックは該当のトランザクションブロックでのみ有効になります。

## パラメータ

このコマンドのパラメータの意味については[`tg_set_transaction`](./tg_set_transaction.md)を参照してください。

## 例

パラメータを指定せずに`tg_start_transaction`を実行すると、デフォルトのトランザクション特性でトランザクションブロックが開始されます。

```sql
SELECT tg_start_transaction();  -- デフォルトのトランザクション特性が適用される

UPDATE tg_table SET c2 = 'new data' WHERE c1 = 1;

SELECT tg_commit();
```

`tg_set_transaction`でデフォルトのトランザクション特性を設定した場合は、`tg_set_transaction`で設定されたトランザクション特性が適用されます。

```sql
SELECT tg_set_transaction('short', 'interrupt');  -- デフォルトのトランザクション特性を変更する

SELECT tg_start_transaction();  -- 変更されたデフォルトのトランザクション特性が適用される（優先度は'interrupt'）
UPDATE tg_table SET c2 = 'new data' WHERE c1 = 1;
SELECT tg_commit();

SELECT tg_start_transaction();  -- 変更されたデフォルトのトランザクション特性が適用される（優先度は'interrupt'）
UPDATE tg_table SET c2 = 'next data' WHERE c1 = 2;
SELECT tg_commit();
```

`tg_start_transaction`にパラメータを付与してトランザクションブロックを開始すると、そのトランザクションブロックに適用するトランザクション特性を変更できます。

```sql
SELECT tg_start_transaction('short', 'interrupt');  -- 優先度を'interrupt'に変更
UPDATE tg_table SET c2 = 'new data' WHERE c1 = 1;
SELECT tg_commit();

SELECT tg_start_transaction();  -- デフォルトのトランザクション特性が適用される（優先度は'default'）
UPDATE tg_table SET c2 = 'next data' WHERE c1 = 2;
SELECT tg_commit();
```

---
