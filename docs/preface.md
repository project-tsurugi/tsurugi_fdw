# [Tsurugi FDW for Tsurugi](./README.md)

## 概要

### Tsurugi FDWについて

Tsurugi FDWは、PostgreSQLをユーザインタフェースとしてTsurugiを利用する機能を提供します。  
具体的には、PostgreSQLの外部データラッパー（Foreign Data Wrapper、以下FDW）機能を利用してTsurugiのテーブルを外部テーブルとして扱い、PostgreSQLで入力されたDML文をTsurugiへ転送します。  
これにより、PostgreSQLを利用しているユーザは、PostgreSQLが持つライブラリやJDBCドライバを活かしつつTsurugiにアクセスすることができます。  

> [!NOTE]
> PostgreSQLとTsurugiはアーキテクチャおよびその性質が異なるためTsurugi FDWには[注意事項](./appendixes.md#注意事項)および[制限事項](./appendixes.md#制限事項)があります。  
> また、Tsurugi FDWはPostgreSQLを経由するオーバーヘッドがかかるため他のTsurugi外部インタフェースと比べてパフォーマンスが劣る点に留意ください。

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
  - IMPORT FOREIGN SCHEMA

- クライアントインタフェース
  - JDBC（タイプ4 JDBCドライバ）

PostgreSQLからTsurugi固有のトランザクション特性を設定するユーザ定義関数（User-Defined Functions、以下UDF）を提供します。

- UDF
  - tg_set_transaction -- デフォルトのトランザクション特性を設定する
  - tg_set_write_preserve -- Longトランザクションの書き込み予約テーブルを設定する
  - tg_set_inclusive_read_areas -- Longトランザクションの読み込み予約テーブルを設定する
  - tg_set_exclusive_read_areas -- Longトランザクションの読み込み制約テーブルを設定する
  - tg_show_transaction -- デフォルトのトランザクション特性を表示する
  - [tg_show_tables](udf_reference/tg_show_tables.md) -- Tsurugiのテーブル定義を表示する
  - [tg_verify_tables](udf_reference/tg_verify_tables.md) -- Tsurugiのテーブル定義とPostgreSQLの外部テーブル定義を比較検証する
