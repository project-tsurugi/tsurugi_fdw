/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE tg_numeric (
        id INTEGER NOT NULL PRIMARY KEY,
        num NUMERIC(10, 6)
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE tg_numeric_s0 (
        id INTEGER NOT NULL PRIMARY KEY,
        num NUMERIC(38, 0)
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE tg_numeric_s38 (
        id INTEGER NOT NULL PRIMARY KEY,
        num NUMERIC(38, 38)
    )
', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE tg_numeric (
    id INTEGER NOT NULL,
    num NUMERIC(10, 6)
) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_numeric_s0 (
    id INTEGER NOT NULL,
    num NUMERIC(38, 0)
) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_numeric_s38 (
    id INTEGER NOT NULL,
    num NUMERIC(38, 38)
) SERVER tsurugidb;

/* SET DATASTYLE */
SET datestyle TO ISO, ymd;

/* PREPARE */
/* Basic Action */
PREPARE tg_insnum  (integer, numeric) AS INSERT INTO tg_numeric (id, num) VALUES ($1, $2);
PREPARE tg_updnum1 (integer, numeric) AS UPDATE tg_numeric SET num = $2 WHERE id = $1;
PREPARE tg_updnum2 (integer, numeric) AS UPDATE tg_numeric SET id = $1 WHERE num = $2;
PREPARE tg_delnum1 (integer)          AS DELETE FROM tg_numeric WHERE id = $1;
PREPARE tg_delnum2 (numeric)          AS DELETE FROM tg_numeric WHERE num = $1;
PREPARE tg_selnum1 (integer)          AS SELECT * FROM tg_numeric WHERE id = $1;
PREPARE tg_selnum2 (numeric)          AS SELECT * FROM tg_numeric WHERE num = $1;

EXECUTE tg_insnum (1, 3.14);
EXECUTE tg_insnum (2, -3.14);

SELECT * FROM tg_numeric;

EXECUTE tg_updnum1 (1, 3.141592);
EXECUTE tg_updnum2 (2222, -3.14);

SELECT * FROM tg_numeric;

EXECUTE tg_selnum1 (2222);
EXECUTE tg_selnum2 (3.141592);

EXECUTE tg_delnum1 (1);
EXECUTE tg_delnum2 (-3.14);

SELECT * FROM tg_numeric;

/* Mathematical Functions */
-- Retutn numeric types
EXECUTE tg_insnum ( 1, abs(-17.4));
EXECUTE tg_insnum ( 2, ceil(-42.8));
EXECUTE tg_insnum ( 3, ceiling(-95.3));
EXECUTE tg_insnum ( 4, div(9,4));
EXECUTE tg_insnum ( 5, CAST(exp(1.0) AS DECIMAL(10,6)));
EXECUTE tg_insnum ( 6, factorial(5));
EXECUTE tg_insnum ( 7, floor(-42.8));
EXECUTE tg_insnum ( 8, CAST(ln(2.0) AS DECIMAL(10,6)));
EXECUTE tg_insnum ( 9, log(100.0));
EXECUTE tg_insnum (10, log10(100.0));
EXECUTE tg_insnum (11, log(2.0, 64.0));
EXECUTE tg_insnum (12, mod(9,4));
EXECUTE tg_insnum (13, power(9.0, 3.0));
EXECUTE tg_insnum (14, round(42.4));
EXECUTE tg_insnum (15, round(42.4382, 2));
EXECUTE tg_insnum (16, sign(-8.4));
EXECUTE tg_insnum (17, CAST(sqrt(2.0) AS DECIMAL(10,6)));
EXECUTE tg_insnum (18, trunc(42.8));
EXECUTE tg_insnum (19, trunc(42.4382, 2));
-- Retutn double precision or integer types
EXECUTE tg_insnum (20, CAST(cbrt(27.0) AS DECIMAL(10,6)));
EXECUTE tg_insnum (21, CAST(degrees(0.5) AS DECIMAL(10,6)));
EXECUTE tg_insnum (22, CAST(pi() AS DECIMAL(10,6)));
EXECUTE tg_insnum (23, CAST(radians(45.0) AS DECIMAL(10,6)));
EXECUTE tg_insnum (24, CAST(scale(8.41) AS DECIMAL(10,6)));
EXECUTE tg_insnum (25, CAST(width_bucket(5.35, 0.024, 10.06, 5) AS DECIMAL(10,6)));

SELECT * FROM tg_numeric;

/* value check */
PREPARE tg_insval_s0 (integer, numeric) AS INSERT INTO tg_numeric_s0 (id, num) VALUES ($1, $2);
PREPARE tg_insval_s38 (integer, numeric) AS INSERT INTO tg_numeric_s38 (id, num) VALUES ($1, $2);

-- correct value
EXECUTE tg_insval_s0 ( 1, 0);
EXECUTE tg_insval_s0 ( 2, 1);
EXECUTE tg_insval_s0 ( 3, 18446744073709551615);
EXECUTE tg_insval_s0 ( 4, 18446744073709551616);
EXECUTE tg_insval_s0 ( 5, 99999999999999999999999999999999999999);
EXECUTE tg_insval_s0 ( 6, -1);
EXECUTE tg_insval_s0 ( 7, -18446744073709551615);
EXECUTE tg_insval_s0 ( 8, -18446744073709551616);
EXECUTE tg_insval_s0 ( 9, -99999999999999999999999999999999999999);

SELECT * FROM tg_numeric_s0;

-- correct value
EXECUTE tg_insval_s38 ( 1, 0);  -- see tsurugi-issues#736
EXECUTE tg_insval_s38 ( 2, 0.00000000000000000000000000000000000001);
EXECUTE tg_insval_s38 ( 3, 0.00000000000000000018446744073709551615);
EXECUTE tg_insval_s38 ( 4, 0.00000000000000000018446744073709551616);
EXECUTE tg_insval_s38 ( 5, 0.99999999999999999999999999999999999999);
EXECUTE tg_insval_s38 ( 6, -0.00000000000000000000000000000000000001);
EXECUTE tg_insval_s38 ( 7, -0.00000000000000000018446744073709551615);
EXECUTE tg_insval_s38 ( 8, -0.00000000000000000018446744073709551616);
EXECUTE tg_insval_s38 ( 9, -0.99999999999999999999999999999999999999);

SELECT * FROM tg_numeric_s38;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE tg_numeric;
DROP FOREIGN TABLE tg_numeric_s0;
DROP FOREIGN TABLE tg_numeric_s38;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE tg_numeric', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE tg_numeric_s0', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE tg_numeric_s38', 'tsurugidb');
