# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## はじめに

1. Tsurugi FDWについて

    Tsurugi FDWは、PostgreSQLのエクステンションです。PostgreSQLのユーザインタフェースを利用してTsurugiを利用する機能を提供します。

    具体的には、PostgreSQLの外部データラッパー（Foreign Data Wrapper、以下FDW）機能を利用してTsurugiのテーブルを外部テーブルとして扱い、PostgreSQLで入力されたDDL文、DML文をTsurugiへ転送しています。

1. Tsurugi FDW 機能一覧

    Tsurugi FDWは、PostgreSQLからTsurugiに対して以下の機能を提供します。

    - SQL コマンド
      - CREATE TABLE
      - DROP TABLE
      - CREATE INDEX
      - DROP INDEX
      - CREATE ROLE
      - DROP ROLE
      - GRANT
      - REVOKE
      - SELECT
      - INSERT
      - UPDATE
      - DELETE
      - PREPARE
      - EXECUTE

    - データ型　※ 括弧内は（`SQL標準データ型`/`TsurugiDBデータ型`）を示す
      - integer （INT / int4）
      - bigint （BIGINT / int8）
      - decimal （DECIMAL / decimal）
      - numeric （NUMERIC / decimal）
      - real （REAL / froat4）
      - double precision （DOUBLE / froat8）
      - character [ (n) ] （CHAR / character）
      - character varying [ (n) ] （VARCHAR / character）
      - date（DATE / date）
      - time [ (p) ] [ without time zone ] （TIME / time_of_day）
      - timestamp [ (p) ] [ without time zone ] （TIMESTAMP / time_point）

    - クライアントインタフェース
      - JDBC（タイプ4 JDBCドライバ）

    また、PostgreSQLからTsurugiのトランザクションを制御するユーザ定義関数（User-Defined Functions、以下UDF）を提供します。

    - UDF
      - tg_start_transaction -- 新しいトランザクションブロックを開始する
      - tg_commit -- 現在のトランザクションをコミットする
      - tg_rollback -- 現在のトランザクションをアボートする
      - tg_show_transaction -- デフォルトのトランザクション特性の値を表示する
      - tg_set_transaction -- デフォルトのトランザクション特性を設定する
      - tg_set_write_preserve -- Longトランザクションにおける書き込み予約テーブルを設定する
      - tg_set_inclusive_read_areas -- Longトランザクションにおける読み込み予約テーブルを設定する
      - tg_set_exclusive_read_areas -- Longトランザクションにおける読み込み制約テーブルを設定する

    なお、上記以外の機能は利用できません。例えば、以下のような機能となります。

    - 非サポート機能一覧
      - アクセスメソッド（ACCESS METHOD）
      - 集約関数（AGGREGATE）
      - キャスト（CAST）
      - 照合順序（COLLATION）
      - 符号化方式変換（CONVERSION）
      - ドメイン（DOMAIN）
      - イベントトリガ（EVENT TRIGGER）
      - マテリアライズドビュー（MATERIALIZED VIEW）
      - 演算子（OPERATOR）
      - セキュリティポリシー（POLICY）
      - スキーマ（SCHEMA）
      - シーケンスジェネレータ（SEQUENCE）
      - 拡張統計情報（STATISTICS）
      - テキスト検索（TEXT SEARCH）
      - 変換（TRANSFORM）
      - トリガ（TRIGGER）
      - ビュー（VIEW）
      - 統計（ANALYZE / EXPLAIN / VACUUM）
      - カーソル（DECLARE / FETCH / CLOSE）
      - 通知（NOTIFY / LISTEN）
      - セーブポイント（SAVEPOINT）
      - 二相コミット（COMMIT PREPARED）
      - 手続き言語（PL/pgSQL）
