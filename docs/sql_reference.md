# [Tsurugi FDW for Tsurugi](./README.md)

## リファレンス（SQL）

Tsurugi FDW がサポートする SQL コマンドについて説明します。SQL の詳細な文法等については PostgreSQL 公式ドキュメント（ [SQL コマンドリファレンス](https://www.postgresql.org/docs/current/sql-commands.html) ）を参照してください。

Tsurugi FDW は、PostgreSQL のプランナが生成した実行計画に基づき、実行可能な処理を Tsurugi 側へプッシュダウンして実行します。プッシュダウンできない処理は PostgreSQL 側で実行します。

そのため、PostgreSQL がサポートしている機能であっても、常に Tsurugi 側で実行されるとは限りません。また、Tsurugi 側で未サポートの関数・演算子・構文や PostgreSQL 固有の機能を含む場合でも、内容によっては PostgreSQL 側で処理されることで実行できる場合があります。

ただし、FDW 経由での実行として未対応の操作や、互換性制約（データ型・関数・演算子等）により変換・評価できない場合は、実行に失敗することがあります。

### サポートしている主なSQL

#### 参照（読み取り）

- `SELECT`（`WHERE` / `ORDER BY` / `GROUP BY` / `HAVING` / `LIMIT`、集約関数（`aggregate`）、`JOIN`、`CASE` 式）

#### 更新（書き込み）
- `INSERT`
- `UPDATE`
- `DELETE`

#### 定義系（FDW設定・外部テーブル）
- `CREATE EXTENSION tsurugi_fdw;`
- `CREATE SERVER ... FOREIGN DATA WRAPPER tsurugi_fdw OPTIONS ('...');`
- `CREATE FOREIGN TABLE ... SERVER ...;`
- `IMPORT FOREIGN SCHEMA ... FROM SERVER ... INTO ...;`
  - IMPORT FOREIGN SCHEMA の Tsurugi FDW 固有の仕様は [IMPORT FOREIGN SCHEMA for Tsurugi FDW](sql_reference/import_foreign_schema.md) を参照してください。
- `CREATE USER MAPPING FOR ... SERVER ... OPTIONS (user '...', password '...');`

#### トランザクション

- `BEGIN`
- `COMMIT`
- `ROLLBACK`

### 非サポートの主なSQL

#### 参照（読み取り）
- `SELECT ... OFFSET`：オフセット指定を含む取得は非サポート
- `SELECT ... FOR UPDATE`：行ロックを伴う参照は非サポート

#### 更新（書き込み）
- `INSERT` / `UPDATE` / `DELETE` の `RETURNING` 句：更新結果の返却は非サポート
- `INSERT ... ON CONFLICT DO NOTHING`：衝突時に無視する構文は非サポート

#### 定義系（FDW設定・外部テーブル）
- `TRUNCATE`：テーブル全件削除コマンドは非サポート

#### トランザクション
- `SAVEPOINT` / `RELEASE SAVEPOINT` / `ROLLBACK TO SAVEPOINT`：FDW 経由ではサブトランザクション／部分ロールバックを扱えないため非サポート

#### データロード
- `COPY <foreign_table> TO ...`：外部テーブルは `COPY table TO` の対象外であるため非サポート（`COPY (SELECT ...) TO` は可能）
- `COPY <foreign_table> FROM ...`：FDW 経由の `COPY` による一括投入に対応していないため非サポート

#### データ型・値
- `timestamp` の `infinity` / `-infinity`：PostgreSQL と Tsurugi で扱える値（無限大／無限小）の仕様が異なるため非サポート
