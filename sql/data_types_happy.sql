SET timezone TO 'UTC';
/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('CREATE TABLE fdw_type_int (c INT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_bigint (c BIGINT)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_decimal (c DECIMAL)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_decimal_p (c DECIMAL(5))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_decimal_ps (c DECIMAL(5, 2))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_numeric_v (c DECIMAL)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_numeric_p_v (c DECIMAL(5))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_numeric_ps_v (c DECIMAL(5, 2))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_real (c REAL)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_double (c DOUBLE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_char (c CHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_char_l (c CHAR(10))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_varchar (c VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_varchar_l (c VARCHAR(10))', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_text (c VARCHAR)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_date (c DATE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_time (c TIME)', 'tsurugidb');
--SELECT tg_execute_ddl('CREATE TABLE fdw_type_time_tz (c TIME WITH TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_timestamp (c TIMESTAMP)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_timestamp_wo_tz (c TIMESTAMP WITHOUT TIME ZONE)', 'tsurugidb');
SELECT tg_execute_ddl('CREATE TABLE fdw_type_timestamp_tz (c TIMESTAMP WITH TIME ZONE)', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE fdw_type_int (c integer) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_bigint (c bigint) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal (c decimal) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal_p (c decimal(5)) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal_ps (c decimal(5, 2)) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric_v (c numeric) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric_p_v (c numeric(5)) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric_ps_v (c numeric(5, 2)) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_real (c real) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_double (c double precision) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_char (c char) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_char_l (c char(10)) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_varchar (c varchar) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_varchar_l (c varchar(10)) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_text (c text) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_date (c date) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_time (c time) SERVER tsurugidb;
--CREATE FOREIGN TABLE fdw_type_time_tz (c time with time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_timestamp (c timestamp) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_timestamp_wo_tz (c timestamp without time zone) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_timestamp_tz (c timestamp with time zone) SERVER tsurugidb;

/* Test */
-- Numeric Types
--- integer
INSERT INTO fdw_type_int VALUES (12345);
INSERT INTO fdw_type_int VALUES (-12345);
INSERT INTO fdw_type_int VALUES (NULL);
INSERT INTO fdw_type_int VALUES (true);  -- error
INSERT INTO fdw_type_int VALUES ('invalid');  -- error
SELECT * FROM fdw_type_int;

--- bigint
INSERT INTO fdw_type_bigint VALUES (12345);
INSERT INTO fdw_type_bigint VALUES (-12345);
INSERT INTO fdw_type_bigint VALUES (NULL);
INSERT INTO fdw_type_bigint VALUES (true);  -- error
INSERT INTO fdw_type_bigint VALUES ('invalid');  -- error
SELECT * FROM fdw_type_bigint;

--- decimal
INSERT INTO fdw_type_decimal VALUES (12345);
INSERT INTO fdw_type_decimal VALUES (-12345);
INSERT INTO fdw_type_decimal VALUES (NULL);
INSERT INTO fdw_type_decimal VALUES (true);  -- error
INSERT INTO fdw_type_decimal VALUES ('invalid');  -- error
SELECT * FROM fdw_type_decimal;

--- decimal(5)
INSERT INTO fdw_type_decimal_p VALUES (12345);
INSERT INTO fdw_type_decimal_p VALUES (-12345);
INSERT INTO fdw_type_decimal_p VALUES (NULL);
INSERT INTO fdw_type_decimal_p VALUES (123456);  -- error
INSERT INTO fdw_type_decimal_p VALUES (true);  -- error
INSERT INTO fdw_type_decimal_p VALUES ('invalid');  -- error
SELECT * FROM fdw_type_decimal_p;

--- decimal(5, 2)
INSERT INTO fdw_type_decimal_ps VALUES (123.45);
INSERT INTO fdw_type_decimal_ps VALUES (-123.45);
INSERT INTO fdw_type_decimal_ps VALUES (NULL);
INSERT INTO fdw_type_decimal_ps VALUES (1234);  -- error
INSERT INTO fdw_type_decimal_ps VALUES (1234.56);  -- error
INSERT INTO fdw_type_decimal_ps VALUES (123.567);  -- error
INSERT INTO fdw_type_decimal_ps VALUES (true);  -- error
INSERT INTO fdw_type_decimal_ps VALUES ('invalid');  -- error
SELECT * FROM fdw_type_decimal_ps;

--- numeric
INSERT INTO fdw_type_numeric_v VALUES (12345);
INSERT INTO fdw_type_numeric_v VALUES (-12345);
INSERT INTO fdw_type_numeric_v VALUES (NULL);
INSERT INTO fdw_type_numeric_v VALUES (true);  -- error
INSERT INTO fdw_type_numeric_v VALUES ('invalid');  -- error
SELECT * FROM fdw_type_numeric_v;

--- numeric(5)
INSERT INTO fdw_type_numeric_p_v VALUES (12345);
INSERT INTO fdw_type_numeric_p_v VALUES (-12345);
INSERT INTO fdw_type_numeric_p_v VALUES (NULL);
INSERT INTO fdw_type_numeric_p_v VALUES (123456);  -- error
INSERT INTO fdw_type_numeric_p_v VALUES (true);  -- error
INSERT INTO fdw_type_numeric_p_v VALUES ('invalid');  -- error
SELECT * FROM fdw_type_numeric_p_v;

--- numeric(5, 2)
INSERT INTO fdw_type_numeric_ps_v VALUES (123.45);
INSERT INTO fdw_type_numeric_ps_v VALUES (-123.45);
INSERT INTO fdw_type_numeric_ps_v VALUES (NULL);
INSERT INTO fdw_type_numeric_ps_v VALUES (1234);  -- error
INSERT INTO fdw_type_numeric_ps_v VALUES (1234.56);  -- error
INSERT INTO fdw_type_numeric_ps_v VALUES (123.567);  -- error
INSERT INTO fdw_type_numeric_ps_v VALUES (true);  -- error
INSERT INTO fdw_type_numeric_ps_v VALUES ('invalid');  -- error
SELECT * FROM fdw_type_numeric_ps_v;

--- real
INSERT INTO fdw_type_real VALUES (1.2345);
INSERT INTO fdw_type_real VALUES (-1.2345);
INSERT INTO fdw_type_real VALUES (NULL);
INSERT INTO fdw_type_real VALUES (true);  -- error
INSERT INTO fdw_type_real VALUES ('invalid');  -- error
SELECT * FROM fdw_type_real;

--- double precision
INSERT INTO fdw_type_double VALUES (1.2345);
INSERT INTO fdw_type_double VALUES (-1.2345);
INSERT INTO fdw_type_double VALUES (NULL);
INSERT INTO fdw_type_double VALUES (true);  -- error
INSERT INTO fdw_type_double VALUES ('invalid');  -- error
SELECT * FROM fdw_type_double;

-- Character Types
--- char
INSERT INTO fdw_type_char VALUES ('a');
INSERT INTO fdw_type_char VALUES ('');
INSERT INTO fdw_type_char VALUES (NULL);
INSERT INTO fdw_type_char VALUES (1);  -- auto-cast
INSERT INTO fdw_type_char VALUES ('aX');  -- error
SELECT * FROM fdw_type_char;

--- char(length)
INSERT INTO fdw_type_char_l VALUES ('abcdef');
INSERT INTO fdw_type_char_l VALUES ('');
INSERT INTO fdw_type_char_l VALUES (NULL);
INSERT INTO fdw_type_char_l VALUES (12345);  -- auto-cast
INSERT INTO fdw_type_char_l VALUES ('1234567890X');  -- error
SELECT * FROM fdw_type_char_l;

--- varchar
INSERT INTO fdw_type_varchar VALUES ('abcdef');
INSERT INTO fdw_type_varchar VALUES ('');
INSERT INTO fdw_type_varchar VALUES (NULL);
INSERT INTO fdw_type_varchar VALUES (12345);  -- auto-cast
SELECT * FROM fdw_type_varchar;

--- varchar(length)
INSERT INTO fdw_type_varchar_l VALUES ('abcdef');
INSERT INTO fdw_type_varchar_l VALUES ('');
INSERT INTO fdw_type_varchar_l VALUES (NULL);
INSERT INTO fdw_type_varchar_l VALUES (12345);  -- auto-cast
INSERT INTO fdw_type_varchar_l VALUES ('1234567890X');  -- error
SELECT * FROM fdw_type_varchar_l;

--- text
INSERT INTO fdw_type_text VALUES ('abcdef');
INSERT INTO fdw_type_text VALUES ('');
INSERT INTO fdw_type_text VALUES (NULL);
INSERT INTO fdw_type_text VALUES (12345);  -- auto-cast
SELECT * FROM fdw_type_text;

-- Date/Time Types
--- date
INSERT INTO fdw_type_date VALUES (DATE '2025-01-01');
INSERT INTO fdw_type_date VALUES (DATE '0001-01-01');
INSERT INTO fdw_type_date VALUES (DATE '9999-12-31');
INSERT INTO fdw_type_date VALUES (NULL);
INSERT INTO fdw_type_date VALUES ('2025-01-01');  -- error
INSERT INTO fdw_type_date VALUES (DATE '1/8/1999');  -- error
INSERT INTO fdw_type_date VALUES (DATE '1/18/1999');  -- error
INSERT INTO fdw_type_date VALUES (DATE '08-Jan-99');  -- error
INSERT INTO fdw_type_date VALUES (DATE 'Jan-08-99');  -- error
INSERT INTO fdw_type_date VALUES (DATE 'January 8, 99 BC');  -- error
INSERT INTO fdw_type_date VALUES (DATE '01:02:03.456');  -- error
INSERT INTO fdw_type_date VALUES (TIME '01:02:03.456');  -- error
INSERT INTO fdw_type_date VALUES (DATE '2021-02-30');  -- error
INSERT INTO fdw_type_date VALUES (DATE 'invalid');  -- error
SET datestyle TO ISO, YMD;
SELECT * FROM fdw_type_date;
SET datestyle TO 'default';

--- time
INSERT INTO fdw_type_time VALUES (TIME '01:02:03.456');
INSERT INTO fdw_type_time VALUES (TIME '01:02:03.456789012');
INSERT INTO fdw_type_time VALUES (TIME '00:00:00');
INSERT INTO fdw_type_time VALUES (TIME '23:59:59.999999');
INSERT INTO fdw_type_time VALUES (NULL);
INSERT INTO fdw_type_time VALUES ('01:02:03.456');  -- error
INSERT INTO fdw_type_time VALUES (DATE '2025/01/01');  -- error
INSERT INTO fdw_type_time VALUES (TIME '2025/01/01');  -- error
INSERT INTO fdw_type_time VALUES (TIME '25:00:00');  -- error
INSERT INTO fdw_type_time VALUES (TIME '010203.456789012');  -- error
INSERT INTO fdw_type_time VALUES (TIME 'invalid');  -- error
SET datestyle TO ISO, YMD;
SELECT * FROM fdw_type_time;
SET datestyle TO 'default';

--- time with time zone
--INSERT INTO fdw_type_time_tz VALUES ('04:05:06.789+9:00');
--INSERT INTO fdw_type_time_tz VALUES ('04:05:06.789+9');
--INSERT INTO fdw_type_time_tz VALUES ('04:05:06.789 UTC');
--INSERT INTO fdw_type_time_tz VALUES ('04:05:06.789 Universal');
--INSERT INTO fdw_type_time_tz VALUES ('00:00:00+00');
--INSERT INTO fdw_type_time_tz VALUES ('12:00');
--INSERT INTO fdw_type_time_tz VALUES ('23:59:59.999999+14');
--INSERT INTO fdw_type_time_tz VALUES (NULL);
--INSERT INTO fdw_type_time_tz VALUES ('2025/01/01');
--INSERT INTO fdw_type_time_tz VALUES ('12:00-16:00');
--INSERT INTO fdw_type_time_tz VALUES ('12:00+16:00');
--INSERT INTO fdw_type_time_tz VALUES ('25:00:00+0');
--INSERT INTO fdw_type_time_tz VALUES ('invalid+tz');
--SET datestyle TO ISO, YMD;
--SELECT * FROM fdw_type_time_tz;
--SET datestyle TO 'default';

--- timestamp
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '2025-01-01 00:00:00');
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '0001-01-01 00:00:00');
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '9999-12-31 23:59:59.999999');
INSERT INTO fdw_type_timestamp VALUES (NULL);
INSERT INTO fdw_type_timestamp VALUES ('2025-01-01 00:00:00');  -- error
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '2025/01/01');  -- error
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '2025/01/01 12:00');  -- error
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '01:02:03.456');  -- error
INSERT INTO fdw_type_timestamp VALUES (DATE '2021-02-30');  -- error
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '2021-02-30 04:05:06.789');  -- error
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP '2025-01-01 25:00:00');  -- error
INSERT INTO fdw_type_timestamp VALUES (TIMESTAMP 'invalid');  -- error
SET datestyle TO ISO, YMD;
SELECT * FROM fdw_type_timestamp;
SET datestyle TO 'default';

--- timestamp without time zone
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '2025-01-01 00:00:00');
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '0001-01-01 00:00:00');
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '9999-12-31 23:59:59.999999');
INSERT INTO fdw_type_timestamp_wo_tz VALUES (NULL);
INSERT INTO fdw_type_timestamp_wo_tz VALUES ('2025-01-01 00:00:00');  -- error
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '2025/01/01');  -- error
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '2025/01/01 12:00');  -- error
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '01:02:03.456');  -- error
INSERT INTO fdw_type_timestamp_wo_tz VALUES (DATE '2021-02-30');  -- error
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '2021-02-30 04:05:06.789');  -- error
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE '2025-01-01 25:00:00');  -- error
INSERT INTO fdw_type_timestamp_wo_tz VALUES (TIMESTAMP WITHOUT TIME ZONE 'invalid');  -- error
SET datestyle TO ISO, YMD;
SELECT * FROM fdw_type_timestamp_wo_tz;
SET datestyle TO 'default';

--- timestamp with time zone
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:01:02.34567+9:00');
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:01:02.34567+900');
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:01:02.34567+9');
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:01:02.34567Z');
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01T12:01:02.34567Z');
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '0001-01-01 00:00:00+00');
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '9999-12-31 23:59:59.999999+14');
INSERT INTO fdw_type_timestamp_tz VALUES (NULL);
INSERT INTO fdw_type_timestamp_tz VALUES ('2025-01-01 12:01:02.34567+9:00');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIME WITH TIME ZONE '04:05:06.789+9:00');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:01:02.34567 UTC');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:01:02.34567 Universal');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:00');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:00-16:00');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2025-01-01 12:00+16:00');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE '2021-02-30 04:05:06.789+9:00');  -- error
INSERT INTO fdw_type_timestamp_tz VALUES (TIMESTAMP WITH TIME ZONE 'invalid+tz');  -- error
SET datestyle TO ISO, YMD;
SELECT * FROM fdw_type_timestamp_tz;
SET datestyle TO 'default';

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE fdw_type_int;
DROP FOREIGN TABLE fdw_type_bigint;
DROP FOREIGN TABLE fdw_type_decimal;
DROP FOREIGN TABLE fdw_type_decimal_p;
DROP FOREIGN TABLE fdw_type_decimal_ps;
DROP FOREIGN TABLE fdw_type_numeric_v;
DROP FOREIGN TABLE fdw_type_numeric_p_v;
DROP FOREIGN TABLE fdw_type_numeric_ps_v;
DROP FOREIGN TABLE fdw_type_real;
DROP FOREIGN TABLE fdw_type_double;
DROP FOREIGN TABLE fdw_type_char;
DROP FOREIGN TABLE fdw_type_char_l;
DROP FOREIGN TABLE fdw_type_varchar;
DROP FOREIGN TABLE fdw_type_varchar_l;
DROP FOREIGN TABLE fdw_type_text;
DROP FOREIGN TABLE fdw_type_date;
DROP FOREIGN TABLE fdw_type_time;
--DROP FOREIGN TABLE fdw_type_time_tz;
DROP FOREIGN TABLE fdw_type_timestamp;
DROP FOREIGN TABLE fdw_type_timestamp_wo_tz;
DROP FOREIGN TABLE fdw_type_timestamp_tz;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE fdw_type_int', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_bigint', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_ps', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_v', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_p_v', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_ps_v', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_real', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_double', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_char', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_char_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_text', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_date', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_time', 'tsurugidb');
--SELECT tg_execute_ddl('DROP TABLE fdw_type_time_tz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_wo_tz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');
