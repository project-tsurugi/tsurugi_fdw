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
PREPARE prep_insert (integer) AS
  INSERT INTO fdw_Case_Table (col) VALUES ($1);
EXECUTE prep_insert (1000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO fdw_Case_table (col) VALUES ($1);
EXECUTE prep_insert (2000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO fdw_CASE_table (col) VALUES ($1);
EXECUTE prep_insert (3000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO fdw_CASE_TABLE (col) VALUES ($1);
EXECUTE prep_insert (4000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO public.fdw_Case_Table (col) VALUES ($1);
EXECUTE prep_insert (5000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO fdw_case_table (COL) VALUES ($1);
EXECUTE prep_insert (6000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO "Public".fdw_case_table (col) VALUES ($1);
PREPARE prep_insert (integer) AS
  INSERT INTO fdw_case_table ("COL") VALUES ($1);

PREPARE prep_insert (integer, integer) AS
  INSERT INTO fdw_case_table (col, "Col") VALUES ($1, $2);
EXECUTE prep_insert (9000, 9);
DEALLOCATE prep_insert;

PREPARE prep_update (integer) AS
  UPDATE fdw_Case_Table SET col = $1;
EXECUTE prep_update (1000);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE fdw_Case_table SET col = $1;
EXECUTE prep_update (2000);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE fdw_CASE_table SET col = $1;
EXECUTE prep_update (3000);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE fdw_CASE_TABLE SET col = $1;
EXECUTE prep_update (4000);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE public.fdw_Case_Table SET col = $1;
EXECUTE prep_update (5000);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE fdw_case_table SET COL = $1;
EXECUTE prep_update (100);
DEALLOCATE prep_update;

PREPARE prep_update (integer, integer) AS
  UPDATE fdw_case_table SET col = $1 WHERE COL > $2;
EXECUTE prep_update (100, 5000);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE "Public".fdw_case_table SET col = $1;
PREPARE prep_update (integer, integer) AS
  UPDATE fdw_case_table SET col = $1 WHERE "COL" > $2;

PREPARE prep_delete AS DELETE FROM fdw_Case_Table;
EXECUTE prep_delete;
DEALLOCATE prep_delete;

PREPARE prep_delete AS DELETE FROM fdw_Case_table;
EXECUTE prep_delete;
DEALLOCATE prep_delete;

PREPARE prep_delete AS DELETE FROM fdw_CASE_table;
EXECUTE prep_delete;
DEALLOCATE prep_delete;

PREPARE prep_delete AS DELETE FROM fdw_CASE_TABLE;
EXECUTE prep_delete;
DEALLOCATE prep_delete;

PREPARE prep_delete AS DELETE FROM public.fdw_Case_Table;
EXECUTE prep_delete;
DEALLOCATE prep_delete;

PREPARE prep_delete (integer) AS
  DELETE FROM fdw_case_table WHERE COL > 5000;
EXECUTE prep_delete;
DEALLOCATE prep_delete;

PREPARE prep_delete AS DELETE FROM "Public".fdw_case_table;
PREPARE prep_delete (integer) AS
  DELETE FROM fdw_case_table WHERE "COL" > 5000;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');

