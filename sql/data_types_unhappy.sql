/* Test case: unhappy path - Unsupported data types */

-- Numeric Types - integer
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_int (c INT)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_int (
  c integer
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_int VALUES (2147483648);
INSERT INTO fdw_type_int VALUES (-2147483649);
INSERT INTO fdw_type_int VALUES (2.1);  -- see tsurugi-issues#736
INSERT INTO fdw_type_int VALUES ('invalid');

INSERT INTO fdw_type_int VALUES (0);
UPDATE fdw_type_int SET c = 2147483648;
UPDATE fdw_type_int SET c = 1 + 2147483648;
UPDATE fdw_type_int SET c = -2147483649;
UPDATE fdw_type_int SET c = -1 - -2147483649;
UPDATE fdw_type_int SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_int SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_int WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_int;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_int', 'tsurugidb');

-- Numeric Types - bigint
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_bigint (c BIGINT)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_bigint (
  c bigint
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_bigint VALUES (9223372036854775808);
INSERT INTO fdw_type_bigint VALUES (-9223372036854775809);
INSERT INTO fdw_type_bigint VALUES (2.1);  -- see tsurugi-issues#736
INSERT INTO fdw_type_bigint VALUES ('invalid');

INSERT INTO fdw_type_bigint VALUES (0);
UPDATE fdw_type_bigint SET c = 9223372036854775808;
UPDATE fdw_type_bigint SET c = 1 + 9223372036854775808;
UPDATE fdw_type_bigint SET c = -9223372036854775809;
UPDATE fdw_type_bigint SET c = -1 - -9223372036854775809;
UPDATE fdw_type_bigint SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_bigint SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_bigint WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_bigint;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_bigint', 'tsurugidb');

-- Numeric Types - decimal
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal (c DECIMAL)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_decimal (
  c decimal
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_decimal VALUES ('invalid');
UPDATE fdw_type_decimal SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_decimal SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_decimal WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_decimal;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal', 'tsurugidb');

-- Numeric Types - decimal(5)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_p (c DECIMAL(5))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_decimal_p (
  c decimal(5)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_decimal_p VALUES (123456);
INSERT INTO fdw_type_decimal_p VALUES ('invalid');
UPDATE fdw_type_decimal_p SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_decimal_p SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_decimal_p WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_decimal_p;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_p', 'tsurugidb');

-- Numeric Types - decimal(5, 2)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_ps (c DECIMAL(5, 2))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_decimal_ps (
  c decimal(5, 2)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_decimal_ps VALUES (1234);
INSERT INTO fdw_type_decimal_ps VALUES (1234.56);
INSERT INTO fdw_type_decimal_ps VALUES (123.567);
INSERT INTO fdw_type_decimal_ps VALUES ('invalid');
UPDATE fdw_type_decimal_ps SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_decimal_ps SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_decimal_ps WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_decimal_ps;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_ps', 'tsurugidb');

-- Numeric Types - decimal(38, 0)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_ps0 (c DECIMAL(38, 0))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_decimal_ps0 (
  c decimal(38, 0)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_decimal_ps0
  VALUES (100000000000000000000000000000000000000);
INSERT INTO fdw_type_decimal_ps0
  VALUES (340282366920938463463374607431768211455);
INSERT INTO fdw_type_decimal_ps0
  VALUES (340282366920938463463374607431768211456);

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_decimal_ps0;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_ps0', 'tsurugidb');

-- Numeric Types - decimal(38, 38)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_ps38 (c DECIMAL(38, 38))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_decimal_ps38 (
  c decimal(38, 38)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_decimal_ps38 VALUES (1);
INSERT INTO fdw_type_decimal_ps38
  VALUES (0.000000000000000000000000000000000000001);
INSERT INTO fdw_type_decimal_ps38
  VALUES (0.340282366920938463463374607431768211455);
INSERT INTO fdw_type_decimal_ps38
  VALUES (0.340282366920938463463374607431768211456);

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_decimal_ps38;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_ps38', 'tsurugidb');

-- Numeric Types - numeric
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric (c NUMERIC)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_numeric (
  c numeric
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_numeric VALUES ('invalid');
UPDATE fdw_type_numeric SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_numeric SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_numeric WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_numeric;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric', 'tsurugidb');

-- Numeric Types - numeric(5)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_p (c NUMERIC(5))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_numeric_p (
  c numeric(5)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_numeric_p VALUES (123456);
INSERT INTO fdw_type_numeric_p VALUES ('invalid');
UPDATE fdw_type_numeric_p SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_numeric_p SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_numeric_p WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_numeric_p;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_p', 'tsurugidb');

-- Numeric Types - numeric(5, 2)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_ps (c NUMERIC(5, 2))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_numeric_ps (
  c numeric(5, 2)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_numeric_ps VALUES (1234);
INSERT INTO fdw_type_numeric_ps VALUES (1234.56);
INSERT INTO fdw_type_numeric_ps VALUES (123.567);
INSERT INTO fdw_type_numeric_ps VALUES ('invalid');
UPDATE fdw_type_numeric_ps SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_numeric_ps SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_numeric_ps WHERE invalid >= 1;

INSERT INTO fdw_type_numeric_ps VALUES (ceiling(-95.3));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(cbrt(27.0) AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(degrees(0.5) AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (div(9,4));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(exp(1.0) AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (factorial(5));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(ln(2.0) AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (log(100.0));
INSERT INTO fdw_type_numeric_ps VALUES (log10(100.0));
INSERT INTO fdw_type_numeric_ps VALUES (log(2.0, 64.0));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(pi() AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (power(9.0, 3.0));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(radians(45.0) AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (sign(-8.4));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(scale(8.41) AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (CAST(sqrt(2.0) AS DECIMAL(5, 2)));
INSERT INTO fdw_type_numeric_ps VALUES (trunc(42.8));
INSERT INTO fdw_type_numeric_ps VALUES (trunc(42.4382, 2));

INSERT INTO fdw_type_numeric_ps
  VALUES (CAST(width_bucket(5.35, 0.024, 5, 2, 5) AS DECIMAL(5, 2)));

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_numeric_ps;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_ps', 'tsurugidb');

-- Numeric Types - numeric(38, 0)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_ps0 (c NUMERIC(38, 0))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_numeric_ps0 (
  c numeric(38, 0)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_numeric_ps0
  VALUES (100000000000000000000000000000000000000);
INSERT INTO fdw_type_numeric_ps0
  VALUES (340282366920938463463374607431768211455);
INSERT INTO fdw_type_numeric_ps0
  VALUES (340282366920938463463374607431768211456);

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_numeric_ps0;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_ps0', 'tsurugidb');

-- Numeric Types - numeric(38, 38)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_ps38 (c NUMERIC(38, 38))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_numeric_ps38 (
  c numeric(38, 38)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_numeric_ps38 VALUES (1);
INSERT INTO fdw_type_numeric_ps38
  VALUES (0.000000000000000000000000000000000000001);
INSERT INTO fdw_type_numeric_ps38
  VALUES (0.340282366920938463463374607431768211455);
INSERT INTO fdw_type_numeric_ps38
  VALUES (0.340282366920938463463374607431768211456);

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_numeric_ps38;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_ps38', 'tsurugidb');

-- Numeric Types - real
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_real (c REAL)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_real (
  c real
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_real VALUES ('invalid');
UPDATE fdw_type_real SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_real SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_real WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_real;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_real', 'tsurugidb');

-- Numeric Types - double precision
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_double (c DOUBLE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_double (
  c double precision
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_double VALUES ('invalid');
UPDATE fdw_type_double SET invalid = 2 WHERE c >= 1;
UPDATE fdw_type_double SET c = 2 WHERE invalid = 1;
DELETE FROM fdw_type_double WHERE invalid >= 1;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_double;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_double', 'tsurugidb');

-- Character Types - char
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_char (c CHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_char (
  c char
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_char VALUES ('iX');
INSERT INTO fdw_type_char VALUES ('i');
UPDATE fdw_type_char SET c = 'uX';
UPDATE fdw_type_char SET invalid = 'u' WHERE c = 'i';
UPDATE fdw_type_char SET c = 'u' WHERE invalid = 'i';
DELETE FROM fdw_type_char WHERE invalid = 'i';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_char;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_char', 'tsurugidb');

-- Character Types - char(length)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_char_l (c CHAR(10))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_char_l (
  c char(10)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_char_l VALUES ('insert_valX');
INSERT INTO fdw_type_char_l VALUES ('insert_val');
UPDATE fdw_type_char_l SET c = 'update_valX';
UPDATE fdw_type_char_l SET invalid = 'update_val' WHERE c = 'insert_val';
UPDATE fdw_type_char_l SET c = 'update_valX' WHERE invalid = 'insert_val';
DELETE FROM fdw_type_char_l WHERE c = 'update_valX';
DELETE FROM fdw_type_char_l WHERE invalid = 'insert_val';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_char_l;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_char_l', 'tsurugidb');

-- Character Types - varchar(length)
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_varchar_l (c VARCHAR(10))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_varchar_l (
  c varchar(10)
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_varchar_l VALUES ('insert_valX');
INSERT INTO fdw_type_varchar_l VALUES ('insert_val');
UPDATE fdw_type_varchar_l SET c = 'update_valX';
UPDATE fdw_type_varchar_l SET invalid = 'update_val' WHERE c = 'insert_val';
UPDATE fdw_type_varchar_l SET c = 'update_valX' WHERE invalid = 'insert_val';

DELETE FROM fdw_type_varchar_l WHERE c = 'update_valX';
DELETE FROM fdw_type_varchar_l WHERE invalid = 'insert_val';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_varchar_l;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar_l', 'tsurugidb');

-- Date/Time Types - date
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_date (c DATE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_date (
  c date
) SERVER tsurugidb;

--- Test
SET DATESTYLE TO 'default';
INSERT INTO fdw_type_date VALUES (date '01:02:03.456');
INSERT INTO fdw_type_date VALUES (time '01:02:03.456');
INSERT INTO fdw_type_date VALUES (date '2021-02-30');
INSERT INTO fdw_type_date VALUES (date 'invalid');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_date VALUES (date '1/8/1999');
INSERT INTO fdw_type_date VALUES (date '1/18/1999');
INSERT INTO fdw_type_date VALUES (date '08-Jan-99');
INSERT INTO fdw_type_date VALUES (date 'Jan-08-99');
INSERT INTO fdw_type_date VALUES (date 'January 8, 99 BC');
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_date;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_date', 'tsurugidb');

-- Date/Time Types - time
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_time (c TIME)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_time (
  c time
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_time VALUES (date '2025/01/01');
INSERT INTO fdw_type_time VALUES (time '2025/01/01');
INSERT INTO fdw_type_time VALUES (time '25:00:00');
INSERT INTO fdw_type_time VALUES (time '050607.890123456');
INSERT INTO fdw_type_time VALUES (time 'invalid');

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_time;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_time', 'tsurugidb');

-- Date/Time Types - timestamp
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp (c TIMESTAMP)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_timestamp (
  c timestamp
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_timestamp VALUES (timestamp '01:02:03.456');
INSERT INTO fdw_type_timestamp VALUES (date '2021-02-30');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2021-02-30 04:05:06.789');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2025-01-01 25:00:00');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2025/01/01');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2025/01/01 12:00');
INSERT INTO fdw_type_timestamp VALUES (timestamp 'invalid');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_timestamp VALUES (timestamp '1/8/1999 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp '1/18/1999 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp '08-Jan-99 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp 'Jan-08-99 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp 'January 8, 99 BC 01:02:03');
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp', 'tsurugidb');

-- Date/Time Types - timestamp without time zone
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp_wo_tz (c TIMESTAMP WITHOUT TIME ZONE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_timestamp_wo_tz (
  c timestamp without time zone
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '01:02:03.456');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (date '2021-02-30');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2021-02-30 04:05:06.789');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2025-01-01 25:00:00');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2025/01/01');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2025/01/01 12:00');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone 'invalid');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '1/8/1999 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '1/18/1999 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '08-Jan-99 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone 'Jan-08-99 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone 'January 8, 99 BC 01:02:03');
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_wo_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_wo_tz', 'tsurugidb');

-- Date/Time Types - timestamp with time zone
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp_tz (c TIMESTAMP WITH TIME ZONE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_timestamp_tz (
  c timestamp with time zone
) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_timestamp_tz
  VALUES (time with time zone '04:05:06.789+9:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:00-16:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:00+16:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2021-02-30 04:05:06.789+9:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone 'invalid+tz');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '1/8/1999 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '1/18/1999 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '08-Jan-99 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone 'Jan-08-99 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone 'January 8, 99 BC 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:01:02.34567 UTC');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:01:02.34567 Universal');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:00');
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');

-- Unsupported Types - serial
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c1 INTEGER, c2 CHAR(14))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c1 serial, c2 char(14)) SERVER tsurugidb;

--- Test
INSERT INTO fdw_type_unsupported (c2) VALUES ('serial is null');
SELECT * FROM fdw_type_unsupported;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - bigserial
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c1 BIGINT, c2 CHAR(14))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c1 bigserial, c2 char(14))
  SERVER tsurugidb;

-- Test
INSERT INTO fdw_type_unsupported (c2) VALUES ('serial is null');
SELECT * FROM fdw_type_unsupported;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');
