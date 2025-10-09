/* Test case: unhappy path - Case sensitivity */
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
INSERT INTO fdw_Case_Table (col) VALUES (1000);
INSERT INTO fdw_Case_table (col) VALUES (2000);
INSERT INTO fdw_CASE_table (col) VALUES (3000);
INSERT INTO fdw_CASE_TABLE (col) VALUES (4000);
INSERT INTO public.fdw_Case_Table (col) VALUES (5000);
INSERT INTO "Public".fdw_case_table (col) VALUES (6000);

INSERT INTO fdw_case_table (COL) VALUES (7000);
INSERT INTO fdw_case_table ("COL") VALUES (8000);
INSERT INTO fdw_case_table (col, "Col") VALUES (9000, 9);

UPDATE fdw_Case_Table SET col = 1000;
UPDATE fdw_Case_table SET col = 2000;
UPDATE fdw_CASE_table SET col = 3000;
UPDATE fdw_CASE_TABLE SET col = 4000;
UPDATE public.fdw_Case_Table SET col = 5000;
UPDATE "Public".fdw_case_table SET col = 6000;
UPDATE fdw_case_table SET COL = 100;
UPDATE fdw_case_table SET col = 100 WHERE COL > 5000;
UPDATE fdw_case_table SET col = 100 WHERE "COL" > 5000;

DELETE FROM fdw_Case_Table;
DELETE FROM fdw_Case_table;
DELETE FROM fdw_CASE_table;
DELETE FROM fdw_CASE_TABLE;
DELETE FROM public.fdw_Case_Table;
DELETE FROM "Public".fdw_case_table;
DELETE FROM fdw_case_table WHERE COL > 5000;
DELETE FROM fdw_case_table WHERE "COL" > 5000;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');

