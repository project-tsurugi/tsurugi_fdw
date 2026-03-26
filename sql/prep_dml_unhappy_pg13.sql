/* Test case: unhappy path - Unsupported DML statement patterns (preparation) - PostgreSQL 13 */

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

-- GROUP BY ALL
PREPARE prep_select AS
  SELECT ref_id, COUNT(*), SUM(value)
    FROM fdw_sel_unsupported_test
    GROUP BY ALL ref_id
    ORDER BY ref_id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- GROUP BY DISTINCT
PREPARE prep_select AS
  SELECT ref_id, COUNT(*), SUM(value)
    FROM fdw_sel_unsupported_test
    GROUP BY DISTINCT ref_id
    ORDER BY ref_id;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_sel_unsupported_test;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_sel_unsupported_test', 'tsurugidb');
