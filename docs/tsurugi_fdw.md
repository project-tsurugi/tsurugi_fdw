# Tsurugi FDW for Tsurugi

## [はじめに](./preface.md)

1. Tsurugi FDWについて
1. Tsurugi FDW 機能一覧

## [セットアップ](./setup.md)

1. 必要条件
1. Tsurugiのインストール
1. PostgreSQLのインストール
1. Tsurugi FDW のインストール
1. Tsurugi FDW 初期設定
1. Tsurugi FDW 起動と終了
1. Tsurugi FDW アンインストール

## [チュートリアル](./tutorial.md)

### [基本的なSQL言語](./tutorial.md#基本的なsql言語)

   1. テーブルの作成
   1. データの挿入
   1. データの問い合わせ
   1. データの更新と削除
   1. アクセス制御
   1. インデックス
   1. プリペアドステートメント

### [Tsurugi固有の機能](./tutorial.md#Tsurugi固有の機能)

   1. トランザクション

## [リファレンス（SQL）](./sql_reference.md)

- CREATE INDEX
- CREATE ROLE
- CREATE TABLE
- DELETE
- DROP INDEX
- DROP ROLE
- DROP TABLE
- EXECUTE
- GRANT
- INSERT
- PREPARE
- REVOKE
- SELECT
- UPDATE

## [リファレンス（UDF）](./udf_reference.md)

- tg_commit
- tg_rollback
- tg_set_exclusive_read_areas
- tg_set_inclusive_read_areas
- tg_set_transaction
- tg_set_write_preserve
- tg_show_transaction
- tg_start_transaction

## [付録](./appendixes.md)

- 注意事項
- 制約事項
- サードパーティライセンス
- 修正履歴

以上
