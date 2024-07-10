/* DDL */
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
    c6 CHAR(10) COLLATE "en_US.utf8",
    c7 VARCHAR(26) COLLATE "en_US.utf8"
);

CREATE TABLE pt3(
    c1 INTEGER PRIMARY KEY,
    c2 CHAR(10)
);

/* DML */
-- TG tables
INSERT INTO 
    t1(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (1, 11, 111, 1.1, 1.11, 'first', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    t1(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (2, 22, 222, 2.2, 2.22, 'second', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    t1(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (3, 33, 333, 3.3, 3.33, 'third', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
SELECT * FROM t1;

INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (1, 11, 111, 1.1, 1.11, 'one', 'ABC');
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (2, 22, 222, 2.2, 2.22, 'two', 'XYZ');
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (3, 33, 333, 3.3, 3.33, 'three', 'ABC');
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (4, NULL, NULL, NULL, NULL, 'NULL', NULL);
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (5, 55, 555, 5.5, 5.55, 'five', 'XYZ');
SELECT * FROM t2;

INSERT INTO
    t3(c1, c2)
VALUES
    (1, 'ichi');
INSERT INTO
    t3(c1, c2)
VALUES
    (2, 'ni');
INSERT INTO
    t3(c1, c2)
VALUES
    (3, 'san');
INSERT INTO
    t3(c1, c2)
VALUES
    (4, 'si');
INSERT INTO
    t3(c1, c2)
VALUES
    (5, 'go');
SELECT * FROM t3;

-- PG tables
INSERT INTO 
    pt1 
VALUES
    (1, 11, 111, 1.1, 1.11, 'first', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    pt1 
VALUES
    (2, 22, 222, 2.2, 2.22, 'second', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    pt1 
VALUES
    (3, 33, 333, 3.3, 3.33, 'third', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
SELECT * FROM pt1;

INSERT INTO 
    pt2 
VALUES
    (1, 11, 111, 1.1, 1.11, 'one', 'ABC');
INSERT INTO 
    pt2 
VALUES
    (2, 22, 222, 2.2, 2.22, 'two', 'XYZ');
INSERT INTO 
    pt2 
VALUES
    (3, 33, 333, 3.3, 3.33, 'three', 'ABC');
INSERT INTO 
    pt2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (4, NULL, NULL, NULL, NULL, 'NULL', NULL);
INSERT INTO 
    pt2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (5, 55, 555, 5.5, 5.55, 'five', 'XYZ');
SELECT * FROM pt2;

INSERT INTO
    pt3(c1, c2)
VALUES
    (1, 'ichi');
INSERT INTO
    pt3(c1, c2)
VALUES
    (2, 'ni');
INSERT INTO
    pt3(c1, c2)
VALUES
    (3, 'san');
INSERT INTO
    pt3(c1, c2)
VALUES
    (4, 'si');
INSERT INTO
    pt3(c1, c2)
VALUES
    (5, 'go');
SELECT * FROM pt3;

-- SELECT
-- PG
SELECT * FROM pt1;
-- TG
SELECT * FROM t1;

-- PG
SELECT c2, c4, c6 FROM pt2;
-- TG
SELECT c2, c4, c6 FROM t2;

-- PG
SELECT c6 FROM pt2;
-- TG
SELECT c6 FROM t2;

-- PG
SELECT c1, c2 AS seisu FROM pt2;
-- TG
SELECT c1, c2 AS seisu  FROM t2;

-- ORDER BY #1
-- PG
SELECT
    *
FROM
    pt2
ORDER BY 
    c6;

-- TG
SELECT
    *
FROM
    t2
ORDER BY 
    c6;

-- ORDER BY #2
-- PG
SELECT
    c1, c2, c3, c4, c5, c6, c7
FROM
    pt2
ORDER BY 
    6;

-- TG
SELECT
    c1, c2, c3, c4, c5, c6, c7
FROM
    t2
ORDER BY 
    6;

-- ORDER BY #3
-- PG
SELECT
    c1, c4, c5, c6, c7
FROM
    pt2
WHERE
    c1 > 2
ORDER BY
    c7;

-- TG
SELECT
    c1, c4, c5, c6, c7
FROM
    t2
WHERE
    c1 > 2
ORDER BY
    c7;

-- ORDER BY #4
-- PG
SELECT
    c1, c2
FROM
    pt2
WHERE
    c2 * 2 > 50
ORDER BY
    c3 DESC;

-- TG
SELECT
    c1, c2
FROM
    t2
WHERE
    c2 * 2 > 50
ORDER BY
    c3 DESC;

-- WHERE #1
-- PG
SELECT
    *
FROM
    pt2
WHERE
    c3 > 2
ORDER BY
    c1;

-- TG
SELECT
    *
FROM
    t2
WHERE
    c3 > 2
ORDER BY
    c1;

-- WHERE #2
-- PG
SELECT
    *
FROM
    pt2
WHERE
    c7 = 'XYZ'
ORDER BY
    c1;

-- TG
SELECT
    *
FROM
    t2
WHERE
    c7 = 'XYZ'
ORDER BY
    c1;

-- WHERE #3
-- PG
SELECT 
    c1, c2, c6, c7
FROM
    pt1
WHERE
    c1 = 1 OR c1 = 3;

-- TG
SELECT 
    c1, c2, c6, c7
FROM
    t1
WHERE
    c1 = 1 OR c1 = 3;

-- WHERE #4
-- PG
SELECT 
    c1, c3, c5, c7 
FROM 
    pt1 
WHERE 
    c1 = 2;

-- TG
SELECT 
    c1, c3, c5, c7 
FROM 
    t1 
WHERE 
    c1 = 2;

-- WHERE #5
-- PG
SELECT
    *
FROM
    pt1
WHERE
    c4 >= 2.2 AND c4 < 5.5;

-- TG
SELECT
    *
FROM
    t1
WHERE
    c4 >= 2.2 AND c4 < 5.5;

-- WHERE #6
-- PG
SELECT
    *
FROM
    pt2
WHERE
    c4 BETWEEN 2.2 AND 5.5;

-- TG
SELECT
    *
FROM
    t2
WHERE
    c4 BETWEEN 2.2 AND 5.5;

-- WHERE #7
-- PG
SELECT
    *
FROM
    pt1
WHERE
    c7 LIKE '%LMN%';

-- TG
SELECT
    *
FROM
    t1
WHERE
    c7 LIKE '%LMN%';

-- WHERE #8
-- PG
SELECT
    *
FROM
    pt1
WHERE
    EXISTS (SELECT * FROM pt2 WHERE c2 = 22);

-- TG
/*
SELECT
    *
FROM
    t1
WHERE
    EXISTS (SELECT * FROM t2 WHERE c2 = 22);
*/
-- WHERE #9
-- PG
SELECT
    *
FROM
    pt2
WHERE
    c4 IN (1.1,3.3);

-- TG
SELECT
    *
FROM
    t2
WHERE
    c4 IN (1.1,3.3);

-- GROUP BY #1
-- PG
SELECT
    count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7
FROM 
    pt2
GROUP BY
    c7;

-- TG
SELECT
    count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7
FROM 
    t2
GROUP BY
    c7;

-- GROUP BY #2
-- PG
SELECT
    count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7
FROM 
    pt2
GROUP BY
    c7
HAVING 
    sum(c2) > 55;

-- TG
SELECT
    count(c1) AS "count(c1)", sum(c2) AS "sum(c2)", c7
FROM 
    t2
GROUP BY
    c7
HAVING 
    sum(c2) > 55;

-- GROUP BY #3
-- PG
SELECT
    c7, count(c1), sum(c2), avg(c3), min(c4), max(c5)
FROM
    pt2
GROUP BY
    c7;

-- TG
SELECT
    c7, count(c1), sum(c2), avg(c3), min(c4), max(c5)
FROM
    pt2
GROUP BY
    c7;

-- FOREIGN TABLE JOIN
-- TG JOIN #1 /* tsurugi-issue#863 */
SELECT 
    *
FROM 
    t1 a INNER JOIN t2 b ON a.c1 = b.c1
WHERE
    b.c1 > 1;

-- TG JOIN #2 /* tsurugi-issue#863 */
SELECT 
    a.c1, a.c2, b.c1, b.c7
FROM 
    t1 a INNER JOIN t2 b USING (c1)
ORDER BY
    b.c4 DESC;   

-- TG JOIN #3 /* tsurugi-issue#863 */
SELECT 
    a.c1, a.c3, b.c1, b.c6
FROM 
    t1 a INNER JOIN t2 b ON a.c1 != b.c1;

-- POSTGRESQL TABLE JOIN
-- PG JOIN #1
-- PG
SELECT
    *
FROM 
    pt1 a INNER JOIN pt2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1;

-- TG
SELECT 
    *
FROM 
    t1 a INNER JOIN pt2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1;

-- PG JOIN #2
-- PG
SELECT 
    a.c1, a.c2, b.c4, b.c6
FROM 
    pt1 a INNER JOIN pt2  b USING (c1)
ORDER BY
    b.c4 DESC;

-- TG
SELECT 
    a.c1, a.c2, b.c4, b.c6
FROM 
    t1 a INNER JOIN pt2  b USING (c1)
ORDER BY
    b.c4 DESC;

-- PG JOIN  #3
-- PG
SELECT 
    a.c1, a.c3, b.c5, b.c7
FROM 
    pt2 a LEFT OUTER JOIN pt1 b ON a.c1 = b.c1;

-- TG
SELECT 
    a.c1, a.c3, b.c5, b.c7
FROM 
    t2 a LEFT OUTER JOIN pt1 b ON a.c1 = b.c1;

-- PG JOIN #4
-- PG
SELECT 
    *
FROM 
    pt1 a INNER JOIN pt2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1 AND a.c1 < 3;

-- TG
SELECT 
    *
FROM 
    pt1 a INNER JOIN t2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1 AND a.c1 < 3;

-- PG JOIN #5
-- PG
SELECT
    count(a.c1), sum(b.c2), b.c7
FROM 
    pt1 a INNER JOIN pt2 b USING (c2)
GROUP BY
    b.c7;

-- TG
SELECT
    count(a.c1), sum(b.c2), b.c7
FROM 
    pt1 a INNER JOIN t2 b USING (c2)
GROUP BY
    b.c7;

-- PG JOIN #6
-- PG
SELECT
    *
FROM
    pt1 AS a JOIN pt2 AS b ON a.c4=b.c4 JOIN pt1 AS c ON b.c4=c.c4
WHERE
    a.c2=22;

-- TG /* tsurugi-issue#863 */
SELECT
    *
FROM
    t1 AS a JOIN t2 AS b ON a.c4=b.c4 JOIN t1 AS c ON b.c4=c.c4
WHERE
    a.c2=22;

-- PG&TG /* tsurugi-issue#863 */
SELECT
    *
FROM
    t1 AS a JOIN pt2 AS b ON a.c4=b.c4 JOIN t1 AS c ON b.c4=c.c4
WHERE
    a.c2=22;

-- PG JOIN #7
-- PG
SELECT
    *
FROM
    pt1 AS a CROSS JOIN pt2 AS b
ORDER BY
    b.c1;

-- TG /* tsurugi-issue#863 */
SELECT
    *
FROM
    t1 AS a CROSS JOIN t2 AS b
ORDER BY
    b.c1;

-- PG&TG
SELECT
    *
FROM
    pt1 AS a CROSS JOIN t2 AS b
ORDER BY
    b.c1;

-- PG JOIN #7
-- PG
SELECT
    *
FROM
    pt1 AS a JOIN pt1 AS b ON a.c3=b.c3;

-- TG /* tsurugi-issue#863 */
SELECT
    *
FROM
    t1 AS a JOIN t1 AS b ON a.c3=b.c3;

/* DDL */
DROP TABLE t1;
DROP FOREIGN TABLE t1;
DROP TABLE t2;
DROP FOREIGN TABLE t2;
DROP TABLE t3;
DROP FOREIGN TABLE t3;
DROP TABLE pt1;
DROP TABLE pt2;
DROP TABLE pt3;
