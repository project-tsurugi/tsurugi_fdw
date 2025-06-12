/* Test setup: DDL of the Tsurugi */
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
CREATE FOREIGN TABLE tg_numeric_s0 (
    id INTEGER NOT NULL,
    num NUMERIC(38, 0)
) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_numeric_s38 (
    id INTEGER NOT NULL,
    num NUMERIC(38, 38)
) SERVER tsurugidb;

/* PREPARE */
PREPARE tg_insval_s0 (integer, numeric) AS INSERT INTO tg_numeric_s0 (id, num) VALUES ($1, $2);
PREPARE tg_insval_s38 (integer, numeric) AS INSERT INTO tg_numeric_s38 (id, num) VALUES ($1, $2);

-- incorrect value
EXECUTE tg_insval_s0 (99, 100000000000000000000000000000000000000);
EXECUTE tg_insval_s0 (98, 340282366920938463463374607431768211455);
EXECUTE tg_insval_s0 (97, 340282366920938463463374607431768211456);

SELECT * FROM tg_numeric_s0;

-- incorrect value
EXECUTE tg_insval_s38 (99, 1);
EXECUTE tg_insval_s38 (98, 0.000000000000000000000000000000000000001);
EXECUTE tg_insval_s38 (97, 0.340282366920938463463374607431768211455);
EXECUTE tg_insval_s38 (96, 0.340282366920938463463374607431768211456);

SELECT * FROM tg_numeric_s38;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE tg_numeric_s0;
DROP FOREIGN TABLE tg_numeric_s38;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE tg_numeric_s0', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE tg_numeric_s38', 'tsurugidb');
