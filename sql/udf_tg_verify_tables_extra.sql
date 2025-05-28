/* Test case: 3-5-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_int (col INT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_bigint (col BIGINT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_real (col REAL)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_float (col FLOAT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_double (col DOUBLE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_double_precision (col DOUBLE PRECISION)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal (col DECIMAL)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_p (col DECIMAL(5))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_ps (col DECIMAL(5, 1))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_max (col DECIMAL(*))');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_int (col integer) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_bigint (col bigint) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_real (col real) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_float (col real) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_double (col double precision) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_double_precision (col double precision) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_p (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_ps (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_max (col numeric) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_int;
DROP FOREIGN TABLE udf_test_table_bigint;
DROP FOREIGN TABLE udf_test_table_real;
DROP FOREIGN TABLE udf_test_table_float;
DROP FOREIGN TABLE udf_test_table_double;
DROP FOREIGN TABLE udf_test_table_double_precision;
DROP FOREIGN TABLE udf_test_table_decimal;
DROP FOREIGN TABLE udf_test_table_decimal_p;
DROP FOREIGN TABLE udf_test_table_decimal_ps;
DROP FOREIGN TABLE udf_test_table_decimal_max;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_int');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_bigint');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_real');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_float');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_double');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_double_precision');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_p');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_ps');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_max');

/* Test case: 3-5-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char (col CHAR)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char_len (col CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character (col CHARACTER)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character_len (col CHARACTER(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_varchar (col VARCHAR)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_varchar_len (col VARCHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char_varying (col CHAR VARYING)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char_varying_len (col CHAR VARYING(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character_varying (col CHARACTER VARYING)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character_varying_len (col CHARACTER VARYING(64))');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_char (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_char_len (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character_len (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_varchar (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_varchar_len (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_char_varying (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_char_varying_len (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character_varying (col text) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character_varying_len (col text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_char;
DROP FOREIGN TABLE udf_test_table_char_len;
DROP FOREIGN TABLE udf_test_table_character;
DROP FOREIGN TABLE udf_test_table_character_len;
DROP FOREIGN TABLE udf_test_table_varchar;
DROP FOREIGN TABLE udf_test_table_varchar_len;
DROP FOREIGN TABLE udf_test_table_char_varying;
DROP FOREIGN TABLE udf_test_table_char_varying_len;
DROP FOREIGN TABLE udf_test_table_character_varying;
DROP FOREIGN TABLE udf_test_table_character_varying_len;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char_len');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character_len');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_varchar');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_varchar_len');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char_varying');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char_varying_len');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character_varying');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character_varying_len');

/* Test case: 3-5-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_date (col DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_time (col TIME)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_time_without_time_zone (col TIME)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamp (col TIMESTAMP)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamp_without_time_zone (col TIMESTAMP)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timetz (col TIME WITH TIME ZONE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_time_with_time_zone (col TIME WITH TIME ZONE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamptz (col TIMESTAMP WITH TIME ZONE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamp_with_time_zone (col TIMESTAMP WITH TIME ZONE)');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_date (col date) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_time (col time) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_time_without_time_zone (col time without time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamp (col timestamp) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamp_without_time_zone (col timestamp without time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timetz (col timetz) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_time_with_time_zone (col time with time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamptz (col timestamptz) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamp_with_time_zone (col timestamp with time zone) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_date;
DROP FOREIGN TABLE udf_test_table_time;
DROP FOREIGN TABLE udf_test_table_time_without_time_zone;
DROP FOREIGN TABLE udf_test_table_timestamp;
DROP FOREIGN TABLE udf_test_table_timestamp_without_time_zone;
DROP FOREIGN TABLE udf_test_table_timetz;
DROP FOREIGN TABLE udf_test_table_time_with_time_zone;
DROP FOREIGN TABLE udf_test_table_timestamptz;
DROP FOREIGN TABLE udf_test_table_timestamp_with_time_zone;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_date');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_time');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_time_without_time_zone');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamp');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamp_without_time_zone');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timetz');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_time_with_time_zone');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamptz');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamp_with_time_zone');

/* Test case: 3-5-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_int (col INT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_bigint (col BIGINT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_real (col REAL)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_float (col FLOAT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_double (col DOUBLE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_double_precision (col DOUBLE PRECISION)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal (col DECIMAL)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_p (col DECIMAL(5))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_ps (col DECIMAL(5, 1))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_max (col DECIMAL(*))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_p2 (col DECIMAL(5))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_decimal_ps2 (col DECIMAL(5, 1))');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_int (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_bigint (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_real (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_float (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_double (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_double_precision (col numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal (col integer) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_p (col integer) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_ps (col integer) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_max (col integer) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_p2 (col numeric(5)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_decimal_ps2 (col numeric(5, 1)) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_int;
DROP FOREIGN TABLE udf_test_table_bigint;
DROP FOREIGN TABLE udf_test_table_real;
DROP FOREIGN TABLE udf_test_table_float;
DROP FOREIGN TABLE udf_test_table_double;
DROP FOREIGN TABLE udf_test_table_double_precision;
DROP FOREIGN TABLE udf_test_table_decimal;
DROP FOREIGN TABLE udf_test_table_decimal_p;
DROP FOREIGN TABLE udf_test_table_decimal_ps;
DROP FOREIGN TABLE udf_test_table_decimal_max;
DROP FOREIGN TABLE udf_test_table_decimal_p2;
DROP FOREIGN TABLE udf_test_table_decimal_ps2;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_int');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_bigint');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_real');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_float');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_double');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_double_precision');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_p');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_ps');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_max');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_p2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_decimal_ps2');

/* Test case: 3-5-5 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char (col CHAR)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char_l (col CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character (col CHARACTER)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character_l (col CHARACTER(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_varchar (col VARCHAR)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_varchar_l (col VARCHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char_varying (col CHAR VARYING)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char_varying_l (col CHAR VARYING(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character_varying (col CHARACTER VARYING)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_character_varying_l (col CHARACTER VARYING(64))');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_char (col character) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_char_l (col character(64)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character (col character) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character_l (col character(64)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_varchar (col varchar) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_varchar_l (col varchar(64)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_char_varying (col varchar) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_char_varying_l (col varchar(64)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character_varying (col varchar) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_character_varying_l (col varchar(64)) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_char;
DROP FOREIGN TABLE udf_test_table_char_l;
DROP FOREIGN TABLE udf_test_table_character;
DROP FOREIGN TABLE udf_test_table_character_l;
DROP FOREIGN TABLE udf_test_table_varchar;
DROP FOREIGN TABLE udf_test_table_varchar_l;
DROP FOREIGN TABLE udf_test_table_char_varying;
DROP FOREIGN TABLE udf_test_table_char_varying_l;
DROP FOREIGN TABLE udf_test_table_character_varying;
DROP FOREIGN TABLE udf_test_table_character_varying_l;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char_l');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character_l');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_varchar');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_varchar_l');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char_varying');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char_varying_l');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character_varying');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_character_varying_l');

/* Test case: 3-5-6 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_date (col DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_time (col TIME)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamp (col TIMESTAMP)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_time_with_time_zone (col TIME WITH TIME ZONE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamp_with_time_zone (col TIMESTAMP WITH TIME ZONE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_time_p (col TIME)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamp_p (col TIMESTAMP)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_time_with_time_zone_p (col TIME WITH TIME ZONE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_timestamp_with_time_zone_p (col TIMESTAMP WITH TIME ZONE)');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_date (col time) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_time (col time with time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamp (col timestamp with time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_time_with_time_zone (col time) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamp_with_time_zone (col timestamp) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_time_p (col time(3)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamp_p (col timestamp(3)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_time_with_time_zone_p (col time(3) with time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_timestamp_with_time_zone_p (col timestamp(3) with time zone) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_date;
DROP FOREIGN TABLE udf_test_table_time;
DROP FOREIGN TABLE udf_test_table_timestamp;
DROP FOREIGN TABLE udf_test_table_time_with_time_zone;
DROP FOREIGN TABLE udf_test_table_timestamp_with_time_zone;
DROP FOREIGN TABLE udf_test_table_time_p;
DROP FOREIGN TABLE udf_test_table_timestamp_p;
DROP FOREIGN TABLE udf_test_table_time_with_time_zone_p;
DROP FOREIGN TABLE udf_test_table_timestamp_with_time_zone_p;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_date');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_time');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamp');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_time_with_time_zone');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamp_with_time_zone');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_time_p');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamp_p');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_time_with_time_zone_p');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_timestamp_with_time_zone_p');

/* Test case: 3-5-7 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_binary (col BINARY)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_binary_l (col BINARY(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_varbinary (col VARBINARY)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_varbinary_l (col VARBINARY(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_binary_varying (col BINARY VARYING)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_binary_varying_l (col BINARY VARYING(64))');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_binary (col bytea) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_binary_l (col bytea) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_varbinary (col bytea) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_varbinary_l (col bytea) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_binary_varying (col bytea) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_binary_varying_l (col bytea) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_binary;
DROP FOREIGN TABLE udf_test_table_binary_l;
DROP FOREIGN TABLE udf_test_table_varbinary;
DROP FOREIGN TABLE udf_test_table_varbinary_l;
DROP FOREIGN TABLE udf_test_table_binary_varying;
DROP FOREIGN TABLE udf_test_table_binary_varying_l;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_binary');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_binary_l');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_varbinary');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_varbinary_l');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_binary_varying');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_binary_varying_l');

/* Test case: 3-5-8 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_boolean (col INT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_smallint (col INT)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_numeric_p (col DECIMAL(5))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_varchar (col VARCHAR)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_char (col CHAR)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_bytea (col BINARY)');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_boolean (col boolean) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_smallint (col smallint) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_numeric_p (col numeric(5)) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_varchar (col varchar) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_char (col char) SERVER tsurugidb;
CREATE FOREIGN TABLE udf_test_table_bytea (col bytea) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_boolean;
DROP FOREIGN TABLE udf_test_table_smallint;
DROP FOREIGN TABLE udf_test_table_numeric_p;
DROP FOREIGN TABLE udf_test_table_varchar;
DROP FOREIGN TABLE udf_test_table_char;
DROP FOREIGN TABLE udf_test_table_bytea;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_boolean');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_smallint');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_numeric_p');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_varchar');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_char');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_bytea');

/* Test case: 4-5-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', True);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', TRUE);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', False);
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', FALSE);
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_1');

/* Test case: 4-5-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))');
-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugidb;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 't');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'yes');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'y');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'on');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', '1');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'f');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'no');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'n');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', 'off');
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'summary', '0');
-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE udf_test_table_1;
-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE udf_test_table_1');

/* Test case: 8-1-1 */
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
            'SELECT tg_execute_ddl(''tsurugidb'', ''CREATE TABLE IF NOT EXISTS udf_test_table_%s (%s)'')',
            to_char(i, 'FM0000'), columns_def);
        EXECUTE format(
            'CREATE FOREIGN TABLE IF NOT EXISTS udf_test_table_%s (%s) SERVER tsurugidb',
            to_char(i, 'FM0000'), columns_def);
    END LOOP;
END $$;
-- Test
SELECT tg_verify_tables('tg_schema', 'tsurugidb', 'public', 'detail', true);
-- Test teardown: DDL of the Tsurugi/PostgreSQL
DO $$
DECLARE
    TABLE_MAX CONSTANT INT := 1000;
    i INT;
BEGIN
    FOR i IN 1..TABLE_MAX LOOP
        EXECUTE format(
            'SELECT tg_execute_ddl(''tsurugidb'', ''DROP TABLE IF EXISTS udf_test_table_%s'')',
            to_char(i, 'FM0000'));
        EXECUTE format(
            'DROP FOREIGN TABLE IF EXISTS udf_test_table_%s',
            to_char(i, 'FM0000'));
    END LOOP;
END $$;
