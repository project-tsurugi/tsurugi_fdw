/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE update_delete_int1 (
        col1 int PRIMARY KEY,
        col2 int
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE update_delete_bigint1 (
        col1 int PRIMARY KEY,
        col2 bigint
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE update_delete_real1 (
        col1 int PRIMARY KEY,
        col2 real
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE update_delete_double1 (
        col1 int PRIMARY KEY,
        col2 double precision
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE update_delete_char1 (
        col1 int PRIMARY KEY,
        col2 char(2)
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE update_delete_varchar1 (
        col1 int PRIMARY KEY,
        col2 varchar(2)
    )
', 'tsurugidb');

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
INSERT INTO update_delete_int1 (col1, col2) VALUES (2, 2);
SELECT * FROM update_delete_int1 ORDER BY col1;

UPDATE update_delete_int1 SET col2 = col2+2147483645;
SELECT * FROM update_delete_int1 ORDER BY col1;

DELETE FROM update_delete_int1 WHERE col2 = 2147483647;
SELECT * FROM update_delete_int1 ORDER BY col1;

---bigint
SELECT * FROM update_delete_bigint1 ORDER BY col1;
INSERT INTO update_delete_bigint1 (col1, col2) VALUES (1, 1);
INSERT INTO update_delete_bigint1 (col1, col2) VALUES (2, 2);
SELECT * FROM update_delete_bigint1 ORDER BY col1;

UPDATE update_delete_bigint1 SET col2 = col2+9223372036854775805;
SELECT * FROM update_delete_bigint1 ORDER BY col1;

DELETE FROM update_delete_bigint1 WHERE col2 = 9223372036854775807;
SELECT * FROM update_delete_bigint1 ORDER BY col1;

---real
SELECT * FROM update_delete_real1 ORDER BY col1;
INSERT INTO update_delete_real1 (col1, col2) VALUES (1, 1.1);
INSERT INTO update_delete_real1 (col1, col2) VALUES (2, 0.1);
INSERT INTO update_delete_real1 (col1, col2) VALUES (3, 3.4);
SELECT * FROM update_delete_real1 ORDER BY col1;

UPDATE update_delete_real1 SET col2 = col2+1;
SELECT * FROM update_delete_real1 ORDER BY col1;  -- fix Tsurugi1.0.0-BETA4

DELETE FROM update_delete_real1 WHERE col2 = cast(4.4 as real);  -- see tsurugi-issues#736
SELECT * FROM update_delete_real1 ORDER BY col1;  -- fix Tsurugi1.0.0-BETA4

---double precision
SELECT * FROM update_delete_double1 ORDER BY col1;
INSERT INTO update_delete_double1 (col1, col2) VALUES (1, 1.1);
INSERT INTO update_delete_double1 (col1, col2) VALUES (2, 0.1);
INSERT INTO update_delete_double1 (col1, col2) VALUES (3, 3.4);
SELECT * FROM update_delete_double1 ORDER BY col1;

UPDATE update_delete_double1 SET col2 = col2+1;
SELECT * FROM update_delete_double1 ORDER BY col1;

DELETE FROM update_delete_double1 WHERE col2 = 4.4;
SELECT * FROM update_delete_double1 ORDER BY col1;

---char
SELECT * FROM update_delete_char1 ORDER BY col1;
INSERT INTO update_delete_char1 (col1, col2) VALUES (1, 'ab');
INSERT INTO update_delete_char1 (col1, col2) VALUES (2, 'kl');
SELECT * FROM update_delete_char1 ORDER BY col1;

UPDATE update_delete_char1 SET col2 = 'uv' WHERE col2 = 'ab';
SELECT * FROM update_delete_char1 ORDER BY col1;

DELETE FROM update_delete_char1 WHERE col2 = 'kl';
SELECT * FROM update_delete_char1 ORDER BY col1;

---varchar
SELECT * FROM update_delete_varchar1 ORDER BY col1;
INSERT INTO update_delete_varchar1 (col1, col2) VALUES (1, 'ab');
INSERT INTO update_delete_varchar1 (col1, col2) VALUES (2, 'kl');
SELECT * FROM update_delete_varchar1 ORDER BY col1;

UPDATE update_delete_varchar1 SET col2 = 'uv' WHERE col2 = 'ab';
SELECT * FROM update_delete_varchar1 ORDER BY col1;

DELETE FROM update_delete_varchar1 WHERE col2 = 'kl';
SELECT * FROM update_delete_varchar1 ORDER BY col1;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE update_delete_int1;
DROP FOREIGN TABLE update_delete_bigint1;
DROP FOREIGN TABLE update_delete_real1;
DROP FOREIGN TABLE update_delete_double1;
DROP FOREIGN TABLE update_delete_char1;
DROP FOREIGN TABLE update_delete_varchar1;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE update_delete_int1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE update_delete_bigint1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE update_delete_real1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE update_delete_double1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE update_delete_char1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE update_delete_varchar1', 'tsurugidb');
