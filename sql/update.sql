--
-- UPDATE syntax tests
--

SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_update_test (
        a   INT DEFAULT 10,
        b   INT,
        c   VARCHAR
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_update_test (
    a   INT DEFAULT 10,
    b   INT,
    c   VARCHAR
) SERVER tsurugidb;
ALTER FOREIGN TABLE tsurugifdw_update_test
  ALTER COLUMN a OPTIONS (ADD key 'true');
ALTER FOREIGN TABLE tsurugifdw_update_test
  ALTER COLUMN b OPTIONS (ADD key 'true');

SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_upsert_test (
        a   INT PRIMARY KEY,
        b   VARCHAR
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_upsert_test (
    a   INT,
    b   VARCHAR
) SERVER tsurugidb;
ALTER FOREIGN TABLE tsurugifdw_upsert_test
  ALTER COLUMN a OPTIONS (ADD key 'true');
ALTER FOREIGN TABLE tsurugifdw_upsert_test
  ALTER COLUMN b OPTIONS (ADD key 'true');

INSERT INTO tsurugifdw_update_test VALUES (5, 10, 'foo');
INSERT INTO tsurugifdw_update_test(b, a) VALUES (15, 10);

SELECT * FROM tsurugifdw_update_test;

UPDATE tsurugifdw_update_test SET a = DEFAULT, b = DEFAULT;

SELECT * FROM tsurugifdw_update_test;

-- aliases for the UPDATE target table
UPDATE tsurugifdw_update_test AS t SET b = 10 WHERE t.a = 10;

SELECT * FROM tsurugifdw_update_test;

UPDATE tsurugifdw_update_test t SET b = t.b + 10 WHERE t.a = 10;

SELECT * FROM tsurugifdw_update_test;

-- error, you're not supposed to qualify the target column
UPDATE tsurugifdw_update_test t SET t.b = t.b + 10 WHERE t.a = 10;

--
-- Test VALUES in FROM
--

UPDATE tsurugifdw_update_test SET a=v.i FROM (VALUES(100, 20)) AS v(i, j)
  WHERE tsurugifdw_update_test.b = v.j;

SELECT * FROM tsurugifdw_update_test;

-- fail, wrong data type:
UPDATE tsurugifdw_update_test SET a = v.* FROM (VALUES(100, 20)) AS v(i, j)
  WHERE tsurugifdw_update_test.b = v.j;

--
-- Test multiple-set-clause syntax
--

INSERT INTO tsurugifdw_update_test SELECT a,b+1,c FROM tsurugifdw_update_test;
SELECT * FROM tsurugifdw_update_test;

UPDATE tsurugifdw_update_test SET (c,b,a) = ('bugle', b+11, DEFAULT) WHERE c = 'foo';
SELECT * FROM tsurugifdw_update_test ORDER BY b;
UPDATE tsurugifdw_update_test SET (c,b) = ('car', a+b), a = a + 1 WHERE a = 10;
SELECT * FROM tsurugifdw_update_test ORDER BY b;
-- fail, multi assignment to same column:
UPDATE tsurugifdw_update_test SET (c,b) = ('car', a+b), b = a + 1 WHERE a = 10;

-- uncorrelated sub-select:
UPDATE tsurugifdw_update_test
  SET (b,a) = (select a,b from tsurugifdw_update_test where b = 41 and c = 'car')
  WHERE a = 100 AND b = 20;
SELECT * FROM tsurugifdw_update_test ORDER BY b;
-- correlated sub-select:
-- fail, Tsurugi does not support "IS DISTINCT FROM"
UPDATE tsurugifdw_update_test o
  SET (b,a) = (select a+1,b from tsurugifdw_update_test i
               where i.a=o.a and i.b=o.b and i.c is not distinct from o.c);
-- fail, multiple rows supplied:
UPDATE tsurugifdw_update_test SET (b,a) = (select a+1,b from tsurugifdw_update_test);
-- set to null if no rows supplied:
UPDATE tsurugifdw_update_test SET (b,a) = (select a+1,b from tsurugifdw_update_test where a = 1000)
  WHERE a = 11;
SELECT * FROM tsurugifdw_update_test ORDER BY a;
-- *-expansion should work in this context:
UPDATE tsurugifdw_update_test SET (a,b) = ROW(v.*) FROM (VALUES(21, 100)) AS v(i, j)
  WHERE tsurugifdw_update_test.a = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
UPDATE tsurugifdw_update_test SET (a,b) = (v.*) FROM (VALUES(21, 101)) AS v(i, j)
  WHERE tsurugifdw_update_test.a = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
UPDATE tsurugifdw_update_test AS t SET b = tsurugifdw_update_test.b + 10 WHERE t.a = 10;

-- Make sure that we can update to a TOASTed value.
UPDATE tsurugifdw_update_test SET c = repeat('x', 10000) WHERE c = 'car';
SELECT a, b, char_length(c) FROM tsurugifdw_update_test ORDER BY a;

-- Check multi-assignment with a Result node to handle a one-time filter.
DELETE FROM tsurugifdw_update_test;

INSERT INTO tsurugifdw_update_test(a,b,c) VALUES
  (NULL, NULL, NULL),
  (21, 100, NULL),
  (41, 12, repeat('x',10000)),
  (42, 12, repeat('x',10000));
SELECT a, b, char_length(c) FROM tsurugifdw_update_test ORDER BY a;
UPDATE tsurugifdw_update_test t
  SET (a, b) = (SELECT b, a FROM tsurugifdw_update_test s WHERE s.a = t.a)
  WHERE CURRENT_USER = SESSION_USER;
SELECT a, b, char_length(c) FROM tsurugifdw_update_test ORDER BY a;

-- Test ON CONFLICT DO UPDATE
-- fail, Tsurugi does not support "ON CONFLICT"

INSERT INTO tsurugifdw_upsert_test VALUES(1, 'Boo'), (3, 'Zoo');
-- uncorrelated  sub-select:
WITH aaa AS (SELECT 1 AS a, 'Foo' AS b) INSERT INTO tsurugifdw_upsert_test
  VALUES (1, 'Bar') ON CONFLICT(a)
  DO UPDATE SET (b, a) = (SELECT b, a FROM aaa) RETURNING *;
-- correlated sub-select:
INSERT INTO tsurugifdw_upsert_test VALUES (1, 'Baz'), (3, 'Zaz') ON CONFLICT(a)
  DO UPDATE SET (b, a) = (SELECT b || ', Correlated', a from tsurugifdw_upsert_test i WHERE i.a = tsurugifdw_upsert_test.a)
  RETURNING *;
-- correlated sub-select (EXCLUDED.* alias):
INSERT INTO tsurugifdw_upsert_test VALUES (1, 'Bat'), (3, 'Zot') ON CONFLICT(a)
  DO UPDATE SET (b, a) = (SELECT b || ', Excluded', a from tsurugifdw_upsert_test i WHERE i.a = excluded.a)
  RETURNING *;

-- ON CONFLICT using system attributes in RETURNING, testing both the
-- inserting and updating paths. See bug report at:
-- https://www.postgresql.org/message-id/73436355-6432-49B1-92ED-1FE4F7E7E100%40finefun.com.au
INSERT INTO tsurugifdw_upsert_test VALUES (2, 'Beeble') ON CONFLICT(a)
  DO UPDATE SET (b, a) = (SELECT b || ', Excluded', a from tsurugifdw_upsert_test i WHERE i.a = excluded.a)
  RETURNING tableoid::regclass, xmin = pg_current_xact_id()::xid AS xmin_correct, xmax = 0 AS xmax_correct;
-- currently xmax is set after a conflict - that's probably not good,
-- but it seems worthwhile to have to be explicit if that changes.
INSERT INTO tsurugifdw_upsert_test VALUES (2, 'Brox') ON CONFLICT(a)
  DO UPDATE SET (b, a) = (SELECT b || ', Excluded', a from tsurugifdw_upsert_test i WHERE i.a = excluded.a)
  RETURNING tableoid::regclass, xmin = pg_current_xact_id()::xid AS xmin_correct, xmax = pg_current_xact_id()::xid AS xmax_correct;

SELECT tg_execute_ddl('
    DROP TABLE tsurugifdw_update_test', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_update_test;
SELECT tg_execute_ddl('
    DROP TABLE tsurugifdw_upsert_test', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_upsert_test;

---------------------------
-- UPDATE with row movement
---------------------------

SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_range_parted (
        a varchar,
        b bigint,
        c numeric,
        d int,
        e varchar
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_range_parted (
	a text,
	b bigint,
	c numeric,
	d int,
	e varchar
) SERVER tsurugidb;
ALTER FOREIGN TABLE tsurugifdw_range_parted
  ALTER COLUMN a OPTIONS (ADD key 'true');
INSERT INTO tsurugifdw_range_parted(a,b,c,d,e) VALUES
  ('k4', 4, 150, 1, 'row_b4'),
  ('k5', 5, 110, 1, 'row_b5');

-- Common table needed for multiple test scenarios.
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_mintab(c1 int)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_mintab(c1 int) SERVER tsurugidb;
INSERT into tsurugifdw_mintab VALUES (120);

-- update partition key using updatable view.
CREATE VIEW upview AS SELECT * FROM tsurugifdw_range_parted WHERE (select c > c1 FROM tsurugifdw_mintab) WITH CHECK OPTION;
-- ok
UPDATE upview set c = 199 WHERE b = 4;
-- fail, check option violation
UPDATE upview set c = 120 WHERE b = 4;
-- fail, row movement with check option violation
UPDATE upview set a = 'b', b = 15, c = 120 WHERE b = 4;
-- ok, row movement, check option passes
UPDATE upview set a = 'b', b = 15 WHERE b = 4;

SELECT * FROM tsurugifdw_range_parted;

-- cleanup
DROP VIEW upview;

CREATE OR REPLACE FUNCTION trans_updatetrigfunc()
RETURNS trigger LANGUAGE plpgsql AS
$$
BEGIN
  RAISE NOTICE 'trigger=%, old=%, new=%', TG_NAME, OLD, NEW;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trans_updatetrig
AFTER UPDATE ON tsurugifdw_range_parted
FOR EACH ROW
EXECUTE FUNCTION trans_updatetrigfunc();

UPDATE tsurugifdw_range_parted set c = (case when c = 96 then 110 else c + 1 end ) WHERE a = 'b' and b > 10 and c >= 96;
SELECT * FROM tsurugifdw_range_parted;

DROP TRIGGER trans_updatetrig ON tsurugifdw_range_parted;

-- Cleanup: tsurugifdw_range_parted no longer needed.
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_range_parted', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_range_parted;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_mintab', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_mintab;
