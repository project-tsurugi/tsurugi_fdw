/* show default option */
SELECT tg_show_transaction();

/* set option */
SELECT tg_set_transaction('long');
SELECT tg_set_transaction('read_only');
SELECT tg_set_transaction('default');
SELECT tg_set_transaction('Short', 'interrupt');
SELECT tg_set_transaction('Long', 'wait');
SELECT tg_set_transaction('Read_Only', 'interrupt_exclude');
SELECT tg_set_transaction('DEFAULT', 'wait_exclude');
SELECT tg_set_transaction('short', 'default');
SELECT tg_set_transaction('long', 'interrupt', 'regression-test');

/* set option (error) */
SELECT tg_set_transaction('short transaction');
SELECT tg_set_transaction('wait');
SELECT tg_set_transaction('short', 'exlude');
SELECT tg_set_transaction('short', 'wait', '');

/* set write preserve */
-- table preparation
CREATE TABLE table1 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
CREATE TABLE wp_table1 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
CREATE TABLE wp_table2 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
CREATE FOREIGN TABLE table1 (column1 INTEGER NOT NULL) SERVER ogawayama;
CREATE FOREIGN TABLE wp_table1 (column1 INTEGER NOT NULL) SERVER ogawayama;
CREATE FOREIGN TABLE wp_table2 (column1 INTEGER NOT NULL) SERVER ogawayama;

SELECT tg_set_write_preserve('wp_table1');
SELECT tg_set_write_preserve('wp_table2');
SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
SELECT tg_set_transaction('short'); -- reset write preserve

/* set write preserve (error) */
SELECT tg_set_write_preserve('wp_table3');
SELECT tg_set_write_preserve('wp_table1', 'wp_table2', 'wp_table3');
SELECT tg_set_write_preserve(NULL);
SELECT tg_set_write_preserve('wp_table1', 'wp_table2', NULL);

/* start transaction */
SELECT tg_start_transaction();
SELECT tg_start_transaction(); -- warning
SELECT tg_commit();

/* commit */
SELECT tg_commit(); -- warning

/* rollback */
SELECT tg_rollback(); -- warning
SELECT tg_start_transaction();
SELECT tg_rollback();

/* Implicit transaction */
INSERT INTO table1 (column1) VALUES (100);
SELECT * FROM table1;
UPDATE table1 SET column1 = column1+1;
SELECT * FROM table1;
DELETE FROM table1 WHERE column1 = 101;
SELECT * from table1;

/* Explicit transaction (commit) */
SELECT tg_start_transaction();
INSERT INTO table1 (column1) VALUES (200);
SELECT tg_commit();
SELECT * FROM table1;

SELECT tg_start_transaction();
UPDATE table1 SET column1 = column1+1;
SELECT tg_commit();
SELECT * FROM table1;

SELECT tg_start_transaction();
DELETE FROM table1 WHERE column1 = 201;
SELECT tg_commit();
SELECT * from table1;

/* Explicit transaction (rollback) */
SELECT tg_start_transaction();
INSERT INTO table1 (column1) VALUES (300);
SELECT tg_rollback();
SELECT * FROM table1;

INSERT INTO table1 (column1) VALUES (400);
SELECT tg_start_transaction();
UPDATE table1 SET column1 = column1+1;
SELECT tg_rollback();
SELECT * FROM table1;
SELECT tg_start_transaction();
DELETE FROM table1 WHERE column1 = 400;
SELECT tg_rollback();
SELECT * FROM table1;

/* Long transaction */
SELECT tg_set_transaction('long');

SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
INSERT INTO wp_table1 (column1) VALUES (100);
INSERT INTO wp_table2 (column1) VALUES (100);
INSERT INTO table1 (column1) VALUES (500); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;
UPDATE wp_table1 SET column1 = column1+1;
UPDATE wp_table2 SET column1 = column1+1;
UPDATE table1 SET column1 = column1+1; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;
DELETE FROM wp_table1 WHERE column1 = 101;
DELETE FROM wp_table2 WHERE column1 = 101;
DELETE FROM table1 WHERE column1 = 400; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;

SELECT tg_set_write_preserve('wp_table1');
INSERT INTO wp_table1 (column1) VALUES (200);
INSERT INTO wp_table2 (column1) VALUES (200); -- error
INSERT INTO table1 (column1) VALUES (500); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;
UPDATE wp_table1 SET column1 = column1+1;
UPDATE table1 SET column1 = column1+1; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;
DELETE FROM wp_table1 WHERE column1 = 201;
DELETE FROM table1 WHERE column1 = 400; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;

/* Explicit specific transaction */
/* Execute a specific Short transaction during a Long transaction */
SELECT tg_set_transaction('long');
SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
INSERT INTO wp_table1 (column1) VALUES (300);
INSERT INTO wp_table2 (column1) VALUES (300);
INSERT INTO table1 (column1) VALUES (600); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;

SELECT tg_start_transaction('short', 'default', 'specific-transaction');
SELECT tg_show_transaction();
INSERT INTO wp_table1 (column1) VALUES (400);
INSERT INTO wp_table2 (column1) VALUES (400);
INSERT INTO table1 (column1) VALUES (700);
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;
SELECT tg_commit();

SELECT tg_show_transaction();
INSERT INTO wp_table1 (column1) VALUES (500);
INSERT INTO wp_table2 (column1) VALUES (500);
INSERT INTO table1 (column1) VALUES (800); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM table1;

/* Cooperation with PostgreSQL table */
SELECT tg_set_transaction('short');
-- table preparation
CREATE TABLE tg_table (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
CREATE FOREIGN TABLE tg_table (column1 INTEGER NOT NULL) SERVER ogawayama;
	CREATE TABLE pg_table (column1 INTEGER NOT NULL PRIMARY KEY);
INSERT INTO tg_table (column1) VALUES (999);
-- Start the Tsurugi transaction
SELECT tg_start_transaction();
-- Update the Tsurugi table
UPDATE tg_table SET column1 = column1+1;
	BEGIN;
	-- Insert pre-commit Tsurugi table into PostgreSQL table
	INSERT INTO pg_table SELECT column1 from tg_table;
-- Abort the Tsuguri transaction
SELECT tg_rollback();
	COMMIT;
-- Updates to the Tsurugi table are discarded(999)
SELECT * from tg_table;
	-- Do not discard updates to PostgreSQL tables(1000)
	SELECT * from pg_table;

/* clean up */
DROP FOREIGN TABLE tg_table;
DROP FOREIGN TABLE table1;
DROP FOREIGN TABLE wp_table1;
DROP FOREIGN TABLE wp_table2;
DROP TABLE tg_table;
DROP TABLE pg_table;
DROP TABLE table1;
DROP TABLE wp_table1;
DROP TABLE wp_table2;