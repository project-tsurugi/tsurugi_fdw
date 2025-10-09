/* Test setup: PostgreSQL environment */
SET datestyle TO ISO, YMD;
SET timezone TO 'Asia/Tokyo';

/* Test case: happy path - Standard DML statement variations */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_dml_basic_table_1 (
    c1 INTEGER NOT NULL PRIMARY KEY
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_dml_basic_table_2 (
    c1 INTEGER NOT NULL PRIMARY KEY,
    c2 BIGINT DEFAULT 9999,
    c3 DOUBLE PRECISION,
    c4 VARCHAR(100),
    c5 DATE
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_dml_basic_table_1 (
  c1 integer NOT NULL
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_dml_basic_table_2 (
  c1 integer NOT NULL,
  c2 bigint DEFAULT 9999,
  c3 double precision,
  c4 varchar(100),
  c5 date
) SERVER tsurugidb;

-- Test
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;

-- INSERT statement variation (single column)
INSERT INTO fdw_dml_basic_table_1 (c1) VALUES (1);
INSERT INTO fdw_dml_basic_table_1 (c1) VALUES (100);
INSERT INTO fdw_dml_basic_table_1 (c1) VALUES (10);
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;

-- SELECT statement variation (single column)
--- WHERE variation
---- Equality pattern
SELECT * FROM fdw_dml_basic_table_1 WHERE c1 = 10 ORDER BY c1;
---- Inequality pattern
SELECT c1 FROM fdw_dml_basic_table_1 WHERE c1 <> 10 ORDER BY c1;
---- Greater than pattern
SELECT * FROM fdw_dml_basic_table_1 WHERE c1 > 10 ORDER BY c1;
---- Greater than or equal pattern
SELECT c1 FROM fdw_dml_basic_table_1 WHERE c1 >= 10 ORDER BY c1;
---- Less than pattern
SELECT * FROM fdw_dml_basic_table_1 WHERE c1 < 10 ORDER BY c1;
---- Less than or equal pattern
SELECT c1 FROM fdw_dml_basic_table_1 WHERE c1 <= 0 ORDER BY c1;

--- ORDER variation
---- Default order pattern
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
---- Ascending order pattern
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1 ASC;
---- Descending order pattern
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1 DESC;

-- UPDATE statement variation (single column)
--- Single condition and direct value
UPDATE fdw_dml_basic_table_1 SET c1 = 1000 WHERE c1 = 1;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
UPDATE fdw_dml_basic_table_1 SET c1 = 0 WHERE c1 = 9999;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
--- Single condition and expression values
UPDATE fdw_dml_basic_table_1 SET c1 = c1 * 2 WHERE c1 = 100;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
--- Multiple conditions and expression values
UPDATE fdw_dml_basic_table_1 SET c1 = c1 + 10 WHERE c1 = 10 OR c1 = 200;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
UPDATE fdw_dml_basic_table_1 SET c1 = c1 + 10 WHERE c1 = 9999 OR c1 = -1;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
--- Update without condition
UPDATE fdw_dml_basic_table_1 SET c1 = c1 + 1;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;

-- DELETE statement variation (single column)
INSERT INTO fdw_dml_basic_table_1 VALUES (1);
INSERT INTO fdw_dml_basic_table_1 VALUES (2);
INSERT INTO fdw_dml_basic_table_1 VALUES (3);
INSERT INTO fdw_dml_basic_table_1 VALUES (4);
INSERT INTO fdw_dml_basic_table_1 VALUES (5);
--- Single condition
DELETE FROM fdw_dml_basic_table_1 WHERE c1 = 211;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
DELETE FROM fdw_dml_basic_table_1 WHERE c1 = -1;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
--- Multiple conditions
DELETE FROM fdw_dml_basic_table_1 WHERE c1 >= 21 OR c1 = 3;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
DELETE FROM fdw_dml_basic_table_1 WHERE c1 >= 21 OR c1 = 3;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
--- Delete in inequality conditions.
DELETE FROM fdw_dml_basic_table_1 WHERE c1 <> 2 AND c1 <> 4;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
DELETE FROM fdw_dml_basic_table_1 WHERE c1 <> 2 AND c1 <> 4;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
--- Delete without condition
DELETE FROM fdw_dml_basic_table_1;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;
DELETE FROM fdw_dml_basic_table_1;
SELECT * FROM fdw_dml_basic_table_1 ORDER BY c1;

-- INSERT statement variation (multiple columns)
--- Full column insert with column names
INSERT INTO fdw_dml_basic_table_2 (c1, c2, c3, c4, c5)
  VALUES (1, 100, 1.1, '1st', '2025-01-01');
--- Full column insert without column names
INSERT INTO fdw_dml_basic_table_2
  VALUES (3, 300, 3.3, NULL, '2025-03-03');
--- Partial column insert with 4 columns
INSERT INTO fdw_dml_basic_table_2 (c1, c2, c3, c4)
  VALUES (2, 200, 2.2, '2nd');
--- Partial column insert with 1 column
INSERT INTO fdw_dml_basic_table_2 (c1)
  VALUES (5);
--- Partial column insert with 3 columns
INSERT INTO fdw_dml_basic_table_2 (c1, c2, c4)
  VALUES (6, 600, '6th');
--- Partial column insert with 2 columns
INSERT INTO fdw_dml_basic_table_2 (c1, c3)
  VALUES (7, 7.7);
--- Columns are in different order
INSERT INTO fdw_dml_basic_table_2 (c3, c1, c2, c5, c4)
  VALUES (4.4, 4, 400, '2025-04-04', '4th');
--- Batch insert
INSERT INTO fdw_dml_basic_table_2
  VALUES
    (8, 800, 8.8, '8th', '2025-08-08'),
    (9, 900, 9.9, '9th', '2025-08-08');
SELECT c1, c2, c3, c4, c5 FROM fdw_dml_basic_table_2 ORDER BY c1;

-- SELECT statement variation (multiple columns)
--- Columns variation
---- Single column (integer) selection
SELECT c1 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Single column (bigint) selection
SELECT c2 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Single column (double precision) selection
SELECT c3 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Single column (varchar) selection
SELECT c4 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Single column (date) selection
SELECT c5 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Multiple columns (integer/bigint) selection
SELECT c1, c2 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Multiple columns (integer/double precision) selection
SELECT c1, c3 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Multiple columns (double precision/varchar/bigint) selection
SELECT c2, c3, c1 FROM fdw_dml_basic_table_2 ORDER BY c1;
---- Column name alias
SELECT c1 AS id, c2 AS value FROM fdw_dml_basic_table_2 ORDER BY c2, c1 DESC;

--- WHERE variation
SELECT c1 FROM fdw_dml_basic_table_2
  WHERE (c1 < 5) AND (c3 > 2.2) ORDER BY c1;
SELECT c1 FROM fdw_dml_basic_table_2 WHERE (c2 <> 600) AND (c3 IS NULL) ORDER BY c2;
SELECT * FROM fdw_dml_basic_table_2 WHERE c4 IS NOT NULL AND c5 IS NOT NULL ORDER BY c3;
SELECT c1, c4 FROM fdw_dml_basic_table_2 WHERE c4 <= '4th' ORDER BY c4;
SELECT * FROM fdw_dml_basic_table_2 WHERE c4 >= '8th' ORDER BY c5, c2;
SELECT c1, c5 FROM fdw_dml_basic_table_2 WHERE c5 <= date '2025-03-03' ORDER BY c1;

SELECT c1, c2 FROM fdw_dml_basic_table_2
  WHERE (c2 * 2) BETWEEN 500 AND 1000
  ORDER BY c2;
SELECT c1, c4 FROM fdw_dml_basic_table_2
  WHERE c4 IS NOT NULL
  ORDER BY c4 DESC;
SELECT c1, c5 FROM fdw_dml_basic_table_2
  WHERE c5 IS NOT NULL
  ORDER BY c5 DESC, c1;
SELECT c1, c2, c3, c4, c5 FROM fdw_dml_basic_table_2
  WHERE c4 IS NOT NULL AND c5 IS NOT NULL
  ORDER BY c2 DESC;
SELECT * FROM fdw_dml_basic_table_2
  WHERE (c2 < 500 AND c4 IS NOT NULL) OR (c3 < 3) ORDER BY c1;
SELECT * FROM fdw_dml_basic_table_2 WHERE c4 LIKE '%th' ORDER BY c2;

--- tsurugi-issue#1078 (disable due to development) */
SELECT * FROM fdw_dml_basic_table_2 WHERE c4 LIKE '%th' ORDER BY c1;
SELECT * FROM fdw_dml_basic_table_2 WHERE c3 IN (1.1, 2.2) ORDER BY c3;

--- ORDER variation
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c5 DESC, c1 DESC;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c4, c1;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c3 ASC, c1;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c2, c1;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c1 DESC;
SELECT c1, c2, c3, c4, c5 FROM fdw_dml_basic_table_2 ORDER BY c5, c4 DESC, c1;

-- UPDATE statement variation (multiple columns)
UPDATE fdw_dml_basic_table_2 SET c2 = c2 + 10;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c1;

UPDATE fdw_dml_basic_table_2 SET c3 = c3 - 0.1 WHERE c2 = 110;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c2 DESC, c1;

UPDATE fdw_dml_basic_table_2 SET c3 = c3 + 2 WHERE c2 >= 410;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c3 ASC, c1;

UPDATE fdw_dml_basic_table_2 SET c5 = c5, c4 = c4 WHERE c4 >= '5th';
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c1;
UPDATE fdw_dml_basic_table_2
  SET c4 = '9thUpdate', c5 = date '2021-09-09' WHERE c4 = '9th';
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c1;

-- DELETE statement variation (multiple columns)
DELETE FROM fdw_dml_basic_table_2 WHERE c1 < 0;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c1;

DELETE FROM fdw_dml_basic_table_2 WHERE c3 IS NULL;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c2, c1;

DELETE FROM fdw_dml_basic_table_2 WHERE c4 LIKE '9th%';
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c4, c1;

DELETE FROM fdw_dml_basic_table_2 WHERE c2 > 800;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c3, c1;

DELETE FROM fdw_dml_basic_table_2 WHERE c3 <= 1.0;
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c2 DESC, c1;

DELETE FROM fdw_dml_basic_table_2 WHERE (c1 <> 2) AND (c1 <> 4);
SELECT * FROM fdw_dml_basic_table_2 ORDER BY c4, c1;

DELETE FROM fdw_dml_basic_table_2;
SELECT * FROM fdw_dml_basic_table_2;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_dml_basic_table_1;
DROP FOREIGN TABLE fdw_dml_basic_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_dml_basic_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_dml_basic_table_2', 'tsurugidb');

/* Test case: happy path - Aggregation related testing */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_group_basic_table (
    c1 INTEGER PRIMARY KEY,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 INTEGER,
    c7 VARCHAR(5)
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_group_basic_table (
  c1 integer,
  c2 integer,
  c3 bigint,
  c4 real,
  c5 double precision,
  c6 integer,
  c7 varchar(5)
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_group_basic_table
  (c1, c2, c3, c4, c5, c6, c7)
  VALUES
    (1, 11, 111, 1.1, 1.11, 1, 'aaa'),
    (2, 22, 222, 2.2, 2.22, 2, 'bbb'),
    (3, 33, 333, 3.3, 3.33, 3, 'ccc'),
    (4, 44, 444, 4.4, 4.44, 1, 'aaa'),
    (5, 55, 555, 5.5, 5.55, 2, 'bbb');

-- GROUP BY variations
SELECT COUNT(c1) AS "count(c1)", SUM(c2) AS "sum(c2)", c6
  FROM fdw_group_basic_table
  GROUP BY c6
  ORDER BY c6;
SELECT COUNT(c3) AS "count(c3)", SUM(c4) AS "sum(c4)", c7
  FROM fdw_group_basic_table
  GROUP BY c7
  ORDER BY c7;
SELECT COUNT(c1) AS "count(c1)", SUM(c2) AS "sum(c2)", c6
  FROM fdw_group_basic_table
  GROUP BY c6
  HAVING SUM(c2) > 55
  ORDER BY c6;
SELECT COUNT(c3) AS "count(c3)", SUM(c4) AS "sum(c4)", c7
  FROM fdw_group_basic_table
  GROUP BY c7
  HAVING SUM(c2) <> 55
  ORDER BY c7;
SELECT c6, COUNT(c1), SUM(c2), AVG(c3), MIN(c4), MAX(c5)
  FROM fdw_group_basic_table
  GROUP BY c6
  ORDER BY c6;
SELECT c7, COUNT(c1), SUM(c2), AVG(c3), MIN(c4), MAX(c5)
  FROM fdw_group_basic_table
  WHERE c1 <= 3
  GROUP BY c7
  ORDER BY c7;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_group_basic_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_group_basic_table', 'tsurugidb');

/* Test case: happy path - JOIN related testing */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_join_basic_table_1 (
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
  CREATE TABLE fdw_join_basic_table_2 (
    c1 INTEGER PRIMARY KEY,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_join_basic_table_1 (
  c1 integer,
  c2 integer,
  c3 bigint,
  c4 real,
  c5 double precision,
  c6 char(10),
  c7 varchar(26)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_join_basic_table_2 (
  c1 integer,
  c2 integer,
  c3 bigint,
  c4 real,
  c5 double precision,
  c6 char(10),
  c7 varchar(26)
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_join_basic_table_1
  (c1, c2, c3, c4, c5, c6, c7)
  VALUES
    (1, 11, 111, 1.1, 1.11, 'one', 'first'),
    (2, 22, 222, 2.2, 2.22, 'two', 'second'),
    (3, 33, 333, 3.3, 3.33, 'three', 'third');

INSERT INTO fdw_join_basic_table_2
  (c1, c2, c3, c4, c5, c6, c7)
  VALUES
    (1, 11, 111, 1.1, 1.11, 'one', 'first'),
    (2, 22, 222, 2.2, 2.22, 'two', 'second'),
    (3, 33, 333, 3.3, 3.33, 'three', 'third'),
    (4, NULL, NULL, NULL, NULL, 'NULL', NULL),
    (5, 55, 555, 5.5, 5.55, 'five', 'fifth');

-- TG JOIN - tsurugi-issue#863
SELECT *
  FROM fdw_join_basic_table_1 a
  INNER JOIN fdw_join_basic_table_2 b ON a.c1 = b.c1
  WHERE b.c1 > 1
  ORDER BY a.c1;
SELECT *
  FROM fdw_join_basic_table_1 a
  INNER JOIN fdw_join_basic_table_2 b ON a.c1 = b.c1
  WHERE b.c1 > 3
  ORDER BY a.c1;
SELECT a.c1, a.c2, b.c2, b.c7
  FROM fdw_join_basic_table_1 a
  INNER JOIN fdw_join_basic_table_2 b USING (c1)
  ORDER BY b.c4 DESC;
SELECT *
  FROM fdw_join_basic_table_1 AS a
  JOIN fdw_join_basic_table_2 AS b ON a.c4 = b.c4
  JOIN fdw_join_basic_table_1 AS c ON b.c4 = c.c4
  WHERE a.c2 = 22;
SELECT *
  FROM fdw_join_basic_table_1 AS a
  JOIN fdw_join_basic_table_2 AS b ON a.c4 = b.c4
  JOIN fdw_join_basic_table_1 AS c ON b.c4 = c.c4
  WHERE a.c2 = 44;
SELECT *
  FROM  fdw_join_basic_table_1 AS a
  CROSS JOIN fdw_join_basic_table_2 AS b
  ORDER BY b.c1, a.c1;
SELECT *
  FROM fdw_join_basic_table_1 AS a
  JOIN fdw_join_basic_table_1 AS b ON a.c3 = b.c3
  ORDER BY a.c3;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_join_basic_table_1;
DROP FOREIGN TABLE fdw_join_basic_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_join_basic_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_join_basic_table_2', 'tsurugidb');

/* Test case: happy path - Supported SELECT statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_select_variation_table_1 (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    value NUMERIC(10,2) NOT NULL,
    ref_id INT,
    manager_id INT
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_select_variation_table_2 (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_select_variation_table_1 (
  id integer,
  name text,
  value numeric,
  ref_id integer,
  manager_id integer
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_select_variation_table_2 (
  id integer,
  name varchar(100)
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_select_variation_table_1
  (id, name, value, ref_id, manager_id)
  VALUES
    (1000, 'name-1000', 100000, NULL, NULL),
    (1001, 'name-1001', 60000, 1, 1002),
    (1002, 'name-1002', 75000, 1, 1000),
    (1003, 'name-1003', 50000, 2, 1005),
    (1004, 'name-1004', 55000, 3, 1005),
    (1005, 'name-1005', 80000, 3, 1000);
INSERT INTO fdw_select_variation_table_2
  (id, name)
  VALUES
    (1, 'dep-1'),
    (2, 'dep-2'),
    (3, 'dep-3'),
    (4, 'dep-4');

-- SELECT ALL
SELECT ALL id, name, value
  FROM fdw_select_variation_table_1
  ORDER BY value, id;

-- SELECT DISTINCT
SELECT DISTINCT (ref_id) ref_id
  FROM fdw_select_variation_table_1
  ORDER BY ref_id;
SELECT DISTINCT (t2.id) id, t2.name
  FROM fdw_select_variation_table_1 t1
  JOIN fdw_select_variation_table_2 t2 ON (t1.ref_id = t2.id)
  ORDER BY t2.id;

-- AS
SELECT id AS user_id, name AS user_name FROM fdw_select_variation_table_1
  ORDER BY id;

-- [INNER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  INNER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id;

-- LEFT [OUTER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  LEFT OUTER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  LEFT JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id;
-- RIGHT [OUTER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  RIGHT OUTER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t2.id, t1.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  RIGHT JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t2.id, t1.id;
-- FULL [OUTER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  FULL OUTER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id, t2.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  FULL JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id, t2.id;
-- CROSS JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  CROSS JOIN fdw_select_variation_table_2 t2
  ORDER BY t1.id, t2.id;

-- BETWEEN ... AND
SELECT id, name, value
  FROM fdw_select_variation_table_1
  WHERE value BETWEEN 60000 AND 80000
  ORDER BY id;

-- IN
SELECT id, name, manager_id
  FROM fdw_select_variation_table_1
  WHERE manager_id IN (1000)
  ORDER BY id;
SELECT id, name, manager_id
  FROM fdw_select_variation_table_1
  WHERE manager_id IN (1000, 1005)
  ORDER BY id;

-- LIKE
SELECT id, name, value
  FROM fdw_select_variation_table_1
  WHERE name LIKE 'name-%'
  ORDER BY id;

-- ORDER BY
SELECT * FROM fdw_select_variation_table_1 ORDER BY value;
-- ORDER BY ASC
SELECT * FROM fdw_select_variation_table_1 ORDER BY value ASC;
-- ORDER BY DESC
SELECT * FROM fdw_select_variation_table_1 ORDER BY value DESC;
-- ORDER BY + NULLS FIRST
SELECT * FROM fdw_select_variation_table_1 ORDER BY ref_id NULLS FIRST;
-- ORDER BY + NULLS LAST --- Tsurugi specifications
SELECT * FROM fdw_select_variation_table_1 ORDER BY ref_id NULLS LAST;

-- GROUP BY
SELECT ref_id, COUNT(*), SUM(value)
  FROM fdw_select_variation_table_1
  GROUP BY ref_id
  ORDER BY ref_id;

-- HAVING
SELECT ref_id, COUNT(*), SUM(value)
  FROM fdw_select_variation_table_1
  GROUP BY ref_id
  HAVING COUNT(*) >= 2
  ORDER BY ref_id;

-- LIMIT
SELECT * FROM fdw_select_variation_table_1 ORDER BY id LIMIT 2;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_select_variation_table_1;
DROP FOREIGN TABLE fdw_select_variation_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_select_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_select_variation_table_2', 'tsurugidb');

/* Test case: happy path - Supported INSERT statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_ins_variation_table (
    c_int INTEGER DEFAULT 11,
    c_big BIGINT DEFAULT 22,
    c_dec DECIMAL DEFAULT 33,
    c_rel REAL DEFAULT 44.4,
    c_dbl DOUBLE PRECISION DEFAULT 55.5,
    c_chr CHAR DEFAULT ''a'',
    c_vchr VARCHAR DEFAULT ''default'',
    c_date DATE DEFAULT DATE ''2025-01-01'',
    c_time TIME DEFAULT TIME ''01:00:00'',
    c_tstmp TIMESTAMP DEFAULT TIMESTAMP ''2025-03-03 03:03:03''
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_ins_variation_table (
  c_int integer,
  c_big bigint,
  c_dec decimal,
  c_rel real,
  c_dbl double precision,
  c_chr char,
  c_vchr varchar,
  c_date date,
  c_time time,
  c_tstmp timestamp
) SERVER tsurugidb;

-- DEFAULT VALUES
INSERT INTO fdw_ins_variation_table DEFAULT VALUES;
SELECT * FROM fdw_ins_variation_table ORDER BY c_int;

-- INSERT ... VALUES (...), ...
INSERT INTO fdw_ins_variation_table
  (c_int, c_vchr, c_big, c_chr, c_dec)
  VALUES (4, 'key4', 400, 'b', 34), (5, 'key5', 500, 'c', 35);
SELECT * FROM fdw_ins_variation_table ORDER BY c_big;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_ins_variation_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_ins_variation_table', 'tsurugidb');

/* Test case: happy path - Supported UPDATE statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_upd_variation_table (
    c_int INTEGER,
    c_big BIGINT,
    c_dec DECIMAL,
    c_rel REAL,
    c_dbl DOUBLE PRECISION,
    c_chr CHAR,
    c_vchr VARCHAR,
    c_date DATE,
    c_time TIME,
    c_tstmp TIMESTAMP,
    c_tstmptz TIMESTAMP WITH TIME ZONE
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_upd_variation_table (
  c_int integer,
  c_big bigint,
  c_dec decimal,
  c_rel real,
  c_dbl double precision,
  c_chr char,
  c_vchr varchar,
  c_date date,
  c_time time,
  c_tstmp timestamp,
  c_tstmptz timestamp with time zone
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_upd_variation_table
  VALUES
  (1, 11, 12, 13.1, 14.2, 'a', 'val_1', '2025-01-01', '01:00:00',
   '2025-01-01 01:00:00', '2025-01-01 01:00:00+09'),
  (5, 51, 52, 53.1, 54.2, 'e', 'val_5', '2025-05-05', '05:00:00',
   '2025-05-05 05:00:00', '2025-05-05 05:00:00+09'),
  (10, 101, 102, 103.1, 104.2, 'j', 'val_10', '2025-10-10', '09:00:00',
   '2025-10-10 10:00:00', '2025-10-10 10:00:00+09'),
  (20, 201, 202, 203.1, 204.2, 't', 'val_20', '2025-08-20', '20:00:00',
   '2025-08-20 20:00:00', '2025-08-20 20:00:00+09');
SELECT * FROM fdw_upd_variation_table ORDER BY c_int;

-- SET column_name (int) = value
UPDATE fdw_upd_variation_table SET c_int = 6 WHERE c_int = 1;
SELECT * FROM fdw_upd_variation_table ORDER BY c_int;

-- SET column_name (bigint) = expression
UPDATE fdw_upd_variation_table
  SET c_int = 1, c_big = c_big + 101
  WHERE c_big = 11;
SELECT * FROM fdw_upd_variation_table ORDER BY c_big;

-- SET column_name (decimal) = expression
UPDATE fdw_upd_variation_table
  SET c_big = c_big - 101, c_dec = c_dec - 1
  WHERE c_dec = 12;
SELECT * FROM fdw_upd_variation_table ORDER BY c_dec DESC;

-- SET column_name (real) = expression
UPDATE fdw_upd_variation_table
  SET c_dec = c_dec + 1, c_rel = c_rel * 10
  WHERE c_rel = 13.1::real;
SELECT * FROM fdw_upd_variation_table ORDER BY c_rel DESC;

-- SET column_name (double precision) = expression
UPDATE fdw_upd_variation_table
  SET c_rel = c_rel / 10, c_dbl = c_dbl * 10 / 2
  WHERE c_dbl = CAST(14.2 AS double precision);
SELECT * FROM fdw_upd_variation_table ORDER BY c_dbl DESC;

-- SET column_name (char) = value
UPDATE fdw_upd_variation_table
  SET c_dbl = c_dbl * 2 / 10, c_chr = 'k' WHERE c_chr = 'a';
SELECT * FROM fdw_upd_variation_table ORDER BY c_chr;

-- SET column_name (varchar) = expression
UPDATE fdw_upd_variation_table
  SET c_chr = 'a', c_vchr = c_vchr || '_updated'
  WHERE c_vchr = 'val_1';
SELECT * FROM fdw_upd_variation_table ORDER BY c_vchr;

-- SET column_name (date) = value
UPDATE fdw_upd_variation_table
  SET c_vchr = 'val_1', c_date = '2025-08-08'
  WHERE c_date = '2025-01-01'::date;
SELECT * FROM fdw_upd_variation_table ORDER BY c_date;

-- SET column_name (time) = value
UPDATE fdw_upd_variation_table
  SET c_date = '2025-01-01', c_time = '12:00:00'
  WHERE c_time = '01:00:00'::time;
SELECT * FROM fdw_upd_variation_table ORDER BY c_time DESC;

-- SET column_name (timestamp) = value
UPDATE fdw_upd_variation_table
  SET c_time = '01:00:00', c_tstmp = '2025-08-08 12:00:00'
  WHERE c_tstmp = '2025-01-01 01:00:00'::timestamp;
SELECT * FROM fdw_upd_variation_table ORDER BY c_tstmp;

-- SET column_name (timestamp with time zone) = value
UPDATE fdw_upd_variation_table
  SET c_tstmp = '2025-01-01 01:00:00', c_tstmptz = '2025-08-08 12:00:00+09'
  WHERE c_tstmptz = '2025-01-01 01:00:00+09'::timestamp with time zone;
SELECT * FROM fdw_upd_variation_table ORDER BY c_tstmptz DESC;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_upd_variation_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_upd_variation_table', 'tsurugidb');

/* Test case: happy path - Supported DELETE statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_del_variation_table (
    id INT PRIMARY KEY,
    key_col VARCHAR(100),
    value_col INT
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_del_variation_table (
  id integer,
  key_col text,
  value_col integer
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_del_variation_table
  (id, key_col, value_col)
  VALUES
    (1, 'key1', 10),
    (2, 'key2', 20),
    (3, 'key3', 30),
    (4, 'key4', 40),
    (5, 'key5', 50),
    (6, 'key6', 60),
    (7, 'key7', 70),
    (8, 'key8', 80),
    (9, 'key9', 90),
    (10, 'key10', 100);
SELECT * FROM fdw_del_variation_table ORDER BY id;

-- Test
DELETE FROM fdw_del_variation_table WHERE id BETWEEN 3 AND 5;
SELECT * FROM fdw_del_variation_table ORDER BY id;

DELETE FROM fdw_del_variation_table WHERE value_col IN (10, 60);
SELECT * FROM fdw_del_variation_table ORDER BY id DESC;

DELETE FROM fdw_del_variation_table WHERE key_col LIKE '%1%';
SELECT * FROM fdw_del_variation_table ORDER BY key_col;

DELETE
  FROM fdw_del_variation_table
  WHERE (key_col <> 'key2') AND (value_col < 90);
SELECT * FROM fdw_del_variation_table ORDER BY key_col DESC;

DELETE FROM fdw_del_variation_table;
SELECT * FROM fdw_del_variation_table;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_del_variation_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table', 'tsurugidb');

/* Test teardown: PostgreSQL environment */
SET datestyle TO 'default';
SET timezone TO DEFAULT;
