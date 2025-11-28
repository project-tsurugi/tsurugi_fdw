/* Test case: unhappy path - Unsupported DML statement patterns - PostgreSQL 12-16 */

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

-- Sub queries
SELECT *
  FROM fdw_sel_unsupported_test
  WHERE value = (SELECT MAX(value) FROM fdw_sel_unsupported_test);

-- LIMIT OFFSET
SELECT * FROM fdw_sel_unsupported_test LIMIT 2 OFFSET 1;

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
  id integer DEFAULT 9999,
  key_col varchar(100) DEFAULT 'default',
  value_col integer DEFAULT 0
) SERVER tsurugidb;

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
UPDATE fdw_upd_unsupported_test SET date_col = date_col + INTERVAL '1 days';

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
