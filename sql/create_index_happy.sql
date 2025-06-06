/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE t3_create_index (
        c1 INTEGER NOT NULL PRIMARY KEY
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE INDEX t3_c1_secondary_index ON t3_create_index (c1)
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE t4_create_index (
        c1 INTEGER NOT NULL PRIMARY KEY,
        c2 BIGINT,
        c3 DOUBLE PRECISION
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE INDEX t4_c3_secondary_index ON t4_create_index (c3)
', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE t3_create_index (
    c1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE t4_create_index (
    c1 INTEGER NOT NULL,
    c2 BIGINT,
    c3 DOUBLE PRECISION
) SERVER tsurugidb;

/* DML */
SELECT * FROM t3_create_index ORDER BY c1;
INSERT INTO t3_create_index (c1) VALUES (1);
SELECT * FROM t3_create_index ORDER BY c1;

SELECT * FROM t4_create_index ORDER BY c1;
INSERT INTO t4_create_index (c1, c2, c3) VALUES (1, 100, 1.1);
INSERT INTO t4_create_index (c1, c2, c3) VALUES (2, 200, 2.2);
SELECT * FROM t4_create_index ORDER BY c1;

SELECT * FROM t3_create_index ORDER BY c1;
INSERT INTO t3_create_index (c1) VALUES (10);
INSERT INTO t3_create_index (c1) VALUES (100);
SELECT * FROM t3_create_index ORDER BY c1;

SELECT * FROM t4_create_index ORDER BY c1;
UPDATE t4_create_index SET c2 = c2+10;
UPDATE t4_create_index SET c3 = c3+1.1 WHERE c2 = 110;
SELECT * FROM t4_create_index ORDER BY c1;

SELECT * FROM t3_create_index ORDER BY c1;
DELETE FROM t3_create_index WHERE c1 = 10;
SELECT * FROM t3_create_index ORDER BY c1;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE t3_create_index;
DROP FOREIGN TABLE t4_create_index;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP INDEX t3_c1_secondary_index', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE t3_create_index', 'tsurugidb');
SELECT tg_execute_ddl('DROP INDEX t4_c3_secondary_index', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE t4_create_index', 'tsurugidb');
