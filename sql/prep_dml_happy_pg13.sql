/* Test case: happy path - Supported DML statement patterns (preparation) - PostgreSQL 13 */

/* Test case: happy path - Supported SELECT statement patterns */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_select_variation_table (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    value NUMERIC(10,2) NOT NULL,
    ref_id INT,
    manager_id INT
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_select_variation_table (
  id integer,
  name varchar(100),
  value numeric,
  ref_id integer,
  manager_id integer
) SERVER tsurugidb;

-- Initialization of test data
INSERT INTO fdw_select_variation_table
  (id, name, value, ref_id, manager_id)
  VALUES
    (1000, 'name-1000', 100000, NULL, NULL),
    (1001, 'name-1001', 60000, 1, 1002),
    (1002, 'name-1002', 75000, 1, 1000),
    (1003, 'name-1003', 60000, 2, 1005),
    (1004, 'name-1004', 55000, 3, 1005),
    (1005, 'name-1005', 80000, 3, 1000);

-- FETCH FIRST ... WITH TIES
-----FIXME: Changing expectations due to issues
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_select_variation_table ORDER BY value
    FETCH FIRST 2 ROWS WITH TIES;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- FETCH NEXT ... WITH TIES
-----FIXME: Changing expectations due to issues
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_select_variation_table ORDER BY value
    FETCH NEXT 2 ROWS WITH TIES;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_select_variation_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_select_variation_table', 'tsurugidb');
