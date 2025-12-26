/* Test case: unhappy path - Unsupported DML statement patterns - PostgreSQL 16 */

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
SELECT id, name, ((value / 10000) * ref_id)::int AS lank
  FROM fdw_sel_unsupported_test;

-- CASE WHEN
SELECT
  id, name,
  CASE
    WHEN value >= 100000 THEN 'High'
    WHEN value >= 75000 THEN 'Medium'
    ELSE 'Low' END AS lank
  FROM fdw_sel_unsupported_test;

-- WINDOW
SELECT id, name, value, RANK() OVER w AS rk
  FROM fdw_sel_unsupported_test
  WINDOW w AS (ORDER BY value DESC);

-- GROUP BY ALL
SELECT ref_id, COUNT(*), SUM(value)
  FROM fdw_sel_unsupported_test
  GROUP BY ALL ref_id
  ORDER BY ref_id;

-- GROUP BY DISTINCT
SELECT ref_id, COUNT(*), SUM(value)
  FROM fdw_sel_unsupported_test
  GROUP BY DISTINCT ref_id
  ORDER BY ref_id;

-- FETCH FIRST ... WITH TIES
SELECT * FROM fdw_sel_unsupported_test ORDER BY value
  FETCH FIRST 2 ROWS WITH TIES;

-- FETCH NEXT ... WITH TIES
SELECT * FROM fdw_sel_unsupported_test ORDER BY value
  FETCH NEXT 2 ROWS WITH TIES;

-- OFFSET FETCH FIRST ... WITH TIES
SELECT * FROM fdw_sel_unsupported_test ORDER BY value
  OFFSET 1 FETCH FIRST 2 ROWS WITH TIES;

-- OFFSET FETCH NEXT ... WITH TIES
SELECT * FROM fdw_sel_unsupported_test ORDER BY value
  OFFSET 1 FETCH NEXT 2 ROWS WITH TIES;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_sel_unsupported_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_sel_unsupported_test', 'tsurugidb');
