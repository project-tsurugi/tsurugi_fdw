/* Test case: unhappy path - UDF tg_show_tables() */
-- Test case: 3-2-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');
--- Test
SELECT tg_show_tables('tg_schema', 'unknown_server', 'detail', true);
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_2', 'tsurugidb');

-- Test case: 5-1-1
--- Test
SELECT tg_show_tables();

-- Test case: 5-1-2
--- Test
SELECT tg_show_tables('', 'tsurugidb', 'summary', true);

-- Test case: 5-1-3
--- Test
SELECT tg_show_tables(NULL, 'tsurugidb', 'summary', true);

-- Test case: 5-2-1
--- Test
SELECT tg_show_tables('tg_schema');

-- Test case: 5-2-2
--- Test
SELECT tg_show_tables('tg_schema', '', 'summary', true);

-- Test case: 5-2-3
--- Test
SELECT tg_show_tables('tg_schema', NULL, 'summary', true);

-- Test case: 5-3-2
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'invalid_mode', true);

-- Test case: 5-3-3
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', '', true);

-- Test case: 5-3-4
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', NULL, true);

-- Test case: 5-4-2
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'invalid');

-- Test case: 5-4-3
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', '');

-- Test case: 5-4-4
--- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', NULL);
