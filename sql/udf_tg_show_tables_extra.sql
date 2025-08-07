/* Test case: 3-4-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', False);
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', FALSE);
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', True);
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', TRUE);
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 3-4-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
-- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 't');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'yes');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'y');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'on');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', '1');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'f');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'no');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'n');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', 'off');
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'summary', '0');
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 7-1-1 */
-- Test setup: DDL of the Tsurugi
DO $$
DECLARE
    TABLE_MAX CONSTANT INT := 100;
    COLUMN_MAX CONSTANT INT := 50;
    columns_def TEXT;
    i INT;
BEGIN
    SELECT string_agg(format('col_%s INT', n), ', ')
        INTO columns_def
    FROM generate_series(1, COLUMN_MAX) n;

    FOR i IN 1..TABLE_MAX LOOP
        EXECUTE format(
            'SELECT tg_execute_ddl(''CREATE TABLE IF NOT EXISTS udf_test_table_%s (%s)'', ''tsurugidb'')',
            to_char(i, 'FM0000'), columns_def);
    END LOOP;
END $$;
-- Test
SELECT tg_show_tables('tg_schema', 'tsurugidb', 'detail', true);
-- Test teardown: DDL of the Tsurugi/PostgreSQL
DO $$
DECLARE
    TABLE_MAX CONSTANT INT := 100;
    i INT;
BEGIN
    FOR i IN 1..TABLE_MAX LOOP
        EXECUTE format(
            'SELECT tg_execute_ddl(''DROP TABLE IF EXISTS udf_test_table_%s'', ''tsurugidb'')',
            to_char(i, 'FM0000'));
    END LOOP;
END $$;
