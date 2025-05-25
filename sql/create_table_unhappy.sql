/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE t1_create_table (
        c1 INTEGER NOT NULL PRIMARY KEY
    )
');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE t1_create_table (
    c1 INTEGER NOT NULL
) SERVER tsurugidb;

/* DML */
INSERT INTO public.t1_create_table (c1) VALUES (1000);
INSERT INTO "puBlIc"."t1_create_table" (c1) VALUES (999); -- error
UPDATE "PUBLIC"."t1_create_table" SET c1 = c1+100; -- error
DELETE FROM "Public"."t1_create_table" WHERE c1 > 1000; -- error

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE t1_create_table;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE t1_create_table');
