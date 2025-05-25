/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE update_delete_int1 (
        col1 int PRIMARY KEY,
        col2 int
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE update_delete_bigint1 (
        col1 int PRIMARY KEY,
        col2 bigint
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE update_delete_real1 (
        col1 int PRIMARY KEY,
        col2 real
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE update_delete_double1 (
        col1 int PRIMARY KEY,
        col2 double precision
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE update_delete_char1 (
        col1 int PRIMARY KEY,
        col2 char(2)
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE update_delete_varchar1 (
        col1 int PRIMARY KEY,
        col2 varchar(2)
    )
');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE update_delete_int1 (
    col1 int,
    col2 int
) SERVER tsurugidb;
CREATE FOREIGN TABLE update_delete_bigint1 (
    col1 int,
    col2 bigint
) SERVER tsurugidb;
CREATE FOREIGN TABLE update_delete_real1 (
    col1 int,
    col2 real
) SERVER tsurugidb;
CREATE FOREIGN TABLE update_delete_double1 (
    col1 int,
    col2 double precision
) SERVER tsurugidb;
CREATE FOREIGN TABLE update_delete_char1 (
    col1 int,
    col2 char(2)
) SERVER tsurugidb;
CREATE FOREIGN TABLE update_delete_varchar1 (
    col1 int,
    col2 varchar(2)
) SERVER tsurugidb;

/* DML */
---int
SELECT * FROM update_delete_int1 ORDER BY col1;

INSERT INTO update_delete_int1 (col1, col2) VALUES (1, 1);
SELECT * FROM update_delete_int1 ORDER BY col1;

UPDATE update_delete_int1 SET col3 = 2 WHERE col2 = 1;
SELECT * FROM update_delete_int1 ORDER BY col1;

UPDATE update_delete_int1 SET col2 = 2 WHERE col3 = 1;
SELECT * FROM update_delete_int1 ORDER BY col1;

DELETE FROM update_delete_int1 WHERE col3 = 1;
SELECT * FROM update_delete_int1 ORDER BY col1;

---bigint
SELECT * FROM update_delete_bigint1 ORDER BY col1;
INSERT INTO update_delete_bigint1 (col1, col2) VALUES (1, 1);
SELECT * FROM update_delete_bigint1 ORDER BY col1;

UPDATE update_delete_bigint1 SET col3 = 2 WHERE col2 = 1;
SELECT * FROM update_delete_bigint1 ORDER BY col1;

UPDATE update_delete_bigint1 SET col2 = 2 WHERE col3 = 1;
SELECT * FROM update_delete_bigint1 ORDER BY col1;

DELETE FROM update_delete_bigint1 WHERE col3 = 1;
SELECT * FROM update_delete_bigint1 ORDER BY col1;

---real
SELECT * FROM update_delete_real1 ORDER BY col1;
INSERT INTO update_delete_real1 (col1, col2) VALUES (1, 1.1);
SELECT * FROM update_delete_real1 ORDER BY col1;

UPDATE update_delete_real1 SET col3 = 2.2 WHERE col2 = 1.1;
SELECT * FROM update_delete_real1 ORDER BY col1;

UPDATE update_delete_real1 SET col2 = 2.2 WHERE col3 = 1.1;
SELECT * FROM update_delete_real1 ORDER BY col1;

DELETE FROM update_delete_real1 WHERE col3 = 1.1;
SELECT * FROM update_delete_real1 ORDER BY col1;

---double precision
SELECT * FROM update_delete_double1 ORDER BY col1;
INSERT INTO update_delete_double1 (col1, col2) VALUES (1, 1.1);
SELECT * FROM update_delete_double1 ORDER BY col1;

UPDATE update_delete_double1 SET col3 = 2.2 WHERE col2 = 1.1;
SELECT * FROM update_delete_double1 ORDER BY col1;

UPDATE update_delete_double1 SET col2 = 2.2 WHERE col3 = 1.1;
SELECT * FROM update_delete_double1 ORDER BY col1;

DELETE FROM update_delete_double1 WHERE col3 = 1.1;
SELECT * FROM update_delete_double1 ORDER BY col1;

---char
SELECT * FROM update_delete_char1 ORDER BY col1;
INSERT INTO update_delete_char1 (col1, col2) VALUES (1, 'ab');
SELECT * FROM update_delete_char1 ORDER BY col1;

UPDATE update_delete_char1 SET col2 = 'uvd' WHERE col2 = 'ab';
SELECT * FROM update_delete_char1 ORDER BY col1;

UPDATE update_delete_char1 SET col3 = 'uv' WHERE col2 = 'ab';
SELECT * FROM update_delete_char1 ORDER BY col1;

UPDATE update_delete_char1 SET col2 = 'uv' WHERE col3 = 'ab';
SELECT * FROM update_delete_char1 ORDER BY col1;

DELETE FROM update_delete_char1 WHERE col3 = 'ab';
SELECT * FROM update_delete_char1 ORDER BY col1;

---varchar
SELECT * FROM update_delete_varchar1 ORDER BY col1;
INSERT INTO update_delete_varchar1 (col1, col2) VALUES (1, 'ab');
SELECT * FROM update_delete_varchar1 ORDER BY col1;

UPDATE update_delete_varchar1 SET col2 = 'uvd' WHERE col2 = 'ab';
SELECT * FROM update_delete_varchar1 ORDER BY col1;

UPDATE update_delete_varchar1 SET col3 = 'uv' WHERE col2 = 'ab';
SELECT * FROM update_delete_varchar1 ORDER BY col1;

UPDATE update_delete_varchar1 SET col2 = 'uv' WHERE col3 = 'ab';
SELECT * FROM update_delete_varchar1 ORDER BY col1;

DELETE FROM update_delete_varchar1 WHERE col3 = 'ab';
SELECT * FROM update_delete_varchar1 ORDER BY col1;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE update_delete_int1;
DROP FOREIGN TABLE update_delete_bigint1;
DROP FOREIGN TABLE update_delete_real1;
DROP FOREIGN TABLE update_delete_double1;
DROP FOREIGN TABLE update_delete_char1;
DROP FOREIGN TABLE update_delete_varchar1;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE update_delete_int1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE update_delete_bigint1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE update_delete_real1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE update_delete_double1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE update_delete_char1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE update_delete_varchar1');
