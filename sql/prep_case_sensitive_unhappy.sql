/* Test case: unhappy path - Case sensitivity (preparation) */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_case_table (
    col INT,
    Col INT
  )
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_case_table (
  col integer,
  "Col" integer
) SERVER tsurugidb;

-- Test
PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_case_table ("COL") VALUES ($1);
EXECUTE fdw_prepare_ins (1000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer, integer) AS
  INSERT INTO fdw_case_table (col, Col) VALUES ($1, $2);
EXECUTE fdw_prepare_ins (2000, 2);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO "Public".fdw_case_table (col) VALUES ($1);
EXECUTE fdw_prepare_ins (3000);
DEALLOCATE fdw_prepare_ins;

UPDATE "Public".fdw_case_table SET col = 6000;
UPDATE fdw_case_table SET col = 100 WHERE "COL" > 5000;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE "Public".fdw_case_table SET col = $1;
EXECUTE fdw_prepare_ins (4000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE fdw_case_table SET col = $1 WHERE "COL" > $2;
EXECUTE fdw_prepare_ins (100, 5000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_del AS DELETE FROM fdw_Case_Table;
  DELETE FROM "Public".fdw_case_table;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del AS DELETE FROM fdw_Case_Table;
  DELETE FROM fdw_case_table WHERE "COL" > 5000;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');

