SET datestyle TO ISO, YMD;
SET timezone TO 'Asia/Tokyo';

/* Test case: 3-1-1_4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_type_num (
    col_int INT,
    col_bigint BIGINT,
    col_real REAL,
    col_float FLOAT,
    col_double DOUBLE,
    col_double_precision DOUBLE PRECISION,
    col_decimal DECIMAL,
    col_decimal_p DECIMAL(2),
    col_decimal_ps DECIMAL(3, 2),
    col_decimal_max DECIMAL(*)
  )
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_type_num;
INSERT INTO fdw_test_type_num 
  (col_int, col_bigint, col_real, col_float, col_double, col_double_precision,
    col_decimal, col_decimal_p, col_decimal_ps, col_decimal_max)
  VALUES (1, 2, 3.33, 4.44, 5.55, 6.66, 77777, 88, 9.99, 1000);
SELECT * FROM fdw_test_type_num;
UPDATE fdw_test_type_num
  SET col_int = 2, col_bigint = 3, col_real = 4.567, col_float = 5.678, col_double = 6.78901,
      col_double_precision = 7.89012, col_decimal = 890, col_decimal_p = 90, col_decimal_ps = 1.23,
      col_decimal_max = 99999
  WHERE col_int = 1;
SELECT * FROM fdw_test_type_num;
DELETE FROM fdw_test_type_num WHERE col_double = 6.78901;
SELECT * FROM fdw_test_type_num;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_type_num;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_num');

/* Test case: 3-2-1_4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_type_str (
    col_char CHAR,
    col_char_l CHAR(64),
    col_character CHARACTER,
    col_character_l CHARACTER(64),
    col_varchar VARCHAR,
    col_varchar_l VARCHAR(64),
    col_char_varying CHAR VARYING,
    col_char_varying_l CHAR VARYING(64),
    col_character_varying CHARACTER VARYING,
    col_character_varying_l CHARACTER VARYING(64)
  )
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_type_str;
INSERT INTO fdw_test_type_str
  (col_char, col_char_l, col_character, col_character_l, col_varchar, col_varchar_l,
   col_char_varying, col_char_varying_l, col_character_varying, col_character_varying_l)
  VALUES ('1', 'char', '2', 'character', 'varchar', 'varchar_l',
          'char_varying', 'char_varying_l', 'character_varying', 'character_varying_l');
SELECT * FROM fdw_test_type_str;
UPDATE fdw_test_type_str
  SET col_char = '3', col_char_l = 'char_upd', col_character = '4', col_character_l = 'character_upd',
      col_varchar = 'varchar_upd', col_varchar_l = 'varchar_l_upd', col_char_varying = 'char_varying_upd',
      col_char_varying_l = 'char_varying_l_upd', col_character_varying = 'character_varying_upd',
      col_character_varying_l = 'character_varying_l_upd'
  WHERE col_char = '1';
SELECT * FROM fdw_test_type_str;
DELETE FROM fdw_test_type_str WHERE col_char = '3';
SELECT * FROM fdw_test_type_str;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_type_str;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_str');

/* Test case: 3-3-1_4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_type_datetime (
    col_date DATE,
    col_time TIME,
    col_time_tz TIME WITH TIME ZONE,
    col_timestamp TIMESTAMP,
    col_timestamp_tz TIMESTAMP WITH TIME ZONE
  )
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_type_datetime;
INSERT INTO fdw_test_type_datetime
  (col_date, col_time, col_timestamp, col_timestamp_tz)
  VALUES (DATE '2025-01-23', TIME '08:09:10', TIMESTAMP '2025-01-23 08:09:10',
          TIMESTAMP WITH TIME ZONE '2025-01-23 08:09:10+09');
SELECT * FROM fdw_test_type_datetime;
UPDATE fdw_test_type_datetime
  SET col_date = DATE '2025-02-12', col_time = TIME '09:10:11', col_timestamp = TIMESTAMP '2025-02-12 09:10:11',
      col_timestamp_tz = TIMESTAMP WITH TIME ZONE '2025-02-12 09:10:11+09' WHERE col_date = DATE '2025-01-23';
SELECT * FROM fdw_test_type_datetime;
DELETE FROM fdw_test_type_datetime WHERE col_date = DATE '2025-02-12';
SELECT * FROM fdw_test_type_datetime;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_type_datetime;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_datetime');

/* Test case: 3-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_type_invalid (col_binary BINARY)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_invalid');

/* Test case: 4-1-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_table_name2_________3_________4_________5_________6__ (id INT, name VARCHAR)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_name2_________3_________4_________5_________6__;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_name2_________3_________4_________5_________6__;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','
  DROP TABLE fdw_test_table_name2_________3_________4_________5_________6__
');

/* Test case: 4-1-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_table_name2_________3_________4_________5_________6___ (id INT, name VARCHAR)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_name2_________3_________4_________5_________6___;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_name2_________3_________4_________5_________6___;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','
  DROP TABLE fdw_test_table_name2_________3_________4_________5_________6___
');

/* Test case: 4-1-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_table_name2_________3_________4_________5_________6____ (id INT, name VARCHAR)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_name2_________3_________4_________5_________6___;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_name2_________3_________4_________5_________6___;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','
  DROP TABLE fdw_test_table_name2_________3_________4_________5_________6____
');

/* Test case: 4-2-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','
  CREATE TABLE fdw_test_table (id INT, columnname_________2_________3_________4_________5_________6__ VARCHAR)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','DROP TABLE fdw_test_table');

/* Test case: 4-2-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','
  CREATE TABLE fdw_test_table (id INT, columnname_________2_________3_________4_________5_________6___ VARCHAR)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','DROP TABLE fdw_test_table');

/* Test case: 4-2-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','
  CREATE TABLE fdw_test_table (id INT, columnname_________2_________3_________4_________5_________6____ VARCHAR)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb','DROP TABLE fdw_test_table');

/* Test case: 6-1 */
-- Test setup: DDL of the Tsurugi
DO $$
DECLARE
    TABLE_MAX CONSTANT INT := 1000;
    COLUMN_MAX CONSTANT INT := 50;
    columns_def TEXT;
    i INT;
BEGIN
    SELECT string_agg(format('col_%s INT', n), ', ')
        INTO columns_def
    FROM generate_series(1, COLUMN_MAX) n;

    FOR i IN 1..TABLE_MAX LOOP
        EXECUTE format(
            'SELECT tg_execute_ddl(''tsurugidb'', ''CREATE TABLE IF NOT EXISTS fdw_test_table_%s (%s)'')',
            to_char(i, 'FM0000'), columns_def);
    END LOOP;
END $$;
-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_0001
\d fdw_test_table_0050
\d fdw_test_table_0256
\d fdw_test_table_0512
\d fdw_test_table_0999
\d fdw_test_table_1000
-- Test teardown: DDL of the Tsurugi/PostgreSQL
DO $$
DECLARE
    TABLE_MAX CONSTANT INT := 1000;
    i INT;
BEGIN
    FOR i IN 1..TABLE_MAX LOOP
        EXECUTE format(
            'SELECT tg_execute_ddl(''tsurugidb'', ''DROP TABLE IF EXISTS fdw_test_table_%s'')',
            to_char(i, 'FM0000'));
        EXECUTE format(
            'DROP FOREIGN TABLE IF EXISTS fdw_test_table_%s',
            to_char(i, 'FM0000'));
    END LOOP;
END $$;
