# [Tsurugi FDW for Tsurugi](./README.md)

## リファレンス（SQL）

tsurugi_fdw は、PostgreSQL のプランナが生成した実行計画に基づき、実行可能な処理を Tsurugi 側へプッシュダウンして実行します。プッシュダウンできない処理は PostgreSQL 側で実行します。

そのため、PostgreSQL がサポートしている機能であっても、常に Tsurugi 側で実行されるとは限りません。また、Tsurugi 側で未サポートの関数・演算子・構文や PostgreSQL 固有の機能を含む場合でも、内容によっては PostgreSQL 側で処理されることで実行できる場合があります。

ただし、FDW 経由での実行として未対応の操作や、互換性制約（データ型・関数・演算子等）により変換・評価できない場合は、実行に失敗することがあります。

### サポートしている主なSQL

#### 定義系（FDW設定・外部テーブル）
- `CREATE EXTENSION tsurugi_fdw;`
- `CREATE SERVER ... FOREIGN DATA WRAPPER tsurugi_fdw OPTIONS ('...');`
- `CREATE FOREIGN TABLE ... SERVER ...;`
- `IMPORT FOREIGN SCHEMA ... FROM SERVER ... INTO ...;`
  - IMPORT FOREIGN SCHEMA の Tsurugi FDW 固有の仕様は [IMPORT FOREIGN SCHEMA for Tsurugi FDW](sql_reference/import_foreign_schema.md) を参照してください。
- `CREATE USER MAPPING FOR ... SERVER ... OPTIONS (user '...', password '...');`

#### 参照（読み取り）

- `SELECT`（`WHERE` / `ORDER BY` / `GROUP BY` / `HAVING` / `LIMIT` / `OFFSET`、集約関数（`aggregate`）、`JOIN`、`CASE` 式）

#### 更新（書き込み）
- `INSERT`
- `UPDATE`
- `DELETE`

#### ユーザー定義関数？

### 非サポートの主なSQL

#### 参照（読み取り）
- `SELECT` の `OFFSET`：オフセット指定を含む取得は不可

#### 更新（書き込み）
- `INSERT` / `UPDATE` / `DELETE` の `RETURNING` 句：更新結果の返却は不可
- `INSERT` の `ON CONFLICT DO NOTHING`：衝突時に無視する構文は不可

#### データロード
- `COPY`：外部テーブルに対するコピー入力は不可

#### 定義・操作（DDL）
- `TRUNCATE`：テーブル全件削除コマンドは不可

#### データ型・値
- `timestamp` の `infinity` / `-infinity`：PostgreSQL と Tsurugi で扱える値（無限大／無限小）の仕様が異なるため非サポート
