/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE t1_prepare_select_statement (
        c1 INTEGER PRIMARY KEY,
        c2 INTEGER,
        c3 BIGINT,
        c4 REAL,
        c5 DOUBLE PRECISION,
        c6 CHAR(10),
        c7 VARCHAR(26)
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE t2_prepare_select_statement (
        c1 INTEGER PRIMARY KEY,
        c2 INTEGER,
        c3 BIGINT,
        c4 REAL,
        c5 DOUBLE PRECISION,
        c6 CHAR(10),
        c7 VARCHAR(26)
    )
', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE t1_prepare_select_statement (
    c1 INTEGER,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;
CREATE FOREIGN TABLE t2_prepare_select_statement (
    c1 INTEGER,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

/* PREPARE */
-- ORDER BY #2
/* failed (10) because of ORDER BY 6 */
PREPARE select_t2_orderby2
    AS SELECT c1, c2, c3, c4, c5, c6, c7 FROM t2_prepare_select_statement ORDER BY 6;

-- WHERE #8
/* not support EXISTS failed. (10) */
PREPARE select_t1_where8
    AS SELECT * FROM t1_prepare_select_statement WHERE EXISTS (SELECT * FROM t2_prepare_select_statement WHERE c2 = 22) ORDER BY c1;

-- GROUP BY #1
/* aggregate functions alias not support failed. (10) */
PREPARE select_t2_group1_ng
    AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM t2_prepare_select_statement GROUP BY c7;

-- GROUP BY #2
/* aggregate functions alias not support failed. (10) */
PREPARE select_t2_group2_ng1
    AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM t2_prepare_select_statement GROUP BY c7 HAVING sum(c2) > 55 ORDER BY c7;

-- TG JOIN #2
/* failed (10) : mismatched input 'USING' */
PREPARE select_join2
    AS SELECT a.c1, a.c2, b.c1, b.c7 FROM t1_prepare_select_statement a INNER JOIN t2_prepare_select_statement b USING (c1) ORDER BY b.c4 DESC;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE t1_prepare_select_statement;
DROP FOREIGN TABLE t2_prepare_select_statement;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE t1_prepare_select_statement', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE t2_prepare_select_statement', 'tsurugidb');
