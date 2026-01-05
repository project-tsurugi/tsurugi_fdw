/* Test case: unhappy path - IMPORT FOREIGN SCHEMA functionality */
-- Test case: 1-4
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public OPTIONS (name 'value');

-- Test case: ---
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO unknown_schema;

-- Test case: 5-1
IMPORT FOREIGN SCHEMA public FROM SERVER unknown_server INTO public;

-- Test case: 2-3-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_test_table_2 (id INT, since DATE) SERVER tsurugidb;

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_2;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 3-5
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_type_invalid (col_blob BLOB)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_type_invalid', 'tsurugidb');
