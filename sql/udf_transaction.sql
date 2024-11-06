/* show default option */
SELECT tg_show_transaction();

/* set option */
SELECT tg_set_transaction('OCC'); -- for Tsurugi Books
SELECT tg_set_transaction('LTX'); -- for Tsurugi Books
SELECT tg_set_transaction('RTX'); -- for Tsurugi Books
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
CREATE FOREIGN TABLE udf_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE wp_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE wp_table2 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE ri_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE ri_table2 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE re_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE re_table2 (column1 INTEGER NOT NULL) SERVER tsurugidb;

SELECT tg_set_write_preserve('wp_table1');
SELECT tg_set_write_preserve('wp_table2');
SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
SELECT tg_set_transaction('short'); -- reset write preserve

SELECT tg_set_inclusive_read_areas('ri_table1');
SELECT tg_set_inclusive_read_areas('ri_table2');
SELECT tg_set_inclusive_read_areas('ri_table1', 'ri_table2');
SELECT tg_set_transaction('short'); -- reset inclusiveReadArea

SELECT tg_set_exclusive_read_areas('re_table1');
SELECT tg_set_exclusive_read_areas('re_table2');
SELECT tg_set_exclusive_read_areas('re_table1', 're_table2');
SELECT tg_set_transaction('short'); -- reset exclusiveReadArea

SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
SELECT tg_set_inclusive_read_areas('ri_table1', 'ri_table2');
SELECT tg_set_exclusive_read_areas('re_table1', 're_table2');
SELECT tg_set_transaction('short'); -- reset tableName

/* set write preserve (error) */
SELECT tg_set_write_preserve('wp_table3');
SELECT tg_set_write_preserve('wp_table1', 'wp_table2', 'wp_table3');
SELECT tg_set_write_preserve(NULL);
SELECT tg_set_write_preserve('wp_table1', 'wp_table2', NULL);

/* set inclusive read areas (error) */
SELECT tg_set_inclusive_read_areas('ri_table3');
SELECT tg_set_inclusive_read_areas('ri_table1', 'ri_table2', 'ri_table3');
SELECT tg_set_inclusive_read_areas(NULL);
SELECT tg_set_inclusive_read_areas('ri_table1', 'ri_table2', NULL);

/* set exclusive read areas (error) */
SELECT tg_set_exclusive_read_areas('re_table3');
SELECT tg_set_exclusive_read_areas('re_table1', 're_table2', 're_table3');
SELECT tg_set_exclusive_read_areas(NULL);
SELECT tg_set_exclusive_read_areas('re_table1', 're_table2', NULL);

/* start transaction */
BEGIN;
BEGIN; -- warning
COMMIT;

/* commit */
COMMIT; -- warning

/* rollback */
ROLLBACK; -- warning
BEGIN;
ROLLBACK;

SELECT tg_set_write_preserve('');
SELECT tg_set_inclusive_read_areas('');
SELECT tg_set_exclusive_read_areas('');

/* Implicit transaction */
INSERT INTO udf_table1 (column1) VALUES (100);
SELECT * FROM udf_table1;
UPDATE udf_table1 SET column1 = column1+1;
SELECT * FROM udf_table1;
DELETE FROM udf_table1 WHERE column1 = 101;
SELECT * from udf_table1;

/* Explicit transaction (commit) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (200);
COMMIT;
SELECT * FROM udf_table1;

BEGIN;
UPDATE udf_table1 SET column1 = column1+1;
COMMIT;
SELECT * FROM udf_table1;

BEGIN;
DELETE FROM udf_table1 WHERE column1 = 201;
COMMIT;
SELECT * from udf_table1;

/* Explicit transaction (rollback) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (300);
ROLLBACK;
SELECT * FROM udf_table1;

INSERT INTO udf_table1 (column1) VALUES (400);
BEGIN;
UPDATE udf_table1 SET column1 = column1+1;
ROLLBACK;
SELECT * FROM udf_table1;
BEGIN;
DELETE FROM udf_table1 WHERE column1 = 400;
ROLLBACK;
SELECT * FROM udf_table1;

/* Long transaction */
SELECT tg_set_transaction('long');

SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
INSERT INTO wp_table1 (column1) VALUES (100);
INSERT INTO wp_table2 (column1) VALUES (100);
INSERT INTO udf_table1 (column1) VALUES (500); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;
UPDATE wp_table1 SET column1 = column1+1;
UPDATE wp_table2 SET column1 = column1+1;
UPDATE udf_table1 SET column1 = column1+1; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;
DELETE FROM wp_table1 WHERE column1 = 101;
DELETE FROM wp_table2 WHERE column1 = 101;
DELETE FROM udf_table1 WHERE column1 = 400; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;

SELECT tg_set_write_preserve('wp_table1');
INSERT INTO wp_table1 (column1) VALUES (200);
INSERT INTO wp_table2 (column1) VALUES (200); -- error
INSERT INTO udf_table1 (column1) VALUES (500); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;
UPDATE wp_table1 SET column1 = column1+1;
UPDATE udf_table1 SET column1 = column1+1; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;
DELETE FROM wp_table1 WHERE column1 = 201;
DELETE FROM udf_table1 WHERE column1 = 400; -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;

SELECT tg_set_transaction('short'); -- reset tableName

/* inclusive read areasを指定した場合は、そのLTXがreadするのは指定したtableのみである */
SELECT tg_set_transaction('long');
SELECT tg_set_inclusive_read_areas('ri_table1');

SELECT * FROM ri_table1; -- success

/*
エラー詳細に含まれるTIDが毎回異なる値になるためテスト対象外とする
SELECT * FROM ri_table2; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004e7 shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:ri_table2, no key information} )
SELECT * FROM re_table1; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004e8 shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:re_table1, no key information} )
SELECT * FROM re_table2; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004e9 shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:re_table2, no key information} )
*/

SELECT tg_set_transaction('short'); -- reset tableName

/* exclusive read areasは、そのLTXがreadしないtableを宣言する */
/* リストアップされているtableをreadした場合はエラーになりそれ以外のtableはread可能 */
SELECT tg_set_transaction('long');
SELECT tg_set_exclusive_read_areas('re_table1');

SELECT * FROM ri_table1; -- success
SELECT * FROM ri_table2; -- success
/*
エラー詳細に含まれるTIDが毎回異なる値になるためテスト対象外とする
SELECT * FROM re_table1; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004ec shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:re_table1, no key information} )
*/
SELECT * FROM re_table2; -- success

/* 通常はどちらか一方のみを指定する使い方になることを想定 */
SELECT tg_set_inclusive_read_areas('ri_table1');
SELECT tg_set_exclusive_read_areas('re_table1');

SELECT * FROM ri_table1; -- success
/*
エラー詳細に含まれるTIDが毎回異なる値になるためテスト対象外とする
SELECT * FROM ri_table2; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004ef shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:ri_table2, no key information} )
SELECT * FROM re_table1; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004f0 shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:re_table1, no key information} )
SELECT * FROM re_table2; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004f1 shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:re_table2, no key information} )
*/

SELECT tg_set_transaction('short');

SELECT * FROM ri_table1; -- success
SELECT * FROM ri_table2; -- success
SELECT * FROM re_table1; -- success
SELECT * FROM re_table2; -- success

/* Explicit specific transaction */
/* Execute a specific Short transaction during a Long transaction */
SELECT tg_set_transaction('long');
SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
INSERT INTO wp_table1 (column1) VALUES (300);
INSERT INTO wp_table2 (column1) VALUES (300);
INSERT INTO udf_table1 (column1) VALUES (600); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;

SELECT tg_set_transaction('short', 'default', 'specific-transaction');
SELECT tg_show_transaction();
INSERT INTO wp_table1 (column1) VALUES (400);
INSERT INTO wp_table2 (column1) VALUES (400);
INSERT INTO udf_table1 (column1) VALUES (700);
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;

SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
SELECT tg_set_transaction('long');
SELECT tg_show_transaction();
INSERT INTO wp_table1 (column1) VALUES (500);
INSERT INTO wp_table2 (column1) VALUES (500);
INSERT INTO udf_table1 (column1) VALUES (800); -- error
SELECT * FROM wp_table1;
SELECT * FROM wp_table2;
SELECT * FROM udf_table1;

/* Cooperation with PostgreSQL table */
SELECT tg_set_transaction('short');
-- table preparation
CREATE FOREIGN TABLE tg_table (column1 INTEGER NOT NULL) SERVER tsurugidb;
	CREATE TABLE pg_table (column1 INTEGER NOT NULL PRIMARY KEY);
INSERT INTO tg_table (column1) VALUES (999);
-- Start the Tsurugi transaction
BEGIN;
-- Update the Tsurugi table
UPDATE tg_table SET column1 = column1+1;
	-- BEGIN;
	-- Insert pre-commit Tsurugi table into PostgreSQL table
	INSERT INTO pg_table SELECT column1 from tg_table;
-- Abort the Tsuguri transaction
ROLLBACK;
	-- COMMIT;
-- Updates to the Tsurugi table are discarded(999)
SELECT * from tg_table;
	-- Do not discard updates to PostgreSQL tables(1000)
	-- SELECT * from pg_table;

/* clean up */
DROP FOREIGN TABLE tg_table;
DROP FOREIGN TABLE udf_table1;
DROP FOREIGN TABLE wp_table1;
DROP FOREIGN TABLE wp_table2;
DROP FOREIGN TABLE ri_table1;
DROP FOREIGN TABLE ri_table2;
DROP FOREIGN TABLE re_table1;
DROP FOREIGN TABLE re_table2;
