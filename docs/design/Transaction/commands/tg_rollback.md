# tg_rollback

tg_rollback - 現在のトランザクションをアボートする

## 概要

```
tg_rollback()
```

## 説明

このコマンドは現在のTsurugiトランザクションをロールバックし、そのトランザクションで行われたすべての更新を破棄します。

## パラメータ

なし

## 例

`tg_rollback`は`tg_start_transaction`によって開始されたトランザクションブロックを終了し、そのトランザクションで行われたすべての変更をアボートします。

```sql
SELECT tg_start_transaction();

UPDATE tg_table SET c2 = 'new data' WHERE c1 = 1;

SELECT tg_rollback();
```

---
# tg_rollback

tg_rollback - 現在のトランザクションをアボートする

## 概要

```
tg_rollback()
```

## 説明

このコマンドは現在のTsurugiトランザクションをロールバックし、そのトランザクションで行われたすべての更新を破棄します。

## パラメータ

なし

## 例

`tg_rollback`は`tg_start_transaction`によって開始されたトランザクションブロックを終了し、そのトランザクションで行われたすべての変更をアボートします。

```sql
SELECT tg_start_transaction();

UPDATE tg_table SET c2 = 'new data' WHERE c1 = 1;

SELECT tg_rollback();
```

---
