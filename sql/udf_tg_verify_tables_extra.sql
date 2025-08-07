/* Test case: 3-5-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_int (col INT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_bigint (col BIGINT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_real (col REAL)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_float (col FLOAT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_double (col DOUBLE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_double_precision (col DOUBLE PRECISION)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal (col DECIMAL)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_p (col DECIMAL(5))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_ps (col DECIMAL(5, 1))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_max (col DECIMAL(*))', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_int', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_bigint', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_real', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_float', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_double', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_double_precision', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_ps', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_max', 'tsurugidb');

/* Test case: 3-5-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char (col CHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char_len (col CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character (col CHARACTER)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character_len (col CHARACTER(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_varchar (col VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_varchar_len (col VARCHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char_varying (col CHAR VARYING)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char_varying_len (col CHAR VARYING(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character_varying (col CHARACTER VARYING)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character_varying_len (col CHARACTER VARYING(64))', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char_len', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character_len', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_varchar', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_varchar_len', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char_varying', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char_varying_len', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character_varying', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character_varying_len', 'tsurugidb');

/* Test case: 3-5-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_date (col DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_time (col TIME)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_time_without_time_zone (col TIME)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamp (col TIMESTAMP)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamp_without_time_zone (col TIMESTAMP)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timetz (col TIME WITH TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_time_with_time_zone (col TIME WITH TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamptz (col TIMESTAMP WITH TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamp_with_time_zone (col TIMESTAMP WITH TIME ZONE)', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_date', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_time', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_time_without_time_zone', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamp', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamp_without_time_zone', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timetz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_time_with_time_zone', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamptz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamp_with_time_zone', 'tsurugidb');

/* Test case: 3-5-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_int (col INT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_bigint (col BIGINT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_real (col REAL)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_float (col FLOAT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_double (col DOUBLE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_double_precision (col DOUBLE PRECISION)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal (col DECIMAL)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_p (col DECIMAL(5))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_ps (col DECIMAL(5, 1))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_max (col DECIMAL(*))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_p2 (col DECIMAL(5))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_decimal_ps2 (col DECIMAL(5, 1))', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_int', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_bigint', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_real', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_float', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_double', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_double_precision', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_ps', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_max', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_p2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_decimal_ps2', 'tsurugidb');

/* Test case: 3-5-5 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char (col CHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char_l (col CHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character (col CHARACTER)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character_l (col CHARACTER(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_varchar (col VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_varchar_l (col VARCHAR(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char_varying (col CHAR VARYING)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char_varying_l (col CHAR VARYING(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character_varying (col CHARACTER VARYING)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_character_varying_l (col CHARACTER VARYING(64))', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_varchar', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_varchar_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char_varying', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char_varying_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character_varying', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_character_varying_l', 'tsurugidb');

/* Test case: 3-5-6 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_date (col DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_time (col TIME)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamp (col TIMESTAMP)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_time_with_time_zone (col TIME WITH TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamp_with_time_zone (col TIMESTAMP WITH TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_time_p (col TIME)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamp_p (col TIMESTAMP)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_time_with_time_zone_p (col TIME WITH TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_timestamp_with_time_zone_p (col TIMESTAMP WITH TIME ZONE)', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_date', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_time', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamp', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_time_with_time_zone', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamp_with_time_zone', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_time_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamp_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_time_with_time_zone_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_timestamp_with_time_zone_p', 'tsurugidb');

/* Test case: 3-5-7 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_binary (col BINARY)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_binary_l (col BINARY(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_varbinary (col VARBINARY)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_varbinary_l (col VARBINARY(64))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_binary_varying (col BINARY VARYING)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_binary_varying_l (col BINARY VARYING(64))', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_binary', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_binary_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_varbinary', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_varbinary_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_binary_varying', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_binary_varying_l', 'tsurugidb');

/* Test case: 3-5-8 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_boolean (col INT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_smallint (col INT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_numeric_p (col DECIMAL(5))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_varchar (col VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_char (col CHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_bytea (col BINARY)', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_boolean', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_smallint', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_numeric_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_varchar', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_char', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE udf_test_table_bytea', 'tsurugidb');

/* Test case: 4-5-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 4-5-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('CREATE TABLE udf_test_table_1 (id INT, name CHAR(64))', 'tsurugidb');
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
SELECT tg_execute_ddl('DROP TABLE udf_test_table_1', 'tsurugidb');

/* Test case: 8-1-1 */
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
    TABLE_MAX CONSTANT INT := 100;
    i INT;
BEGIN
    FOR i IN 1..TABLE_MAX LOOP
        EXECUTE format(
            'SELECT tg_execute_ddl(''DROP TABLE IF EXISTS udf_test_table_%s'', ''tsurugidb'')',
            to_char(i, 'FM0000'));
        EXECUTE format(
            'DROP FOREIGN TABLE IF EXISTS udf_test_table_%s',
            to_char(i, 'FM0000'));
    END LOOP;
END $$;
