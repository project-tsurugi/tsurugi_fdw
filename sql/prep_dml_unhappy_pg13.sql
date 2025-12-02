/* Test case: unhappy path - Unsupported DML statement patterns (preparation) - PostgreSQL 13 */

/* Test case: unhappy path - invalid PREPARE statement */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_invalid_test (id INTEGER)
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_invalid_test (id integer) SERVER tsurugidb;

-- invalid PREPARE statement
PREPARE invalid (int) AS SELECT $1 FROM fdw_invalid_test;
EXECUTE invalid(1);
DEALLOCATE invalid;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_invalid_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_invalid_test', 'tsurugidb');

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

-- Arithmetic operation
PREPARE prep_select AS
  SELECT id, name, ((value / 10000) * ref_id)::int AS lank
    FROM fdw_sel_unsupported_test;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- CASE WHEN
PREPARE prep_select (integer, integer) AS
  SELECT
    id, name,
    CASE
      WHEN value >= $1 THEN 'High'
      WHEN value >= $2 THEN 'Medium'
      ELSE 'Low' END AS lank
    FROM fdw_sel_unsupported_test;
EXECUTE prep_select (100000, 75000);
DEALLOCATE prep_select;

-- WINDOW
PREPARE prep_select AS
  SELECT id, name, value, RANK() OVER w AS rk
    FROM fdw_sel_unsupported_test
    WINDOW w AS (ORDER BY value DESC);
EXECUTE prep_select;
DEALLOCATE prep_select;

-- FETCH FIRST ... WITH TIES
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    FETCH FIRST 2 ROWS WITH TIES;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- FETCH NEXT ... WITH TIES
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    FETCH NEXT 2 ROWS WITH TIES;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- OFFSET FETCH FIRST ... WITH TIES
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH FIRST 2 ROWS WITH TIES;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- OFFSET FETCH NEXT ... WITH TIES
PREPARE prep_select AS
  SELECT * FROM fdw_sel_unsupported_test ORDER BY value
    OFFSET 1 FETCH NEXT 2 ROWS WITH TIES;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_sel_unsupported_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_sel_unsupported_test', 'tsurugidb');
