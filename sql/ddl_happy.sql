/* Test case: happy path - Data Definition Language */

-- SERVER OPTIONS
--- Test setup: DDL of the PostgreSQL
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

--- Test case: CREATE SERVER: defaults
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
\des+ tsurugidb
DROP SERVER tsurugidb;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw OPTIONS (endpoint 'ipc');
\des+ tsurugidb
DROP SERVER tsurugidb;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw OPTIONS (dbname 'test_db');
\des+ tsurugidb
DROP SERVER tsurugidb;

--- Test case: CREATE SERVER ... /ALTER SERVER ...
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
\des+ tsurugidb

ALTER SERVER tsurugidb OPTIONS (endpoint 'ipc', dbname 'test_db');
\des+ tsurugidb

ALTER SERVER tsurugidb OPTIONS (DROP endpoint, DROP dbname);
\des+ tsurugidb

ALTER SERVER tsurugidb
  OPTIONS (endpoint 'stream', address '127.0.0.1', port '12345');
\des+ tsurugidb

ALTER SERVER tsurugidb OPTIONS (DROP endpoint, DROP address, DROP port);
\des+ tsurugidb

DROP SERVER tsurugidb;

--- Test case: CREATE SERVER ... OPTIONS .../ALTER SERVER ...: IPC
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'ipc', dbname 'test_db');
\des+ tsurugidb

ALTER SERVER tsurugidb
  OPTIONS (SET endpoint 'stream', address '127.0.0.1', port '12345', DROP dbname);
\des+ tsurugidb

ALTER SERVER tsurugidb
  OPTIONS (SET endpoint 'ipc', dbname 'test_db', DROP address, DROP port);
\des+ tsurugidb

ALTER SERVER tsurugidb
  OPTIONS (SET endpoint 'stream', address 'localhost', port '1');
\des+ tsurugidb

ALTER SERVER tsurugidb OPTIONS (SET endpoint 'ipc', SET dbname 'test_db_2');
\des+ tsurugidb

DROP SERVER tsurugidb;

--- Test case: CREATE SERVER ... OPTIONS .../ALTER SERVER ...: TCP
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (endpoint 'stream', address '127.0.0.1', port '12345');
\des+ tsurugidb
DROP SERVER tsurugidb;

--- Test case: case sensitivity
CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw
  OPTIONS (ENDPOINT 'ipc', DBNAME 'TEST_DB', ADDRESS '127.0.0.1', PORT '12345');
\des+ tsurugidb
DROP SERVER tsurugidb;

--- Test teardown: DDL of the PostgreSQL
\c contrib_regression
DROP DATABASE contrib_regression_ddl;

--- Basic operations
---- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_ddl_table (c INTEGER)
', 'tsurugidb');

---- Test case: INSERT is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

INSERT INTO fdw_ddl_table VALUES (1), (2);
SELECT * FROM fdw_ddl_table ORDER BY c;
UPDATE fdw_ddl_table SET c = c + 10;
SELECT * FROM fdw_ddl_table ORDER BY c;
DELETE FROM fdw_ddl_table WHERE c = 11;
SELECT * FROM fdw_ddl_table ORDER BY c;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test case: SELECT is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

SELECT * FROM fdw_ddl_table ORDER BY c;
UPDATE fdw_ddl_table SET c = c - 10;
SELECT * FROM fdw_ddl_table ORDER BY c;
DELETE FROM fdw_ddl_table WHERE c = 2;
SELECT * FROM fdw_ddl_table ORDER BY c;
INSERT INTO fdw_ddl_table VALUES (3);
SELECT * FROM fdw_ddl_table ORDER BY c;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test case: UPDATE is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

UPDATE fdw_ddl_table SET c = c + 20;
SELECT * FROM fdw_ddl_table ORDER BY c;
DELETE FROM fdw_ddl_table WHERE c = 23;
SELECT * FROM fdw_ddl_table ORDER BY c;
INSERT INTO fdw_ddl_table VALUES (4);
SELECT * FROM fdw_ddl_table ORDER BY c;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test case: DELETE is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

DELETE FROM fdw_ddl_table WHERE c = 4;
SELECT * FROM fdw_ddl_table ORDER BY c;
INSERT INTO fdw_ddl_table VALUES (5);
SELECT * FROM fdw_ddl_table ORDER BY c;
UPDATE fdw_ddl_table SET c = 111;
SELECT * FROM fdw_ddl_table ORDER BY c;
DELETE FROM fdw_ddl_table;
SELECT * FROM fdw_ddl_table ORDER BY c;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test case: INSERT (preparation) is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

PREPARE fdw_prepare_ins(integer, integer) AS
  INSERT INTO fdw_ddl_table VALUES ($1), ($2);
PREPARE fdw_prepare_sel AS SELECT * FROM fdw_ddl_table ORDER BY c;
PREPARE fdw_prepare_upd(integer) AS UPDATE fdw_ddl_table SET c = c + $1;
PREPARE fdw_prepare_del(integer) AS DELETE FROM fdw_ddl_table WHERE c = $1;

EXECUTE fdw_prepare_ins(1, 2);
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_upd(10);
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_del(11);
EXECUTE fdw_prepare_sel;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test case: SELECT (preparation) is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

PREPARE fdw_prepare_ins(integer) AS INSERT INTO fdw_ddl_table VALUES ($1);
PREPARE fdw_prepare_sel AS SELECT * FROM fdw_ddl_table ORDER BY c;
PREPARE fdw_prepare_upd(integer) AS UPDATE fdw_ddl_table SET c = c + $1;
PREPARE fdw_prepare_del(integer) AS DELETE FROM fdw_ddl_table WHERE c = $1;

EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_upd(-10);
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_del(2);
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_ins(3);
EXECUTE fdw_prepare_sel;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test case: UPDATE (preparation) is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

PREPARE fdw_prepare_ins(integer) AS INSERT INTO fdw_ddl_table VALUES ($1);
PREPARE fdw_prepare_sel AS SELECT * FROM fdw_ddl_table ORDER BY c;
PREPARE fdw_prepare_upd(integer) AS UPDATE fdw_ddl_table SET c = c + $1;
PREPARE fdw_prepare_del(integer) AS DELETE FROM fdw_ddl_table WHERE c = $1;

EXECUTE fdw_prepare_upd(20);
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_del(23);
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_ins(4);
EXECUTE fdw_prepare_sel;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test case: DELETE (preparation) is the first operation
CREATE DATABASE contrib_regression_ddl;
\c contrib_regression_ddl
CREATE EXTENSION tsurugi_fdw;

CREATE SERVER tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE fdw_ddl_table (c integer) SERVER tsurugidb;

PREPARE fdw_prepare_ins AS INSERT INTO fdw_ddl_table VALUES (5);
PREPARE fdw_prepare_sel AS SELECT * FROM fdw_ddl_table ORDER BY c;
PREPARE fdw_prepare_upd AS UPDATE fdw_ddl_table SET c = 111;
PREPARE fdw_prepare_del(integer) AS DELETE FROM fdw_ddl_table WHERE c = $1;
PREPARE fdw_prepare_del_all AS DELETE FROM fdw_ddl_table;

EXECUTE fdw_prepare_del(4);
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_ins;
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_upd;
EXECUTE fdw_prepare_sel;
EXECUTE fdw_prepare_del_all;
EXECUTE fdw_prepare_sel;

\c contrib_regression
DROP DATABASE contrib_regression_ddl;

---- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_ddl_table', 'tsurugidb');
