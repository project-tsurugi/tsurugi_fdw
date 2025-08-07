/* Test case: unhappy path - Unsupported DML statement patterns (preparation) - PostgreSQL 12-15 */

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
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test
  UNION
  SELECT * FROM fdw_sel_unsupported_test;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- UNION ALL
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test
  UNION ALL
  SELECT * FROM fdw_sel_unsupported_test;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- UNION DISTINCT
PREPARE fdw_prepare_sel AS
  SELECT id, name FROM fdw_sel_unsupported_test
  UNION DISTINCT
  SELECT id, name FROM fdw_sel_unsupported_test ORDER BY id, name;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- INTERSECT
PREPARE fdw_prepare_sel AS
  SELECT id FROM fdw_sel_unsupported_test
  INTERSECT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- INTERSECT ALL
PREPARE fdw_prepare_sel AS
  SELECT id FROM fdw_sel_unsupported_test
  INTERSECT ALL
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- INTERSECT DISTINCT
PREPARE fdw_prepare_sel AS
  SELECT id FROM fdw_sel_unsupported_test
  INTERSECT DISTINCT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- EXCEPT
PREPARE fdw_prepare_sel AS
  SELECT id FROM fdw_sel_unsupported_test
  EXCEPT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- EXCEPT ALL
PREPARE fdw_prepare_sel AS
  SELECT id FROM fdw_sel_unsupported_test
  EXCEPT ALL
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- EXCEPT DISTINCT
PREPARE fdw_prepare_sel AS
  SELECT id FROM fdw_sel_unsupported_test
  EXCEPT DISTINCT
  SELECT id FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- WITH
PREPARE fdw_prepare_sel AS
  WITH value_data AS (
    SELECT id, name, value FROM fdw_sel_unsupported_test WHERE value >= 75000
  )
  SELECT * FROM value_data;
-----FIXME: Disabled due to BUG-#1
-----EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- WITH RECURSIVE
PREPARE fdw_prepare_sel AS
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
-----FIXME: Disabled due to BUG-#1
-----EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- Sub queries
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test
    WHERE value = (SELECT MAX(value) FROM fdw_sel_unsupported_test);
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- SELECT DISTINCT ON
PREPARE fdw_prepare_sel AS
  SELECT DISTINCT ON (id) id, name FROM fdw_sel_unsupported_test ORDER BY id;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- ORDER BY USING operator
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value USING >;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- IN
PREPARE fdw_prepare_sel (double precision[])
  AS SELECT * FROM fdw_sel_unsupported_test WHERE id = ANY($1);
EXECUTE fdw_prepare_sel (ARRAY[1.1, 2.2]);
DEALLOCATE fdw_prepare_sel;

-- LIMIT ALL
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test LIMIT ALL;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- LIMIT OFFSET
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test LIMIT 2 OFFSET 1;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- FETCH FIRST ... ONLY
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test
    ORDER BY value FETCH FIRST 2 ROWS ONLY;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- FETCH NEXT ... ONLY
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test
    ORDER BY value FETCH NEXT 2 ROWS ONLY;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- OFFSET FETCH FIRST ... ONLY
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH FIRST 2 ROWS ONLY;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- OFFSET FETCH NEXT ... ONLY
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH NEXT 2 ROWS ONLY;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- SELECT FOR UPDATE / NOWAIT
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test FOR UPDATE NOWAIT;
BEGIN;
EXECUTE fdw_prepare_sel;
END;
DEALLOCATE fdw_prepare_sel;

-- SELECT FOR UPDATE / SKIP LOCKED
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test FOR UPDATE SKIP LOCKED;
BEGIN;
EXECUTE fdw_prepare_sel;
END;
DEALLOCATE fdw_prepare_sel;

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
PREPARE fdw_prepare_with AS
  WITH data AS (
    SELECT 'key1'::TEXT AS key_col, 100 AS value_col
  )
  INSERT INTO fdw_ins_unsupported_test (id, key_col, value_col)
    SELECT 1, key_col, value_col FROM data;
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- INSERT ... AS alias
PREPARE fdw_prepare_with (integer, varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test AS it (id, key_col, value_col)
    VALUES ($1, $2, $3);
EXECUTE fdw_prepare_with (2, 'key2', 200);
DEALLOCATE fdw_prepare_with;

-- DEFAULT VALUES
PREPARE fdw_prepare_with (integer, varchar(100)) AS
  INSERT INTO fdw_ins_unsupported_test VALUES ($1, $2, DEFAULT);
EXECUTE fdw_prepare_with (3, 'key3');
DEALLOCATE fdw_prepare_with;

-- INSERT ... SELECT
PREPARE fdw_prepare_with AS
  INSERT INTO fdw_ins_unsupported_test SELECT 6, 'key6', 600;
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- ON CONFLICT DO NOTHING
PREPARE fdw_prepare_with (integer, varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test
    VALUES ($1, $2, $3) ON CONFLICT (id) DO NOTHING;
EXECUTE fdw_prepare_with (4, 'key4', 777);
DEALLOCATE fdw_prepare_with;

-- ON CONFLICT DO UPDATE SET ...
PREPARE fdw_prepare_with (varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ($1, $2)
    ON CONFLICT (key_col) DO UPDATE SET value_col = EXCLUDED.value_col;
EXECUTE fdw_prepare_with ('key4', 444);
DEALLOCATE fdw_prepare_with;

-- RETURNING
PREPARE fdw_prepare_with (varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ($1, $2)
    RETURNING id, key_col AS inserted_key;
EXECUTE fdw_prepare_with ('key6', 600);
DEALLOCATE fdw_prepare_with;

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
PREPARE fdw_prepare_with AS
  WITH upd_data AS (
    SELECT 'key1'::TEXT AS key_col, 100 AS new_val
  )
  UPDATE fdw_upd_unsupported_test SET value_col = upd_data.new_val
    FROM upd_data WHERE fdw_upd_unsupported_test.key_col = upd_data.key_col;
-----FIXME: Disabled due to BUG-#1
-----EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- ONLY
PREPARE fdw_prepare_with AS
  UPDATE ONLY fdw_upd_unsupported_test
    SET value_col = 111 WHERE key_col = 'key1';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- AS alias
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test ut
    SET value_col = 222 WHERE ut.key_col = 'key2';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- AS alias (AS)
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test AS ut
    SET value_col = 222 WHERE ut.key_col = 'key2';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- SET column_name = DEFAULT
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = DEFAULT WHERE key_col = 'key3';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- SET column_name = date + INTERVAL
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test
    SET date_col = date_col + INTERVAL '1 days';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- SET (col1, col2) = ROW (...)
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test
    SET (key_col, value_col) =
      ROW('key1_modified', 123) WHERE key_col = 'key1';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- SET (col1, col2) = (sub-SELECT)
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test
    SET (key_col, value_col) =
      (SELECT 'key2_modified', 222) WHERE key_col = 'key2';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- UPDATE ... FROM
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = fdw_upd_unsupported_test.value_col + add_data.value_col
      FROM fdw_upd_unsupported_test add_data
      WHERE fdw_upd_unsupported_test.key_col = add_data.key_col;
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- RETURNING
PREPARE fdw_prepare_with AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = value_col + 1 WHERE key_col = 'key3'
    RETURNING id, key_col AS updated_key, value_col;
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

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
PREPARE fdw_prepare_with AS
  WITH keys_to_delete AS (
    SELECT 'key1'::TEXT AS key_col
  )
  DELETE FROM fdw_del_variation_table_1
    USING keys_to_delete
      WHERE fdw_del_variation_table_1.key_col = keys_to_delete.key_col;
-----FIXME: Disabled due to BUG-#1
-----EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- ONLY
PREPARE fdw_prepare_with AS
  DELETE FROM ONLY fdw_del_variation_table_1 WHERE key_col = 'key1';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- AS alias
PREPARE fdw_prepare_with AS
  DELETE FROM fdw_del_variation_table_1 dt WHERE dt.key_col = 'key2';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- AS alias (AS)
PREPARE fdw_prepare_with AS
  DELETE FROM fdw_del_variation_table_1 AS dt WHERE dt.key_col = 'key3';
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- USING
PREPARE fdw_prepare_with AS
  DELETE FROM fdw_del_variation_table_1
    USING fdw_del_variation_table_2
      WHERE fdw_del_variation_table_1.key_col =
        fdw_del_variation_table_2.key_col;
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- RETURNING
PREPARE fdw_prepare_with AS
  DELETE FROM fdw_del_variation_table_1 WHERE key_col = 'key6'
    RETURNING id, key_col AS deleted_key;
EXECUTE fdw_prepare_with;
DEALLOCATE fdw_prepare_with;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_del_variation_table_1;
DROP FOREIGN TABLE fdw_del_variation_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_2', 'tsurugidb');
