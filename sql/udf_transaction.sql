/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE udf_table1 (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE wp_table1 (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE wp_table2 (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE ri_table1 (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE ri_table2 (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE re_table1 (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE re_table2 (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE tg_table (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE udf_table1 (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE wp_table1 (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE wp_table2 (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE ri_table1 (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE ri_table2 (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE re_table1 (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE re_table2 (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_table (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;

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
SELECT * FROM udf_table1 ORDER BY column1;
UPDATE udf_table1 SET column1 = column1+1;
SELECT * FROM udf_table1 ORDER BY column1;
DELETE FROM udf_table1 WHERE column1 = 101;
SELECT * from udf_table1 ORDER BY column1;

/* Explicit transaction (begin) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (100);
UPDATE udf_table1 SET column1 = column1+2;
DELETE FROM udf_table1 WHERE column1 = 102;
COMMIT;
SELECT * from udf_table1 ORDER BY column1;

/* Explicit transaction (start transaction) */
START TRANSACTION;
INSERT INTO udf_table1 (column1) VALUES (100);
UPDATE udf_table1 SET column1 = column1+3;
DELETE FROM udf_table1 WHERE column1 = 103;
COMMIT;
SELECT * from udf_table1 ORDER BY column1;

/* Explicit transaction (commit) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (200);
COMMIT;
SELECT * FROM udf_table1 ORDER BY column1;

BEGIN;
UPDATE udf_table1 SET column1 = column1+1;
COMMIT;
SELECT * FROM udf_table1 ORDER BY column1;

BEGIN;
DELETE FROM udf_table1 WHERE column1 = 201;
COMMIT;
SELECT * from udf_table1 ORDER BY column1;

/* Explicit transaction (end) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (200);
END;
SELECT * FROM udf_table1 ORDER BY column1;

BEGIN;
UPDATE udf_table1 SET column1 = column1+2;
END;
SELECT * FROM udf_table1 ORDER BY column1;

BEGIN;
DELETE FROM udf_table1 WHERE column1 = 202;
END;
SELECT * from udf_table1 ORDER BY column1;

/* Explicit transaction (rollback) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (300);
ROLLBACK;
SELECT * FROM udf_table1 ORDER BY column1;

INSERT INTO udf_table1 (column1) VALUES (400);
BEGIN;
UPDATE udf_table1 SET column1 = column1+1;
ROLLBACK;
SELECT * FROM udf_table1 ORDER BY column1;
BEGIN;
DELETE FROM udf_table1 WHERE column1 = 400;
ROLLBACK;
SELECT * FROM udf_table1 ORDER BY column1;

BEGIN;
INSERT INTO udf_table1 (column1) VALUES (300);
INSERT INTO udf_table2 (column1) VALUES (400);
COMMIT;
SELECT * FROM udf_table1 ORDER BY column1;

/* Explicit transaction (abort) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (300);
ABORT;
SELECT * FROM udf_table1 ORDER BY column1;

BEGIN;
UPDATE udf_table1 SET column1 = column1+2;
ABORT;
SELECT * FROM udf_table1 ORDER BY column1;

BEGIN;
DELETE FROM udf_table1 WHERE column1 = 400;
ABORT;
SELECT * FROM udf_table1 ORDER BY column1;

DELETE FROM udf_table1 WHERE column1 = 400;

/* Auto commit off */
\echo :AUTOCOMMIT
\set AUTOCOMMIT off
\echo :AUTOCOMMIT

BEGIN;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;

INSERT INTO udf_table1 (column1) VALUES (410);
COMMIT;
SELECT * FROM udf_table1 ORDER BY column1;
DELETE FROM udf_table1 WHERE column1 = 410;
COMMIT;

BEGIN;
INSERT INTO udf_table1 (column1) VALUES (420);
COMMIT;
SELECT * FROM udf_table1 ORDER BY column1;
DELETE FROM udf_table1 WHERE column1 = 420;
COMMIT;

INSERT INTO udf_table1 (column1) VALUES (430);
ROLLBACK;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;

BEGIN;
INSERT INTO udf_table1 (column1) VALUES (440);
ROLLBACK;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;


\echo :AUTOCOMMIT
\set AUTOCOMMIT on
\echo :AUTOCOMMIT

INSERT INTO udf_table1 (column1) VALUES (400);

/* Long transaction */
SELECT tg_set_transaction('long');

SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
INSERT INTO wp_table1 (column1) VALUES (100);
INSERT INTO wp_table2 (column1) VALUES (100);
INSERT INTO udf_table1 (column1) VALUES (500); -- error
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;
SELECT * FROM udf_table1 ORDER BY column1;
UPDATE wp_table1 SET column1 = column1+1;
UPDATE wp_table2 SET column1 = column1+1;
UPDATE udf_table1 SET column1 = column1+1; -- error
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;
SELECT * FROM udf_table1 ORDER BY column1;
DELETE FROM wp_table1 WHERE column1 = 101;
DELETE FROM wp_table2 WHERE column1 = 101;
DELETE FROM udf_table1 WHERE column1 = 400; -- error
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;
SELECT * FROM udf_table1 ORDER BY column1;

SELECT tg_set_write_preserve('wp_table1');
INSERT INTO wp_table1 (column1) VALUES (200);
INSERT INTO wp_table2 (column1) VALUES (200); -- error
INSERT INTO udf_table1 (column1) VALUES (500); -- error
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;
SELECT * FROM udf_table1 ORDER BY column1;
UPDATE wp_table1 SET column1 = column1+1;
UPDATE udf_table1 SET column1 = column1+1; -- error
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;
SELECT * FROM udf_table1 ORDER BY column1;
DELETE FROM wp_table1 WHERE column1 = 201;
DELETE FROM udf_table1 WHERE column1 = 400; -- error
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;
SELECT * FROM udf_table1 ORDER BY column1;

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

SELECT * FROM ri_table1 ORDER BY column1; -- success
SELECT * FROM ri_table2 ORDER BY column1; -- success
/*
エラー詳細に含まれるTIDが毎回異なる値になるためテスト対象外とする
SELECT * FROM re_table1; -- error
ERROR:  Tsurugi Server INACTIVE_TRANSACTION_EXCEPTION (SQL-02025: serialization failed transaction:TID-00000000000004ec shirakami response Status=ERR_READ_AREA_VIOLATION {reason_code:CC_LTX_READ_AREA_VIOLATION, storage_name:re_table1, no key information} )
*/
SELECT * FROM re_table2 ORDER BY column1; -- success

/* 通常はどちらか一方のみを指定する使い方になることを想定 */
SELECT tg_set_inclusive_read_areas('ri_table1');
SELECT tg_set_exclusive_read_areas('re_table1');

SELECT * FROM ri_table1 ORDER BY column1; -- success
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

SELECT * FROM ri_table1 ORDER BY column1; -- success
SELECT * FROM ri_table2 ORDER BY column1; -- success
SELECT * FROM re_table1 ORDER BY column1; -- success
SELECT * FROM re_table2 ORDER BY column1; -- success

SELECT tg_set_write_preserve('');
SELECT tg_set_inclusive_read_areas('');
SELECT tg_set_exclusive_read_areas('');

/* Explicit long transaction (tg_set_write_preserve) */
SELECT tg_set_transaction('long');

SELECT tg_set_write_preserve('wp_table1');
BEGIN;
INSERT INTO wp_table1 (column1) VALUES (100);
COMMIT;
SELECT * FROM wp_table1 ORDER BY column1;
DELETE FROM udf_table1 WHERE column1 = 100;

SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
BEGIN;
INSERT INTO wp_table1 (column1) VALUES (200);
INSERT INTO wp_table2 (column1) VALUES (300);
COMMIT;
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;

SELECT tg_set_write_preserve('wp_table3');
BEGIN;
SELECT * FROM wp_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_write_preserve('wp_table3', 'wp_table4');
BEGIN;
SELECT * FROM wp_table1 ORDER BY column1;
SELECT * FROM wp_table2 ORDER BY column1;
COMMIT;

SELECT tg_set_write_preserve('wp_table1', 'wp_table3');
BEGIN;
INSERT INTO wp_table1 (column1) VALUES (100);
COMMIT;

SELECT tg_set_write_preserve('');

/* Explicit long transaction (tg_set_inclusive_read_areas) */
SELECT tg_set_transaction('long');

SELECT tg_set_inclusive_read_areas('ri_table1');
BEGIN;
SELECT * FROM ri_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_inclusive_read_areas('ri_table1', 'ri_table2'); 
BEGIN;
SELECT * FROM ri_table1 ORDER BY column1;
SELECT * FROM ri_table2 ORDER BY column1;
COMMIT;

SELECT tg_set_inclusive_read_areas('ri_table3');
BEGIN;
SELECT * FROM ri_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_inclusive_read_areas('ri_table3', 'ri_table4');
BEGIN;
SELECT * FROM ri_table1 ORDER BY column1;
SELECT * FROM ri_table2 ORDER BY column1;
COMMIT;

SELECT tg_set_inclusive_read_areas('ri_table1', 'ri_table3');
BEGIN;
SELECT * FROM ri_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_inclusive_read_areas('');

/* Explicit long transaction (tg_set_exclusive_read_areas) */
SELECT tg_set_transaction('long');

SELECT tg_set_exclusive_read_areas('re_table1'); 
BEGIN;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_exclusive_read_areas('re_table1', 're_table2');
BEGIN;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_exclusive_read_areas('re_table3');
BEGIN;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_exclusive_read_areas('re_table3', 're_table4');
BEGIN;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_exclusive_read_areas('wp_table1', 'wp_table3');
BEGIN;
SELECT * FROM udf_table1 ORDER BY column1;
COMMIT;

SELECT tg_set_exclusive_read_areas('');

/* Since tsurugi_fdw 1.0.0, the following UDF is no longer supported.*/
SELECT tg_start_transaction();
SELECT tg_start_transaction('short');
SELECT tg_start_transaction('short', 'interrupt');
SELECT tg_start_transaction('short', 'interrupt', 'test-label');
SELECT tg_commit();
SELECT tg_rollback();

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE udf_table1;
DROP FOREIGN TABLE wp_table1;
DROP FOREIGN TABLE wp_table2;
DROP FOREIGN TABLE ri_table1;
DROP FOREIGN TABLE ri_table2;
DROP FOREIGN TABLE re_table1;
DROP FOREIGN TABLE re_table2;
DROP FOREIGN TABLE tg_table;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE tg_table');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_table1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE wp_table1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE wp_table2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE ri_table1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE ri_table2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE re_table1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE re_table2');
