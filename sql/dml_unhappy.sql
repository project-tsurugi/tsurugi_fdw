/* Test case: unhappy path - Unsupported DML statement patterns - PostgreSQL 12-15 */

/* Test case: unhappy path - Unsupported SELECT statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_sel_unsupported_test (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    value NUMERIC(10,2) NOT NULL,
    ref_id INT,
    manager_id INT
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_sel_unsupported_test (
  id INTEGER,
  name TEXT,
  value NUMERIC,
  ref_id INT,
  manager_id INT
) SERVER tsurugidb;

-- UNION
SELECT * FROM fdw_sel_unsupported_test
UNION
SELECT * FROM fdw_sel_unsupported_test;

-- UNION ALL
SELECT * FROM fdw_sel_unsupported_test
UNION ALL
SELECT * FROM fdw_sel_unsupported_test;

-- UNION DISTINCT
SELECT ref_id, name FROM fdw_sel_unsupported_test
UNION DISTINCT
SELECT id, name FROM fdw_sel_unsupported_test ORDER BY ref_id, name;

-- INTERSECT
SELECT ref_id FROM fdw_sel_unsupported_test
INTERSECT
SELECT id FROM fdw_sel_unsupported_test ORDER BY ref_id;

-- INTERSECT ALL
SELECT ref_id FROM fdw_sel_unsupported_test
INTERSECT ALL
SELECT id FROM fdw_sel_unsupported_test ORDER BY ref_id;

-- INTERSECT DISTINCT
SELECT ref_id FROM fdw_sel_unsupported_test
INTERSECT DISTINCT
SELECT id FROM fdw_sel_unsupported_test ORDER BY ref_id;

-- EXCEPT
SELECT ref_id FROM fdw_sel_unsupported_test
EXCEPT
SELECT id FROM fdw_sel_unsupported_test ORDER BY ref_id;

-- EXCEPT ALL
SELECT ref_id FROM fdw_sel_unsupported_test
EXCEPT ALL
SELECT id FROM fdw_sel_unsupported_test ORDER BY ref_id;

-- EXCEPT DISTINCT
SELECT ref_id FROM fdw_sel_unsupported_test
EXCEPT DISTINCT
SELECT id FROM fdw_sel_unsupported_test ORDER BY ref_id;

-- WITH
-----FIXME: Disabled due to BUG-#1
-----WITH value_data AS (
-----  SELECT id, name, value FROM fdw_sel_unsupported_test WHERE value >= 75000
-----)
-----SELECT * FROM value_data;

-- WITH RECURSIVE
-----FIXME: Disabled due to BUG-#1
-----WITH RECURSIVE chart AS (
-----  SELECT id, name, manager_id, 1 AS level
-----    FROM fdw_sel_unsupported_test
-----    WHERE manager_id IS NULL
-----  UNION ALL
-----  SELECT e.id, e.name, e.manager_id, oc.level + 1
-----    FROM fdw_sel_unsupported_test e
-----    JOIN chart oc ON e.manager_id = oc.id
-----)
-----SELECT * FROM chart ORDER BY level, id;

-- Sub queries
SELECT *
  FROM fdw_sel_unsupported_test
  WHERE value = (SELECT MAX(value) FROM fdw_sel_unsupported_test);

-- SELECT DISTINCT ON
SELECT DISTINCT ON (id) id, name FROM fdw_sel_unsupported_test ORDER BY id;

-- ORDER BY USING operator
SELECT * FROM fdw_sel_unsupported_test ORDER BY value USING >;

-- LIMIT ALL
SELECT * FROM fdw_sel_unsupported_test LIMIT ALL;
-- LIMIT OFFSET
SELECT * FROM fdw_sel_unsupported_test LIMIT 2 OFFSET 1;

-- FETCH FIRST ... ONLY
SELECT * FROM fdw_sel_unsupported_test
  ORDER BY value FETCH FIRST 2 ROWS ONLY;

-- FETCH NEXT ... ONLY
SELECT * FROM fdw_sel_unsupported_test
  ORDER BY value FETCH NEXT 2 ROWS ONLY;

-- OFFSET FETCH FIRST ... ONLY
SELECT * FROM fdw_sel_unsupported_test ORDER BY value
  OFFSET 1 FETCH FIRST 2 ROWS ONLY;

-- OFFSET FETCH NEXT ... ONLY
SELECT * FROM fdw_sel_unsupported_test ORDER BY value
  OFFSET 1 FETCH NEXT 2 ROWS ONLY;

-- SELECT FOR UPDATE / NOWAIT
BEGIN;
SELECT * FROM fdw_sel_unsupported_test FOR UPDATE NOWAIT;
END;

-- SELECT FOR UPDATE / SKIP LOCKED
BEGIN;
SELECT * FROM fdw_sel_unsupported_test FOR UPDATE SKIP LOCKED;
END;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_sel_unsupported_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_sel_unsupported_test', 'tsurugidb');

/* Test case: unhappy path - Unsupported INSERT statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_ins_unsupported_test (
    id INT PRIMARY KEY DEFAULT 9999,
    key_col VARCHAR(100) DEFAULT ''default'',
    value_col INT DEFAULT 0
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_ins_unsupported_test (
  id integer,
  key_col varchar(100),
  value_col integer
) SERVER tsurugidb;

-- WITH
WITH data AS (
  SELECT 'key1'::TEXT AS key_col, 100 AS value_col
)
INSERT INTO fdw_ins_unsupported_test
  (id, key_col, value_col)
  SELECT 1, key_col, value_col FROM data;

-- INSERT ... AS alias
INSERT INTO fdw_ins_unsupported_test AS it
  (id, key_col, value_col)
  VALUES (2, 'key2', 200);

-- DEFAULT VALUES
INSERT INTO fdw_ins_unsupported_test VALUES (3, 'key3', DEFAULT);

-- INSERT ... SELECT
INSERT INTO fdw_ins_unsupported_test SELECT 6, 'key6', 600;

-- ON CONFLICT DO NOTHING
INSERT INTO fdw_ins_unsupported_test
  VALUES (4, 'key4', 777) ON CONFLICT (id) DO NOTHING;
-- ON CONFLICT DO UPDATE SET ...
INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ('key4', 444)
  ON CONFLICT (key_col) DO UPDATE SET value_col = EXCLUDED.value_col;

-- RETURNING
INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ('key6', 600)
  RETURNING id, key_col AS inserted_key;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_ins_unsupported_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_ins_unsupported_test', 'tsurugidb');

/* Test case: unhappy path - Unsupported UPDATE statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_upd_unsupported_test (
    id INT PRIMARY KEY,
    key_col VARCHAR(100),
    value_col INT,
    date_col DATE
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_upd_unsupported_test (
  id integer,
  key_col varchar(100),
  value_col integer,
  date_col date
) SERVER tsurugidb;

-- WITH
-----FIXME: Disabled due to BUG-#1
-----WITH upd_data AS (
-----  SELECT 'key1'::TEXT AS key_col, 100 AS new_val
-----)
-----UPDATE fdw_upd_unsupported_test SET value_col = upd_data.new_val
-----  FROM upd_data WHERE fdw_upd_unsupported_test.key_col = upd_data.key_col;

-- ONLY
UPDATE ONLY fdw_upd_unsupported_test
  SET value_col = 111 WHERE key_col = 'key1';

-- AS alias
UPDATE fdw_upd_unsupported_test ut
  SET value_col = 222 WHERE ut.key_col = 'key2';
UPDATE fdw_upd_unsupported_test AS ut
  SET value_col = 222 WHERE ut.key_col = 'key2';

-- SET column_name = DEFAULT
UPDATE fdw_upd_unsupported_test SET value_col = DEFAULT WHERE key_col = 'key3';

-- SET column_name = date + INTERVAL
UPDATE fdw_upd_unsupported_test SET date_col = date_col + INTERVAL '1 days';

-- SET (col1, col2) = ROW (...)
UPDATE fdw_upd_unsupported_test
  SET (key_col, value_col) = ROW('key1_modified', 123)
  WHERE key_col = 'key1';

-- SET (col1, col2) = (sub-query)
UPDATE fdw_upd_unsupported_test
  SET (key_col, value_col) = (SELECT 'key2_modified', 222)
  WHERE key_col = 'key2';

-- UPDATE ... FROM
UPDATE fdw_upd_unsupported_test
  SET value_col = fdw_upd_unsupported_test.value_col + add_data.value_col
    FROM fdw_upd_unsupported_test add_data
    WHERE fdw_upd_unsupported_test.key_col = add_data.key_col;

-- RETURNING
UPDATE fdw_upd_unsupported_test
  SET value_col = value_col + 1
  WHERE key_col = 'key3'
  RETURNING id, key_col AS updated_key, value_col;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_upd_unsupported_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_upd_unsupported_test', 'tsurugidb');

/* Test case: unhappy path - Unsupported DELETE statement patterns */
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
  id integer,
  key_col varchar(100),
  value_col integer
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_del_variation_table_2 (
  key_col varchar(100)
) SERVER tsurugidb;

-- WITH
-----FIXME: Disabled due to BUG-#1
-----WITH keys_to_delete AS (
-----  SELECT 'key1'::TEXT AS key_col
-----)
-----DELETE FROM fdw_del_variation_table_1
-----  USING keys_to_delete WHERE fdw_del_variation_table_1.key_col = keys_to_delete.key_col;

-- ONLY
DELETE FROM ONLY fdw_del_variation_table_1 WHERE key_col = 'key1';

-- AS alias
DELETE FROM fdw_del_variation_table_1 dt WHERE dt.key_col = 'key2';
DELETE FROM fdw_del_variation_table_1 AS dt WHERE dt.key_col = 'key3';

-- USING
DELETE FROM fdw_del_variation_table_1
  USING fdw_del_variation_table_2
    WHERE fdw_del_variation_table_1.key_col = fdw_del_variation_table_2.key_col;

-- RETURNING
DELETE FROM fdw_del_variation_table_1 WHERE key_col = 'key6'
  RETURNING id, key_col AS deleted_key;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_del_variation_table_1;
DROP FOREIGN TABLE fdw_del_variation_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_2', 'tsurugidb');
