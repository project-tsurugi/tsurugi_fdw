CREATE DATABASE contrib_regression2;
\c contrib_regression2

CREATE TABLE tsurugifdw_regressiontest(id INT);
CREATE EXTENSION tsurugi_fdw;
\dx tsurugi_fdw
DROP TABLE tsurugifdw_regressiontest;

CREATE EXTENSION postgres_fdw;
\dx postgres_fdw
CREATE SERVER IF NOT EXISTS postgresdb FOREIGN DATA WRAPPER postgres_fdw;
CREATE FOREIGN TABLE postgresfdw_regressiontest(id INT) SERVER postgresdb;
CREATE EXTENSION tsurugi_fdw;
\dx tsurugi_fdw
DROP FOREIGN TABLE postgresfdw_regressiontest;

DROP EXTENSION postgres_fdw CASCADE;

CREATE TABLE tsurugifdw_regressiontest(id INT);
CREATE EXTENSION postgres_fdw;
\dx postgres_fdw
DROP TABLE tsurugifdw_regressiontest;
DROP EXTENSION postgres_fdw CASCADE;

CREATE EXTENSION tsurugi_fdw;
\dx tsurugi_fdw
CREATE SERVER IF NOT EXISTS tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;

CREATE FOREIGN TABLE tsurugifdw_regressiontest(id INT) SERVER tsurugidb;
SELECT EXISTS (
  SELECT 1
  FROM pg_class
  WHERE relname = 'tsurugifdw_regressiontest'
  AND relkind = 'f'
);

CREATE EXTENSION postgres_fdw;
\dx postgres_fdw
CREATE SERVER IF NOT EXISTS postgresdb FOREIGN DATA WRAPPER postgres_fdw;

-- error (CREATE TABLE)
CREATE TABLE t0_create_table(c1 INTEGER NOT NULL);
SELECT * FROM t0_create_table;
CREATE TABLE IF NOT EXISTS mytable1 (id INT);
SELECT * FROM mytable1;
CREATE TABLE mytable2 (LIKE t0_create_table);
SELECT * FROM mytable2;
CREATE TABLE mytable3 (INHERITS t0_create_table);
SELECT * FROM mytable3;
CREATE TABLE mytable4 (id INT) PARTITION BY LIST (id);
SELECT * FROM mytable4;
CREATE TABLE mytable5 (id INT) USING heap;
SELECT * FROM mytable5;
CREATE TABLE mytable6 (id INT) WITH (fillfactor = 70);
SELECT * FROM mytable6;
CREATE UNLOGGED TABLE unlogged_table(id INT);
SELECT * FROM unlogged_table;
CREATE TEMPORARY TABLE temporary_table (id INT);
SELECT * FROM temporary_table;
CREATE LOCAL TEMPORARY TABLE temporary_table1 (id INT);
SELECT * FROM temporary_table1;
CREATE TEMP TABLE temp_table (id iNT);
SELECT * FROM temp_table;
CREATE LOCAL TEMP TABLE temp_table1 (id iNT);
SELECT * FROM temp_table1;

-- error (CREATE TABLE AS)
CREATE TABLE t1_create_table_as AS SELECT * FROM tsurugifdw_regressiontest;
SELECT * FROM t1_create_table_as;
SELECT * INTO t2_create_table_as FROM tsurugifdw_regressiontest;
SELECT * FROM t2_create_table_as;

-- error (CREATE FOREIGN TABLE)
CREATE FOREIGN TABLE foreign_table (
    id INT,
    name TEXT,
    value NUMERIC
) SERVER postgresdb;
SELECT EXISTS (
  SELECT 1
  FROM pg_class
  WHERE relname = 'foreign_table'
  AND relkind = 'f'
);
CREATE FOREIGN TABLE IF NOT EXISTS foreign_table (
    id INT,
    name TEXT,
    value NUMERIC
) SERVER postgresdb;
SELECT EXISTS (
  SELECT 1
  FROM pg_class
  WHERE relname = 'foreign_table'
  AND relkind = 'f'
);

DROP EXTENSION tsurugi_fdw CASCADE;

-- Success (CREATE TABLE)
CREATE TABLE t0_create_table(c1 INTEGER NOT NULL);
SELECT * FROM t0_create_table;
CREATE TABLE IF NOT EXISTS mytable1 (id INT);
SELECT * FROM mytable1;
CREATE TABLE mytable2 (LIKE t0_create_table);
SELECT * FROM mytable2;
CREATE TABLE mytable3 (INHERITS t0_create_table);
SELECT * FROM mytable3;
CREATE TABLE mytable4 (id INT) PARTITION BY LIST (id);
SELECT * FROM mytable4;
CREATE TABLE mytable5 (id INT) USING heap;
SELECT * FROM mytable5;
CREATE TABLE mytable6 (id INT) WITH (fillfactor = 70);
SELECT * FROM mytable6;
CREATE UNLOGGED TABLE unlogged_table(id INT);
SELECT * FROM unlogged_table;
CREATE TEMPORARY TABLE temporary_table (id INT);
SELECT * FROM temporary_table;
CREATE LOCAL TEMPORARY TABLE temporary_table1 (id INT);
SELECT * FROM temporary_table1;
CREATE TEMP TABLE temp_table (id iNT);
SELECT * FROM temp_table;
CREATE LOCAL TEMP TABLE temp_table1 (id iNT);
SELECT * FROM temp_table1;

-- Success (CREATE TABLE AS)
CREATE TABLE t1_create_table_as AS SELECT * FROM t0_create_table;
SELECT * FROM t1_create_table_as;
SELECT * INTO t2_create_table_as FROM t0_create_table;
SELECT * FROM t2_create_table_as;


-- Success (CREATE FOREIGN TABLE)
CREATE FOREIGN TABLE foreign_table (
    id INT,
    name TEXT,
    value NUMERIC
) SERVER postgresdb;
SELECT EXISTS (
  SELECT 1
  FROM pg_class
  WHERE relname = 'foreign_table'
  AND relkind = 'f'
);
CREATE FOREIGN TABLE IF NOT EXISTS foreign_table (
    id INT,
    name TEXT,
    value NUMERIC
) SERVER postgresdb;
SELECT EXISTS (
  SELECT 1
  FROM pg_class
  WHERE relname = 'foreign_table'
  AND relkind = 'f'
);

\c contrib_regression
DROP DATABASE contrib_regression2;
