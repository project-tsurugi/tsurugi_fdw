# tg_start_transaction

tg_start_transaction - 新しいトランザクションブロックを開始する

## 概要

```
tg_start_transaction( [transaction_type [, priority [, label] ] ] )

transaction_typeには以下のいずれかが入ります。

    { 'short' | 'long' | 'read_only' }

priorityには以下のいずれかが入ります。

    { 'default' | 'interrupt' | 'wait' | 'interrupt_exclude' | 'wait_exclude' }

```

## 説明

このコマンドは新しいトランザクションブロックを開始します。トランザクション種別や優先度、ラベル名を指定すると、[`tg_set_transaction`](./tg_set_transaction.md)が実行されたときのように、新しいトランザクションはそれらの特性を持ちます。

## パラメータ

このコマンドのパラメータの意味については[`tg_set_transaction`](./tg_set_transaction.md)を参照してください。

## 例

`tg_start_transaction`

---
