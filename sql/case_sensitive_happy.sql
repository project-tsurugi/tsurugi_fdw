/* Test case: happy path - Case sensitivity */
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
/* Fix tsurugi-issues#568 */
INSERT INTO fdw_case_table VALUES (1001, 1);
INSERT INTO fdw_case_table (col, "Col") VALUES (1002, 2);
INSERT INTO fdw_Case_Table (COL) VALUES (1003);
INSERT INTO fdw_Case_table ("Col") VALUES (4);
INSERT INTO fdw_case_table ("col") VALUES (1005);
INSERT INTO fdw_CASE_table ("Col", col) VALUES (6, 1006);
INSERT INTO fdw_CASE_TABLE (cOL) VALUES (1007);
SELECT * FROM fdw_case_table ORDER BY Col, col;
SELECT * FROM FDW_CASE_TABLE ORDER BY "Col", col;

INSERT INTO public.fdw_case_table (col, "Col") VALUES (2001, 1);
INSERT INTO public.fdw_Case_Table (col) VALUES (2002);
INSERT INTO PUBLIC.fdw_case_table ("col") VALUES (2003);
INSERT INTO Public.fdw_case_table ("Col") VALUES (4);
INSERT INTO "public".fdw_case_table (col) VALUES (2005);
INSERT INTO public."fdw_case_table" ("Col", col) VALUES (6, 2006);
INSERT INTO "public"."fdw_case_table" (Col) VALUES (2007);
SELECT * FROM public.fdw_case_table ORDER BY Col DESC, col DESC;
SELECT * FROM PUBLIC.fdw_case_table ORDER BY "Col" DESC, col DESC;

UPDATE fdw_case_table SET col = col + 100;
UPDATE fdw_Case_Table SET COL = "col" + 100;
UPDATE FDW_CASE_TABLE SET "col" = COL + 100 WHERE COL > 2000;
UPDATE fdw_case_table SET "Col" = "Col" + 10 WHERE Col IS NOT NULL;
UPDATE fdw_case_table SET "Col" = 99 WHERE "Col" IS NULL;
SELECT * FROM "fdw_case_table" ORDER BY Col;
SELECT * FROM "public".fdw_case_table ORDER BY "Col", col DESC;

UPDATE public.fdw_case_table SET Col = Col + 10;
UPDATE "public".FDW_CASE_TABLE SET "col" = "col" + 100 WHERE col > 2000;
UPDATE public."fdw_case_table" SET "Col" = "Col" + 10 WHERE "Col" < 15;
UPDATE "public"."fdw_case_table" SET "col" = col + 400 WHERE "col" < 2000;
UPDATE public.Fdw_Case_Table SET "col" = NULL WHERE "Col" = 16;
UPDATE Public.fdw_case_table SET "col" = "Col" * 10 WHERE Col IS NULL;
UPDATE PUBLIC.FDW_CASE_TABLE SET "Col" = Col / 100 WHERE "Col" = 99;
SELECT * FROM "public"."fdw_case_table" ORDER BY Col, col DESC;
SELECT * FROM PUBLIC."fdw_case_table" ORDER BY "Col", col DESC;

DELETE FROM fdw_case_table WHERE col = 160;
DELETE FROM public.FDW_CASE_TABLE WHERE "col" >= 2415;
DELETE FROM "public".fdw_case_table WHERE Col <= 140;
DELETE FROM PUBLIC."fdw_case_table" WHERE "col" > 2411;
DELETE FROM "public"."fdw_case_table" WHERE "Col" > 21;
DELETE FROM Public.fdw_Case_table WHERE "Col" <> 16;
DELETE FROM PUBLIC.fdw_CASE_TABLE WHERE COL = 1615;
SELECT * FROM "public".fdw_case_table ORDER BY col;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');
