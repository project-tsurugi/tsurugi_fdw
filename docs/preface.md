# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## はじめに

### Tsurugi FDWについて

Tsurugi FDWは、PostgreSQLのユーザインタフェースを利用してTsurugiを利用する機能を提供します。

具体的には、PostgreSQLの外部データラッパー（Foreign Data Wrapper、以下FDW）機能を利用してTsurugiのテーブルを外部テーブルとして扱い、PostgreSQLで入力されたDML文をTsurugiへ転送しています。

### Tsurugi FDWの機能

Tsurugi FDWは、PostgreSQLからTsurugiを利用するため以下の機能を提供します。

- SQL コマンド
  - SELECT
  - INSERT
  - UPDATE
  - DELETE
  - PREPARE
  - EXECUTE
  - START TRANSACTION
  - COMMIT
  - ROLLBACK

- データ型　※ 括弧内は（`Tsurugiのデータ型`）を示す
  - integer （int4）
  - bigint （int8）
  - decimal [ (p [, s]) ] （decimal）
  - numeric [ (p [, s]) ] （decimal）
  - real （froat4）
  - double precision （froat8）
  - character [ (n) ] （character）
  - character varying [ (n) ] （character）
  - date（date）
  - time [ (p) ] [ without time zone ] （time_of_day）
  - time [ (p) ] with time zone （time_of_day_with_time_zone）
  - timestamp [ (p) ] [ without time zone ] （time_point）
  - timestamp [ (p) ] with time zone （time_point_with_time_zone）

- クライアントインタフェース
  - JDBC（タイプ4 JDBCドライバ）

また、PostgreSQLからTsurugi固有のトランザクションを制御するユーザ定義関数（User-Defined Functions、以下UDF）を提供します。

- UDF
  - tg_set_transaction -- デフォルトのトランザクション特性を設定する
  - tg_set_write_preserve -- Longトランザクションの書き込み予約テーブルを設定する
  - tg_set_inclusive_read_areas -- Longトランザクションの読み込み予約テーブルを設定する
  - tg_set_exclusive_read_areas -- Longトランザクションの読み込み制約テーブルを設定する
  - tg_show_transaction -- デフォルトのトランザクション特性を表示する

なお、上記以外の機能は利用できません。例えば、以下のような機能となります。

- 非サポート機能一覧
  - アクセスメソッド（ACCESS METHOD）
  - 集約関数（AGGREGATE）
  - キャスト（CAST）
  - 照合順序（COLLATION）
  - 符号化方式変換（CONVERSION）
  - ドメイン（DOMAIN）
  - イベントトリガ（EVENT TRIGGER）
  - インデックス（INDEX）
  - マテリアライズドビュー（MATERIALIZED VIEW）
  - 演算子（OPERATOR）
  - セキュリティポリシー（POLICY）
  - スキーマ（SCHEMA）
  - シーケンスジェネレータ（SEQUENCE）
  - 拡張統計情報（STATISTICS）
  - テーブル（TABLE）
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
  - pgODBC（ODBCドライバ）
