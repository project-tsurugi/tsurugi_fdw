# tg_commit

tg_commit - 現在のトランザクションをコミットする

## 概要

```
tg_commit()
```

## 説明

このコマンドは現在のTsurugiトランザクションをコミットします。

## パラメータ

なし

## 例

`tg_commit`は`tg_start_transaction`によって開始されたトランザクションブロックを終了し、すべての変更を永続化します。

```sql
SELECT tg_start_transaction();

UPDATE tg_table SET c2 = 'new data' WHERE c1 = 1;

SELECT tg_commit();
```

---
