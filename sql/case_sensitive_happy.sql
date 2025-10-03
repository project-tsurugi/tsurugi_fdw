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
INSERT INTO fdw_case_table VALUES (1000, 1);
INSERT INTO public.fdw_case_table (col, "Col") VALUES (2000, 2);
INSERT INTO "public".fdw_case_table (col) VALUES (3000);
INSERT INTO "public"."fdw_case_table" (Col) VALUES (4);
INSERT INTO Public.fdw_case_table ("col") VALUES (5000);
INSERT INTO PUBLIC.fdw_case_table ("Col") VALUES (6);
SELECT * FROM public.fdw_case_table ORDER BY col, Col DESC;

UPDATE fdw_case_table SET col = col + 100;
UPDATE public.fdw_case_table SET Col = Col + 10;
UPDATE "public".fdw_case_table SET "col" = "col" + 100 WHERE col > 5000;
UPDATE public."fdw_case_table" SET "Col" = "Col" + 100 WHERE Col > 12;
UPDATE "public"."fdw_case_table" SET "col" = col + 100 WHERE "col" > 3000;
UPDATE Public.fdw_case_table SET "col" = Col * 10 WHERE col IS NULL;
UPDATE PUBLIC.fdw_case_table SET "Col" = col / 100 WHERE "Col" IS NULL;
SELECT * FROM fdw_case_table ORDER BY col;
SELECT * FROM Public.fdw_case_table ORDER BY Col;

DELETE FROM fdw_case_table WHERE col = 1100;
DELETE FROM public.fdw_case_table WHERE "col" > 5000;
DELETE FROM "public".fdw_case_table WHERE Col > 114;
DELETE FROM public."fdw_case_table" WHERE "col" >= 3200;
DELETE FROM "public"."fdw_case_table" WHERE "Col" > 100;
DELETE FROM Public.fdw_case_table WHERE col <> 2100;
DELETE FROM PUBLIC.fdw_case_table WHERE Col <> 12;
SELECT * FROM Public.fdw_case_table;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');
