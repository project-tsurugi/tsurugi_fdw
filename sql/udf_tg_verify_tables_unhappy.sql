/* Test case: unhappy path - UDF tg_verify_tables() */
-- Test case: 4-2-2
--- Test
SELECT tg_verify_tables('tg_schema', 'unknown_server', 'public', 'summary', true);

-- Test case: 4-2-3
--- Test
SELECT tg_verify_tables('tg_schema', 'TSURUGIDB', 'public', 'detail', true);

-- Test case: 4-3-2
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'invalid_schema', 'detail', true);

-- Test case: 4-3-3
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'PUBLIC', 'detail', true);

-- Test case: 6-1-1
--- Test
SELECT tg_verify_tables();

-- Test case: 6-1-2
--- Test
SELECT tg_verify_tables('', 'tsurugidb', 'public', 'summary', true);

-- Test case: 6-1-3
--- Test
SELECT tg_verify_tables(NULL, 'tsurugidb', 'public', 'summary', true);

-- Test case: 6-2-1
--- Test
SELECT tg_verify_tables('tg_schema');

-- Test case: 6-2-2
--- Test
SELECT tg_verify_tables('tg_schema', '', 'public', 'summary', true);

-- Test case: 6-2-3
--- Test
SELECT tg_verify_tables('tg_schema', NULL, 'public', 'summary', true);

-- Test case: 6-3-1
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb');

-- Test case: 6-3-2
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', '', 'detail', true);

-- Test case: 6-3-3
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', NULL, 'detail', true);

-- Test case: 6-4-2
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'invalid_mode', true);

-- Test case: 6-4-3
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', '', true);

-- Test case: 6-4-4
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', NULL, true);

-- Test case: 6-5-2
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'invalid');

-- Test case: 6-5-3
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', '');

-- Test case: 6-5-4
--- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', NULL);
