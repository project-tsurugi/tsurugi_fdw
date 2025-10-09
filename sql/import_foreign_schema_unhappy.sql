/* Test case: unhappy path - IMPORT FOREIGN SCHEMA functionality */
-- Test case: 1-4
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public OPTIONS (name 'value');

-- Test case: ---
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO unknown_schema;

-- Test case: 5-1
IMPORT FOREIGN SCHEMA public FROM SERVER unknown_server INTO public;
