# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## リファレンス（UDF）

Tsurugi FDWがサポートするユーザ定義関数について説明します。

### Tsurugi固有トランザクション特性の設定

Tsurugi固有のトランザクション特性を設定する以下のUDFを提供します。

- [tg_set_exclusive_read_areas](udf_reference/tg_set_exclusive_read_areas.md) -- Longトランザクションの読み込み制約テーブルを設定する
- [tg_set_inclusive_read_areas](udf_reference/tg_set_inclusive_read_areas.md) -- Longトランザクションの読み込み予約テーブルを設定する
- [tg_set_transaction](udf_reference/tg_set_transaction.md) -- デフォルトのトランザクション特性を設定する
- [tg_set_write_preserve](udf_reference/tg_set_write_preserve.md) -- Longトランザクションの書き込み予約テーブルを設定する
- [tg_show_transaction](udf_reference/tg_show_transaction.md) -- デフォルトのトランザクション特性を表示する

### Tsurugiのテーブル定義の参照

Tsurugiのテーブル定義の状況を参照する以下のUDFを提供します。

- [tg_show_tables](udf_reference/tg_show_tables.md) -- Tsurugiのテーブル定義を表示する
- [tg_verify_tables](udf_reference/tg_verify_tables.md) -- Tsurugiテーブル定義とPostgreSQLの外部テーブル定義の検証結果を表示する
