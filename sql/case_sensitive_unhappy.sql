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
INSERT INTO fdw_case_table ("COL") VALUES (1000);
INSERT INTO fdw_case_table (col, Col) VALUES (2000, 2);
INSERT INTO "Public".fdw_case_table (col) VALUES (3000);

UPDATE "Public".fdw_case_table SET col = 4000;
UPDATE fdw_case_table SET col = 100 WHERE "COL" > 5000;

DELETE FROM "Public".fdw_case_table;
DELETE FROM fdw_case_table WHERE "COL" > 6000;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_case_table;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_case_table', 'tsurugidb');

