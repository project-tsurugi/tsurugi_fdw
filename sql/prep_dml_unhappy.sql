/* Test case: unhappy path - Unsupported DML statement patterns (preparation) - PostgreSQL 12-16 */

/* Test case: unhappy path - invalid PREPARE statement */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_invalid_test (id INTEGER)
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_invalid_test (id integer) SERVER tsurugidb;

-- invalid PREPARE statement
PREPARE invalid AS SELECT * FROM unknown_table;
PREPARE invalid (varchar) AS SELECT * FROM fdw_invalid_test WHERE $1 = 100;
PREPARE invalid (char) AS SELECT * FROM fdw_invalid_test WHERE id = $1;
PREPARE invalid (real) AS SELECT * FROM fdw_invalid_test WHERE id = $1;
PREPARE invalid (int) AS SELECT * FROM fdw_invalid_test ORDER BY id limit $1;
EXECUTE invalid (1);
DEALLOCATE invalid;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_invalid_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_invalid_test', 'tsurugidb');

/* Test case: unhappy path - Unsupported SELECT statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_sel_unsupported_test (
    id INTEGER,
    name VARCHAR,
    value INTEGER
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_sel_unsupported_test (
  id integer,
  name varchar,
  value integer
) SERVER tsurugidb;

-- UNION
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test
  UNION
  SELECT * FROM fdw_sel_unsupported_test;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- UNION ALL
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test
  UNION ALL
  SELECT * FROM fdw_sel_unsupported_test;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- UNION DISTINCT
PREPARE prep_select AS
  SELECT id, name FROM fdw_sel_unsupported_test
  UNION DISTINCT
  SELECT id, name FROM fdw_sel_unsupported_test ORDER BY id, name;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- INTERSECT
PREPARE prep_select AS
  SELECT id FROM fdw_sel_unsupported_test
  INTERSECT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- INTERSECT ALL
PREPARE prep_select AS
  SELECT id FROM fdw_sel_unsupported_test
  INTERSECT ALL
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- INTERSECT DISTINCT
PREPARE prep_select AS
  SELECT id FROM fdw_sel_unsupported_test
  INTERSECT DISTINCT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- EXCEPT
PREPARE prep_select AS
  SELECT id FROM fdw_sel_unsupported_test
  EXCEPT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- EXCEPT ALL
PREPARE prep_select AS
  SELECT id FROM fdw_sel_unsupported_test
  EXCEPT ALL
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- EXCEPT DISTINCT
PREPARE prep_select AS
  SELECT id FROM fdw_sel_unsupported_test
  EXCEPT DISTINCT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- WITH
PREPARE prep_select AS
  WITH value_data AS (
    SELECT id, name, value FROM fdw_sel_unsupported_test WHERE value >= 75000
  )
  SELECT * FROM value_data;
-----FIXME: Disabled due to issues
-----EXECUTE prep_select;
DEALLOCATE prep_select;

-- WITH RECURSIVE
PREPARE prep_select AS
  WITH RECURSIVE chart AS (
    SELECT id, name, value, 1 AS level
      FROM fdw_sel_unsupported_test
      WHERE value IS NULL
    UNION ALL
    SELECT e.id, e.name, e.value, oc.level + 1
      FROM fdw_sel_unsupported_test e
      JOIN chart oc ON e.id = oc.id
  )
  SELECT * FROM chart ORDER BY level, id;
-----FIXME: Disabled due to issues
-----EXECUTE prep_select;
DEALLOCATE prep_select;

-- Sub queries
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test
    WHERE value = (SELECT MAX(value) FROM fdw_sel_unsupported_test);
EXECUTE prep_select;
DEALLOCATE prep_select;

-- SELECT DISTINCT ON
PREPARE prep_select AS
  SELECT DISTINCT ON (id) id, name FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- ORDER BY USING operator
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value USING >;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- IN
PREPARE prep_select (double precision[])
  AS SELECT * FROM fdw_sel_unsupported_test WHERE id = ANY($1);
EXECUTE prep_select (ARRAY[1.1, 2.2]);
DEALLOCATE prep_select;

-- LIMIT ALL
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test LIMIT ALL;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- LIMIT OFFSET
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test LIMIT 2 OFFSET 1;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- FETCH FIRST ... ONLY
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test
    ORDER BY value FETCH FIRST 2 ROWS ONLY;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- FETCH NEXT ... ONLY
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test
    ORDER BY value FETCH NEXT 2 ROWS ONLY;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- OFFSET FETCH FIRST ... ONLY
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH FIRST 2 ROWS ONLY;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- OFFSET FETCH NEXT ... ONLY
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH NEXT 2 ROWS ONLY;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- SELECT FOR UPDATE / NOWAIT
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test FOR UPDATE NOWAIT;
BEGIN;
EXECUTE prep_select;
END;
DEALLOCATE prep_select;

-- SELECT FOR UPDATE / SKIP LOCKED
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test FOR UPDATE SKIP LOCKED;
BEGIN;
EXECUTE prep_select;
END;
DEALLOCATE prep_select;

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
  id integer DEFAULT 9999,
  key_col varchar(100) DEFAULT 'default',
  value_col integer DEFAULT 0
) SERVER tsurugidb;

-- WITH
PREPARE prep_with AS
  WITH data AS (
    SELECT 'key1'::TEXT AS key_col, 100 AS value_col
  )
  INSERT INTO fdw_ins_unsupported_test (id, key_col, value_col)
    SELECT 1, key_col, value_col FROM data;
EXECUTE prep_with;
DEALLOCATE prep_with;

-- INSERT ... AS alias
PREPARE prep_with (integer, varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test AS it (id, key_col, value_col)
    VALUES ($1, $2, $3);
EXECUTE prep_with (2, 'key2', 200);
DEALLOCATE prep_with;

-- DEFAULT VALUES
PREPARE prep_with (integer, varchar(100)) AS
  INSERT INTO fdw_ins_unsupported_test VALUES ($1, $2, DEFAULT);
EXECUTE prep_with (3, 'key3');
DEALLOCATE prep_with;

-- INSERT ... SELECT
PREPARE prep_with AS
  INSERT INTO fdw_ins_unsupported_test SELECT 6, 'key6', 600;
EXECUTE prep_with;
DEALLOCATE prep_with;

-- ON CONFLICT DO NOTHING
PREPARE prep_with (integer, varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test
    VALUES ($1, $2, $3) ON CONFLICT (id) DO NOTHING;
EXECUTE prep_with (4, 'key4', 777);
DEALLOCATE prep_with;

-- ON CONFLICT DO UPDATE SET ...
PREPARE prep_with (varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ($1, $2)
    ON CONFLICT (key_col) DO UPDATE SET value_col = EXCLUDED.value_col;
EXECUTE prep_with ('key4', 444);
DEALLOCATE prep_with;

-- RETURNING
PREPARE prep_with (varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ($1, $2)
    RETURNING id, key_col AS inserted_key;
EXECUTE prep_with ('key6', 600);
DEALLOCATE prep_with;

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
    value_col INT DEFAULT 0,
    date_col DATE
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_upd_unsupported_test (
  id integer,
  key_col varchar(100),
  value_col integer DEFAULT 0,
  date_col date
) SERVER tsurugidb;

-- WITH
PREPARE prep_with AS
  WITH upd_data AS (
    SELECT 'key1'::TEXT AS key_col, 100 AS new_val
  )
  UPDATE fdw_upd_unsupported_test SET value_col = upd_data.new_val
    FROM upd_data WHERE fdw_upd_unsupported_test.key_col = upd_data.key_col;
-----FIXME: Disabled due to issues
-----EXECUTE prep_with;
DEALLOCATE prep_with;

-- ONLY
PREPARE prep_with AS
  UPDATE ONLY fdw_upd_unsupported_test
    SET value_col = 111 WHERE key_col = 'key1';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- AS alias
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test ut
    SET value_col = 222 WHERE ut.key_col = 'key2';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- AS alias (AS)
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test AS ut
    SET value_col = 222 WHERE ut.key_col = 'key2';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- SET column_name = DEFAULT
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = DEFAULT WHERE key_col = 'key3';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- SET column_name = date + INTERVAL
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test
    SET date_col = date_col + INTERVAL '1 days';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- SET (col1, col2) = ROW (...)
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test
    SET (key_col, value_col) =
      ROW('key1_modified', 123) WHERE key_col = 'key1';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- SET (col1, col2) = (sub-SELECT)
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test
    SET (key_col, value_col) =
      (SELECT 'key2_modified', 222) WHERE key_col = 'key2';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- UPDATE ... FROM
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = fdw_upd_unsupported_test.value_col + add_data.value_col
      FROM fdw_upd_unsupported_test add_data
      WHERE fdw_upd_unsupported_test.key_col = add_data.key_col;
EXECUTE prep_with;
DEALLOCATE prep_with;

-- RETURNING
PREPARE prep_with AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = value_col + 1 WHERE key_col = 'key3'
    RETURNING id, key_col AS updated_key, value_col;
EXECUTE prep_with;
DEALLOCATE prep_with;

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
PREPARE prep_with AS
  WITH keys_to_delete AS (
    SELECT 'key1'::TEXT AS key_col
  )
  DELETE FROM fdw_del_variation_table_1
    USING keys_to_delete
      WHERE fdw_del_variation_table_1.key_col = keys_to_delete.key_col;
-----FIXME: Disabled due to issues
-----EXECUTE prep_with;
DEALLOCATE prep_with;

-- ONLY
PREPARE prep_with AS
  DELETE FROM ONLY fdw_del_variation_table_1 WHERE key_col = 'key1';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- AS alias
PREPARE prep_with AS
  DELETE FROM fdw_del_variation_table_1 dt WHERE dt.key_col = 'key2';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- AS alias (AS)
PREPARE prep_with AS
  DELETE FROM fdw_del_variation_table_1 AS dt WHERE dt.key_col = 'key3';
EXECUTE prep_with;
DEALLOCATE prep_with;

-- USING
PREPARE prep_with AS
  DELETE FROM fdw_del_variation_table_1
    USING fdw_del_variation_table_2
      WHERE fdw_del_variation_table_1.key_col =
        fdw_del_variation_table_2.key_col;
EXECUTE prep_with;
DEALLOCATE prep_with;

-- RETURNING
PREPARE prep_with AS
  DELETE FROM fdw_del_variation_table_1 WHERE key_col = 'key6'
    RETURNING id, key_col AS deleted_key;
EXECUTE prep_with;
DEALLOCATE prep_with;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_del_variation_table_1;
DROP FOREIGN TABLE fdw_del_variation_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_2', 'tsurugidb');
