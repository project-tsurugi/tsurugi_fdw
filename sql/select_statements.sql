/* DDL */
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
) SERVER ogawayama;

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
) SERVER ogawayama;

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

/* DML */
SELECT * FROM t1;
SELECT c2, c4, c6 FROM t2;

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
SELECT c1, c3, c5, c7 FROM t1 WHERE c1 = 2;

INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (1, 11, 111, 1.1, 1.11, 'one', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (2, 22, 222, 2.2, 2.22, 'two', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (3, 33, 333, 3.3, 3.33, 'three', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (4, NULL, NULL, NULL, NULL, 'NULL', NULL);
INSERT INTO 
    t2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (5, 55, 555, 5.5, 5.55, 'five', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
SELECT * FROM t2;
SELECT c6 FROM t2;

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
    (1, 11, 111, 1.1, 1.11, 'one', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    pt2 
VALUES
    (2, 22, 222, 2.2, 2.22, 'two', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    pt2 
VALUES
    (3, 33, 333, 3.3, 3.33, 'three', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
INSERT INTO 
    pt2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (4, NULL, NULL, NULL, NULL, 'NULL', NULL);
INSERT INTO 
    pt2(c1, c2, c3, c4, c5, c6, c7)
VALUES
    (5, 55, 555, 5.5, 5.55, 'five', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
SELECT * FROM pt2;

-- FOREIGN TABLE JOIN
SELECT 
    *
FROM 
    t1 a INNER JOIN t2 b ON a.c1 = b.c1
WHERE
    b.c1 > 1;

SELECT 
    a.c1, b.c2, a.c4, b.c6
FROM 
    t1 a INNER JOIN t2 b USING (c1)
ORDER BY
    b.c4 DESC;   

SELECT 
    a.c1, b.c3, a.c5, b.c7
FROM 
    t1 a INNER JOIN t2 b ON a.c1 != b.c1;

-- POSTGRESQL TABLE JOIN
-- #1
SELECT 
    *
FROM 
    pt1 a INNER JOIN pt2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1;

SELECT 
    *
FROM 
    t1 a INNER JOIN pt2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1;

-- #2
SELECT 
    a.c1, a.c2, b.c4, b.c6
FROM 
    pt1 a INNER JOIN pt2  b USING (c1)
ORDER BY
    b.c4 DESC;

SELECT 
    a.c1, a.c2, b.c4, b.c6
FROM 
    t1 a INNER JOIN pt2  b USING (c1)
ORDER BY
    b.c4 DESC;

-- #3
SELECT 
    a.c1, a.c3, b.c5, b.c7
FROM 
    pt2 a LEFT OUTER JOIN pt1 b ON a.c1 = b.c1;

SELECT 
    a.c1, a.c3, b.c5, b.c7
FROM 
    t2 a LEFT OUTER JOIN pt2 b ON a.c1 = b.c1;

-- #4
SELECT 
    *
FROM 
    pt1 a INNER JOIN pt2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1 AND a.c1 < 3;

SELECT 
    *
FROM 
    pt1 a INNER JOIN t2 b ON a.c4 = b.c4
WHERE
    a.c1 > 1 AND a.c1 < 3;

-- #5
SELECT
    count(a.c1), sum(b.c2), b.c7
FROM 
    pt1 a INNER JOIN pt2 b USING (c2)
GROUP BY
    b.c7;

SELECT
    count(a.c1), sum(b.c2), b.c7
FROM 
    pt1 a INNER JOIN t2 b USING (c2)
GROUP BY
    b.c7;

/* DDL */
DROP TABLE t1;
DROP FOREIGN TABLE t1;
DROP TABLE t2;
DROP FOREIGN TABLE t2;
DROP TABLE pt1;
DROP TABLE pt2;
