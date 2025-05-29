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

/* set option (error) */
SELECT tg_set_transaction('short transaction');
SELECT tg_set_transaction('wait');
SELECT tg_set_transaction('short', 'exlude');
SELECT tg_set_transaction('short', 'wait', '');

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

SELECT tg_set_transaction('short'); -- reset tableName

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

/* Explicit transaction (rollback) */
BEGIN;
INSERT INTO udf_table1 (column1) VALUES (300);
INSERT INTO udf_table2 (column1) VALUES (400);
COMMIT;
SELECT * FROM udf_table1 ORDER BY column1;

/* transaction */
INSERT INTO udf_table1 (column1) VALUES (400);

/* Long transaction */
SELECT tg_set_transaction('long');

SELECT tg_set_write_preserve('wp_table1', 'wp_table2');
INSERT INTO udf_table1 (column1) VALUES (500); -- error
SELECT * FROM udf_table1 ORDER BY column1;
UPDATE udf_table1 SET column1 = column1+1; -- error
SELECT * FROM udf_table1 ORDER BY column1;
DELETE FROM udf_table1 WHERE column1 = 400; -- error
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

/* Explicit long transaction (tg_set_write_preserve) */
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

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_table1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE wp_table1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE wp_table2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE ri_table1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE ri_table2');
