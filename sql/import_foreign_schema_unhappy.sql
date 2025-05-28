/* Test case: 1-4 */
-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public OPTIONS (name 'value');

/* Test case: --- */
-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO unknown_schema;

/* Test case: 5-1 */
-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER unknown_server INTO public;
