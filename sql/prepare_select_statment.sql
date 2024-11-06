/***********/
/*** DDL ***/
/***********/
CREATE FOREIGN TABLE t1_prepare_select_statement(
    c1 INTEGER, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE FOREIGN TABLE t2_prepare_select_statement(
    c1 INTEGER, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE FOREIGN TABLE t3_prepare_select_statement(
    c1 INTEGER,
    c2 CHAR(10)
) SERVER tsurugidb;

/***************/
/*** PREPARE ***/
/***************/
PREPARE insert_t1 (INTEGER, INTEGER, BIGINT, REAL, DOUBLE PRECISION, CHAR(10), VARCHAR(26)) 
    AS INSERT INTO t1_prepare_select_statement (c1, c2, c3, c4, c5, c6, c7) VALUES ($1, $2, $3, $4, $5, $6, $7);
PREPARE select_t1_all 
	AS SELECT * FROM t1_prepare_select_statement;
PREPARE insert_t2 (INTEGER, INTEGER, BIGINT, REAL, DOUBLE PRECISION, CHAR(10), VARCHAR(26)) 
    AS INSERT INTO t2_prepare_select_statement (c1, c2, c3, c4, c5, c6, c7) VALUES ($1, $2, $3, $4, $5, $6, $7);
PREPARE select_t2_all 
	AS SELECT * FROM t2_prepare_select_statement;
PREPARE insert_t3 (INTEGER, CHAR(10)) 
    AS INSERT INTO t3_prepare_select_statement (c1, c2) VALUES ($1, $2);
PREPARE select_t3_all 
	AS SELECT * FROM t3_prepare_select_statement;

-- SELECT
PREPARE select_t2_c2_c4_c6
	AS SELECT c2, c4, c6 FROM t2_prepare_select_statement;
PREPARE select_t2_c6
	AS SELECT c6 FROM t2_prepare_select_statement;
PREPARE select_t2_c1_c2_seisu
	AS SELECT c1, c2 AS seisu FROM t2_prepare_select_statement;
-- ORDER BY #1
PREPARE select_t2_orderby1
	AS SELECT * FROM t2_prepare_select_statement ORDER BY c6;
-- ORDER BY #2
/* failed (10) because of ORDER BY 6 */
PREPARE select_t2_orderby2
	AS SELECT c1, c2, c3, c4, c5, c6, c7 FROM t2_prepare_select_statement ORDER BY 6;
-- ORDER BY #3
PREPARE select_t2_orderby3
	AS SELECT c1, c4, c5, c6, c7 FROM t2_prepare_select_statement WHERE c1 > 2 ORDER BY c7;
-- ORDER BY #4
PREPARE select_t2_orderby4
	AS SELECT c1, c2 FROM t2_prepare_select_statement WHERE c2 * 2 > 50 ORDER BY c3 DESC;
-- WHERE #1
PREPARE select_t2_where1
	AS SELECT * FROM t2_prepare_select_statement WHERE c3 > 2 ORDER BY c1;
-- WHERE #2
PREPARE select_t2_where2
	AS SELECT * FROM t2_prepare_select_statement WHERE c7 = 'XYZ' ORDER BY c1;
-- WHERE #3
PREPARE select_t1_where3
	AS SELECT c1, c2, c6, c7 FROM t1_prepare_select_statement WHERE c1 = 1 OR c1 = 3;
-- WHERE #4
PREPARE select_t1_where4
	AS SELECT c1, c3, c5, c7 FROM t1_prepare_select_statement WHERE c1 = 2;
-- WHERE #5
PREPARE select_t1_where5
	AS SELECT * FROM t1_prepare_select_statement WHERE c4 >= 2.2 AND c4 < 5.5;
-- WHERE #6
/* tsurugi-issue#69 */
PREPARE select_t2_where6
	AS SELECT * FROM t2_prepare_select_statement WHERE c4 BETWEEN 2.2 AND 5.5;
-- WHERE #7
/* tsurugi-issue#103 (no longer supports) */
PREPARE select_t1_where7
	AS SELECT * FROM t1_prepare_select_statement WHERE c7 LIKE '%LMN%';
-- WHERE #8
/* not support EXISTS failed. (10) */
PREPARE select_t1_where8
	AS SELECT * FROM t1_prepare_select_statement WHERE EXISTS (SELECT * FROM t2_prepare_select_statement WHERE c2 = 22);
-- WHERE #9
/* tsurugi-issue#70 */
PREPARE select_t2_where9
	AS SELECT * FROM t2_prepare_select_statement WHERE c4 IN (1.1,3.3);
-- GROUP BY #1
/* aggregate functions alias not support failed. (10) */
PREPARE select_t2_group1_ng
	AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM t2_prepare_select_statement GROUP BY c7;
PREPARE select_t2_group1
	AS SELECT count(c1), sum(c2), c7 FROM t2_prepare_select_statement GROUP BY c7;
-- GROUP BY #2
/* aggregate functions alias not support failed. (10) */
PREPARE select_t2_group2_ng1
	AS SELECT count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7 FROM t2_prepare_select_statement GROUP BY c7 HAVING sum(c2) > 55;
/* having support. (tsurugi-issue#739) */
PREPARE select_t2_group2
	AS SELECT count(c1), sum(c2), c7 FROM t2_prepare_select_statement GROUP BY c7 HAVING sum(c2) > 55;
-- GROUP BY #3
/* tsurugi-issue#974 : Restrictions of the AGV aggregation function */
PREPARE select_t2_group3_exe_ng1
	AS SELECT c7, count(c1), sum(c2), avg(c3), min(c4), max(c5) FROM t2_prepare_select_statement GROUP BY c7;
-- FOREIGN TABLE JOIN
-- TG JOIN #1
PREPARE select_join1
	AS SELECT * FROM t1_prepare_select_statement a INNER JOIN t2_prepare_select_statement b ON a.c1 = b.c1 WHERE b.c1 > 1;
-- TG JOIN #2
/* failed (10) : mismatched input 'USING' */
PREPARE select_join2
	AS SELECT a.c1, a.c2, b.c1, b.c7 FROM t1_prepare_select_statement a INNER JOIN t2_prepare_select_statement b USING (c1) ORDER BY b.c4 DESC;
-- TG JOIN #3
PREPARE select_join3
	AS SELECT a.c1, a.c3, b.c1, b.c6 FROM t1_prepare_select_statement a INNER JOIN t2_prepare_select_statement b ON a.c1 != b.c1;

PREPARE select_pg_join_tg6
	AS SELECT * FROM t1_prepare_select_statement AS a JOIN t2_prepare_select_statement AS b ON a.c4=b.c4 JOIN t1_prepare_select_statement AS c ON b.c4=c.c4 WHERE a.c2=22;

PREPARE select_pg_join_tg7
	AS SELECT * FROM t1_prepare_select_statement AS a CROSS JOIN t2_prepare_select_statement AS b ORDER BY b.c1;

PREPARE select_pg_join_tg8
	AS SELECT * FROM t1_prepare_select_statement AS a JOIN t1_prepare_select_statement AS b ON a.c3=b.c3;
/***************/
/*** EXECUTE ***/
/***************/
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

-- SELECT
EXECUTE select_t1_all;
EXECUTE select_t2_c2_c4_c6;
EXECUTE select_t2_c6;
EXECUTE select_t2_c1_c2_seisu;

-- ORDER BY #1
EXECUTE select_t2_orderby1;
-- ORDER BY #2
/* failed (10) because of ORDER BY 6
EXECUTE select_t2_orderby2;
*/
-- ORDER BY #3
EXECUTE select_t2_orderby3;
-- ORDER BY #4
EXECUTE select_t2_orderby4;

-- WHERE #1
EXECUTE select_t2_where1;
-- WHERE #2
EXECUTE select_t2_where2;
-- WHERE #3
EXECUTE select_t1_where3;
-- WHERE #4
EXECUTE select_t1_where4;
-- WHERE #5
EXECUTE select_t1_where5;
-- WHERE #6
/* tsurugi-issue#69 */
EXECUTE select_t2_where6;
-- WHERE #7
/* tsurugi-issue#103 (no longer supports) */
EXECUTE select_t1_where7;
-- WHERE #8
/* not support EXISTS failed. (10)
EXECUTE select_t1_where8;
*/
-- WHERE #9
/* tsurugi-issue#70
EXECUTE select_t2_where9;
*/

-- GROUP BY #1
/* aggregate functions alias not support failed. (10)
EXECUTE select_t2_group1_ng;
*/
EXECUTE select_t2_group1;
-- GROUP BY #2
/* aggregate functions alias not support failed. (10)
EXECUTE select_t2_group2_ng1;
*/
/* having support. (tsurugi-issue#739) */
EXECUTE select_t2_group2;
-- GROUP BY #3
/* tsurugi-issue#974 : Restrictions of the AGV aggregation function
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

-- PG JOIN #6
EXECUTE select_pg_join_tg6;
-- PG JOIN #7
EXECUTE select_pg_join_tg7;
-- PG JOIN #8
EXECUTE select_pg_join_tg8;

/***********/
/*** DDL ***/
/***********/
DROP FOREIGN TABLE t1_prepare_select_statement;
DROP FOREIGN TABLE t2_prepare_select_statement;
DROP FOREIGN TABLE t3_prepare_select_statement;
