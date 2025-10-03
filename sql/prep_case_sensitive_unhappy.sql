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
  INSERT INTO fdw_Case_Table (col) VALUES ($1);
EXECUTE fdw_prepare_ins (1000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_Case_table (col) VALUES ($1);
EXECUTE fdw_prepare_ins (2000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_CASE_table (col) VALUES ($1);
EXECUTE fdw_prepare_ins (3000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_CASE_TABLE (col) VALUES ($1);
EXECUTE fdw_prepare_ins (4000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO public.fdw_Case_Table (col) VALUES ($1);
EXECUTE fdw_prepare_ins (5000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_case_table (COL) VALUES ($1);
EXECUTE fdw_prepare_ins (6000);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO "Public".fdw_case_table (col) VALUES ($1);
PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_case_table ("COL") VALUES ($1);

PREPARE fdw_prepare_ins (integer, integer) AS
  INSERT INTO fdw_case_table (col, "Col") VALUES ($1, $2);
EXECUTE fdw_prepare_ins (9000, 9);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_Case_Table SET col = $1;
EXECUTE fdw_prepare_upd (1000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_Case_table SET col = $1;
EXECUTE fdw_prepare_upd (2000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_CASE_table SET col = $1;
EXECUTE fdw_prepare_upd (3000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_CASE_TABLE SET col = $1;
EXECUTE fdw_prepare_upd (4000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE public.fdw_Case_Table SET col = $1;
EXECUTE fdw_prepare_upd (5000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_case_table SET COL = $1;
EXECUTE fdw_prepare_upd (100);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE fdw_case_table SET col = $1 WHERE COL > $2;
EXECUTE fdw_prepare_upd (100, 5000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE "Public".fdw_case_table SET col = $1;
PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE fdw_case_table SET col = $1 WHERE "COL" > $2;

PREPARE fdw_prepare_del AS DELETE FROM fdw_Case_Table;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del AS DELETE FROM fdw_Case_table;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del AS DELETE FROM fdw_CASE_table;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del AS DELETE FROM fdw_CASE_TABLE;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del AS DELETE FROM public.fdw_Case_Table;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM fdw_case_table WHERE COL > 5000;
EXECUTE fdw_prepare_del;
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del AS DELETE FROM "Public".fdw_case_table;
PREPARE fdw_prepare_del (integer) AS
  DELETE FROM fdw_case_table WHERE "COL" > 5000;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');

