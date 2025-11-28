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
PREPARE fdw_prepare_ins (integer, integer) AS
  INSERT INTO fdw_case_table VALUES ($1, $2);
EXECUTE fdw_prepare_ins (1001, 1);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer, integer) AS
  INSERT INTO fdw_case_table (col, "Col") VALUES ($1, $2);
EXECUTE fdw_prepare_ins (1002, 2);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_Case_Table (COL) VALUES ($1);
EXECUTE fdw_prepare_ins (1003);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_Case_table ("Col") VALUES ($1);
EXECUTE fdw_prepare_ins (4);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_case_table ("col") VALUES ($1);
EXECUTE fdw_prepare_ins (1005);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer, integer) AS
  INSERT INTO fdw_CASE_table ("Col", col) VALUES ($1, $2);
EXECUTE fdw_prepare_ins (6, 1006);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_CASE_TABLE (cOL) VALUES ($1);
EXECUTE fdw_prepare_ins (1007);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_sel AS
  SELECT * FROM fdw_case_table ORDER BY Col, col;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_sel AS
  SELECT * FROM FDW_CASE_TABLE ORDER BY "Col", col;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_ins (integer, integer) AS
  INSERT INTO public.fdw_case_table (col, "Col") VALUES ($1, $2);
EXECUTE fdw_prepare_ins (2001, 1);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO public.fdw_Case_Table (col) VALUES ($1);
EXECUTE fdw_prepare_ins (2002);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO PUBLIC.fdw_case_table ("col") VALUES ($1);
EXECUTE fdw_prepare_ins (2003);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO Public.fdw_case_table ("Col") VALUES ($1);
EXECUTE fdw_prepare_ins (4);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO "public".fdw_case_table (col) VALUES ($1);
EXECUTE fdw_prepare_ins (2005);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer, integer) AS
  INSERT INTO public."fdw_case_table" ("Col", col) VALUES ($1, $2);
EXECUTE fdw_prepare_ins (6, 2006);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO "public"."fdw_case_table" (Col) VALUES ($1);
EXECUTE fdw_prepare_ins (2007);
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_sel AS
  SELECT * FROM public.fdw_case_table ORDER BY Col DESC, col DESC;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_sel AS
  SELECT * FROM PUBLIC.fdw_case_table ORDER BY "Col" DESC, col DESC;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_case_table SET col = col + $1;
EXECUTE fdw_prepare_upd (100);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_Case_Table SET COL = "col" + $1;
EXECUTE fdw_prepare_upd (100);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE FDW_CASE_TABLE SET "col" = COL + $1 WHERE COL > $2;
EXECUTE fdw_prepare_upd (100, 2000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_case_table SET "Col" = "Col" + $1 WHERE Col IS NOT NULL;
EXECUTE fdw_prepare_upd (10);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE fdw_case_table SET "Col" = $1 WHERE "Col" IS NULL;
EXECUTE fdw_prepare_upd (99);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_sel AS
  SELECT * FROM "fdw_case_table" ORDER BY Col;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_sel AS
  SELECT * FROM "public".fdw_case_table ORDER BY "Col", col DESC;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE public.fdw_case_table SET Col = Col + $1;
EXECUTE fdw_prepare_upd (10);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE "public".FDW_CASE_TABLE SET "col" = "col" + $1 WHERE col > $2;
EXECUTE fdw_prepare_upd (100, 2000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE public."fdw_case_table" SET "Col" = "Col" + $1 WHERE "Col" < $2;
EXECUTE fdw_prepare_upd (10, 15);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE "public"."fdw_case_table" SET "col" = col + $1 WHERE "col" < $2;
EXECUTE fdw_prepare_upd (400, 2000);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE public.Fdw_Case_Table SET "col" = NULL WHERE "Col" = $1;
EXECUTE fdw_prepare_upd (16);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer) AS
  UPDATE Public.fdw_case_table SET "col" = "Col" * $1 WHERE Col IS NULL;
EXECUTE fdw_prepare_upd (10);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE PUBLIC.FDW_CASE_TABLE SET "Col" = Col / $1 WHERE "Col" = $2;
EXECUTE fdw_prepare_upd (100, 99);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_sel AS
  SELECT * FROM "public"."fdw_case_table" ORDER BY Col, col DESC;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_sel AS
  SELECT * FROM PUBLIC."fdw_case_table" ORDER BY "Col", col DESC;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM fdw_case_table WHERE col = $1;
EXECUTE fdw_prepare_del (160);
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM public.FDW_CASE_TABLE WHERE "col" >= $1;
EXECUTE fdw_prepare_del (2415);
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM "public".fdw_case_table WHERE Col <= $1;
EXECUTE fdw_prepare_del (140);
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM PUBLIC."fdw_case_table" WHERE "col" > $1;
EXECUTE fdw_prepare_del (2411);
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM "public"."fdw_case_table" WHERE "Col" > $1;
EXECUTE fdw_prepare_del (21);
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM Public.fdw_Case_table WHERE "Col" <> $1;
EXECUTE fdw_prepare_del (16);
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_del (integer) AS
  DELETE FROM PUBLIC.fdw_CASE_TABLE WHERE COL = $1;
EXECUTE fdw_prepare_del (1615);
DEALLOCATE fdw_prepare_del;

PREPARE fdw_prepare_sel AS
  SELECT * FROM "public".fdw_case_table ORDER BY col;
EXECUTE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');
