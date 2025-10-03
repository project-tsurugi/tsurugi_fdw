/* Test case: happy path - UDF tg_show_tables() */
-- Test case: 1-1-1
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', true);

-- Test case: 1-1-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', true);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

-- Test case: 1-1-3
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', true);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

-- Test case: 1-2-1
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', false);

-- Test case: 1-2-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', false);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

-- Test case: 1-2-3
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', false);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

-- Test case: 2-1-1
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', true);

-- Test case: 2-1-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', true);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

-- Test case: 2-1-3
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', true);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

-- Test case: 2-2-1
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', false);

-- Test case: 2-2-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', false);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

-- Test case: 2-2-3
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', false);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

-- Test case: 3-1-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('invalid_schema', 'tsurugidb', 'detail', true);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

-- Test case: 3-2-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE SERVER other_server FOREIGN DATA WRAPPER tsurugi_fdw;
--- Test
SELECT tg_show_tables('tg_schema', 'other_server', 'detail', true);
--- Test teardown: DDL of the PostgreSQL
DROP SERVER other_server;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

-- Test case: 3-2-3
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE SERVER "Tsurugidb" FOREIGN DATA WRAPPER tsurugi_fdw;
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', true);
SELECT tg_show_tables('tg_schema', 'Tsurugidb', 'detail', true);
SELECT tg_show_tables('tg_schema', 'TSURUGIDB', 'detail', true);
--- Test teardown: DDL of the PostgreSQL
DROP SERVER "Tsurugidb";
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

-- Test case: 3-3-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'Summary', false);
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'SUMMARY', false);
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'Detail', false);
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'DETAIL', false);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

-- Test case: 4-1-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', true)
  ->'remote_schema'->'tables_on_remote_schema'->'count';
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

-- Test case: 4-1-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', false)
  ->'remote_schema'->'tables_on_remote_schema'->'count';
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

-- Test case: 4-2-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', true)
  ->'remote_schema'->'tables_on_remote_schema'->'list';
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

-- Test case: 4-2-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', false)
  ->'remote_schema'->'tables_on_remote_schema'->'list';
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_3', 'tsurugidb');

-- Test case: 5-3-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb');
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

-- Test case: 5-4-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail');
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
