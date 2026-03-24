--
-- Tests for common table expressions (WITH query, ... SELECT ...)
--

-- Basic WITH
WITH q1(x,y) AS (SELECT 1,2)
SELECT * FROM q1, q1 AS q2;

-- Multiple uses are evaluated only once
SELECT count(*) FROM (
  WITH q1(x) AS (SELECT random() FROM generate_series(1, 5))
    SELECT * FROM q1
  UNION
    SELECT * FROM q1
) ss;

-- WITH RECURSIVE

-- sum of 1..100
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;

WITH RECURSIVE t(n) AS (
    SELECT (VALUES(1))
UNION ALL
    SELECT n+1 FROM t WHERE n < 5
)
SELECT * FROM t;

-- UNION DISTINCT requires hashable type
WITH RECURSIVE t(n) AS (
    VALUES ('01'::varbit)
UNION
    SELECT n || '10'::varbit FROM t WHERE n < '100'::varbit
)
SELECT n FROM t;

-- recursive view
CREATE RECURSIVE VIEW nums (n) AS
    VALUES (1)
UNION ALL
    SELECT n+1 FROM nums WHERE n < 5;

SELECT * FROM nums;

CREATE OR REPLACE RECURSIVE VIEW nums (n) AS
    VALUES (1)
UNION ALL
    SELECT n+1 FROM nums WHERE n < 6;

SELECT * FROM nums;

-- This is an infinite loop with UNION ALL, but not with UNION
WITH RECURSIVE t(n) AS (
    SELECT 1
UNION
    SELECT 10-n FROM t)
SELECT * FROM t;

-- This'd be an infinite loop, but outside query reads only as much as needed
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t)
SELECT * FROM t LIMIT 10;

-- UNION case should have same property
WITH RECURSIVE t(n) AS (
    SELECT 1
UNION
    SELECT n+1 FROM t)
SELECT * FROM t LIMIT 10;

-- Test behavior with an unknown-type literal in the WITH
WITH q AS (SELECT 'foo' AS x)
SELECT x, pg_typeof(x) FROM q;

WITH RECURSIVE t(n) AS (
    SELECT 'foo'
UNION ALL
    SELECT n || ' bar' FROM t WHERE length(n) < 20
)
SELECT n, pg_typeof(n) FROM t;

-- In a perfect world, this would work and resolve the literal as int ...
-- but for now, we have to be content with resolving to text too soon.
WITH RECURSIVE t(n) AS (
    SELECT '7'
UNION ALL
    SELECT n+1 FROM t WHERE n < 10
)
SELECT n, pg_typeof(n) FROM t;

-- Deeply nested WITH caused a list-munging problem in v13
-- Detection of cross-references and self-references
WITH RECURSIVE w1(c1) AS
 (WITH w2(c2) AS
  (WITH w3(c3) AS
   (WITH w4(c4) AS
    (WITH w5(c5) AS
     (WITH RECURSIVE w6(c6) AS
      (WITH w6(c6) AS
       (WITH w8(c8) AS
        (SELECT 1)
        SELECT * FROM w8)
       SELECT * FROM w6)
      SELECT * FROM w6)
     SELECT * FROM w5)
    SELECT * FROM w4)
   SELECT * FROM w3)
  SELECT * FROM w2)
SELECT * FROM w1;
-- Detection of invalid self-references
WITH RECURSIVE outermost(x) AS (
 SELECT 1
 UNION (WITH innermost1 AS (
  SELECT 2
  UNION (WITH innermost2 AS (
   SELECT 3
   UNION (WITH innermost3 AS (
    SELECT 4
    UNION (WITH innermost4 AS (
     SELECT 5
     UNION (WITH innermost5 AS (
      SELECT 6
      UNION (WITH innermost6 AS
       (SELECT 7)
       SELECT * FROM innermost6))
      SELECT * FROM innermost5))
     SELECT * FROM innermost4))
    SELECT * FROM innermost3))
   SELECT * FROM innermost2))
  SELECT * FROM outermost
  UNION SELECT * FROM innermost1)
 )
 SELECT * FROM outermost ORDER BY 1;

--
-- Some examples with a tree
--
-- department structure represented here is as follows:
--
-- ROOT-+->A-+->B-+->C
--      |         |
--      |         +->D-+->F
--      +->E-+->G

SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_department(
        id INTEGER PRIMARY KEY,
        parent_department INTEGER,
        name VARCHAR
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_department (
        id INTEGER,
        parent_department INTEGER,
        name TEXT
) SERVER tsurugidb;

INSERT INTO tsurugifdw_department VALUES (0, NULL, 'ROOT');
INSERT INTO tsurugifdw_department VALUES (1, 0, 'A');
INSERT INTO tsurugifdw_department VALUES (2, 1, 'B');
INSERT INTO tsurugifdw_department VALUES (3, 2, 'C');
INSERT INTO tsurugifdw_department VALUES (4, 2, 'D');
INSERT INTO tsurugifdw_department VALUES (5, 0, 'E');
INSERT INTO tsurugifdw_department VALUES (6, 4, 'F');
INSERT INTO tsurugifdw_department VALUES (7, 5, 'G');

SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_int4_tbl (
        f1 int
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_int4_tbl (
  f1 int4
) SERVER tsurugidb;

INSERT INTO tsurugifdw_int4_tbl(f1) VALUES
  ('   0  '),
  ('123456     '),
  ('    -123456'),
  ('2147483647'),  -- largest and smallest values
  ('-2147483647');

SELECT * FROM tsurugifdw_int4_tbl;

SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_int8_tbl (
        q1 bigint, q2 bigint
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_int8_tbl (
  q1 int8, q2 int8
) SERVER tsurugidb;

INSERT INTO tsurugifdw_int8_tbl VALUES
  ('  123   ','  456'),
  ('123   ','4567890123456789'),
  ('4567890123456789','123'),
  (+4567890123456789,'4567890123456789'),
  ('+4567890123456789','-4567890123456789');

SELECT * FROM tsurugifdw_int8_tbl;

-- extract all departments under 'A'. Result should be A, B, C, D and F
WITH RECURSIVE subdepartment AS
(
	-- non recursive term
	SELECT name as root_name, * FROM tsurugifdw_department WHERE name = 'A'

	UNION ALL

	-- recursive term
	SELECT sd.root_name, d.* FROM tsurugifdw_department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY name;

-- extract all departments under 'A' with "level" number
WITH RECURSIVE subdepartment(level, id, parent_department, name) AS
(
	-- non recursive term
	SELECT 1, * FROM tsurugifdw_department WHERE name = 'A'

	UNION ALL

	-- recursive term
	SELECT sd.level + 1, d.* FROM tsurugifdw_department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY name;

-- extract all departments under 'A' with "level" number.
-- Only shows level 2 or more
WITH RECURSIVE subdepartment(level, id, parent_department, name) AS
(
	-- non recursive term
	SELECT 1, * FROM tsurugifdw_department WHERE name = 'A'

	UNION ALL

	-- recursive term
	SELECT sd.level + 1, d.* FROM tsurugifdw_department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment WHERE level >= 2 ORDER BY name;

-- "RECURSIVE" is ignored if the query has no self-reference
WITH RECURSIVE subdepartment AS
(
	-- note lack of recursive UNION structure
	SELECT * FROM tsurugifdw_department WHERE name = 'A'
)
SELECT * FROM subdepartment ORDER BY name;

-- inside subqueries
SELECT count(*) FROM (
    WITH RECURSIVE t(n) AS (
        SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 500
    )
    SELECT * FROM t) AS t WHERE n < (
        SELECT count(*) FROM (
            WITH RECURSIVE t(n) AS (
                   SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 100
                )
            SELECT * FROM t WHERE n < 50000
         ) AS t WHERE n < 100);

-- via a VIEW
CREATE TEMPORARY VIEW vsubdepartment AS
	WITH RECURSIVE subdepartment AS
	(
		 -- non recursive term
		SELECT * FROM tsurugifdw_department WHERE name = 'A'
		UNION ALL
		-- recursive term
		SELECT d.* FROM tsurugifdw_department AS d, subdepartment AS sd
			WHERE d.parent_department = sd.id
	)
	SELECT * FROM subdepartment;

SELECT * FROM vsubdepartment ORDER BY name;

-- Check reverse listing
SELECT pg_get_viewdef('vsubdepartment'::regclass);
SELECT pg_get_viewdef('vsubdepartment'::regclass, true);

-- Another reverse-listing example
CREATE VIEW sums_1_100 AS
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;

\d+ sums_1_100

-- corner case in which sub-WITH gets initialized first
with recursive q as (
      select * from tsurugifdw_department
    union all
      (with x as (select * from q)
       select * from x)
    )
select * from q limit 24;

with recursive q as (
      select * from tsurugifdw_department
    union all
      (with recursive x as (
           select * from tsurugifdw_department
         union all
           (select * from q union all select * from x)
        )
       select * from x)
    )
select * from q limit 32;

-- recursive term has sub-UNION
WITH RECURSIVE t(i,j) AS (
	VALUES (1,2)
	UNION ALL
	SELECT t2.i, t.j+1 FROM
		(SELECT 2 AS i UNION ALL SELECT 3 AS i) AS t2
		JOIN t ON (t2.i = t.i+1))

	SELECT * FROM t;

--
-- different tree example
--
SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_tree(
        id INTEGER PRIMARY KEY,
        parent_id INTEGER
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_tree (
    id INTEGER,
    parent_id INTEGER
) SERVER tsurugidb;

INSERT INTO tsurugifdw_tree
VALUES (1, NULL), (2, 1), (3,1), (4,2), (5,2), (6,2), (7,3), (8,3),
       (9,4), (10,4), (11,7), (12,7), (13,7), (14, 9), (15,11), (16,11);

--
-- get all paths from "second level" nodes to leaf nodes
--
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tsurugifdw_tree.id, t.path || tsurugifdw_tree.id
    FROM tsurugifdw_tree JOIN t ON (tsurugifdw_tree.parent_id = t.id)
)
SELECT t1.*, t2.* FROM t AS t1 JOIN t AS t2 ON
	(t1.path[1] = t2.path[1] AND
	array_upper(t1.path,1) = 1 AND
	array_upper(t2.path,1) > 1)
	ORDER BY t1.id, t2.id;

-- just count 'em
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tsurugifdw_tree.id, t.path || tsurugifdw_tree.id
    FROM tsurugifdw_tree JOIN t ON (tsurugifdw_tree.parent_id = t.id)
)
SELECT t1.id, count(t2.*) FROM t AS t1 JOIN t AS t2 ON
	(t1.path[1] = t2.path[1] AND
	array_upper(t1.path,1) = 1 AND
	array_upper(t2.path,1) > 1)
	GROUP BY t1.id
	ORDER BY t1.id;

-- this variant tickled a whole-row-variable bug in 8.4devel
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tsurugifdw_tree.id, t.path || tsurugifdw_tree.id
    FROM tsurugifdw_tree JOIN t ON (tsurugifdw_tree.parent_id = t.id)
)
SELECT t1.id, t2.path, t2 FROM t AS t1 JOIN t AS t2 ON
(t1.id=t2.id);

SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_duplicates (a INT NOT NULL)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_duplicates (a INT) SERVER tsurugidb;
INSERT INTO tsurugifdw_duplicates VALUES(1), (1);

-- Try out a recursive UNION case where the non-recursive part's table slot
-- uses TTSOpsBufferHeapTuple and contains duplicate rows.
WITH RECURSIVE cte (a) as (
	SELECT a FROM tsurugifdw_duplicates
	UNION
	SELECT a FROM cte
)
SELECT a FROM cte;

-- SEARCH clause

SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_graph0 ( f int, t int, label varchar )', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_graph0 ( f int, t int, label text ) SERVER tsurugidb;

insert into tsurugifdw_graph0 values
	(1, 2, 'arc 1 -> 2'),
	(1, 3, 'arc 1 -> 3'),
	(2, 3, 'arc 2 -> 3'),
	(1, 4, 'arc 1 -> 4'),
	(4, 5, 'arc 4 -> 5');

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select * from search_graph order by seq;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union distinct
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select * from search_graph order by seq;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search breadth first by f, t set seq
select * from search_graph order by seq;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union distinct
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search breadth first by f, t set seq
select * from search_graph order by seq;

with recursive test as (
  select 1 as x
  union all
  select x + 1
  from test
) search depth first by x set y
select * from test limit 5;

with recursive test as (
  select 1 as x
  union all
  select x + 1
  from test
) search breadth first by x set y
select * from test limit 5;

-- various syntax errors
with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by foo, tar set seq
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set label
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t, f set seq
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select * from search_graph order by seq;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	(select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t)
) search depth first by f, t set seq
select * from search_graph order by seq;

-- check that we distinguish same CTE name used at different levels
-- (this case could be supported, perhaps, but it isn't today)
with recursive x(col) as (
	select 1
	union
	(with x as (select * from x)
	 select * from x)
) search depth first by col set seq
select * from x;

-- test ruleutils and view expansion
create temp view v_search as
with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph0 g
	union all
	select g.*
	from tsurugifdw_graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select f, t, label from search_graph;

select pg_get_viewdef('v_search');

select * from v_search;

--
-- test cycle detection
--
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_graph ( f int, t int, label varchar )', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_graph ( f int, t int, label text ) SERVER tsurugidb;

insert into tsurugifdw_graph values
	(1, 2, 'arc 1 -> 2'),
	(1, 3, 'arc 1 -> 3'),
	(2, 3, 'arc 2 -> 3'),
	(1, 4, 'arc 1 -> 4'),
	(4, 5, 'arc 4 -> 5'),
	(5, 1, 'arc 5 -> 1');

with recursive search_graph(f, t, label, is_cycle, path) as (
	select *, false, array[row(g.f, g.t)] from tsurugifdw_graph g
	union all
	select g.*, row(g.f, g.t) = any(path), path || row(g.f, g.t)
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t and not is_cycle
)
select * from search_graph ORDER BY f, t;

-- UNION DISTINCT exercises row type hashing support
with recursive search_graph(f, t, label, is_cycle, path) as (
	select *, false, array[row(g.f, g.t)] from tsurugifdw_graph g
	union distinct
	select g.*, row(g.f, g.t) = any(path), path || row(g.f, g.t)
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t and not is_cycle
)
select * from search_graph ORDER BY f, t;

-- ordering by the path column has same effect as SEARCH DEPTH FIRST
with recursive search_graph(f, t, label, is_cycle, path) as (
	select *, false, array[row(g.f, g.t)] from tsurugifdw_graph g
	union all
	select g.*, row(g.f, g.t) = any(path), path || row(g.f, g.t)
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t and not is_cycle
)
select * from search_graph order by path;

-- CYCLE clause

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle using path
select * from search_graph ORDER BY f, t;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union distinct
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to 'Y' default 'N' using path
select * from search_graph ORDER BY f, t;

with recursive test as (
  select 0 as x
  union all
  select (x + 1) % 10
  from test
) cycle x set is_cycle using path
select * from test;

with recursive test as (
  select 0 as x
  union all
  select (x + 1) % 10
  from test
    where not is_cycle  -- redundant, but legal
) cycle x set is_cycle using path
select * from test;

-- multiple CTEs
with recursive
graph(f, t, label) as (
  values (1, 2, 'arc 1 -> 2'),
         (1, 3, 'arc 1 -> 3'),
         (2, 3, 'arc 2 -> 3'),
         (1, 4, 'arc 1 -> 4'),
         (4, 5, 'arc 4 -> 5'),
         (5, 1, 'arc 5 -> 1')
),
search_graph(f, t, label) as (
        select * from tsurugifdw_graph g
        union all
        select g.*
        from tsurugifdw_graph g, search_graph sg
        where g.f = sg.t
) cycle f, t set is_cycle to true default false using path
select f, t, label from search_graph;

-- star expansion
with recursive a as (
	select 1 as b
	union all
	select * from a
) cycle b set c using p
select * from a;

-- search+cycle
with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
  cycle f, t set is_cycle using path
select * from search_graph ORDER BY f, t;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) search breadth first by f, t set seq
  cycle f, t set is_cycle using path
select * from search_graph ORDER BY f, t;

-- various syntax errors
with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle foo, tar set is_cycle using path
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to true default 55 using path
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to point '(1,1)' default point '(0,0)' using path
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set label to true default false using path
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to true default false using label
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set foo to true default false using foo
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t, f set is_cycle to true default false using path
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set foo
  cycle f, t set foo to true default false using path
select * from search_graph;

with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set foo
  cycle f, t set is_cycle to true default false using foo
select * from search_graph;

-- test ruleutils and view expansion
create temp view v_cycle1 as
with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle using path
select f, t, label from search_graph;

create temp view v_cycle2 as
with recursive search_graph(f, t, label) as (
	select * from tsurugifdw_graph g
	union all
	select g.*
	from tsurugifdw_graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to 'Y' default 'N' using path
select f, t, label from search_graph;

select pg_get_viewdef('v_cycle1');
select pg_get_viewdef('v_cycle2');

select * from v_cycle1 order by f, t;
select * from v_cycle2 order by f, t;

--
-- test multiple WITH queries
--
WITH RECURSIVE
  y (id) AS (VALUES (1)),
  x (id) AS (SELECT * FROM y UNION ALL SELECT id+1 FROM x WHERE id < 5)
SELECT * FROM x;

-- forward reference OK
WITH RECURSIVE
    x(id) AS (SELECT * FROM y UNION ALL SELECT id+1 FROM x WHERE id < 5),
    y(id) AS (values (1))
 SELECT * FROM x;

WITH RECURSIVE
   x(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 5),
   y(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM y WHERE id < 10)
 SELECT y.*, x.* FROM y LEFT JOIN x USING (id);

WITH RECURSIVE
   x(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 5),
   y(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 10)
 SELECT y.*, x.* FROM y LEFT JOIN x USING (id);

WITH RECURSIVE
   x(id) AS
     (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 3 ),
   y(id) AS
     (SELECT * FROM x UNION ALL SELECT * FROM x),
   z(id) AS
     (SELECT * FROM x UNION ALL SELECT id+1 FROM z WHERE id < 10)
 SELECT * FROM z;

WITH RECURSIVE
   x(id) AS
     (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 3 ),
   y(id) AS
     (SELECT * FROM x UNION ALL SELECT * FROM x),
   z(id) AS
     (SELECT * FROM y UNION ALL SELECT id+1 FROM z WHERE id < 10)
 SELECT * FROM z;

--
-- Test WITH attached to a data-modifying statement
--

SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_y( a INTEGER )', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_y ( a INTEGER ) SERVER tsurugidb;
ALTER FOREIGN TABLE tsurugifdw_y ALTER COLUMN a OPTIONS (key 'true');
INSERT INTO tsurugifdw_y SELECT generate_series(1, 10);

WITH t AS (
	SELECT a FROM tsurugifdw_y
)
INSERT INTO tsurugifdw_y
SELECT a+20 FROM t;

SELECT * FROM tsurugifdw_y;

WITH t AS (
	SELECT a FROM tsurugifdw_y
)
UPDATE tsurugifdw_y SET a = tsurugifdw_y.a-10 FROM t WHERE tsurugifdw_y.a > 20 AND t.a = tsurugifdw_y.a;

SELECT * FROM tsurugifdw_y;

WITH RECURSIVE t(a) AS (
	SELECT 11
	UNION ALL
	SELECT a+1 FROM t WHERE a < 50
)
DELETE FROM tsurugifdw_y USING t WHERE t.a = tsurugifdw_y.a;

SELECT * FROM tsurugifdw_y;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_y', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_y;

--
-- error cases
--

WITH x(n, b) AS (SELECT 1)
SELECT * FROM tsurugifdw_x;

-- INTERSECT
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 INTERSECT SELECT n+1 FROM tsurugifdw_x)
	SELECT * FROM tsurugifdw_x;

WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 INTERSECT ALL SELECT n+1 FROM tsurugifdw_x)
	SELECT * FROM tsurugifdw_x;

-- EXCEPT
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 EXCEPT SELECT n+1 FROM tsurugifdw_x)
	SELECT * FROM tsurugifdw_x;

WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 EXCEPT ALL SELECT n+1 FROM tsurugifdw_x)
	SELECT * FROM tsurugifdw_x;

-- no non-recursive term
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT n FROM tsurugifdw_x)
	SELECT * FROM tsurugifdw_x;

-- recursive term in the left hand side (strictly speaking, should allow this)
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT n FROM tsurugifdw_x UNION ALL SELECT 1)
	SELECT * FROM tsurugifdw_x;

-- allow this, because we historically have
WITH RECURSIVE tsurugifdw_x(n) AS (
  WITH x1 AS (SELECT 1 AS n)
    SELECT 0
    UNION
    SELECT * FROM x1)
	SELECT * FROM tsurugifdw_x;

-- but this should be rejected
WITH RECURSIVE tsurugifdw_x(n) AS (
  WITH x1 AS (SELECT 1 FROM tsurugifdw_x)
    SELECT 0
    UNION
    SELECT * FROM x1)
	SELECT * FROM tsurugifdw_x;

-- and this too
WITH RECURSIVE tsurugifdw_x(n) AS (
  (WITH x1 AS (SELECT 1 FROM tsurugifdw_x) SELECT * FROM x1)
  UNION
  SELECT 0)
	SELECT * FROM tsurugifdw_x;

-- and this
WITH RECURSIVE tsurugifdw_x(n) AS (
  SELECT 0 UNION SELECT 1
  ORDER BY (SELECT n FROM tsurugifdw_x))
	SELECT * FROM tsurugifdw_x;

-- and this
WITH RECURSIVE tsurugifdw_x(n) AS (
  WITH sub_cte AS (SELECT * FROM tsurugifdw_x)
  DELETE FROM tsurugifdw_graph RETURNING f)
	SELECT * FROM tsurugifdw_x;


SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_y( a INTEGER )', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_y ( a INTEGER ) SERVER tsurugidb;
INSERT INTO tsurugifdw_y SELECT generate_series(1, 10);

-- LEFT JOIN

WITH RECURSIVE tsurugifdw_x(n) AS (SELECT a FROM tsurugifdw_y WHERE a = 1
	UNION ALL
	SELECT x.n+1 FROM tsurugifdw_y LEFT JOIN tsurugifdw_x ON tsurugifdw_x.n = tsurugifdw_y.a WHERE n < 10)
SELECT * FROM tsurugifdw_x;

-- RIGHT JOIN
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT tsurugifdw_x.n+1 FROM tsurugifdw_x RIGHT JOIN tsurugifdw_y ON tsurugifdw_x.n = tsurugifdw_y.a WHERE n < 10)
SELECT * FROM tsurugifdw_x;

-- FULL JOIN
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT tsurugifdw_x.n+1 FROM tsurugifdw_x FULL JOIN tsurugifdw_y ON tsurugifdw_x.n = tsurugifdw_y.a WHERE n < 10)
SELECT * FROM tsurugifdw_x;

-- subquery
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM tsurugifdw_x
                          WHERE n IN (SELECT * FROM tsurugifdw_x))
  SELECT * FROM tsurugifdw_x;

-- aggregate functions
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 UNION ALL SELECT count(*) FROM tsurugifdw_x)
  SELECT * FROM tsurugifdw_x;

WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 UNION ALL SELECT sum(n) FROM tsurugifdw_x)
  SELECT * FROM tsurugifdw_x;

-- ORDER BY
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM tsurugifdw_x ORDER BY 1)
  SELECT * FROM tsurugifdw_x;

-- LIMIT/OFFSET
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM tsurugifdw_x LIMIT 10 OFFSET 1)
  SELECT * FROM tsurugifdw_x;

-- FOR UPDATE
WITH RECURSIVE tsurugifdw_x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM tsurugifdw_x FOR UPDATE)
  SELECT * FROM tsurugifdw_x;

-- target list has a recursive query name
WITH RECURSIVE tsurugifdw_x(id) AS (values (1)
    UNION ALL
    SELECT (SELECT * FROM tsurugifdw_x) FROM tsurugifdw_x WHERE id < 5
) SELECT * FROM tsurugifdw_x;

-- mutual recursive query (not implemented)
WITH RECURSIVE
  tsurugifdw_x (id) AS (SELECT 1 UNION ALL SELECT id+1 FROM tsurugifdw_y WHERE id < 5),
  tsurugifdw_y (id) AS (SELECT 1 UNION ALL SELECT id+1 FROM tsurugifdw_x WHERE id < 5)
SELECT * FROM tsurugifdw_x;

-- non-linear recursion is not allowed
WITH RECURSIVE tsurugifdw_foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM tsurugifdw_foo WHERE i < 10
          UNION ALL
       SELECT i+1 FROM tsurugifdw_foo WHERE i < 5)
) SELECT * FROM tsurugifdw_foo;

WITH RECURSIVE tsurugifdw_foo(i) AS
    (values (1)
    UNION ALL
	   SELECT * FROM
       (SELECT i+1 FROM tsurugifdw_foo WHERE i < 10
          UNION ALL
       SELECT i+1 FROM tsurugifdw_foo WHERE i < 5) AS t
) SELECT * FROM tsurugifdw_foo;

WITH RECURSIVE tsurugifdw_foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM tsurugifdw_foo WHERE i < 10
          EXCEPT
       SELECT i+1 FROM tsurugifdw_foo WHERE i < 5)
) SELECT * FROM tsurugifdw_foo;

WITH RECURSIVE tsurugifdw_foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM tsurugifdw_foo WHERE i < 10
          INTERSECT
       SELECT i+1 FROM tsurugifdw_foo WHERE i < 5)
) SELECT * FROM tsurugifdw_foo;

-- Wrong type induced from non-recursive term
WITH RECURSIVE tsurugifdw_foo(i) AS
   (SELECT i FROM (VALUES(1),(2)) t(i)
   UNION ALL
   SELECT (i+1)::numeric(10,0) FROM tsurugifdw_foo WHERE i < 10)
SELECT * FROM tsurugifdw_foo;

-- rejects different typmod, too (should we allow this?)
WITH RECURSIVE tsurugifdw_foo(i) AS
   (SELECT i::numeric(3,0) FROM (VALUES(1),(2)) t(i)
   UNION ALL
   SELECT (i+1)::numeric(10,0) FROM tsurugifdw_foo WHERE i < 10)
SELECT * FROM tsurugifdw_foo;

-- disallow OLD/NEW reference in CTE
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_x (n integer)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_x (n integer) SERVER tsurugidb;
CREATE RULE r2 AS ON UPDATE TO tsurugifdw_x DO INSTEAD
    WITH t AS (SELECT OLD.*) UPDATE tsurugifdw_y SET a = t.n FROM t;

--
-- test for bug #4902
--
with cte(tsurugifdw_foo) as ( values(42) ) values((select tsurugifdw_foo from cte));
with cte(tsurugifdw_foo) as ( select 42 ) select * from ((select tsurugifdw_foo from cte)) q;

-- test CTE referencing an outer-level variable (to see that changed-parameter
-- signaling still works properly after fixing this bug)
select ( with cte(tsurugifdw_foo) as ( values(f1) )
         select (select tsurugifdw_foo from cte) )
from tsurugifdw_int4_tbl;

select ( with cte(tsurugifdw_foo) as ( values(f1) )
          values((select tsurugifdw_foo from cte)) )
from tsurugifdw_int4_tbl;

--
-- test for bug #19055: interaction of WITH with aggregates
--
-- For now, we just throw an error if there's a use of a CTE below the
-- semantic level that the SQL standard assigns to the aggregate.
-- It's not entirely clear what we could do instead that doesn't risk
-- breaking more things than it fixes.
select f1, (with cte1(x,y) as (select 1,2)
            select count((select i4.f1 from cte1))) as ss
from tsurugifdw_int4_tbl i4;

--
-- test for bug #19106: interaction of WITH with aggregates
--
-- the initial fix for #19055 was too aggressive and broke this case
with a as ( select id from (values (1), (2)) as v(id) ),
     b as ( select max((select sum(id) from a)) as agg )
select agg from b;

--
-- test for nested-recursive-WITH bug
--
WITH RECURSIVE t(j) AS (
    WITH RECURSIVE s(i) AS (
        VALUES (1)
        UNION ALL
        SELECT i+1 FROM s WHERE i < 10
    )
    SELECT i FROM s
    UNION ALL
    SELECT j+1 FROM t WHERE j < 10
)
SELECT * FROM t;

--
-- test WITH attached to intermediate-level set operation
--

WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM innermost
         UNION SELECT 3)
)
SELECT * FROM outermost ORDER BY 1;

WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost  -- fail
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost ORDER BY 1;

WITH RECURSIVE outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost ORDER BY 1;

WITH RECURSIVE outermost(x) AS (
  WITH innermost as (SELECT 2 FROM outermost) -- fail
    SELECT * FROM innermost
    UNION SELECT * from outermost
)
SELECT * FROM outermost ORDER BY 1;

--
-- This test will fail with the old implementation of PARAM_EXEC parameter
-- assignment, because the "q1" Var passed down to A's targetlist subselect
-- looks exactly like the "A.id" Var passed down to C's subselect, causing
-- the old code to give them the same runtime PARAM_EXEC slot.  But the
-- lifespans of the two parameters overlap, thanks to B also reading A.
--

with
A as ( select q2 as id, (select q1) as x from tsurugifdw_int8_tbl ),
B as ( select id, row_number() over (partition by id) as r from A ),
C as ( select A.id, array(select B.id from B where B.id = A.id) from A )
select * from C;

--
-- Test CTEs read in non-initialization orders
--

WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION ALL (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;

WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;

--
-- Data-modifying statements in WITH
--

-- INSERT ... RETURNING
WITH t AS (
    INSERT INTO tsurugifdw_y
    VALUES
        (11),
        (12),
        (13),
        (14),
        (15),
        (16),
        (17),
        (18),
        (19),
        (20)
    RETURNING *
)
SELECT * FROM t;

SELECT * FROM tsurugifdw_y;

-- UPDATE ... RETURNING
WITH t AS (
    UPDATE tsurugifdw_y
    SET a=a+1
    RETURNING *
)
SELECT * FROM t;

SELECT * FROM tsurugifdw_y;

-- DELETE ... RETURNING
WITH t AS (
    DELETE FROM tsurugifdw_y
    WHERE a <= 10
    RETURNING *
)
SELECT * FROM t;

SELECT * FROM tsurugifdw_y;

-- forward reference
WITH RECURSIVE t AS (
	INSERT INTO tsurugifdw_y
		SELECT a+5 FROM t2 WHERE a > 5
	RETURNING *
), t2 AS (
	UPDATE tsurugifdw_y SET a=a-11 RETURNING *
)
SELECT * FROM t
UNION ALL
SELECT * FROM t2;

SELECT * FROM tsurugifdw_y;

-- check merging of outer CTE with CTE in a rule action
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_bug6051 (i int)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_bug6051 (i int) SERVER tsurugidb;
INSERT INTO tsurugifdw_bug6051
  SELECT i FROM generate_series(1,3) AS t(i);

SELECT * FROM tsurugifdw_bug6051;

WITH t1 AS ( DELETE FROM tsurugifdw_bug6051 RETURNING * )
INSERT INTO tsurugifdw_bug6051 SELECT * FROM t1;

SELECT * FROM tsurugifdw_bug6051;

SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_bug6051_2 (i int)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_bug6051_2 (i int) SERVER tsurugidb;

CREATE RULE bug6051_ins AS ON INSERT TO tsurugifdw_bug6051 DO INSTEAD
 INSERT INTO tsurugifdw_bug6051_2
 VALUES(NEW.i);

WITH t1 AS ( DELETE FROM tsurugifdw_bug6051 RETURNING * )
INSERT INTO tsurugifdw_bug6051 SELECT * FROM t1;

SELECT * FROM tsurugifdw_bug6051;
SELECT * FROM tsurugifdw_bug6051_2;

-- check INSERT ... SELECT rule actions are disallowed on commands
-- that have modifyingCTEs
CREATE OR REPLACE RULE bug6051_ins AS ON INSERT TO tsurugifdw_bug6051 DO INSTEAD
 INSERT INTO tsurugifdw_bug6051_2
 SELECT NEW.i;

WITH t1 AS ( DELETE FROM tsurugifdw_bug6051 RETURNING * )
INSERT INTO tsurugifdw_bug6051 SELECT * FROM t1;

-- silly example to verify that hasModifyingCTE flag is propagated
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_bug6051_3 (a int)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_bug6051_3 (a int) SERVER tsurugidb;
INSERT INTO tsurugifdw_bug6051_3
  SELECT a FROM generate_series(11,13) AS a;

CREATE RULE bug6051_3_ins AS ON INSERT TO tsurugifdw_bug6051_3 DO INSTEAD
  SELECT i FROM tsurugifdw_bug6051_2;

BEGIN; SET LOCAL debug_parallel_query = on;

WITH t1 AS ( DELETE FROM tsurugifdw_bug6051_3 RETURNING * )
  INSERT INTO tsurugifdw_bug6051_3 SELECT * FROM t1;

COMMIT;

SELECT * FROM tsurugifdw_bug6051_3;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_bug6051', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_bug6051;
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_bug6051_2', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_bug6051_2;
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_bug6051_3', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_bug6051_3;

-- check that recursive CTE processing doesn't rewrite a CTE more than once
-- (must not try to expand GENERATED ALWAYS IDENTITY columns more than once)
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_id_alw1 (i int GENERATED ALWAYS AS IDENTITY)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_id_alw1 (i int) SERVER tsurugidb;

SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_id_alw2 (i int GENERATED ALWAYS AS IDENTITY)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_id_alw2 (i int) SERVER tsurugidb;
CREATE TEMP VIEW id_alw2_view AS SELECT * FROM tsurugifdw_id_alw2;

SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_id_alw3 (i int GENERATED ALWAYS AS IDENTITY)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_id_alw3 (i int) SERVER tsurugidb;
CREATE RULE id_alw3_ins AS ON INSERT TO tsurugifdw_id_alw3 DO INSTEAD
  WITH t1 AS (INSERT INTO tsurugifdw_id_alw1 DEFAULT VALUES RETURNING i)
    INSERT INTO id_alw2_view DEFAULT VALUES RETURNING i;
CREATE TEMP VIEW id_alw3_view AS SELECT * FROM tsurugifdw_id_alw3;

SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_id_alw4 (i int GENERATED ALWAYS AS IDENTITY)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_id_alw4 (i int) SERVER tsurugidb;

WITH t4 AS (INSERT INTO tsurugifdw_id_alw4 DEFAULT VALUES RETURNING i)
  INSERT INTO id_alw3_view DEFAULT VALUES RETURNING i;

SELECT * from tsurugifdw_id_alw1;
SELECT * from tsurugifdw_id_alw2;
SELECT * from tsurugifdw_id_alw3;
SELECT * from tsurugifdw_id_alw4;

DROP VIEW id_alw2_view;
DROP VIEW id_alw3_view;
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_id_alw1', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_id_alw1;
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_id_alw2', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_id_alw2;
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_id_alw3', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_id_alw3;
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_id_alw4', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_id_alw4;

-- check case where CTE reference is removed due to optimization
SELECT q1 FROM
(
  WITH t_cte AS (SELECT * FROM tsurugifdw_int8_tbl t)
  SELECT q1, (SELECT q2 FROM t_cte WHERE t_cte.q1 = i8.q1) AS t_sub
  FROM tsurugifdw_int8_tbl i8
) ss;

SELECT q1 FROM
(
  WITH t_cte AS MATERIALIZED (SELECT * FROM tsurugifdw_int8_tbl t)
  SELECT q1, (SELECT q2 FROM t_cte WHERE t_cte.q1 = i8.q1) AS t_sub
  FROM tsurugifdw_int8_tbl i8
) ss;

-- a truly recursive CTE in the same list
WITH RECURSIVE t(a) AS (
	SELECT 0
		UNION ALL
	SELECT a+1 FROM t WHERE a+1 < 5
), t2 as (
	INSERT INTO tsurugifdw_y
		SELECT * FROM t RETURNING *
)
SELECT * FROM t2 JOIN tsurugifdw_y USING (a) ORDER BY a;

SELECT * FROM tsurugifdw_y;

-- data-modifying WITH in a modifying statement
WITH t AS (
    DELETE FROM tsurugifdw_y
    WHERE a <= 10
    RETURNING *
)
INSERT INTO tsurugifdw_y SELECT -a FROM t RETURNING *;

SELECT * FROM tsurugifdw_y;

-- check that WITH query is run to completion even if outer query isn't
WITH t AS (
    UPDATE tsurugifdw_y SET a = a * 100 RETURNING *
)
SELECT * FROM t LIMIT 10;

SELECT * FROM tsurugifdw_y;

-- data-modifying WITH containing INSERT...ON CONFLICT DO UPDATE
SELECT tg_execute_ddl(
  'CREATE TABLE tsurugifdw_withz ( k INTEGER PRIMARY KEY, v VARCHAR )',
  'tsurugidb'
);
CREATE FOREIGN TABLE tsurugifdw_withz ( k INTEGER, v TEXT ) SERVER tsurugidb;
INSERT INTO tsurugifdw_withz
SELECT i AS k, (i || ' v')::text AS v
FROM generate_series(1, 16, 3) i;

WITH t AS (
    INSERT INTO tsurugifdw_withz SELECT i, 'insert'
    FROM generate_series(0, 16) i
    ON CONFLICT (k) DO UPDATE SET v = tsurugifdw_withz.v || ', now update'
    RETURNING *
)
SELECT * FROM t JOIN tsurugifdw_y ON t.k = tsurugifdw_y.a ORDER BY a, k;

-- Test EXCLUDED.* reference within CTE
WITH aa AS (
    INSERT INTO tsurugifdw_withz VALUES(1, 5) ON CONFLICT (k) DO UPDATE SET v = EXCLUDED.v
    WHERE tsurugifdw_withz.k != EXCLUDED.k
    RETURNING *
)
SELECT * FROM aa;

-- New query/snapshot demonstrates side-effects of previous query.
SELECT * FROM tsurugifdw_withz ORDER BY k;

--
-- Ensure subqueries within the update clause work, even if they
-- reference outside values
--
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO tsurugifdw_withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 1 LIMIT 1);
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO tsurugifdw_withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = ' update' WHERE tsurugifdw_withz.k = (SELECT a FROM aa);
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO tsurugifdw_withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 1 LIMIT 1);
WITH aa AS (SELECT 'a' a, 'b' b UNION ALL SELECT 'a' a, 'b' b)
INSERT INTO tsurugifdw_withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 'a' LIMIT 1);
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO tsurugifdw_withz VALUES(1, (SELECT b || ' insert' FROM aa WHERE a = 1 ))
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 1 LIMIT 1);

-- Update a row more than once, in different parts of a wCTE. That is
-- an allowed, presumably very rare, edge case, but since it was
-- broken in the past, having a test seems worthwhile.
WITH simpletup AS (
  SELECT 2 k, 'Green' v),
upsert_cte AS (
  INSERT INTO tsurugifdw_withz VALUES(2, 'Blue') ON CONFLICT (k) DO
    UPDATE SET (k, v) = (SELECT k, v FROM simpletup WHERE simpletup.k = tsurugifdw_withz.k)
    RETURNING k, v)
INSERT INTO tsurugifdw_withz VALUES(2, 'Red') ON CONFLICT (k) DO
UPDATE SET (k, v) = (SELECT k, v FROM upsert_cte WHERE upsert_cte.k = tsurugifdw_withz.k)
RETURNING k, v;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_withz', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_withz;

-- WITH referenced by MERGE statement
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_m ( k INTEGER PRIMARY KEY, v VARCHAR )', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_m ( k INTEGER, v TEXT ) SERVER tsurugidb;
INSERT INTO tsurugifdw_m
SELECT i AS k, (i || ' v')::text AS v
FROM generate_series(1, 16, 3) i;

WITH RECURSIVE cte_basic AS (SELECT 1 a, 'cte_basic val' b)
MERGE INTO tsurugifdw_m USING (select 0 k, 'merge source SubPlan' v) o ON tsurugifdw_m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_basic WHERE cte_basic.a = tsurugifdw_m.k LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);

-- Basic:
WITH cte_basic AS MATERIALIZED (SELECT 1 a, 'cte_basic val' b)
MERGE INTO tsurugifdw_m USING (select 0 k, 'merge source SubPlan' v offset 0) o ON tsurugifdw_m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_basic WHERE cte_basic.a = tsurugifdw_m.k LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);
-- Examine
SELECT * FROM tsurugifdw_m where k = 0;

-- InitPlan
WITH cte_init AS MATERIALIZED (SELECT 1 a, 'cte_init val' b)
MERGE INTO tsurugifdw_m USING (select 1 k, 'merge source InitPlan' v offset 0) o ON tsurugifdw_m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_init WHERE a = 1 LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);
-- Examine
SELECT * FROM tsurugifdw_m where k = 1;

-- MERGE source comes from CTE:
WITH merge_source_cte AS MATERIALIZED (SELECT 15 a, 'merge_source_cte val' b)
MERGE INTO tsurugifdw_m USING (select * from merge_source_cte) o ON tsurugifdw_m.k=o.a
WHEN MATCHED THEN UPDATE SET v = (SELECT b || merge_source_cte.*::text || ' merge update' FROM merge_source_cte WHERE a = 15)
WHEN NOT MATCHED THEN INSERT VALUES(o.a, o.b || (SELECT merge_source_cte.*::text || ' merge insert' FROM merge_source_cte));
-- Examine
SELECT * FROM tsurugifdw_m where k = 15;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_m', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_m;

-- check that run to completion happens in proper ordering

DELETE FROM tsurugifdw_y;
INSERT INTO tsurugifdw_y SELECT generate_series(1, 3);
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_yy ( a INTEGER )', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_yy ( a INTEGER ) SERVER tsurugidb;

WITH RECURSIVE t1 AS (
  INSERT INTO tsurugifdw_y SELECT * FROM tsurugifdw_y RETURNING *
), t2 AS (
  INSERT INTO tsurugifdw_yy SELECT * FROM t1 RETURNING *
)
SELECT 1;

SELECT * FROM tsurugifdw_y;
SELECT * FROM tsurugifdw_yy;

WITH RECURSIVE t1 AS (
  INSERT INTO tsurugifdw_yy SELECT * FROM t2 RETURNING *
), t2 AS (
  INSERT INTO tsurugifdw_y SELECT * FROM tsurugifdw_y RETURNING *
)
SELECT 1;

SELECT * FROM tsurugifdw_y;
SELECT * FROM tsurugifdw_yy;

-- triggers

DELETE FROM tsurugifdw_y;
INSERT INTO tsurugifdw_y SELECT generate_series(1, 10);

CREATE FUNCTION y_trigger() RETURNS trigger AS $$
begin
  raise notice 'y_trigger: a = %', new.a;
  return new;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER y_trig BEFORE INSERT ON tsurugifdw_y FOR EACH ROW
    EXECUTE PROCEDURE y_trigger();

WITH t AS (
    INSERT INTO tsurugifdw_y
    VALUES
        (21),
        (22),
        (23)
    RETURNING *
)
SELECT * FROM t;

SELECT * FROM tsurugifdw_y;

DROP TRIGGER y_trig ON tsurugifdw_y;

CREATE TRIGGER y_trig AFTER INSERT ON tsurugifdw_y FOR EACH ROW
    EXECUTE PROCEDURE y_trigger();

WITH t AS (
    INSERT INTO tsurugifdw_y
    VALUES
        (31),
        (32),
        (33)
    RETURNING *
)
SELECT * FROM t LIMIT 1;

SELECT * FROM tsurugifdw_y;

DROP TRIGGER y_trig ON tsurugifdw_y;

CREATE OR REPLACE FUNCTION y_trigger() RETURNS trigger AS $$
begin
  raise notice 'y_trigger';
  return null;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER y_trig AFTER INSERT ON tsurugifdw_y FOR EACH STATEMENT
    EXECUTE PROCEDURE y_trigger();

WITH t AS (
    INSERT INTO tsurugifdw_y
    VALUES
        (41),
        (42),
        (43)
    RETURNING *
)
SELECT * FROM t;

SELECT * FROM tsurugifdw_y;

DROP TRIGGER y_trig ON tsurugifdw_y;
DROP FUNCTION y_trigger();

-- error cases

-- data-modifying WITH tries to use its own output
WITH RECURSIVE t AS (
	INSERT INTO tsurugifdw_y
		SELECT * FROM t
)
VALUES(FALSE);

-- no RETURNING in a referenced data-modifying WITH
WITH t AS (
	INSERT INTO tsurugifdw_y VALUES(0)
)
SELECT * FROM t;

-- RETURNING tries to return its own output
WITH RECURSIVE t(action, a) AS (
	MERGE INTO tsurugifdw_y USING (VALUES (11)) v(a) ON tsurugifdw_y.a = v.a
		WHEN NOT MATCHED THEN INSERT VALUES (v.a)
		RETURNING merge_action(), (SELECT a FROM t)
)
SELECT * FROM t;

-- data-modifying WITH allowed only at the top level
SELECT * FROM (
	WITH t AS (UPDATE tsurugifdw_y SET a=a+1 RETURNING *)
	SELECT * FROM t
) ss;

-- most variants of rules aren't allowed
CREATE RULE y_rule AS ON INSERT TO tsurugifdw_y WHERE a=0 DO INSTEAD DELETE FROM tsurugifdw_y;
WITH t AS (
	INSERT INTO tsurugifdw_y VALUES(0)
)
VALUES(FALSE);
CREATE OR REPLACE RULE y_rule AS ON INSERT TO tsurugifdw_y DO INSTEAD NOTHING;
WITH t AS (
	INSERT INTO tsurugifdw_y VALUES(0)
)
VALUES(FALSE);
CREATE OR REPLACE RULE y_rule AS ON INSERT TO tsurugifdw_y DO INSTEAD NOTIFY foo;
WITH t AS (
	INSERT INTO tsurugifdw_y VALUES(0)
)
VALUES(FALSE);
CREATE OR REPLACE RULE y_rule AS ON INSERT TO tsurugifdw_y DO ALSO NOTIFY foo;
WITH t AS (
	INSERT INTO tsurugifdw_y VALUES(0)
)
VALUES(FALSE);
CREATE OR REPLACE RULE y_rule AS ON INSERT TO tsurugifdw_y
  DO INSTEAD (NOTIFY foo; NOTIFY bar);
WITH t AS (
	INSERT INTO tsurugifdw_y VALUES(0)
)
VALUES(FALSE);

-- check that parser lookahead for WITH doesn't cause any odd behavior
create table tsurugifdw_foo (with baz);  -- fail, WITH is a reserved word
create table tsurugifdw_foo (with ordinality);  -- fail, WITH is a reserved word
with ordinality as (select 1 as x) select * from ordinality;

-- check sane response to attempt to modify CTE relation
WITH with_test AS (SELECT 42) INSERT INTO with_test VALUES (1);

-- check response to attempt to modify table with same name as a CTE (perhaps
-- surprisingly it works, because CTEs don't hide tables from data-modifying
-- statements)
SELECT tg_execute_ddl('CREATE TABLE tsurugifdw_with_test (i int)', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_with_test (i int) SERVER tsurugidb;
with tsurugifdw_with_test as (select 42) insert into tsurugifdw_with_test select * from tsurugifdw_with_test;
select * from tsurugifdw_with_test;
SELECT tg_execute_ddl('DROP TABLE tsurugifdw_with_test', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_with_test;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_department', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_department;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_tree', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_tree;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_duplicates', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_duplicates;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_graph0', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_graph0;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_graph', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_graph;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_y', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_y;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_x', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_x;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_yy', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_yy;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_int4_tbl', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_int4_tbl;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_int8_tbl', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_int8_tbl;
