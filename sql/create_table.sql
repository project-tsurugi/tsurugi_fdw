
/* DML */
SELECT * FROM t1_create_table;
INSERT INTO t1_create_table (c1) VALUES (1);
SELECT * FROM t1_create_table;

SELECT * FROM t2_create_table;
INSERT INTO t2_create_table (c1, c2, c3) VALUES (1, 100, 1.1);
INSERT INTO t2_create_table (c1, c2, c3) VALUES (2, 200, 2.2);
SELECT * FROM t2_create_table;

SELECT * FROM t1_create_table;
INSERT INTO t1_create_table (c1) VALUES (10);
INSERT INTO t1_create_table (c1) VALUES (100);
SELECT * FROM t1_create_table;

SELECT * FROM t2_create_table;
UPDATE t2_create_table SET c2 = c2+10;
UPDATE t2_create_table SET c3 = c3+1.1 WHERE c2 = 110;
SELECT * FROM t2_create_table;

SELECT * FROM t1_create_table;
DELETE FROM t1_create_table WHERE c1 = 10;
SELECT * FROM t1_create_table;

/* Fix tsurugi-issues#568 */
INSERT INTO public.t1_create_table (c1) VALUES (1000);
INSERT INTO PuBlIc.t1_create_table (c1) VALUES (2000);
INSERT INTO PUBLIC.t1_create_table (c1) VALUES (3000);
INSERT INTO "public"."t1_create_table" (c1) VALUES (4000);

SELECT * FROM public.t1_create_table;

UPDATE public.t1_create_table SET c1 = c1+100;
UPDATE PuBlIc.t1_create_table SET c1 = c1+100 WHERE c1 > 1000;
UPDATE public.t1_create_table SET c1 = c1+100 WHERE c1 > 2000;
UPDATE "public"."t1_create_table" SET c1 = c1+100 WHERE c1 > 3000;

SELECT * FROM "public"."t1_create_table";

DELETE FROM public.t1_create_table WHERE c1 = 200;
DELETE FROM "public"."t1_create_table" WHERE c1 > 1000;

SELECT * FROM Public.t1_create_table;

INSERT INTO "puBlIc"."t1_create_table" (c1) VALUES (999); -- error
UPDATE "PUBLIC"."t1_create_table" SET c1 = c1+100; -- error
DELETE FROM "Public"."t1_create_table" WHERE c1 > 1000; -- error
