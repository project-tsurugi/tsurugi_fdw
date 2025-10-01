/* Test case: unhappy path - Data Definition Language */

-- EXTENSION
--- Test setup: DDL of the PostgreSQL
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl

--- Test case: table exists before
CREATE TABLE tsurugifdw_regressiontest(id INT);
CREATE EXTENSION tsurugi_fdw;
\dx tsurugi_fdw
DROP TABLE tsurugifdw_regressiontest;

--- Test case: table does not exist
CREATE EXTENSION tsurugi_fdw;
\dx tsurugi_fdw

--- Test case: DDL restriction - tsurugi_fdw is enabled
---- Test setup: DDL of the PostgreSQL
CREATE SERVER IF NOT EXISTS tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE tsurugifdw_regressiontest(id INT) SERVER tsurugidb;
SELECT EXISTS (
  SELECT 1 FROM pg_class
    WHERE relname = 'tsurugifdw_regressiontest' AND relkind = 'f'
);

---- CREATE TABLE
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

---- CREATE TABLE AS
CREATE TABLE t1_create_table_as AS SELECT * FROM tsurugifdw_regressiontest;
SELECT * FROM t1_create_table_as;
SELECT * INTO t2_create_table_as FROM tsurugifdw_regressiontest;
SELECT * FROM t2_create_table_as;

--- Test case: DDL restriction - tsurugi_fdw is disabled
---- Test setup: DDL of the PostgreSQL
DROP EXTENSION tsurugi_fdw CASCADE;

---- CREATE TABLE
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

---- CREATE TABLE AS
CREATE TABLE t1_create_table_as AS SELECT * FROM t0_create_table;
SELECT * FROM t1_create_table_as;
SELECT * INTO t2_create_table_as FROM t0_create_table;
SELECT * FROM t2_create_table_as;

--- Test teardown: DDL of the PostgreSQL
\c contrib_regression
DROP DATABASE contrib_regression_ddl;

-- SERVER OPTIONS
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_ddl_table (c INTEGER)
', 'tsurugidb');

--- Test setup: DDL of the PostgreSQL
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

--- Test case: option name validation
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (invalid_option 'value');

--- Test case: required options validation
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', port '12345');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
ALTER SERVER tsurugidb OPTIONS (endpoint 'stream');
ALTER SERVER tsurugidb OPTIONS (endpoint 'stream', address '127.0.0.1');
ALTER SERVER tsurugidb OPTIONS (endpoint 'stream', port '12345');
DROP SERVER tsurugidb;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1', port '12345');
ALTER SERVER tsurugidb OPTIONS (DROP address);
ALTER SERVER tsurugidb OPTIONS (DROP port);
ALTER SERVER tsurugidb OPTIONS (DROP address, DROP port);
DROP SERVER tsurugidb;

--- Test case: endpoint option validation
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'invalid_value');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'IPC');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'STREAM');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint ' ipc');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'ipc ');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint '');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint ' ');

--- Test case: dbname option validation
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'ipc', dbname '');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'ipc', dbname ' ');

--- Test case: address option validation
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '', port '12345');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address ' ', port '12345');

--- Test case: port option validation
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1', port '');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1', port ' ');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1', port '0');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1', port 'abc');
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1', port '-1');

--- Test case: dbname option value is incorrect
---- Test setup: DDL of the PostgreSQL
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

---- correct -> incorrect
ALTER SERVER tsurugidb OPTIONS (ADD dbname 'incorrect_dbname');
INSERT INTO fdw_ddl_table VALUES (1);
UPDATE fdw_ddl_table SET c = c + 10;
DELETE FROM fdw_ddl_table;
SELECT * FROM fdw_ddl_table ORDER BY c;

---- incorrect -> correct
ALTER SERVER tsurugidb OPTIONS (DROP dbname);
INSERT INTO fdw_ddl_table VALUES (2);
SELECT * FROM fdw_ddl_table ORDER BY c;
UPDATE fdw_ddl_table SET c = c + 20;
SELECT * FROM fdw_ddl_table ORDER BY c;
DELETE FROM fdw_ddl_table;
SELECT * FROM fdw_ddl_table ORDER BY c;

---- Test setup: PREPARE statements
PREPARE fdw_prepare_ins(integer) AS INSERT INTO fdw_ddl_table VALUES ($1);
PREPARE fdw_prepare_upd(integer) AS UPDATE fdw_ddl_table SET c = c + $1;
PREPARE fdw_prepare_del AS DELETE FROM fdw_ddl_table;
PREPARE fdw_prepare_sel AS SELECT * FROM fdw_ddl_table ORDER BY c;

---- correct -> incorrect (preparation)
ALTER SERVER tsurugidb OPTIONS (ADD dbname 'incorrect_dbname');
EXECUTE fdw_prepare_ins(1);
EXECUTE fdw_prepare_upd(10);
EXECUTE fdw_prepare_del;
EXECUTE fdw_prepare_sel;

---- incorrect -> correct (preparation)
ALTER SERVER tsurugidb OPTIONS (SET dbname 'tsurugi');
-- EXECUTE fdw_prepare_ins(2);
-- EXECUTE fdw_prepare_sel;
-- EXECUTE fdw_prepare_upd(20);
-- EXECUTE fdw_prepare_sel;
-- EXECUTE fdw_prepare_del;
-- EXECUTE fdw_prepare_sel;

---- Test teardown: PREPARE statements
DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_del;

---- Test setup: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_ddl_table;
DROP SERVER tsurugidb;

--- Operations during a transaction
---- Test re-setup: DDL of the PostgreSQL
\c contrib_regression
DROP DATABASE contrib_regression_ddl;

CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl

CREATE EXTENSION tsurugi_fdw;
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

---- Test case: Alter server (incorrect server) - Connected outside a transaction
SELECT * FROM fdw_ddl_table ORDER BY c;
BEGIN;
ALTER SERVER tsurugidb OPTIONS (dbname 'incorrect');
\des+
SELECT * FROM fdw_ddl_table ORDER BY c;
END;
\des+
SELECT * FROM fdw_ddl_table ORDER BY c;

---- Test case: Alter server (correct server) - Connected in a transaction
SELECT * FROM fdw_ddl_table ORDER BY c;
ALTER SERVER tsurugidb OPTIONS (dbname 'incorrect');
\des+
BEGIN;
INSERT INTO fdw_ddl_table VALUES (1), (2);
END;

BEGIN;
ALTER SERVER tsurugidb OPTIONS (SET dbname 'tsurugi');
-- INSERT INTO fdw_ddl_table VALUES (1), (2);
-- SELECT * FROM fdw_ddl_table ORDER BY c;
END;

---- Test re-setup: DDL of the PostgreSQL
\c contrib_regression
DROP DATABASE contrib_regression_ddl;

CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl

CREATE EXTENSION tsurugi_fdw;
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

---- Test case: ALTER SERVER during operations
BEGIN;
INSERT INTO fdw_ddl_table VALUES (3), (4);
ALTER SERVER tsurugidb OPTIONS (dbname 'incorrect-1');
\des+
UPDATE fdw_ddl_table SET c=c+10;
ALTER SERVER tsurugidb OPTIONS (SET dbname 'incorrect-2');
\des+
DELETE FROM fdw_ddl_table WHERE c=14;
ALTER SERVER tsurugidb OPTIONS (SET dbname 'incorrect-3');
\des+
SELECT * FROM fdw_ddl_table ORDER BY c;
ALTER SERVER tsurugidb OPTIONS (SET dbname 'incorrect-4');
\des+
END;

BEGIN;
SELECT * FROM fdw_ddl_table ORDER BY c;
END;

ALTER SERVER tsurugidb OPTIONS (DROP dbname);
\des+

BEGIN;
SELECT * FROM fdw_ddl_table ORDER BY c;
DELETE FROM fdw_ddl_table;
END;

--- Test re-setup: DDL of the PostgreSQL
\c contrib_regression
DROP DATABASE contrib_regression_ddl;

CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl

CREATE EXTENSION tsurugi_fdw;
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

--- Test case: ALTER SERVER during operations
INSERT INTO fdw_ddl_table VALUES (1), (2);

ALTER SERVER tsurugidb OPTIONS (dbname 'incorrect');
SELECT * FROM fdw_ddl_table ORDER BY c;

ALTER SERVER tsurugidb OPTIONS (SET dbname 'tsurugi');
-- UPDATE fdw_ddl_table SET c=c+10;

ALTER SERVER tsurugidb OPTIONS (DROP dbname);
SELECT * FROM fdw_ddl_table ORDER BY c;

ALTER SERVER tsurugidb OPTIONS (dbname 'incorrect');
DELETE FROM fdw_ddl_table;

ALTER SERVER tsurugidb OPTIONS (SET dbname 'tsurugi');
-- DELETE FROM fdw_ddl_table;
-- SELECT * FROM fdw_ddl_table ORDER BY c;

--- Test teardown: DDL of the PostgreSQL
\c contrib_regression
DROP DATABASE contrib_regression_ddl;

--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_ddl_table', 'tsurugidb');
