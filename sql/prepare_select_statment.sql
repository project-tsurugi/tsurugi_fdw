/***********/
/*** DDL ***/
/***********/
-- TG tables
CREATE TABLE t1(
    c1 INTEGER PRIMARY KEY, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
) TABLESPACE tsurugi;

CREATE FOREIGN TABLE t1(
    c1 INTEGER, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE TABLE t2(
    c1 INTEGER PRIMARY KEY, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
) TABLESPACE tsurugi;

CREATE FOREIGN TABLE t2(
    c1 INTEGER, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE TABLE t3(
    c1 INTEGER PRIMARY KEY,
    c2 CHAR(10)
) TABLESPACE tsurugi;

CREATE FOREIGN TABLE t3(
    c1 INTEGER,
    c2 CHAR(10)
) SERVER tsurugidb;

-- PG tables
CREATE TABLE pt1(
    c1 INTEGER PRIMARY KEY, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
);

CREATE TABLE pt2(
    c1 INTEGER PRIMARY KEY, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
);

CREATE TABLE pt3(
    c1 INTEGER PRIMARY KEY,
    c2 CHAR(10)
);

/***************/
/*** PREPARE ***/
/***************/
-- TG tables
PREPARE insert_t1 (INTEGER, INTEGER, BIGINT, REAL, DOUBLE PRECISION, CHAR(10), VARCHAR(26)) 
    AS INSERT INTO t1 (c1, c2, c3, c4, c5, c6, c7) VALUES ($1, $2, $3, $4, $5, $6, $7);
PREPARE select_t1_all 
	AS SELECT * FROM t1;
PREPARE insert_t2 (INTEGER, INTEGER, BIGINT, REAL, DOUBLE PRECISION, CHAR(10), VARCHAR(26)) 
    AS INSERT INTO t2 (c1, c2, c3, c4, c5, c6, c7) VALUES ($1, $2, $3, $4, $5, $6, $7);
PREPARE select_t2_all 
	AS SELECT * FROM t2;
PREPARE insert_t3 (INTEGER, CHAR(10)) 
    AS INSERT INTO t3 (c1, c2) VALUES ($1, $2);
PREPARE select_t3_all 
	AS SELECT * FROM t3;

-- PG tables
PREPARE insert_pt1 (INTEGER, INTEGER, BIGINT, REAL, DOUBLE PRECISION, CHAR(10), VARCHAR(26)) 
    AS INSERT INTO pt1 (c1, c2, c3, c4, c5, c6, c7) VALUES ($1, $2, $3, $4, $5, $6, $7);
PREPARE select_pt1_all 
	AS SELECT * FROM pt1;
PREPARE insert_pt2 (INTEGER, INTEGER, BIGINT, REAL, DOUBLE PRECISION, CHAR(10), VARCHAR(26)) 
    AS INSERT INTO pt2 (c1, c2, c3, c4, c5, c6, c7) VALUES ($1, $2, $3, $4, $5, $6, $7);
PREPARE select_pt2_all 
	AS SELECT * FROM pt2;
PREPARE insert_pt3 (INTEGER, CHAR(10)) 
    AS INSERT INTO pt3 (c1, c2) VALUES ($1, $2);
PREPARE select_pt3_all 
	AS SELECT * FROM pt3;

-- SELECT
-- PG
PREPARE select_pt2_c2_c4_c6
	AS SELECT c2, c4, c6 FROM pt2;
-- TG
PREPARE select_t2_c2_c4_c6
	AS SELECT c2, c4, c6 FROM t2;
-- PG
PREPARE select_pt2_c6
	AS SELECT c6 FROM pt2;
-- TG
PREPARE select_t2_c6
	AS SELECT c6 FROM t2;
-- PG
PREPARE select_pt2_c1_c2_seisu
	AS SELECT c1, c2 AS seisu FROM pt2;
-- TG
PREPARE select_t2_c1_c2_seisu
	AS SELECT c1, c2 AS seisu FROM t2;

-- ORDER BY #1
-- PG
PREPARE select_pt2_orderby1
	AS SELECT * FROM pt2 ORDER BY c6;
-- TG
PREPARE select_t2_orderby1
	AS SELECT * FROM t2 ORDER BY c6;
-- ORDER BY #2
-- PG
PREPARE select_pt2_orderby2
	AS SELECT c1, c2, c3, c4, c5, c6, c7 FROM pt2 ORDER BY 6;
-- TG
/* failed (10) because of ORDER BY 6 */
PREPARE select_t2_orderby2
	AS SELECT c1, c2, c3, c4, c5, c6, c7 FROM t2 ORDER BY 6;
-- ORDER BY #3
-- PG
PREPARE select_pt2_orderby3
	AS SELECT c1, c4, c5, c6, c7 FROM pt2 WHERE c1 > 2 ORDER BY c7;
-- TG
PREPARE select_t2_orderby3
	AS SELECT c1, c4, c5, c6, c7 FROM t2 WHERE c1 > 2 ORDER BY c7;
-- ORDER BY #4
-- PG
PREPARE select_pt2_orderby4
	AS SELECT c1, c2 FROM pt2 WHERE c2 * 2 > 50 ORDER BY c3 DESC;
-- TG
PREPARE select_t2_orderby4
	AS SELECT c1, c2 FROM t2 WHERE c2 * 2 > 50 ORDER BY c3 DESC;

-- WHERE #1
-- PG
PREPARE select_pt2_where1
	AS SELECT * FROM pt2 WHERE c3 > 2 ORDER BY c1;
-- TG
PREPARE select_t2_where1
	AS SELECT * FROM t2 WHERE c3 > 2 ORDER BY c1;
-- WHERE #2
-- PG
PREPARE select_pt2_where2
	AS SELECT * FROM pt2 WHERE c7 = 'XYZ' ORDER BY c1;
-- TG
PREPARE select_t2_where2
	AS SELECT * FROM t2 WHERE c7 = 'XYZ' ORDER BY c1;
-- WHERE #3
-- PG
PREPARE select_pt1_where3
	AS SELECT c1, c2, c6, c7 FROM pt1 WHERE c1 = 1 OR c1 = 3;
-- TG
PREPARE select_t1_where3
	AS SELECT c1, c2, c6, c7 FROM t1 WHERE c1 = 1 OR c1 = 3;
-- WHERE #4
-- PG
PREPARE select_pt1_where4
	AS SELECT c1, c3, c5, c7 FROM pt1 WHERE c1 = 2;
-- TG
PREPARE select_t1_where4
	AS SELECT c1, c3, c5, c7 FROM t1 WHERE c1 = 2;
-- WHERE #5
-- PG
PREPARE select_pt1_where5
	AS SELECT * FROM pt1 WHERE c4 >= 2.2 AND c4 < 5.5;
-- TG
PREPARE select_t1_where5
	AS SELECT * FROM t1 WHERE c4 >= 2.2 AND c4 < 5.5;
-- WHERE #6
-- PG
PREPARE select_pt2_where6
	AS SELECT * FROM pt2 WHERE c4 BETWEEN 2.2 AND 5.5;
-- TG
/* tsurugi-issue#69 */
PREPARE select_t2_where6
	AS SELECT * FROM t2 WHERE c4 BETWEEN 2.2 AND 5.5;
-- WHERE #7
-- PG
PREPARE select_pt1_where7
	AS SELECT * FROM pt1 WHERE c7 LIKE '%LMN%';
-- TG
/* tsurugi-issue#103 */
PREPARE select_t1_where7
	AS SELECT * FROM t1 WHERE c7 LIKE '%LMN%';
-- WHERE #8
-- PG
PREPARE select_pt1_where8
	AS SELECT * FROM pt1 WHERE EXISTS (SELECT * FROM pt2 WHERE c2 = 22);
-- TG
/* not support EXISTS failed. (10) */
PREPARE select_t1_where8
	AS SELECT * FROM t1 WHERE EXISTS (SELECT * FROM t2 WHERE c2 = 22);
-- WHERE #9
-- PG
PREPARE select_pt2_where9
	AS SELECT * FROM pt2 WHERE c4 IN (1.1,3.3);
-- TG
/* tsurugi-issue#70 */
PREPARE select_t2_where9
	AS SELECT * FROM t2 WHERE c4 IN (1.1,3.3);

-- GROUP BY #1
-- PG
PREPARE select_pt2_group1
	AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM pt2 GROUP BY c7;
-- TG
/* aggregate functions alias not support failed. (10) */
PREPARE select_t2_group1_ng
	AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM t2 GROUP BY c7;
PREPARE select_t2_group1
	AS SELECT count(c1), sum(c2), c7 FROM t2 GROUP BY c7;
-- GROUP BY #2
-- PG
PREPARE select_pt2_group2
	AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM pt2 GROUP BY c7 HAVING sum(c2) > 55;
-- TG
/* aggregate functions alias not support failed. (10) */
PREPARE select_t2_group2_ng1
	AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM t2 GROUP BY c7 HAVING sum(c2) > 55;
/* having not support failed. (10) */
PREPARE select_t2_group2_ng2
	AS SELECT count(c1), sum(c2), c7 FROM t2 GROUP BY c7 HAVING sum(c2) > 55;
-- GROUP BY #3
-- PG
PREPARE select_pt2_group3
	AS SELECT c7, count(c1), sum(c2), avg(c3), min(c4), max(c5) FROM pt2 GROUP BY c7;
-- TG
PREPARE select_t2_group3_exe_ng1
	AS SELECT c7, count(c1), sum(c2), avg(c3), min(c4), max(c5) FROM t2 GROUP BY c7;

-- FOREIGN TABLE JOIN
-- TG JOIN #1
PREPARE select_join1
	AS SELECT * FROM t1 a INNER JOIN t2 b ON a.c1 = b.c1 WHERE b.c1 > 1;
-- TG JOIN #2
/* failed (10) : mismatched input 'USING' */
PREPARE select_join2
	AS SELECT a.c1, a.c2, b.c1, b.c7 FROM t1 a INNER JOIN t2 b USING (c1) ORDER BY b.c4 DESC;
-- TG JOIN #3
PREPARE select_join3
	AS SELECT a.c1, a.c3, b.c1, b.c6 FROM t1 a INNER JOIN t2 b ON a.c1 != b.c1;

-- POSTGRESQL TABLE JOIN
-- PG JOIN #1
-- PG
PREPARE select_pg_join_pg1
	AS SELECT * FROM pt1 a INNER JOIN pt2 b ON a.c4 = b.c4 WHERE a.c1 > 1;
-- TG
/* tables are mixed */
PREPARE select_pg_join_tg1
	AS SELECT * FROM t1 a INNER JOIN pt2 b ON a.c4 = b.c4 WHERE a.c1 > 1;
-- PG JOIN #2
-- PG
PREPARE select_pg_join_pg2
	AS SELECT a.c1, a.c2, b.c4, b.c6 FROM pt1 a INNER JOIN pt2 b USING (c1) ORDER BY b.c4 DESC;
-- TG
/* tables are mixed */
PREPARE select_pg_join_tg2
	AS SELECT a.c1, a.c2, b.c4, b.c6 FROM t1 a INNER JOIN pt2  b USING (c1) ORDER BY b.c4 DESC;
-- PG JOIN  #3
-- PG
PREPARE select_pg_join_pg3
	AS SELECT a.c1, a.c3, b.c5, b.c7 FROM pt2 a LEFT OUTER JOIN pt1 b ON a.c1 = b.c1;
-- TG
/* tables are mixed */
PREPARE select_pg_join_tg3
	AS SELECT a.c1, a.c3, b.c5, b.c7 FROM t2 a LEFT OUTER JOIN pt1 b ON a.c1 = b.c1;
-- PG JOIN #4
-- PG
PREPARE select_pg_join_pg4
	AS SELECT * FROM pt1 a INNER JOIN pt2 b ON a.c4 = b.c4 WHERE a.c1 > 1 AND a.c1 < 3;
-- TG
/* tables are mixed */
PREPARE select_pg_join_tg4
	AS SELECT * FROM pt1 a INNER JOIN t2 b ON a.c4 = b.c4 WHERE a.c1 > 1 AND a.c1 < 3;
-- PG JOIN #5
-- PG
PREPARE select_pg_join_pg5
	AS SELECT count(a.c1), sum(b.c2), b.c7 FROM pt1 a INNER JOIN pt2 b USING (c2) GROUP BY b.c7;
-- TG
/* tables are mixed */
PREPARE select_pg_join_tg5
	AS SELECT count(a.c1), sum(b.c2), b.c7 FROM pt1 a INNER JOIN t2 b USING (c2) GROUP BY b.c7;
-- PG JOIN #6
-- PG
PREPARE select_pg_join_pg6
	AS SELECT * FROM pt1 AS a JOIN pt2 AS b ON a.c4=b.c4 JOIN pt1 AS c ON b.c4=c.c4 WHERE a.c2=22;
-- TG
PREPARE select_pg_join_tg6
	AS SELECT * FROM t1 AS a JOIN t2 AS b ON a.c4=b.c4 JOIN t1 AS c ON b.c4=c.c4 WHERE a.c2=22;
-- PG&TG
/* tables are mixed */
PREPARE select_pg_join_pgtg6
	AS SELECT * FROM t1 AS a JOIN pt2 AS b ON a.c4=b.c4 JOIN t1 AS c ON b.c4=c.c4 WHERE a.c2=22;
-- PG JOIN #7
-- PG
PREPARE select_pg_join_pg7
	AS SELECT * FROM pt1 AS a CROSS JOIN pt2 AS b ORDER BY b.c1;
-- TG
PREPARE select_pg_join_tg7
	AS SELECT * FROM t1 AS a CROSS JOIN t2 AS b ORDER BY b.c1;
-- PG&TG
/* tables are mixed */
PREPARE select_pg_join_pgtg7
	AS SELECT * FROM pt1 AS a CROSS JOIN t2 AS b ORDER BY b.c1;
-- PG JOIN #8
-- PG
PREPARE select_pg_join_pg8
	AS SELECT * FROM pt1 AS a JOIN pt1 AS b ON a.c3=b.c3;
-- TG
PREPARE select_pg_join_tg8
	AS SELECT * FROM t1 AS a JOIN t1 AS b ON a.c3=b.c3;


/***************/
/*** EXECUTE ***/
/***************/
-- TG tables
EXECUTE insert_t1 (1, 11, 111, 1.1, 1.11, 'first', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
EXECUTE insert_t1 (2, 22, 222, 2.2, 2.22, 'second', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
EXECUTE insert_t1 (3, 33, 333, 3.3, 3.33, 'third', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
EXECUTE select_t1_all;

EXECUTE insert_t2 (1, 11, 111, 1.1, 1.11, 'one', 'ABC');
EXECUTE insert_t2 (2, 22, 222, 2.2, 2.22, 'two', 'XYZ');
EXECUTE insert_t2 (3, 33, 333, 3.3, 3.33, 'three', 'ABC');
EXECUTE insert_t2 (4, NULL, NULL, NULL, NULL, 'NULL', NULL);
EXECUTE insert_t2 (5, 55, 555, 5.5, 5.55, 'five', 'XYZ');
EXECUTE select_t2_all;

EXECUTE insert_t3 (1, 'ichi');
EXECUTE insert_t3 (2, 'ni');
EXECUTE insert_t3 (3, 'san');
EXECUTE insert_t3 (4, 'si');
EXECUTE insert_t3 (5, 'go');
EXECUTE select_t3_all;

-- PG tables
EXECUTE insert_pt1 (1, 11, 111, 1.1, 1.11, 'first', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
EXECUTE insert_pt1 (2, 22, 222, 2.2, 2.22, 'second', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
EXECUTE insert_pt1 (3, 33, 333, 3.3, 3.33, 'third', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
EXECUTE select_pt1_all;

EXECUTE insert_pt2 (1, 11, 111, 1.1, 1.11, 'one', 'ABC');
EXECUTE insert_pt2 (2, 22, 222, 2.2, 2.22, 'two', 'XYZ');
EXECUTE insert_pt2 (3, 33, 333, 3.3, 3.33, 'three', 'ABC');
EXECUTE insert_pt2 (4, NULL, NULL, NULL, NULL, 'NULL', NULL);
EXECUTE insert_pt2 (5, 55, 555, 5.5, 5.55, 'five', 'XYZ');
EXECUTE select_pt2_all;

EXECUTE insert_pt3 (1, 'ichi');
EXECUTE insert_pt3 (2, 'ni');
EXECUTE insert_pt3 (3, 'san');
EXECUTE insert_pt3 (4, 'si');
EXECUTE insert_pt3 (5, 'go');
EXECUTE select_pt3_all;

-- SELECT
-- PG
EXECUTE select_pt1_all;
-- TG
EXECUTE select_t1_all;
-- PG
EXECUTE select_pt2_c2_c4_c6;
-- TG
EXECUTE select_t2_c2_c4_c6;
-- PG
EXECUTE select_pt2_c6;
-- TG
EXECUTE select_t2_c6;
-- PG
EXECUTE select_pt2_c1_c2_seisu;
-- TG
EXECUTE select_t2_c1_c2_seisu;

-- ORDER BY #1
-- PG
EXECUTE select_pt2_orderby1;
-- TG
EXECUTE select_t2_orderby1;
-- ORDER BY #2
-- PG
EXECUTE select_pt2_orderby2;
-- TG
/* failed (10) because of ORDER BY 6
EXECUTE select_t2_orderby2;
*/
-- ORDER BY #3
-- PG
EXECUTE select_pt2_orderby3;
-- TG
EXECUTE select_t2_orderby3;
-- ORDER BY #4
-- PG
EXECUTE select_pt2_orderby4;
-- TG
EXECUTE select_t2_orderby4;

-- WHERE #1
-- WHERE #1
-- PG
EXECUTE select_pt2_where1;
-- TG
EXECUTE select_t2_where1;
-- WHERE #2
-- PG
EXECUTE select_pt2_where2;
-- TG
EXECUTE select_t2_where2;
-- WHERE #3
-- PG
EXECUTE select_pt1_where3;
-- TG
EXECUTE select_t1_where3;
-- WHERE #4
-- PG
EXECUTE select_pt1_where4;
-- TG
EXECUTE select_t1_where4;
-- WHERE #5
-- PG
EXECUTE select_pt1_where5;
-- TG
EXECUTE select_t1_where5;
-- WHERE #6
-- PG
EXECUTE select_pt2_where6;
-- TG
/* tsurugi-issue#69
EXECUTE select_t2_where6;
*/
-- WHERE #7
-- PG
EXECUTE select_pt1_where7;
-- TG
/* tsurugi-issue#103 */
EXECUTE select_t1_where7;
-- WHERE #8
-- PG
EXECUTE select_pt1_where8;
-- TG
/* not support EXISTS failed. (10)
EXECUTE select_t1_where8;
*/
-- WHERE #9
-- PG
EXECUTE select_pt2_where9;
-- TG
/* tsurugi-issue#70
EXECUTE select_t2_where9;
*/

-- GROUP BY #1
-- PG
EXECUTE select_pt2_group1;
-- TG
/* aggregate functions alias not support failed. (10)
EXECUTE select_t2_group1_ng;
*/
EXECUTE select_t2_group1;
-- GROUP BY #2
-- PG
EXECUTE select_pt2_group2;
-- TG
/* aggregate functions alias not support failed. (10)
EXECUTE select_t2_group2_ng1;
*/
/* having not support failed. (10)
EXECUTE select_t2_group2_ng2;
*/
-- GROUP BY #3
-- PG
EXECUTE select_pt2_group3;
-- TG
/* not support avg return data type 1700: NUMERICOID
EXECUTE select_t2_group3_exe_ng1;
*/

-- FOREIGN TABLE JOIN
-- TG JOIN #1
EXECUTE select_join1;
-- TG JOIN #2
/* failed (10) : mismatched input 'USING'
EXECUTE select_join2;
*/
-- TG JOIN #3
EXECUTE select_join3;

-- POSTGRESQL TABLE JOIN
-- PG JOIN #1
-- PG
EXECUTE select_pg_join_pg1;
-- TG
/* tables are mixed */
EXECUTE select_pg_join_tg1;
-- PG JOIN #2
-- PG
EXECUTE select_pg_join_pg2;
-- TG
/* tables are mixed */
EXECUTE select_pg_join_tg2;
-- PG JOIN  #3
-- PG
EXECUTE select_pg_join_pg3;
-- TG
/* tables are mixed */
EXECUTE select_pg_join_tg3;
-- PG JOIN #4
-- PG
EXECUTE select_pg_join_pg4;
-- TG
/* tables are mixed */
EXECUTE select_pg_join_tg4;
-- PG JOIN #5
-- PG
EXECUTE select_pg_join_pg5;
-- TG
/* tables are mixed */
EXECUTE select_pg_join_tg5;
-- PG JOIN #6
-- PG
EXECUTE select_pg_join_pg6;
-- TG
EXECUTE select_pg_join_tg6;
-- PG&TG
/* tables are mixed */
EXECUTE select_pg_join_pgtg6;
-- PG JOIN #7
-- PG
EXECUTE select_pg_join_pg7;
-- TG
EXECUTE select_pg_join_tg7;
-- PG&TG
/* tables are mixed */
EXECUTE select_pg_join_pgtg7;
-- PG JOIN #8
-- PG
EXECUTE select_pg_join_pg8;
-- TG
EXECUTE select_pg_join_tg8;

/***********/
/*** DDL ***/
/***********/
DROP TABLE t1;
DROP FOREIGN TABLE t1;
DROP TABLE t2;
DROP FOREIGN TABLE t2;
DROP TABLE t3;
DROP FOREIGN TABLE t3;
DROP TABLE pt1;
DROP TABLE pt2;
DROP TABLE pt3;
