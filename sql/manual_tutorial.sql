/* SET DATASTYLE */
SET datestyle TO ISO, ymd;

/* テーブルの作成 */
CREATE TABLE weather (
    id              int primary key,
    city            varchar(80),
    temp_lo         int,           -- 最低気温
    temp_hi         int,           -- 最高気温
    prcp            real,          -- 降水量
    the_date        date default '2023-04-01'
) TABLESPACE tsurugi;

/* 外部テーブルの作成 */
CREATE FOREIGN TABLE weather (
    id              int,
    city            varchar(80),
    temp_lo         int,           -- 最低気温
    temp_hi         int,           -- 最高気温
    prcp            real,          -- 降水量
    the_date        date default '2023-04-01'
) SERVER tsurugidb;

/* データの挿入 */
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
    VALUES (1, 'San Francisco', 46, 50, 0.25);
INSERT INTO weather (temp_lo, temp_hi, prcp, id, city)
    VALUES (43, 57, 0.0, 2, 'San Francisco');
INSERT INTO weather (id, city, temp_lo, temp_hi)
    VALUES (3, 'Hayward', 54, 37);

/* データの問い合わせ */
SELECT * from weather;

/* PostgreSQLテーブルの作成 */
CREATE TABLE cities (
    name            varchar(80),
    location        point
);
INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');
INSERT INTO cities VALUES ('Hayward', '(-122.0, 37.0)');

/* TsurugiとPostgreSQLの同時アクセス */
SELECT *
    FROM weather INNER JOIN cities ON (weather.city = cities.name) ORDER BY id;

/* データの更新 */
UPDATE weather
    SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
    WHERE city = 'Hayward';
select * from weather;

/* データの削除 */
DELETE FROM weather WHERE city = 'Hayward';
select * from weather;

/* データベースロールの作成 */
CREATE ROLE jonathan;

/* アクセス権の付与 */
GRANT SELECT ON weather TO jonathan;    -- Tsurugiテーブルにアクセス権を付与します

/* Tsurugiテーブルのアクセス制御 */
SET ROLE jonathan;          -- 確認のためカレントのデータベースロールを変更します
SELECT * from weather;      -- 問い合わせの操作は成功します
DELETE FROM weather WHERE city = 'San Francisco'; -- 問い合わせ以外の操作は失敗します
RESET ROLE;                 -- 現在のデータベースロールを元に戻します

/* アクセス権の剥奪 */
REVOKE SELECT ON weather FROM jonathan;

/* データベースロールの削除 */
DROP ROLE jonathan;

/* 明示的にトランザクションブロックを開始する */
SELECT tg_start_transaction();      --  明示的にトランザクションを開始する
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)  --  Tsurugiテーブルを操作する
    VALUES (4, 'Los Angeles', 64, 82, 0.0);
SELECT tg_commit();     --  トランザクション終了
SELECT * FROM weather;  -- レグレッションテスト確認用

/* デフォルトのトランザクション特性を変更したい場合 */
SELECT tg_set_transaction('short', 'interrupt');    /*  デフォルトのトランザクション特性を変更する
                                                        （priority = 'interrupt'） */
SELECT tg_start_transaction();  /*  変更されたトランザクション特性が適用される
                                    （priority = 'interrupt'）  */
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
    VALUES (5, 'Oakland', 48, 53, 0.5);
SELECT * FROM weather;
SELECT tg_commit();  -- トランザクション終了

/* 特定のトランザクションブロックのみトランザクション特性を変更 */
SELECT tg_start_transaction('read_only', 'wait', 'read_only_tx');   --  このトランザクションブロックのみで有効
SELECT * FROM weather;
SELECT tg_commit();     --  トランザクション終了
SELECT tg_start_transaction();      --  デフォルトのトランザクション特性が適用される
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
    VALUES (6, 'San Jose', 46, 55, 0.0);
SELECT tg_commit();     --  トランザクション終了
SELECT * FROM weather;  -- レグレッションテスト確認用

/* 暗黙的にトランザクションを開始する */
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
    VALUES (7, 'Sacramento', 48, 60, 0.25);  --  暗黙的にトランザクションが開始し、コミットされる（COMMIT文不要）
SELECT * FROM weather;  -- レグレッションテスト確認用
SELECT tg_start_transaction();
UPDATE weather
    SET temp_hi = temp_hi - 10 WHERE city = 'Sacramento';
SELECT * FROM weather;  -- レグレッションテスト確認用
SELECT tg_rollback();   --  UPDATE文の更新内容は破棄されるが、上記のINSERT文の更新内容は破棄されない
SELECT * FROM weather;  -- レグレッションテスト確認用

/* Longトランザクションを実行する */
SELECT tg_set_transaction('long');      --  Longトランザクションをデフォルトに設定する
SELECT tg_set_write_preserve('weather');    --  書き込みを予約するテーブルを設定する
SELECT tg_start_transaction();  -- Longトランザクション開始
INSERT INTO weather (id, city, temp_lo, temp_hi)
    VALUES (3, 'Hayward', 37, 54);
UPDATE weather SET temp_hi = temp_hi + 5 WHERE city = 'Oakland';
DELETE FROM weather WHERE id = 2;
SELECT * FROM weather;
SELECT tg_commit();             -- Longトランザクション終了

/* プリペアド文 */
PREPARE add_weather (int, varchar(80), int, int, real, date)
    AS INSERT INTO weather (id, city, temp_lo, temp_hi, prcp, the_date)
            VALUES ($1, $2, $3, $4, $5, $6);
EXECUTE add_weather (8, 'San Diego', 41, 57, 0.25, '2023-11-24'); -- 日付固定
SELECT * FROM weather;  -- レグレッションテスト確認用

/* 外部テーブルの削除 */
DROP FOREIGN TABLE weather;
/* テーブルの削除 */
DROP TABLE weather;
/* PostgreSQLテーブルの削除 */
DROP TABLE cities;
