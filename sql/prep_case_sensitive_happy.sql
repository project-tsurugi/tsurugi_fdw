/* Test case: happy path - Case sensitivity (preparation) */
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
PREPARE prep_insert (integer, integer) AS
  INSERT INTO fdw_case_table VALUES ($1, $2);
EXECUTE prep_insert (1000, 1);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer, integer) AS
  INSERT INTO public.fdw_case_table (col, "Col") VALUES ($1, $2);
EXECUTE prep_insert (2000, 2);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO "public".fdw_case_table (col) VALUES ($1);
EXECUTE prep_insert (3000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO "public"."fdw_case_table" (Col) VALUES ($1);
EXECUTE prep_insert (4);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO Public.fdw_case_table ("col") VALUES ($1);
EXECUTE prep_insert (5000);
DEALLOCATE prep_insert;

PREPARE prep_insert (integer) AS
  INSERT INTO PUBLIC.fdw_case_table ("Col") VALUES ($1);
EXECUTE prep_insert (6);
DEALLOCATE prep_insert;

PREPARE prep_select AS
  SELECT * FROM public.fdw_case_table ORDER BY col, Col DESC;
EXECUTE prep_select;
DEALLOCATE prep_select;

PREPARE prep_update (integer) AS
  UPDATE fdw_case_table SET col = col + $1;
EXECUTE prep_update (100);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE public.fdw_case_table SET Col = Col + $1;
EXECUTE prep_update (10);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE "public".fdw_case_table SET "col" = "col" + 100 WHERE col > $1;
EXECUTE prep_update (5000);
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE public."fdw_case_table" SET "Col" = "Col" + $1 WHERE Col > 12;
EXECUTE prep_update (100);
DEALLOCATE prep_update;

PREPARE prep_update (integer, integer) AS
  UPDATE "public"."fdw_case_table" SET "col" = col + $1 WHERE "col" > $2;
EXECUTE prep_update (100, 3000);
DEALLOCATE prep_update;

PREPARE prep_update AS
  UPDATE Public.fdw_case_table SET "col" = Col * 10 WHERE col IS NULL;
EXECUTE prep_update;
DEALLOCATE prep_update;

PREPARE prep_update (integer) AS
  UPDATE PUBLIC.fdw_case_table SET "Col" = col / $1 WHERE "Col" IS NULL;
EXECUTE prep_update (100);
DEALLOCATE prep_update;

PREPARE prep_select AS SELECT * FROM fdw_case_table ORDER BY col;
EXECUTE prep_select;
DEALLOCATE prep_select;

PREPARE prep_select AS SELECT * FROM Public.fdw_case_table ORDER BY Col;
EXECUTE prep_select;
DEALLOCATE prep_select;

PREPARE prep_delete (integer) AS
  DELETE FROM fdw_case_table WHERE col = $1;
EXECUTE prep_delete (1100);
DEALLOCATE prep_delete;

PREPARE prep_delete (integer) AS
  DELETE FROM public.fdw_case_table WHERE "col" > $1;
EXECUTE prep_delete (5000);
DEALLOCATE prep_delete;

PREPARE prep_delete (integer) AS
  DELETE FROM "public".fdw_case_table WHERE Col > $1;
EXECUTE prep_delete (114);
DEALLOCATE prep_delete;

PREPARE prep_delete (integer) AS
  DELETE FROM public."fdw_case_table" WHERE "col" >= $1;
EXECUTE prep_delete (3200);
DEALLOCATE prep_delete;

PREPARE prep_delete AS
  DELETE FROM "public"."fdw_case_table" WHERE "Col" > 100;
EXECUTE prep_delete;
DEALLOCATE prep_delete;

PREPARE prep_delete (integer) AS
  DELETE FROM Public.fdw_case_table WHERE col <> $1;
EXECUTE prep_delete (2100);
DEALLOCATE prep_delete;

PREPARE prep_delete (integer) AS
  DELETE FROM PUBLIC.fdw_case_table WHERE Col <> $1;
EXECUTE prep_delete (12);
DEALLOCATE prep_delete;

PREPARE prep_select AS SELECT * FROM Public.fdw_case_table;
EXECUTE prep_select;
DEALLOCATE prep_select;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');
