/* Test case: 1-1-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 1-1-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 1-1-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 1-1-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 1-2-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 1-2-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 1-2-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 1-2-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 2-1-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 2-1-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 2-1-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 2-1-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 2-2-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 2-2-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 2-2-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 2-2-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 3-1-1 */
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);

/* Test case: 3-1-2 */
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;

/* Test case: 3-1-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 3-1-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

/* Test case: 3-1-5 */
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (id bigint, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_3 (id numeric, schedule timestamp) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
DROP FOREIGN TABLE udf_test_table_3;

/* Test case: 3-1-6 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_remote_1 (id INT, name VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_matched_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_1 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_2 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_local_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_local_2 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_matched_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_1 (id real, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_2 (id integer, schedule timestamptz) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_local_1;
DROP FOREIGN TABLE udf_test_table_local_2;
DROP FOREIGN TABLE udf_test_table_matched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_remote_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_matched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_2', 'tsurugidb');

/* Test case: 3-1-7 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE Udf_Test_Table_1 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE UDF_test_table_2 (id BIGINT, name VARCHAR)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE "Udf_Test_Table_1" (id bigint, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE UDF_test_table_2 (id bigint, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE "Udf_Test_Table_1";
DROP FOREIGN TABLE UDF_test_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE Udf_Test_Table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE UDF_test_table_2', 'tsurugidb');

/* Test case: 3-2-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (
    id INT,
    name CHAR(128),
    address VARCHAR,
    tel CHAR(24),
    since DATE,
    schedule TIMESTAMP
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  id integer,
  name text,
  address text,
  tel text,
  since date,
  schedule timestamp
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 3-2-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (
    id INT,
    name CHAR(128),
    address VARCHAR,
    tel CHAR(24),
    since DATE,
    schedule TIMESTAMP
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  id integer,
  name text,
  address text,
  since date,
  schedule timestamp
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 3-2-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (
    id INT,
    name CHAR(128),
    address VARCHAR,
    since DATE,
    schedule TIMESTAMP
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  id integer,
  name text,
  address text,
  tel text,
  since date,
  schedule timestamp
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 3-3-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT)', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (
    id INT, name CHAR(128), address VARCHAR, tel CHAR(24), since DATE, schedule TIMESTAMP
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  id integer
) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (
  id integer,
  name text,
  address text,
  tel text,
  since date,
  schedule timestamp
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 3-3-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 VARCHAR,
    col_4 VARCHAR,
    col_5 VARCHAR
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 VARCHAR,
    col_4 VARCHAR,
    col_5 VARCHAR
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_3 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 VARCHAR,
    col_4 VARCHAR,
    col_5 VARCHAR
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_4 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 VARCHAR,
    col_4 VARCHAR,
    col_5 VARCHAR
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  invalid integer,
  col_2 text,
  col_3 text,
  col_4 text,
  col_5 text
) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (
  col_1 integer,
  col_2 text,
  invalid text,
  col_4 text,
  col_5 text
) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_3 (
  col_1 integer,
  col_2 text,
  col_3 text,
  col_4 text,
  invalid text
) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_4 (
  col_1 integer,
  invalid_1 text,
  col_3 text,
  invalid_2 text,
  col_5 text
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE IF EXISTS udf_test_table_1;
DROP FOREIGN TABLE IF EXISTS udf_test_table_2;
DROP FOREIGN TABLE IF EXISTS udf_test_table_3;
DROP FOREIGN TABLE IF EXISTS udf_test_table_4;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_4', 'tsurugidb');

/* Test case: 3-3-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (
    col_1 INT,
    col_2 VARCHAR,
    Col_2 DATE,
    COL_2 TIME
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (
    Col_1 INT,
    Col_2 VARCHAR
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  col_1 integer,
  col_2 text,
  "Col_2" date,
  "COL_2" time
) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (
  col_1 integer,
  col_2 text
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 3-4-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (
    col_1 INT
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 DATE,
    col_4 TIME,
    col_5 DECIMAL
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  col_1 integer
) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (
  col_1 integer,
  col_2 text,
  col_3 date,
  col_4 time,
  col_5 numeric
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 3-4-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 DATE,
    col_4 TIME,
    col_5 DECIMAL,
    col_6 INT,
    col_7 VARCHAR,
    col_8 DATE,
    col_9 TIME,
    col_10 DECIMAL
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 DATE,
    col_4 TIME,
    col_5 DECIMAL,
    col_6 INT,
    col_7 VARCHAR,
    col_8 DATE,
    col_9 TIME,
    col_10 DECIMAL
  )
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_3 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 DATE,
    col_4 TIME,
    col_5 DECIMAL,
    col_6 INT,
    col_7 VARCHAR,
    col_8 DATE,
    col_9 TIME,
    col_10 DECIMAL
  )
', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (
  col_2 text,
  col_1 integer,
  col_3 date,
  col_4 time,
  col_5 numeric,
  col_6 integer,
  col_7 text,
  col_8 date,
  col_9 time,
  col_10 numeric
) SERVER tsurugidb;
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_2 (
  col_1 integer,
  col_2 text,
  col_3 date,
  col_7 text,
  col_5 numeric,
  col_6 integer,
  col_4 time,
  col_8 date,
  col_9 time,
  col_10 numeric
) SERVER tsurugidb;
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_3 (
  col_10 numeric,
  col_2 text,
  col_3 date,
  col_4 time,
  col_5 numeric,
  col_6 integer,
  col_7 text,
  col_8 date,
  col_9 time,
  col_1 integer
) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
DROP FOREIGN TABLE udf_test_table_3;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

/* Test case: 4-1-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (id bigint, since date) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('invalid_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

/* Test case: 4-2-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE SERVER other_server FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (id bigint, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_3 (id numeric, schedule timestamp) SERVER other_server;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
SELECT tg_verify_tables('tg_schema', 'other_server', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
DROP FOREIGN TABLE udf_test_table_3;
DROP SERVER other_server;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

/* Test case: 4-2-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE SERVER "Tsurugidb" FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (id bigint, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_3 (id numeric, schedule timestamp) SERVER "Tsurugidb";
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
SELECT tg_verify_tables('tg_schema', 'Tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
DROP FOREIGN TABLE udf_test_table_3;
DROP SERVER "Tsurugidb";
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

/* Test case: 4-3-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE SCHEMA other_schema;
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE other_schema.udf_test_table_2 (id bigint, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE other_schema.udf_test_table_3 (id numeric, schedule timestamp) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'other_schema', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE other_schema.udf_test_table_2;
DROP FOREIGN TABLE other_schema.udf_test_table_3;
DROP SCHEMA other_schema;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

/* Test case: 4-3-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE SCHEMA "Public";
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_2 (id bigint, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE "Public".udf_test_table_3 (id numeric, schedule timestamp) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'Public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
DROP FOREIGN TABLE udf_test_table_2;
DROP FOREIGN TABLE "Public".udf_test_table_3;
DROP SCHEMA "Public";
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

/* Test case: 4-4-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'Summary', false);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'SUMMARY', false);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'Detail', false);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'DETAIL', false);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 5-1-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_remote_1 (id INT, name VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_matched_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_1 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_2 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_local_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_local_2 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_matched_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_1 (id real, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_2 (id integer, schedule timestamptz) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true)->'verification'->'tables_on_only_remote_schema'->'count';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true)->'verification'->'foreign_tables_on_only_local_schema'->'count';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true)->'verification'->'tables_that_need_to_be_altered'->'count';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', true)->'verification'->'available_foreign_table'->'count';
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_local_1;
DROP FOREIGN TABLE udf_test_table_local_2;
DROP FOREIGN TABLE udf_test_table_matched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_remote_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_matched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_2', 'tsurugidb');

/* Test case: 5-1-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_remote_1 (id INT, name VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_matched_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_1 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_2 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_local_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_local_2 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_matched_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_1 (id real, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_2 (id integer, schedule timestamptz) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false)->'verification'->'tables_on_only_remote_schema'->'count';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false)->'verification'->'foreign_tables_on_only_local_schema'->'count';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false)->'verification'->'tables_that_need_to_be_altered'->'count';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', false)->'verification'->'available_foreign_table'->'count';
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_local_1;
DROP FOREIGN TABLE udf_test_table_local_2;
DROP FOREIGN TABLE udf_test_table_matched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_remote_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_matched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_2', 'tsurugidb');

/* Test case: 5-2-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_remote_1 (id INT, name VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_matched_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_1 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_2 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_local_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_local_2 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_matched_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_1 (id real, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_2 (id integer, schedule timestamptz) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true)->'verification'->'tables_on_only_remote_schema'->'list';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true)->'verification'->'foreign_tables_on_only_local_schema'->'list';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true)->'verification'->'tables_that_need_to_be_altered'->'list';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true)->'verification'->'available_foreign_table'->'list';
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_local_1;
DROP FOREIGN TABLE udf_test_table_local_2;
DROP FOREIGN TABLE udf_test_table_matched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_remote_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_matched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_2', 'tsurugidb');

/* Test case: 5-2-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_remote_1 (id INT, name VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_matched_1 (id INT, name CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_1 (id BIGINT, since DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_unmatched_2 (id DECIMAL, schedule TIMESTAMP)', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_local_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_local_2 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_matched_1 (id integer, name text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_1 (id real, since date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_unmatched_2 (id integer, schedule timestamptz) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false)->'verification'->'tables_on_only_remote_schema'->'list';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false)->'verification'->'foreign_tables_on_only_local_schema'->'list';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false)->'verification'->'tables_that_need_to_be_altered'->'list';
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', false)->'verification'->'available_foreign_table'->'list';
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_local_1;
DROP FOREIGN TABLE udf_test_table_local_2;
DROP FOREIGN TABLE udf_test_table_matched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_1;
DROP FOREIGN TABLE udf_test_table_unmatched_2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_remote_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_matched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_unmatched_2', 'tsurugidb');

/* Test case: 6-4-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public');
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 6-5-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail');
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
