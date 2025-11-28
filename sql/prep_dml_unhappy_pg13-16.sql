/* Test case: unhappy path - Unsupported DML statement patterns (preparation) - PostgreSQL 13-16 */

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
  id integer,
  name varchar(100),
  value numeric,
  ref_id integer,
  manager_id integer
) SERVER tsurugidb;

-- OFFSET FETCH FIRST ... WITH TIES
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH FIRST 2 ROWS WITH TIES;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- OFFSET FETCH NEXT ... WITH TIES
PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH NEXT 2 ROWS WITH TIES;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_sel_unsupported_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_sel_unsupported_test', 'tsurugidb');
