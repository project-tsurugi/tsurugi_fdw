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

-- Sub queries
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test
    WHERE value = (SELECT MAX(value) FROM fdw_sel_unsupported_test);
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- LIMIT OFFSET
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test LIMIT 2 OFFSET 1;
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
  id integer DEFAULT 9999,
  key_col varchar(100) DEFAULT 'default',
  value_col integer DEFAULT 0
) SERVER tsurugidb;

-- ON CONFLICT DO NOTHING
PREPARE fdw_prepare_ins (integer, varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test
    VALUES ($1, $2, $3) ON CONFLICT (id) DO NOTHING;
EXECUTE fdw_prepare_ins (4, 'key4', 777);
DEALLOCATE fdw_prepare_ins;

-- ON CONFLICT DO UPDATE SET ...
PREPARE fdw_prepare_ins (varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ($1, $2)
    ON CONFLICT (key_col) DO UPDATE SET value_col = EXCLUDED.value_col;
EXECUTE fdw_prepare_ins ('key4', 444);
DEALLOCATE fdw_prepare_ins;

-- RETURNING
PREPARE fdw_prepare_ins (varchar(100), integer) AS
  INSERT INTO fdw_ins_unsupported_test (key_col, value_col) VALUES ($1, $2)
    RETURNING id, key_col AS inserted_key;
EXECUTE fdw_prepare_ins ('key6', 600);
DEALLOCATE fdw_prepare_ins;

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

-- SET column_name = date + INTERVAL
PREPARE fdw_prepare_upd AS
  UPDATE fdw_upd_unsupported_test
    SET date_col = date_col + INTERVAL '1 days';
EXECUTE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd;

-- SET (col1, col2) = (sub-SELECT)
PREPARE fdw_prepare_upd AS
  UPDATE fdw_upd_unsupported_test
    SET (key_col, value_col) =
      (SELECT 'key2_modified', 222) WHERE key_col = 'key2';
EXECUTE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd;

-- UPDATE ... FROM
PREPARE fdw_prepare_upd AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = fdw_upd_unsupported_test.value_col + add_data.value_col
      FROM fdw_upd_unsupported_test add_data
      WHERE fdw_upd_unsupported_test.key_col = add_data.key_col;
EXECUTE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd;

-- RETURNING
PREPARE fdw_prepare_upd AS
  UPDATE fdw_upd_unsupported_test
    SET value_col = value_col + 1 WHERE key_col = 'key3'
    RETURNING id, key_col AS updated_key, value_col;
EXECUTE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd;

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

-- USING
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_del_variation_table_1
    USING fdw_del_variation_table_2
      WHERE fdw_del_variation_table_1.key_col =
        fdw_del_variation_table_2.key_col;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

-- RETURNING
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_del_variation_table_1 WHERE key_col = 'key6'
    RETURNING id, key_col AS deleted_key;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_del_variation_table_1;
DROP FOREIGN TABLE fdw_del_variation_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_del_variation_table_2', 'tsurugidb');
