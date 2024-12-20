# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## リファレンス（SQL）

Tsurugi FDWがサポートするSQLコマンドについて説明します。

Tsurugiでコンパイルされる以下のSQLコマンドはTsurugiのSQLコマンド仕様に準じます。
詳細は [Tsurugiのドキュメント](https://github.com/project-tsurugi/tsurugidb/blob/master/docs/sql-features.md) を参照してください。

- Definitions (DDL)
  - CREATE TABLE
  - CREATE INDEX
  - DROP TABLE
  - DROP INDEX
- Statements (DML)
  - SELECT
  - INSERT
  - UPDATE
  - DELETE

その他のSQLコマンドはPostgreSQLのSQLコマンド仕様に準じます。
詳細は [PostgreSQLのドキュメント](https://www.postgresql.jp/document/12/html/sql-commands.html) を参照してください。

### SQLコマンド一覧

| コマンド名 | 説明 | サポート |
| :--- | :--- | :---: |
| ABORT | 現在のトランザクションをアボートする | 〇 |
| ALTER AGGREGATE | 集約関数定義を変更する | × |
| ALTER COLLATION | 照合順序の定義を変更する | × |
| ALTER CONVERSION | 変換の定義を変更する | × |
| ALTER DATABASE | データベースを変更する | × |
| ALTER DEFAULT PRIVILEGES | デフォルトのアクセス権限を定義する | × |
| ALTER DOMAIN | ドメイン定義を変更する | × |
| ALTER EVENT TRIGGER | イベントトリガの定義を変更する | × |
| ALTER EXTENSION | 拡張の定義を変更する | × |
| ALTER FOREIGN DATA WRAPPER | 外部データラッパの定義を変更する | × |
| ALTER FOREIGN TABLE | 外部テーブルの定義を変更する | × |
| ALTER FUNCTION | 関数定義を変更する | × |
| ALTER GROUP | ロールの名前またはメンバ資格を変更する | × |
| ALTER INDEX | インデックス定義を変更する | × |
| ALTER LANGUAGE | 手続き言語の定義を変更する | × |
| ALTER LARGE OBJECT | ラージオブジェクトの定義を変更する | × |
| ALTER MATERIALIZED VIEW | マテリアライズドビューの定義を変更する | × |
| ALTER OPERATOR | 演算子の定義を変更する | × |
| ALTER OPERATOR CLASS | 演算子クラスの定義を変更する | × |
| ALTER OPERATOR FAMILY | 演算子族の定義を変更する | × |
| ALTER POLICY | 行単位のセキュリティポリシーの定義を変更する | × |
| ALTER PROCEDURE | プロシージャの定義を変更する | × |
| ALTER PUBLICATION | パブリケーションの定義を変更する | × |
| ALTER ROLE | データベースロールを変更する | × |
| ALTER ROUTINE | ルーチンの定義を変更する | × |
| ALTER RULE | ルールの定義を変更する | × |
| ALTER SCHEMA | スキーマ定義を変更する | × |
| ALTER SEQUENCE | シーケンスジェネレータの定義を変更する | × |
| ALTER SERVER | 外部サーバの定義を変更する | × |
| ALTER STATISTICS | 拡張統計オブジェクトの定義を変更する | × |
| ALTER SUBSCRIPTION | サブスクリプションの定義を変更する | × |
| ALTER SYSTEM | サーバの設定パラメータを変更する | × |
| ALTER TABLE | テーブル定義を変更する | × |
| ALTER TABLESPACE | テーブル空間の定義を変更する | × |
| ALTER TEXT SEARCH CONFIGURATION | テキスト検索設定の定義を変更する | × |
| ALTER TEXT SEARCH DICTIONARY | テキスト検索辞書の定義を変更する | × |
| ALTER TEXT SEARCH PARSER | テキスト検索パーサの定義を変更する | × |
| ALTER TEXT SEARCH TEMPLATE | テキスト検索テンプレートの定義を変更する | × |
| ALTER TRIGGER | トリガ定義を変更する | × |
| ALTER TYPE | 型定義を変更する | × |
| ALTER USER | データベースロールを変更する | × |
| ALTER USER MAPPING | ユーザマップの定義を変更する | × |
| ALTER VIEW | ビュー定義を変更する | × |
| ANALYZE | データベースに関する統計を収集する | × |
| BEGIN | トランザクションブロックを開始する | 〇 |
| CALL | プロシージャを呼び出す | × |
| CHECKPOINT | 先行書き込みログのチェックポイントを強制的に実行する | × |
| CLOSE | カーソルを閉じる | × |
| CLUSTER | インデックスに従ってテーブルをクラスタ化する | × |
| COMMENT | オブジェクトのコメントを定義する、または変更する | × |
| COMMIT | 現在のトランザクションをコミットする | 〇 |
| COMMIT PREPARED | 二相コミット用に事前に準備されたトランザクションをコミットする | × |
| COPY | ファイルとテーブルの間でデータをコピーする | × |
| CREATE ACCESS METHOD | 新しいアクセスメソッドを定義する | × |
| CREATE AGGREGATE | 新しい集約関数を定義する | × |
| CREATE CAST | 新しいキャストを定義する | × |
| CREATE COLLATION | 新しい照合順序を定義する | × |
| CREATE CONVERSION | 新しい符号化方式変換を定義する | × |
| CREATE DATABASE | 新しいデータベースを作成する | × |
| CREATE DOMAIN | 新しいドメインを定義する | × |
| CREATE EVENT TRIGGER | 新しいイベントトリガを定義する | × |
| CREATE EXTENSION | 拡張をインストールする | × |
| CREATE FOREIGN DATA WRAPPER | 新しい外部データラッパを定義する | × |
| CREATE FOREIGN TABLE | 新しい外部テーブルを定義する | × |
| CREATE FUNCTION | 新しい関数を定義する | × |
| CREATE GROUP | 新しいデータベースロールを定義する | × |
| CREATE INDEX | 新しいインデックスを定義する | × |
| CREATE LANGUAGE | 新しい手続き言語を定義する | × |
| CREATE MATERIALIZED VIEW | 新しいマテリアライズドビューを定義する | × |
| CREATE OPERATOR | 新しい演算子を定義する | × |
| CREATE OPERATOR CLASS | 新しい演算子クラスを定義する | × |
| CREATE OPERATOR FAMILY | 新しい演算子族を定義する | × |
| CREATE POLICY | テーブルに新しい行単位のセキュリティポリシーを定義する | × |
| CREATE PROCEDURE | 新しいプロシージャを定義する | × |
| CREATE PUBLICATION | 新しいパブリケーションを定義する | × |
| CREATE ROLE | 新しいデータベースロールを定義する | × |
| CREATE RULE | 新しい書き換えルールを定義する | × |
| CREATE SCHEMA | 新しいスキーマを定義する | × |
| CREATE SEQUENCE | 新しいシーケンスジェネレータを定義する | × |
| CREATE SERVER | 新しい外部サーバを定義する | × |
| CREATE STATISTICS | 拡張統計情報を定義する | × |
| CREATE SUBSCRIPTION | 新しいサブスクリプションを定義する | × |
| CREATE TABLE | 新しいテーブルを定義する | × |
| CREATE TABLE AS | 問い合わせの結果によって新しいテーブルを定義する | × |
| CREATE TABLESPACE | 新しいテーブル空間を定義する | × |
| CREATE TEXT SEARCH CONFIGURATION | 新しいテキスト検索設定を定義する | × |
| CREATE TEXT SEARCH DICTIONARY | 新しいテキスト検索辞書を定義する | × |
| CREATE TEXT SEARCH PARSER | 新しいテキスト検索パーサを定義する | × |
| CREATE TEXT SEARCH TEMPLATE | 新しいテキスト検索テンプレートを定義する | × |
| CREATE TRANSFORM | 新しい変換を定義する | × |
| CREATE TRIGGER | 新しいトリガを定義する | × |
| CREATE TYPE | 新しいデータ型を定義する | × |
| CREATE USER | 新しいデータベースロールを定義する | × |
| CREATE USER MAPPING | 外部サーバのユーザマップを新しく定義する | × |
| CREATE VIEW | 新しいビューを定義する | × |
| DEALLOCATE | プリペアド文の割り当てを解除する | 〇 |
| DECLARE | カーソルを定義する | × |
| DELETE | テーブルから行を削除する | 〇 |
| DISCARD | セッションの状態を破棄する | × |
| DO | 無名コードブロックを実行します | × |
| DROP ACCESS METHOD | アクセスメソッドを削除する | × |
| DROP AGGREGATE | 集約関数を削除する | × |
| DROP CAST | キャストを削除する | × |
| DROP COLLATION | 照合順序を削除する | × |
| DROP CONVERSION | 符号化方式変換を削除する | × |
| DROP DATABASE | データベースを削除する | × |
| DROP DOMAIN | ドメインを削除する | × |
| DROP EVENT TRIGGER | イベントトリガを削除する | × |
| DROP EXTENSION | 拡張を削除する | × |
| DROP FOREIGN DATA WRAPPER | 外部データラッパを削除する | × |
| DROP FOREIGN TABLE | 外部テーブルを削除する | × |
| DROP FUNCTION | 関数を削除する | × |
| DROP GROUP | データベースロールを削除する | × |
| DROP INDEX | インデックスを削除する | × |
| DROP LANGUAGE | 手続き言語を削除する | × |
| DROP MATERIALIZED VIEW | マテリアライズドビューを削除する | × |
| DROP OPERATOR | 演算子を削除する | × |
| DROP OPERATOR CLASS | 演算子クラスを削除する | × |
| DROP OPERATOR FAMILY | 演算子族を削除する | × |
| DROP OWNED | データベースロールにより所有されるデータベース</br>オブジェクトを削除します | × |
| DROP POLICY | テーブルから行単位のセキュリティポリシーを削除する | × |
| DROP PROCEDURE | プロシージャを削除する | × |
| DROP PUBLICATION | パブリケーションを削除する | × |
| DROP ROLE | データベースロールを削除する | × |
| DROP ROUTINE | ルーチンを削除する | × |
| DROP RULE | 書き換えルールを削除する | × |
| DROP SCHEMA | スキーマを削除する | × |
| DROP SEQUENCE | シーケンスを削除する | × |
| DROP SERVER | 外部サーバの記述子を削除する | × |
| DROP STATISTICS | 拡張統計を削除する | × |
| DROP SUBSCRIPTION | サブスクリプションを削除する | × |
| DROP TABLE | テーブルを削除する | × |
| DROP TABLESPACE | テーブル空間を削除する | × |
| DROP TEXT SEARCH CONFIGURATION | テキスト検索設定を削除する | × |
| DROP TEXT SEARCH DICTIONARY | テキスト検索辞書を削除する | × |
| DROP TEXT SEARCH PARSER | テキスト検索パーサを削除する | × |
| DROP TEXT SEARCH TEMPLATE | テキスト検索テンプレートを削除する | × |
| DROP TRANSFORM | 変換を削除する | × |
| DROP TRIGGER | トリガを削除する | × |
| DROP TYPE | データ型を削除する | × |
| DROP USER | データベースロールを削除する | × |
| DROP USER MAPPING | 外部サーバ用のユーザマップを削除します | × |
| DROP VIEW | ビューを削除する | × |
| END | 現在のトランザクションをコミットする | 〇 |
| EXECUTE | プリペアド文を実行する | 〇 |
| EXPLAIN | 問い合わせ文の実行計画を表示する | × |
| FETCH | カーソルを使用して問い合わせから行を取り出す | × |
| GRANT | アクセス権限を定義する | × |
| IMPORT FOREIGN SCHEMA | 外部サーバからテーブル定義をインポートする | × |
| INSERT | テーブルに新しい行を作成する | 〇 |
| LISTEN | 通知を監視する | × |
| LOAD | 共有ライブラリファイルの読み込みを行う | × |
| LOCK | テーブルをロックする | × |
| MOVE | カーソルの位置を決める | × |
| NOTIFY | 通知を生成する | × |
| PREPARE | 実行する文を準備する | 〇 |
| PREPARE TRANSACTION | 二相コミット用に現在のトランザクションを準備する | × |
| REASSIGN OWNED | あるデータベースロールにより所有されたデータベース</br>オブジェクトの所有権を変更する | × |
| REFRESH MATERIALIZED VIEW | マテリアライズドビューの内容を置換する | × |
| REINDEX | インデックスを再構築する | × |
| RELEASE SAVEPOINT | 設定済みのセーブポイントを破棄する | × |
| RESET | 実行時パラメータの値をデフォルト値に戻す | × |
| REVOKE | アクセス権限を取り消す | × |
| ROLLBACK | 現在のトランザクションをアボートする | 〇 |
| ROLLBACK PREPARED | 二相コミット用に事前に準備されたトランザクションを取り消す | × |
| ROLLBACK TO SAVEPOINT | セーブポイントまでロールバックする | × |
| SAVEPOINT | 現在のトランザクション内に新規にセーブポイントを定義する | × |
| SECURITY LABEL | オブジェクトに適用するセキュリティラベルを定義または変更する | × |
| SELECT | テーブルもしくはビューから行を検索する | 〇 |
| SELECT INTO | 問い合わせの結果からの新しいテーブルを定義する | × |
| SET | 実行時パラメータを変更する | × |
| SET CONSTRAINTS | 現在のトランザクションの制約検査のタイミングを設定する | × |
| SET ROLE | 現在のセッションにおける現在のユーザ識別子を設定する | × |
| SET SESSION AUTHORIZATION | セッションのユーザ識別子、現在のセッションの現在のユーザ識別子を設定する | × |
| SET TRANSACTION | 現在のトランザクションの特性を設定する | × |
| SHOW | 実行時パラメータの値を表示する | × |
| START TRANSACTION | トランザクションブロックを開始する | 〇 |
| TRUNCATE | 1テーブルまたはテーブル群を空にする | × |
| UNLISTEN | 通知の監視を停止する | × |
| UPDATE | テーブルの行を更新する | 〇 |
| VACUUM | データベースの不要領域の回収とデータベースの解析を行う | × |
| VALUES | 行セットを計算する | × |
