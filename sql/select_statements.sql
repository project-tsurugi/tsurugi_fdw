/* DML */
-- TG tables
INSERT INTO 
    t1_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (1, 11, 111, 1.1, 1.11, 'first', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    t1_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (2, 22, 222, 2.2, 2.22, 'second', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    t1_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (3, 33, 333, 3.3, 3.33, 'third', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
SELECT * FROM t1_select_statement ORDER BY c1;

INSERT INTO 
    t2_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (1, 11, 111, 1.1, 1.11, 'one', 'ABC');
INSERT INTO 
    t2_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (2, 22, 222, 2.2, 2.22, 'two', 'XYZ');
INSERT INTO 
    t2_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (3, 33, 333, 3.3, 3.33, 'three', 'ABC');
INSERT INTO 
    t2_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (4, NULL, NULL, NULL, NULL, 'NULL', NULL);
INSERT INTO 
    t2_select_statement(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (5, 55, 555, 5.5, 5.55, 'five', 'XYZ');
SELECT * FROM t2_select_statement ORDER BY c1;

INSERT INTO
    t3_select_statement(c1, c2)
VALUES
    (1, 'ichi');
INSERT INTO
    t3_select_statement(c1, c2)
VALUES
    (2, 'ni');
INSERT INTO
    t3_select_statement(c1, c2)
VALUES
    (3, 'san');
INSERT INTO
    t3_select_statement(c1, c2)
VALUES
    (4, 'si');
INSERT INTO
    t3_select_statement(c1, c2)
VALUES
    (5, 'go');
SELECT * FROM t3_select_statement ORDER BY c1;


-- SELECT
SELECT * FROM t1_select_statement ORDER BY c1;
SELECT c2, c4, c6 FROM t2_select_statement ORDER BY c2;
SELECT c6 FROM t2_select_statement ORDER BY c6;
SELECT c1, c2 AS seisu  FROM t2_select_statement ORDER BY c1;

-- ORDER BY #1
SELECT
    *
FROM
    t2_select_statement
ORDER BY 
    c6;

-- ORDER BY #2
SELECT
    c1, c2, c3, c4, c5, c6, c7
FROM
    t2_select_statement
ORDER BY 
    6;

-- ORDER BY #3
SELECT
    c1, c4, c5, c6, c7
FROM
    t2_select_statement
WHERE
    c1 > 2
ORDER BY
    c7;

-- ORDER BY #4
SELECT
    c1, c2
FROM
    t2_select_statement
WHERE
    c2 * 2 > 50
ORDER BY
    c3 DESC;

-- WHERE #1
SELECT
    *
FROM
    t2_select_statement
WHERE
    c3 > 2
ORDER BY
    c1;

-- WHERE #2
SELECT
    *
FROM
    t2_select_statement
WHERE
    c7 = 'XYZ'
ORDER BY
    c1;

-- WHERE #3
SELECT 
    c1, c2, c6, c7
FROM
    t1_select_statement
WHERE
    c1 = 1 OR c1 = 3
ORDER BY 
    c1;

-- WHERE #4
SELECT 
    c1, c3, c5, c7 
FROM 
    t1_select_statement 
WHERE 
    c1 = 2
ORDER BY 
    c1;

-- WHERE #5
SELECT
    *
FROM
    t1_select_statement
WHERE
    c4 >= 2.2 AND c4 < 5.5
ORDER BY 
    c1;

-- WHERE #6
SELECT
    *
FROM
    t2_select_statement
WHERE
    c4 BETWEEN 2.2 AND 5.5
ORDER BY 
    c1;

-- WHERE #7
SELECT
    *
FROM
    t1_select_statement
WHERE
    c7 LIKE '%LMN%'
ORDER BY 
    c1;

-- WHERE #8
/*
SELECT
    *
FROM
    t1_select_statement
WHERE
    EXISTS (SELECT * FROM t2_select_statement WHERE c2 = 22);
*/
-- WHERE #9
SELECT
    *
FROM
    t2_select_statement
WHERE
    c4 IN (1.1,3.3)
ORDER BY
    c4;

-- GROUP BY #1
SELECT
    count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7
FROM 
    t2_select_statement
GROUP BY
    c7
ORDER BY
    c7;

-- GROUP BY #2
SELECT
    count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7
FROM 
    t2_select_statement
GROUP BY
    c7
HAVING 
    sum(c2) > 55
ORDER BY
    c7;

-- GROUP BY #3
/* tsurugi-issue#974 : Restrictions of the AGV aggregation function
SELECT
    c7, count(c1), sum(c2), avg(c3), min(c4), max(c5)
FROM
    t2_select_statement
GROUP BY
    c7;
*/
-- FOREIGN TABLE JOIN
-- TG JOIN #1 /* tsurugi-issue#863 */
SELECT 
    *
FROM 
    t1_select_statement a INNER JOIN t2_select_statement b ON a.c1 = b.c1
WHERE
    b.c1 > 1
ORDER BY
    a.c1;

-- TG JOIN #2 /* tsurugi-issue#863 */
SELECT 
    a.c1, a.c2, b.c1, b.c7
FROM 
    t1_select_statement a INNER JOIN t2_select_statement b USING (c1)
ORDER BY
    b.c4 DESC;   

-- TG JOIN #3 /* tsurugi-issue#863 */
SELECT 
    a.c1, a.c3, b.c1, b.c6
FROM 
    t1_select_statement a INNER JOIN t2_select_statement b ON a.c1 != b.c1
ORDER BY
    a.c1;

-- POSTGRESQL TABLE JOIN
-- TG /* tsurugi-issue#863 */
SELECT
    *
FROM
    t1_select_statement AS a JOIN t2_select_statement AS b ON a.c4=b.c4 JOIN t1_select_statement AS c ON b.c4=c.c4
WHERE
    a.c2=22;

-- TG /* tsurugi-issue#863 */
SELECT
    *
FROM
    t1_select_statement AS a CROSS JOIN t2_select_statement AS b
ORDER BY
    b.c1;

-- TG /* tsurugi-issue#863 */
SELECT
    *
FROM
    t1_select_statement AS a JOIN t1_select_statement AS b ON a.c3=b.c3
ORDER BY
    a.c3;
