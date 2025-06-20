/* Test case: SELECT statement variations */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_select_variation_table_1 (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    value NUMERIC(10,2) NOT NULL,
    ref_id INT,
    manager_id INT
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_select_variation_table_2 (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_select_variation_table_1 (
  id INT,
  name TEXT,
  value NUMERIC,
  ref_id INT,
  manager_id INT
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_select_variation_table_2 (
  id INT,
  name TEXT
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_select_variation_table_1
  (id, name, value, ref_id, manager_id) VALUES
  (1000, 'name-1000', 100000, NULL, NULL),
  (1001, 'name-1001', 60000, 1, 1002),
  (1002, 'name-1002', 75000, 1, 1000),
  (1003, 'name-1003', 50000, 2, 1005),
  (1004, 'name-1004', 55000, 3, 1005),
  (1005, 'name-1005', 80000, 3, 1000);
INSERT INTO fdw_select_variation_table_2
  (id, name) VALUES
  (1, 'dep-1'),
  (2, 'dep-2'),
  (3, 'dep-3'),
  (4, 'dep-4');

-- Test
--- WITH
WITH value_data AS (
  SELECT id, name, value FROM fdw_select_variation_table_1 WHERE value >= 75000
)
SELECT * FROM value_data;

--- WITH RECURSIVE
WITH RECURSIVE chart AS (
  SELECT id, name, manager_id, 1 AS level
    FROM fdw_select_variation_table_1
    WHERE manager_id IS NULL
  UNION ALL
  SELECT e.id, e.name, e.manager_id, oc.level + 1
    FROM fdw_select_variation_table_1 e
    JOIN chart oc ON e.manager_id = oc.id
)
SELECT * FROM chart ORDER BY level, id;

--- SELECT ALL
SELECT ALL id, name, value FROM fdw_select_variation_table_1 ORDER BY value, id;

--- SELECT DISTINCT
----- SELECT DISTINCT ON (id) id, name FROM fdw_select_variation_table_1 ORDER BY id;  ----- [#2]
SELECT DISTINCT ON (t2.id) t2.id, t2.name
  FROM fdw_select_variation_table_1 t1
  JOIN fdw_select_variation_table_2 t2 ON (t1.ref_id = t2.id)
  ORDER BY t2.id;

--- AS
SELECT id AS user_id, name AS user_name FROM fdw_select_variation_table_1;

--- Arithmetic operation
SELECT id, name, ((value / 10000) * ref_id)::int AS lank FROM fdw_select_variation_table_1;

--- CASE WHEN
SELECT id, name, CASE WHEN value >= 100000 THEN 'High' WHEN value >= 75000 THEN 'Medium' ELSE 'Low' END AS lank
  FROM fdw_select_variation_table_1;

--- Sub queries
SELECT * FROM fdw_select_variation_table_1 WHERE value = (SELECT MAX(value) FROM fdw_select_variation_table_1); ----- [#8]

--- [INNER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  INNER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id
  ORDER BY t1.id;

--- LEFT [OUTER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  LEFT OUTER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id ORDER BY t1.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  LEFT JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id ORDER BY t1.id;
--- RIGHT [OUTER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  RIGHT OUTER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id ORDER BY t2.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  RIGHT JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id ORDER BY t2.id;
--- FULL [OUTER] JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  FULL OUTER JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id ORDER BY t1.id, t2.id;
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  FULL JOIN fdw_select_variation_table_2 t2 ON t1.ref_id = t2.id ORDER BY t1.id, t2.id;
--- CROSS JOIN
SELECT t1.id, t1.name, t2.name
  FROM fdw_select_variation_table_1 t1
  CROSS JOIN fdw_select_variation_table_2 t2;

--- BETWEEN ... AND
SELECT id, name, value FROM fdw_select_variation_table_1 WHERE value BETWEEN 60000 AND 80000;

--- IN
SELECT id, name, manager_id FROM fdw_select_variation_table_1 WHERE manager_id IN (1000);
SELECT id, name, manager_id FROM fdw_select_variation_table_1 WHERE manager_id IN (1000, 1005); ----- [#6]

--- LIKE
SELECT id, name, value FROM fdw_select_variation_table_1 WHERE name LIKE 'name-%'; ----- [#7]

--- ORDER BY
SELECT * FROM fdw_select_variation_table_1 ORDER BY value;
--- ORDER BY ASC
SELECT * FROM fdw_select_variation_table_1 ORDER BY value ASC;
--- ORDER BY DESC
SELECT * FROM fdw_select_variation_table_1 ORDER BY value DESC;
--- ORDER BY USING operator
SELECT * FROM fdw_select_variation_table_1 ORDER BY value USING >;
--- ORDER BY + NULLS FIRST
SELECT * FROM fdw_select_variation_table_1 ORDER BY ref_id NULLS FIRST;
--- ORDER BY + NULLS LAST
SELECT * FROM fdw_select_variation_table_1 ORDER BY ref_id NULLS LAST; ----- [#5]

--- GROUP BY
SELECT ref_id, COUNT(*), SUM(value)
  FROM fdw_select_variation_table_1
  GROUP BY ref_id
  ORDER BY ref_id;

--- HAVING
SELECT ref_id, COUNT(*), SUM(value)
  FROM fdw_select_variation_table_1
  GROUP BY ref_id
  HAVING COUNT(*) >= 2;

--- WINDOW
SELECT id, name, value, RANK() OVER w AS rk
  FROM fdw_select_variation_table_1
  WINDOW w AS (ORDER BY value DESC);

--- UNION
SELECT * FROM fdw_select_variation_table_1 UNION SELECT * FROM fdw_select_variation_table_1;
SELECT * FROM fdw_select_variation_table_1 UNION SELECT * FROM fdw_select_variation_table_1 ORDER BY value DESC;
SELECT * FROM fdw_select_variation_table_1 WHERE value>=60000
  UNION SELECT * FROM fdw_select_variation_table_1 WHERE manager_id=1000 ORDER BY value DESC;
--- UNION ALL
SELECT * FROM fdw_select_variation_table_1 UNION ALL SELECT * FROM fdw_select_variation_table_1;
----- SELECT * FROM fdw_select_variation_table_1
-----   UNION ALL SELECT * FROM fdw_select_variation_table_1 ORDER BY value DESC;  ----- [#3]
SELECT * FROM fdw_select_variation_table_1 WHERE value>=60000
  UNION ALL SELECT * FROM fdw_select_variation_table_1 WHERE manager_id=1000 ORDER BY value DESC;
--- UNION DISTINCT
SELECT ref_id, name FROM fdw_select_variation_table_1
  UNION DISTINCT SELECT id, name FROM fdw_select_variation_table_2 ORDER BY ref_id, name;

--- INTERSECT
SELECT ref_id FROM fdw_select_variation_table_1
  INTERSECT SELECT id FROM fdw_select_variation_table_2 ORDER BY ref_id;
--- INTERSECT ALL
SELECT ref_id FROM fdw_select_variation_table_1
  INTERSECT ALL SELECT id FROM fdw_select_variation_table_2 ORDER BY ref_id;
--- INTERSECT DISTINCT
SELECT ref_id FROM fdw_select_variation_table_1
  INTERSECT DISTINCT SELECT id FROM fdw_select_variation_table_2 ORDER BY ref_id;

--- EXCEPT
SELECT ref_id FROM fdw_select_variation_table_1
  EXCEPT SELECT id FROM fdw_select_variation_table_2 ORDER BY ref_id;
--- EXCEPT ALL
SELECT ref_id FROM fdw_select_variation_table_1
  EXCEPT ALL SELECT id FROM fdw_select_variation_table_2 ORDER BY ref_id;
--- EXCEPT DISTINCT
SELECT ref_id FROM fdw_select_variation_table_1
  EXCEPT DISTINCT SELECT id FROM fdw_select_variation_table_2 ORDER BY ref_id;

--- LIMIT
SELECT * FROM fdw_select_variation_table_1 LIMIT 2;
--- LIMIT ALL
SELECT * FROM fdw_select_variation_table_1 LIMIT ALL;
--- LIMIT OFFSET
SELECT * FROM fdw_select_variation_table_1 LIMIT 2 OFFSET 1;

--- FETCH FIRST ... WITH TIES
SELECT * FROM fdw_select_variation_table_1 ORDER BY value FETCH FIRST 2 ROWS WITH TIES;
--- FETCH FIRST ... ONLY
SELECT * FROM fdw_select_variation_table_1 ORDER BY value FETCH FIRST 2 ROWS ONLY;

--- FETCH NEXT ... WITH TIES
SELECT * FROM fdw_select_variation_table_1 ORDER BY value FETCH NEXT 2 ROWS WITH TIES;
--- FETCH NEXT ... ONLY
SELECT * FROM fdw_select_variation_table_1 ORDER BY value FETCH NEXT 2 ROWS ONLY;

--- OFFSET FETCH FIRST ... WITH TIES
SELECT * FROM fdw_select_variation_table_1 ORDER BY value OFFSET 1 FETCH FIRST 2 ROWS WITH TIES;
--- OFFSET FETCH FIRST ... ONLY
SELECT * FROM fdw_select_variation_table_1 ORDER BY value OFFSET 1 FETCH FIRST 2 ROWS ONLY;

--- OFFSET FETCH NEXT ... WITH TIES
SELECT * FROM fdw_select_variation_table_1 ORDER BY value OFFSET 1 FETCH NEXT 2 ROWS WITH TIES;
--- OFFSET FETCH NEXT ... ONLY
SELECT * FROM fdw_select_variation_table_1 ORDER BY value OFFSET 1 FETCH NEXT 2 ROWS ONLY;

--- SELECT FOR UPDATE / NOWAIT
BEGIN;
SELECT * FROM fdw_select_variation_table_1 FOR UPDATE NOWAIT;
END;

--- SELECT FOR UPDATE / SKIP LOCKED
BEGIN;
SELECT * FROM fdw_select_variation_table_1 FOR UPDATE SKIP LOCKED;
END;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_select_variation_table_1;
DROP FOREIGN TABLE fdw_select_variation_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_select_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_select_variation_table_2', 'tsurugidb');

/* Test case: INSERT statement variations */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_ins_variation_table (
    id INT PRIMARY KEY DEFAULT 9999,
    key_col VARCHAR(100) DEFAULT ''default'',
    value_col INT DEFAULT 0
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_ins_variation_table (
  id INT,
  key_col TEXT,
  value_col INT
) SERVER tsurugidb;

-- Test
--- WITH
WITH data AS (
  SELECT 'key1'::TEXT AS key_col, 100 AS value_col
)
INSERT INTO fdw_ins_variation_table (id, key_col, value_col) SELECT 1, key_col, value_col FROM data;

--- INSERT ... AS alias
INSERT INTO fdw_ins_variation_table AS it (id, key_col, value_col) VALUES (2, 'key2', 200);

--- DEFAULT VALUES
INSERT INTO fdw_ins_variation_table DEFAULT VALUES;
SELECT * FROM fdw_ins_variation_table;

INSERT INTO fdw_ins_variation_table VALUES (3, 'key3', DEFAULT);

--- INSERT ... VALUES (...), ...
INSERT INTO fdw_ins_variation_table VALUES (4, 'key4', 400), (5, 'key5', 500);
SELECT * FROM fdw_ins_variation_table;

--- INSERT ... SELECT
INSERT INTO fdw_ins_variation_table SELECT 6, 'key6', 600;

--- ON CONFLICT DO NOTHING
INSERT INTO fdw_ins_variation_table VALUES (4, 'key4', 777) ON CONFLICT (id) DO NOTHING;
--- ON CONFLICT DO UPDATE SET ...
INSERT INTO fdw_ins_variation_table (key_col, value_col) VALUES ('key4', 444)
  ON CONFLICT (key_col) DO UPDATE SET value_col = EXCLUDED.value_col;

--- RETURNING
INSERT INTO fdw_ins_variation_table (key_col, value_col) VALUES ('key6', 600)
  RETURNING id, key_col AS inserted_key;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_ins_variation_table;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_ins_variation_table', 'tsurugidb');

/* Test case: UPDATE statement variations */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_upd_variation_table_1 (
    id INT PRIMARY KEY,
    key_col VARCHAR(100),
    value_col INT DEFAULT 0
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_upd_variation_table_2 (
    key_col VARCHAR(100),
    add_val INT
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_upd_variation_table_1 (
  id INT,
  key_col TEXT,
  value_col INT DEFAULT 0
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_upd_variation_table_2 (
  key_col TEXT,
  add_val INT
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_upd_variation_table_1
  (id, key_col, value_col) VALUES
  (1, 'key1', 10),
  (2, 'key2', 20),
  (3, 'key3', 30);
INSERT INTO fdw_upd_variation_table_2
  (key_col, add_val) VALUES
  ('key3', 5);

-- Test
--- WITH
WITH upd_data AS (
  SELECT 'key1'::TEXT AS key_col, 100 AS new_val
)
UPDATE fdw_upd_variation_table_1 SET value_col = upd_data.new_val
  FROM upd_data WHERE fdw_upd_variation_table_1.key_col = upd_data.key_col;

--- ONLY
UPDATE ONLY fdw_upd_variation_table_1 SET value_col = 111 WHERE key_col = 'key1';

--- AS alias
UPDATE fdw_upd_variation_table_1 ut SET value_col = 222 WHERE ut.key_col = 'key2';
UPDATE fdw_upd_variation_table_1 AS ut SET value_col = 222 WHERE ut.key_col = 'key2';

--- SET column_name = expression
UPDATE fdw_upd_variation_table_1 SET value_col = value_col + 10 WHERE key_col = 'key3';
SELECT * FROM fdw_upd_variation_table_1;

--- SET column_name = DEFAULT
UPDATE fdw_upd_variation_table_1 SET value_col = DEFAULT WHERE key_col = 'key3';

--- SET (col1, col2) = ROW (...)
UPDATE fdw_upd_variation_table_1
  SET (key_col, value_col) = ROW('key1_modified', 123) WHERE key_col = 'key1';

--- SET (col1, col2) = (sub-SELECT)
UPDATE fdw_upd_variation_table_1
  SET (key_col, value_col) = (SELECT 'key2_modified', 222) WHERE key_col = 'key2'; ----- [#9]

--- UPDATE ... FROM
UPDATE fdw_upd_variation_table_1
  SET value_col = value_col + fdw_upd_variation_table_2.add_val
    FROM fdw_upd_variation_table_2
    WHERE fdw_upd_variation_table_1.key_col = fdw_upd_variation_table_2.key_col;

--- RETURNING
UPDATE fdw_upd_variation_table_1 SET value_col = value_col + 1 WHERE key_col = 'key3'
  RETURNING id, key_col AS updated_key, value_col;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_upd_variation_table_1;
DROP FOREIGN TABLE fdw_upd_variation_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_upd_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_upd_variation_table_2', 'tsurugidb');

/* Test case: DELETE statement variations */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_del_variation_table_1 (
    id INT PRIMARY KEY,
    key_col VARCHAR(100),
    value_col INT
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_del_variation_table_2 (
    key_col VARCHAR(100)
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_del_variation_table_1 (
  id INT,
  key_col TEXT,
  value_col INT
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_del_variation_table_2 (
  key_col TEXT
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_del_variation_table_1
  (id, key_col, value_col) VALUES
  (1, 'key1', 10),
  (2, 'key2', 20),
  (3, 'key3', 30),
  (4, 'key4', 40),
  (5, 'key5', 50),
  (6, 'key5', 60);
INSERT INTO fdw_del_variation_table_2
  (key_col) VALUES
  ('key4'), ('key5');

-- Test
--- WITH
WITH keys_to_delete AS (
  SELECT 'key1'::TEXT AS key_col
)
DELETE FROM fdw_del_variation_table_1
  USING keys_to_delete WHERE fdw_del_variation_table_1.key_col = keys_to_delete.key_col;

--- ONLY
DELETE FROM ONLY fdw_del_variation_table_1 WHERE key_col = 'key1';

--- AS alias
DELETE FROM fdw_del_variation_table_1 dt WHERE dt.key_col = 'key2';
DELETE FROM fdw_del_variation_table_1 AS dt WHERE dt.key_col = 'key3';

--- USING
DELETE FROM fdw_del_variation_table_1
  USING fdw_del_variation_table_2
    WHERE fdw_del_variation_table_1.key_col = fdw_del_variation_table_2.key_col;

--- RETURNING
DELETE FROM fdw_del_variation_table_1 WHERE key_col = 'key6'
  RETURNING id, key_col AS deleted_key;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_del_variation_table_1;
DROP FOREIGN TABLE fdw_del_variation_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_2', 'tsurugidb');
