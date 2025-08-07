/* Test case: happy path - Supported data types */
-- Test setup: PostgreSQL environment
SET timezone TO 'UTC';

-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_int (c INT)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_bigint (c BIGINT)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal (c DECIMAL)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_p (c DECIMAL(5))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_ps (c DECIMAL(5, 2))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_ps0 (c DECIMAL(38, 0))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_decimal_ps38 (c DECIMAL(38, 38))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric (c NUMERIC)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_p (c NUMERIC(5))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_ps (c NUMERIC(5, 2))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_ps0 (c NUMERIC(38, 0))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_numeric_ps38 (c NUMERIC(38, 38))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_real (c REAL)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_double (c DOUBLE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_char (c CHAR)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_char_l (c CHAR(10))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_varchar (c VARCHAR)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_varchar_l (c VARCHAR(10))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_text (c VARCHAR)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_date (c DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_time (c TIME)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp (c TIMESTAMP)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp_wo_tz (c TIMESTAMP WITHOUT TIME ZONE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp_tz (c TIMESTAMP WITH TIME ZONE)
', 'tsurugidb');

-- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_int (
  c integer
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_bigint (
  c bigint
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal (
  c decimal
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal_p (
  c decimal(5)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal_ps (
  c decimal(5, 2)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal_ps0 (
  c decimal(38, 0)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_decimal_ps38 (
  c decimal(38, 38)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric (
  c numeric
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric_p (
  c numeric(5)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric_ps (
  c numeric(5, 2)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric_ps0 (
  c numeric(38, 0)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_numeric_ps38 (
  c numeric(38, 38)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_real (
  c real
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_double (
  c double precision
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_char (
  c char
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_char_l (
  c char(10)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_varchar (
  c varchar
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_varchar_l (
  c varchar(10)
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_text (
  c text
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_date (
  c date
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_time (
  c time
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_timestamp (
  c timestamp
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_timestamp_wo_tz (
  c timestamp without time zone
) SERVER tsurugidb;
CREATE FOREIGN TABLE fdw_type_timestamp_tz (
  c timestamp with time zone
) SERVER tsurugidb;

-- Numeric Types
--- integer
INSERT INTO fdw_type_int VALUES (12345);
INSERT INTO fdw_type_int VALUES (-12345);
INSERT INTO fdw_type_int VALUES (NULL);
INSERT INTO fdw_type_int VALUES (2147483644); --max-3
INSERT INTO fdw_type_int VALUES (2147483645); --max-2
INSERT INTO fdw_type_int VALUES (2147483646); --max-1
INSERT INTO fdw_type_int VALUES (2147483647); --max
INSERT INTO fdw_type_int VALUES (-2147483645); --min+3
INSERT INTO fdw_type_int VALUES (-2147483646); --min+2
INSERT INTO fdw_type_int VALUES (-2147483647); --min+1
INSERT INTO fdw_type_int VALUES (-2147483648); --min
INSERT INTO fdw_type_int VALUES (CAST(1.1 AS int));
SELECT * FROM fdw_type_int ORDER BY c;

SELECT * FROM fdw_type_int WHERE c = 2147483647 ORDER BY c;
SELECT * FROM fdw_type_int WHERE c = -2147483648 ORDER BY c;

UPDATE fdw_type_int SET c = 2147483647 WHERE c = -2147483648;
SELECT * FROM fdw_type_int WHERE c = 2147483647 ORDER BY c;

UPDATE fdw_type_int SET c = -2147483648 WHERE c = 2147483647;
SELECT * FROM fdw_type_int WHERE c = -2147483648;
DELETE FROM fdw_type_int WHERE c = -2147483648;
SELECT * FROM fdw_type_int ORDER BY c;

UPDATE fdw_type_int SET c = 2147483647 WHERE c IS NULL;
DELETE FROM fdw_type_int WHERE c = 2147483647;
SELECT * FROM fdw_type_int ORDER BY c;

--- bigint
INSERT INTO fdw_type_bigint VALUES (12345);
INSERT INTO fdw_type_bigint VALUES (-12345);
INSERT INTO fdw_type_bigint VALUES (NULL);
INSERT INTO fdw_type_bigint VALUES (9223372036854775804);  --max-3
INSERT INTO fdw_type_bigint VALUES (9223372036854775805);  --max-2
INSERT INTO fdw_type_bigint VALUES (9223372036854775806);  --max-1
INSERT INTO fdw_type_bigint VALUES (9223372036854775807);  --max
INSERT INTO fdw_type_bigint VALUES (-9223372036854775805);  --min+3
INSERT INTO fdw_type_bigint VALUES (-9223372036854775806);  --min+2
INSERT INTO fdw_type_bigint VALUES (-9223372036854775807);  --min+1
INSERT INTO fdw_type_bigint VALUES (-9223372036854775808); --min
INSERT INTO fdw_type_bigint VALUES (CAST(1.1 AS bigint));
SELECT * FROM fdw_type_bigint ORDER BY c;

SELECT * FROM fdw_type_bigint WHERE c = 9223372036854775807 ORDER BY c;
SELECT * FROM fdw_type_bigint WHERE c = -9223372036854775808 ORDER BY c;

UPDATE fdw_type_bigint
  SET c = 9223372036854775807
  WHERE c = -9223372036854775808;
SELECT * FROM fdw_type_bigint WHERE c = 9223372036854775807 ORDER BY c;

UPDATE fdw_type_bigint
  SET c = -9223372036854775808
  WHERE c = 9223372036854775807;
DELETE FROM fdw_type_bigint WHERE c = -9223372036854775808;
SELECT * FROM fdw_type_bigint ORDER BY c;

UPDATE fdw_type_bigint SET c = 9223372036854775807 WHERE c IS NULL;
DELETE FROM fdw_type_bigint WHERE c = 9223372036854775807;
SELECT * FROM fdw_type_bigint ORDER BY c;

--- decimal
INSERT INTO fdw_type_decimal VALUES (12345);
INSERT INTO fdw_type_decimal VALUES (-12345);
INSERT INTO fdw_type_decimal VALUES (NULL);
SELECT * FROM fdw_type_decimal;

UPDATE fdw_type_decimal SET c = 987654 WHERE c IS NULL;
SELECT * FROM fdw_type_decimal ORDER BY c;

UPDATE fdw_type_decimal SET c = c * -1 WHERE c = 987654;
SELECT * FROM fdw_type_decimal ORDER BY c DESC;

DELETE FROM fdw_type_decimal WHERE c = -987654;
SELECT * FROM fdw_type_decimal ORDER BY c;

--- decimal(5)
INSERT INTO fdw_type_decimal_p VALUES (12345);
INSERT INTO fdw_type_decimal_p VALUES (-12345);
INSERT INTO fdw_type_decimal_p VALUES (NULL);
SELECT * FROM fdw_type_decimal_p;

UPDATE fdw_type_decimal_p SET c = 98765 WHERE c IS NULL;
SELECT * FROM fdw_type_decimal_p ORDER BY c;

UPDATE fdw_type_decimal_p SET c = c * -1 WHERE c = 98765;
SELECT * FROM fdw_type_decimal_p ORDER BY c DESC;

DELETE FROM fdw_type_decimal_p WHERE c = -98765;
SELECT * FROM fdw_type_decimal_p ORDER BY c;

--- decimal(5, 2)
INSERT INTO fdw_type_decimal_ps VALUES (123.45);
INSERT INTO fdw_type_decimal_ps VALUES (-123.45);
INSERT INTO fdw_type_decimal_ps VALUES (NULL);
SELECT * FROM fdw_type_decimal_ps;

UPDATE fdw_type_decimal_ps SET c = 987.65 WHERE c IS NULL;
SELECT * FROM fdw_type_decimal_ps ORDER BY c;

UPDATE fdw_type_decimal_ps SET c = c * -1 WHERE c = 987.65;
SELECT * FROM fdw_type_decimal_ps ORDER BY c DESC;

DELETE FROM fdw_type_decimal_ps WHERE c = -987.65;
SELECT * FROM fdw_type_decimal_ps ORDER BY c;

INSERT INTO fdw_type_decimal_ps VALUES(abs(-17.4));
INSERT INTO fdw_type_decimal_ps VALUES(ceil(-42.8));
INSERT INTO fdw_type_decimal_ps VALUES(floor(-42.8));
INSERT INTO fdw_type_decimal_ps VALUES(mod(9, 4));
INSERT INTO fdw_type_decimal_ps VALUES(round(42.4));
INSERT INTO fdw_type_decimal_ps VALUES(round(42.4382, 2));
SELECT * FROM fdw_type_decimal_ps;

--- decimal(38, 0)
INSERT INTO fdw_type_decimal_ps0 VALUES (0);
INSERT INTO fdw_type_decimal_ps0 VALUES (1);
INSERT INTO fdw_type_decimal_ps0 VALUES (18446744073709551615);
INSERT INTO fdw_type_decimal_ps0 VALUES (18446744073709551616);
INSERT INTO fdw_type_decimal_ps0 VALUES (99999999999999999999999999999999999999);
INSERT INTO fdw_type_decimal_ps0 VALUES (-1);
INSERT INTO fdw_type_decimal_ps0 VALUES (-18446744073709551615);
INSERT INTO fdw_type_decimal_ps0 VALUES (-18446744073709551616);
INSERT INTO fdw_type_decimal_ps0 VALUES (-99999999999999999999999999999999999999);
SELECT * FROM fdw_type_decimal_ps0;

--- decimal(38, 38)
INSERT INTO fdw_type_decimal_ps38 VALUES (0);
INSERT INTO fdw_type_decimal_ps38 VALUES (0.00000000000000000000000000000000000001);
INSERT INTO fdw_type_decimal_ps38 VALUES (0.00000000000000000018446744073709551615);
INSERT INTO fdw_type_decimal_ps38 VALUES (0.00000000000000000018446744073709551616);
INSERT INTO fdw_type_decimal_ps38 VALUES (0.99999999999999999999999999999999999999);
INSERT INTO fdw_type_decimal_ps38 VALUES (-0.00000000000000000000000000000000000001);
INSERT INTO fdw_type_decimal_ps38 VALUES (-0.00000000000000000018446744073709551615);
INSERT INTO fdw_type_decimal_ps38 VALUES (-0.00000000000000000018446744073709551616);
INSERT INTO fdw_type_decimal_ps38 VALUES (-0.99999999999999999999999999999999999999);
SELECT * FROM fdw_type_decimal_ps38;

--- numeric
INSERT INTO fdw_type_numeric VALUES (12345);
INSERT INTO fdw_type_numeric VALUES (-12345);
INSERT INTO fdw_type_numeric VALUES (NULL);
SELECT * FROM fdw_type_numeric;

UPDATE fdw_type_numeric SET c = 987654 WHERE c IS NULL;
SELECT * FROM fdw_type_numeric ORDER BY c;

UPDATE fdw_type_numeric SET c = c * -1 WHERE c = 987654;
SELECT * FROM fdw_type_numeric ORDER BY c DESC;

DELETE FROM fdw_type_numeric WHERE c = -987654;
SELECT * FROM fdw_type_numeric ORDER BY c;

--- numeric(5)
INSERT INTO fdw_type_numeric_p VALUES (12345);
INSERT INTO fdw_type_numeric_p VALUES (-12345);
INSERT INTO fdw_type_numeric_p VALUES (NULL);
SELECT * FROM fdw_type_numeric_p;

UPDATE fdw_type_numeric_p SET c = 98765 WHERE c IS NULL;
SELECT * FROM fdw_type_numeric_p ORDER BY c;

UPDATE fdw_type_numeric_p SET c = c * -1 WHERE c = 98765;
SELECT * FROM fdw_type_numeric_p ORDER BY c DESC;

DELETE FROM fdw_type_numeric_p WHERE c = -98765;
SELECT * FROM fdw_type_numeric_p ORDER BY c;

--- numeric(5, 2)
INSERT INTO fdw_type_numeric_ps VALUES (123.45);
INSERT INTO fdw_type_numeric_ps VALUES (-123.45);
INSERT INTO fdw_type_numeric_ps VALUES (NULL);
SELECT * FROM fdw_type_numeric_ps;

UPDATE fdw_type_numeric_ps SET c = 987.65 WHERE c IS NULL;
SELECT * FROM fdw_type_numeric_ps ORDER BY c;

UPDATE fdw_type_numeric_ps SET c = c * -1 WHERE c = 987.65;
SELECT * FROM fdw_type_numeric_ps ORDER BY c DESC;

DELETE FROM fdw_type_numeric_ps WHERE c = -987.65;
SELECT * FROM fdw_type_numeric_ps ORDER BY c;

INSERT INTO fdw_type_numeric_ps VALUES(abs(-17.4));
INSERT INTO fdw_type_numeric_ps VALUES(ceil(-42.8));
INSERT INTO fdw_type_numeric_ps VALUES(floor(-42.8));
INSERT INTO fdw_type_numeric_ps VALUES(mod(9, 4));
INSERT INTO fdw_type_numeric_ps VALUES(round(42.4));
INSERT INTO fdw_type_numeric_ps VALUES(round(42.4382, 2));
SELECT * FROM fdw_type_numeric_ps;

--- numeric(38, 0)
INSERT INTO fdw_type_numeric_ps0 VALUES (0);
INSERT INTO fdw_type_numeric_ps0 VALUES (1);
INSERT INTO fdw_type_numeric_ps0 VALUES (18446744073709551615);
INSERT INTO fdw_type_numeric_ps0 VALUES (18446744073709551616);
INSERT INTO fdw_type_numeric_ps0 VALUES (99999999999999999999999999999999999999);
INSERT INTO fdw_type_numeric_ps0 VALUES (-1);
INSERT INTO fdw_type_numeric_ps0 VALUES (-18446744073709551615);
INSERT INTO fdw_type_numeric_ps0 VALUES (-18446744073709551616);
INSERT INTO fdw_type_numeric_ps0 VALUES (-99999999999999999999999999999999999999);
SELECT * FROM fdw_type_numeric_ps0;

--- numeric(38, 38)
INSERT INTO fdw_type_numeric_ps38 VALUES (0);  -- see tsurugi-issues#736
INSERT INTO fdw_type_numeric_ps38 VALUES (0.00000000000000000000000000000000000001);
INSERT INTO fdw_type_numeric_ps38 VALUES (0.00000000000000000018446744073709551615);
INSERT INTO fdw_type_numeric_ps38 VALUES (0.00000000000000000018446744073709551616);
INSERT INTO fdw_type_numeric_ps38 VALUES (0.99999999999999999999999999999999999999);
INSERT INTO fdw_type_numeric_ps38 VALUES (-0.00000000000000000000000000000000000001);
INSERT INTO fdw_type_numeric_ps38 VALUES (-0.00000000000000000018446744073709551615);
INSERT INTO fdw_type_numeric_ps38 VALUES (-0.00000000000000000018446744073709551616);
INSERT INTO fdw_type_numeric_ps38 VALUES (-0.99999999999999999999999999999999999999);
SELECT * FROM fdw_type_numeric_ps38;

--- real
INSERT INTO fdw_type_real VALUES (0.1);
INSERT INTO fdw_type_real VALUES (1.1);
INSERT INTO fdw_type_real VALUES (1.2345);
INSERT INTO fdw_type_real VALUES (-1.2345);
INSERT INTO fdw_type_real VALUES (NULL);
INSERT INTO fdw_type_real VALUES (12.345678901234567890); --20 digits
SELECT * FROM fdw_type_real ORDER BY c;

UPDATE fdw_type_real SET c = 9.87654 WHERE c IS NULL;
SELECT * FROM fdw_type_real ORDER BY c;

UPDATE fdw_type_real SET c = c * -1 WHERE c = 9.87654::real;
SELECT * FROM fdw_type_real ORDER BY c DESC;

DELETE FROM fdw_type_real WHERE c = CAST(-9.87654 AS real);
SELECT * FROM fdw_type_real ORDER BY c;

--- double precision
INSERT INTO fdw_type_double VALUES (0.1);
INSERT INTO fdw_type_double VALUES (1.1);
INSERT INTO fdw_type_double VALUES (1.2345);
INSERT INTO fdw_type_double VALUES (-1.2345);
INSERT INTO fdw_type_double VALUES (NULL);
INSERT INTO fdw_type_double VALUES (12.345678901234567890); --20 digits
SELECT * FROM fdw_type_double ORDER BY c;

UPDATE fdw_type_double SET c = 9.87654 WHERE c IS NULL;
SELECT * FROM fdw_type_double ORDER BY c;

UPDATE fdw_type_double SET c = c * -1 WHERE c = 9.87654::double precision;
SELECT * FROM fdw_type_double ORDER BY c DESC;

DELETE FROM fdw_type_double WHERE c = CAST(-9.87654 AS double precision);
SELECT * FROM fdw_type_double ORDER BY c;

-- Character Types
--- char
INSERT INTO fdw_type_char VALUES ('a');
INSERT INTO fdw_type_char VALUES ('');
INSERT INTO fdw_type_char VALUES (NULL);
INSERT INTO fdw_type_char VALUES (1);  -- auto-cast
SELECT * FROM fdw_type_char ORDER BY c;

UPDATE fdw_type_char SET c = 'X' WHERE c IS NULL;
SELECT * FROM fdw_type_char ORDER BY c;

UPDATE fdw_type_char SET c = 'z' WHERE c = 'X';
SELECT * FROM fdw_type_char ORDER BY c DESC;

DELETE FROM fdw_type_char WHERE c = 'z';
SELECT * FROM fdw_type_char ORDER BY c;

--- char(length)
INSERT INTO fdw_type_char_l VALUES ('abcdef');
INSERT INTO fdw_type_char_l VALUES ('PostgreSQL');
INSERT INTO fdw_type_char_l VALUES ('');
INSERT INTO fdw_type_char_l VALUES (NULL);
INSERT INTO fdw_type_char_l VALUES (12345);  -- auto-cast
SELECT * FROM fdw_type_char_l ORDER BY c;

UPDATE fdw_type_char_l SET c = 'NULL' WHERE c IS NULL;
SELECT * FROM fdw_type_char_l ORDER BY c;

UPDATE fdw_type_char_l SET c = 'update' WHERE c = CAST('NULL' AS char(10));
SELECT * FROM fdw_type_char_l ORDER BY c DESC;

DELETE FROM fdw_type_char_l WHERE c = 'update'::char(10);
SELECT * FROM fdw_type_char_l ORDER BY c;

--- varchar
INSERT INTO fdw_type_varchar VALUES ('abcdef');
INSERT INTO fdw_type_varchar VALUES ('');
INSERT INTO fdw_type_varchar VALUES (NULL);
INSERT INTO fdw_type_varchar VALUES (12345);  -- auto-cast
SELECT * FROM fdw_type_varchar ORDER BY c;

UPDATE fdw_type_varchar SET c = 'NULL' WHERE c IS NULL;
SELECT * FROM fdw_type_varchar ORDER BY c;

UPDATE fdw_type_varchar SET c = c || '_updated' WHERE c = 'NULL';
SELECT * FROM fdw_type_varchar ORDER BY c DESC;

DELETE FROM fdw_type_varchar WHERE c = 'NULL_updated';
SELECT * FROM fdw_type_varchar ORDER BY c;

--- varchar(length)
INSERT INTO fdw_type_varchar_l VALUES ('abcdef');
INSERT INTO fdw_type_varchar_l VALUES ('PostgreSQL');
INSERT INTO fdw_type_varchar_l VALUES ('');
INSERT INTO fdw_type_varchar_l VALUES (NULL);
INSERT INTO fdw_type_varchar_l VALUES (12345);  -- auto-cast
SELECT * FROM fdw_type_varchar_l ORDER BY c;

UPDATE fdw_type_varchar_l SET c = 'NULL' WHERE c IS NULL;
SELECT * FROM fdw_type_varchar_l ORDER BY c;

UPDATE fdw_type_varchar_l SET c = 'update' WHERE c = 'NULL';
SELECT * FROM fdw_type_varchar_l ORDER BY c DESC;

DELETE FROM fdw_type_varchar_l WHERE c = 'update';
SELECT * FROM fdw_type_varchar_l ORDER BY c;

--- text
INSERT INTO fdw_type_text VALUES ('abcdef');
INSERT INTO fdw_type_text VALUES ('');
INSERT INTO fdw_type_text VALUES (NULL);
INSERT INTO fdw_type_text VALUES (12345);  -- auto-cast
SELECT * FROM fdw_type_text ORDER BY c;

UPDATE fdw_type_text SET c = 'NULL' WHERE c IS NULL;
SELECT * FROM fdw_type_text ORDER BY c;

UPDATE fdw_type_text SET c = c || '_updated' WHERE c = 'NULL';
SELECT * FROM fdw_type_text ORDER BY c DESC;

DELETE FROM fdw_type_text WHERE c = 'NULL_updated';
SELECT * FROM fdw_type_text ORDER BY c;

-- Date/Time Types
SET DATESTYLE TO ISO, YMD;

--- date
INSERT INTO fdw_type_date VALUES (date '2025-01-01');
INSERT INTO fdw_type_date VALUES ('2025-01-02'::date);
INSERT INTO fdw_type_date VALUES (CAST('2025-01-03' AS date));
INSERT INTO fdw_type_date VALUES (date '0001-01-01');
INSERT INTO fdw_type_date VALUES (date '9999-12-31');
INSERT INTO fdw_type_date VALUES (NULL);
INSERT INTO fdw_type_date VALUES ('2024-12-31');  -- auto cast (tsurugi-issues#896)
SELECT * FROM fdw_type_date ORDER BY c;

UPDATE fdw_type_date SET c = '2025-02-01' WHERE c IS NULL;
SELECT * FROM fdw_type_date ORDER BY c;

UPDATE fdw_type_date SET c = '2025-03-10'::date WHERE c = date '2025-02-01';
SELECT * FROM fdw_type_date ORDER BY c DESC;

DELETE FROM fdw_type_date WHERE c = CAST('2025-03-10' AS date);
SELECT * FROM fdw_type_date ORDER BY c;

--- time
INSERT INTO fdw_type_time VALUES (time '01:02:03.456');
INSERT INTO fdw_type_time VALUES ('03:02:01.456'::time);
INSERT INTO fdw_type_time VALUES (CAST('02:01:03.456' AS time));
INSERT INTO fdw_type_time VALUES (time '01:02:03.456789012');
INSERT INTO fdw_type_time VALUES (time '00:00:00');
INSERT INTO fdw_type_time VALUES (time '23:59:59.999999');
INSERT INTO fdw_type_time VALUES (NULL);
INSERT INTO fdw_type_time VALUES ('04:05:06.789');  -- auto cast (tsurugi-issues#896)
SELECT * FROM fdw_type_time ORDER BY c;

UPDATE fdw_type_time SET c = '00:00:00.001' WHERE c IS NULL;
SELECT * FROM fdw_type_time ORDER BY c;

UPDATE fdw_type_time SET c = '05:06:12.345'::time WHERE c = time '00:00:00.001';
SELECT * FROM fdw_type_time ORDER BY c DESC;

DELETE FROM fdw_type_time WHERE c = CAST('05:06:12.345' AS time);
SELECT * FROM fdw_type_time ORDER BY c;


--- timestamp
INSERT INTO fdw_type_timestamp VALUES (timestamp '2025-01-01 00:00:00');
INSERT INTO fdw_type_timestamp VALUES ('2025-01-02 00:00:00'::timestamp);
INSERT INTO fdw_type_timestamp VALUES (CAST('2025-01-03 00:00:00' AS timestamp));
INSERT INTO fdw_type_timestamp VALUES (timestamp '1887-12-31 15:00:00');
INSERT INTO fdw_type_timestamp VALUES (timestamp '9999-12-31 23:59:59.999999');
INSERT INTO fdw_type_timestamp VALUES (NULL);
INSERT INTO fdw_type_timestamp VALUES ('2024-08-30 04:05:06.789');  -- auto cast (tsurugi-issues#896)
SELECT * FROM fdw_type_timestamp ORDER BY c;

UPDATE fdw_type_timestamp SET c = '2025-01-01 00:00:00.001' WHERE c IS NULL;
SELECT * FROM fdw_type_timestamp ORDER BY c;

UPDATE fdw_type_timestamp
  SET c = '2025-03-02 05:06:12.345'::timestamp
  WHERE c = timestamp '2025-01-01 00:00:00.001';
SELECT * FROM fdw_type_timestamp ORDER BY c DESC;

DELETE
  FROM fdw_type_timestamp
  WHERE c = CAST('2025-03-02 05:06:12.345' AS timestamp);
SELECT * FROM fdw_type_timestamp ORDER BY c;

--- timestamp without time zone
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2025-01-01 00:00:00');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES ('2025-01-02 00:00:00'::timestamp without time zone);
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (CAST('2025-01-03 00:00:00' AS timestamp without time zone));
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '1887-12-31 15:00:00');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '9999-12-31 23:59:59.999999');
INSERT INTO fdw_type_timestamp_wo_tz VALUES (NULL);
INSERT INTO fdw_type_timestamp_wo_tz VALUES ('2024-08-30 04:05:06.789');
SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c;

UPDATE fdw_type_timestamp_wo_tz
  SET c = '2025-01-01 00:00:00.001'
  WHERE c IS NULL;
SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c;

UPDATE fdw_type_timestamp_wo_tz
  SET c = '2025-03-02 05:06:12.345'::timestamp without time zone
  WHERE c = '2025-01-01 00:00:00.001'::timestamp without time zone;
SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c DESC;

DELETE FROM fdw_type_timestamp_wo_tz
  WHERE c = CAST('2025-03-02 05:06:12.345' AS timestamp without time zone);
SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c;

--- timestamp with time zone
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (timestamp with time zone '2025-01-01 12:01:02.34567+9:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES
  ('2025-01-02 12:01:02.34567+9:00'::timestamp with time zone);
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (CAST('2025-01-03 12:01:02.34567+9:00' AS timestamp with time zone));
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (timestamp with time zone '2025-01-01 12:01:02.34567+900');
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (timestamp with time zone '2025-01-01 12:01:02.34567+9');
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (timestamp with time zone '2025-01-01 12:01:02.34567Z');
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (timestamp with time zone '2025-01-01T12:01:02.34567Z');
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (timestamp with time zone '1887-12-31 15:00:00+00');
INSERT INTO fdw_type_timestamp_tz
  VALUES
  (timestamp with time zone '9999-12-31 23:59:59.999999+14');
INSERT INTO fdw_type_timestamp_tz VALUES (NULL);
INSERT INTO fdw_type_timestamp_tz VALUES ('2024-08-30 04:05:06.789+9:00');

SET SESSION TIMEZONE TO 'UTC';  -- check time zone in UTC
SELECT * FROM fdw_type_timestamp_tz ORDER BY c;

SET SESSION TIMEZONE TO 'Asia/Tokyo';  -- check time zone in Asia/Tokyo
SELECT * FROM fdw_type_timestamp_tz ORDER BY c;

UPDATE fdw_type_timestamp_tz SET c = '2025-01-01 00:00:00.001+900' WHERE c IS NULL;
SELECT * FROM fdw_type_timestamp_tz ORDER BY c;

UPDATE fdw_type_timestamp_tz
  SET c = '2025-03-02 05:06:12.345+900'::timestamp with time zone
  WHERE c = '2025-01-01 00:00:00.001+900'::timestamp with time zone;
SELECT * FROM fdw_type_timestamp_tz ORDER BY c DESC;

DELETE FROM fdw_type_timestamp_tz
  WHERE c = CAST('2025-03-02 05:06:12.345+900' AS timestamp with time zone);
SELECT * FROM fdw_type_timestamp_tz ORDER BY c;

SET DATESTYLE TO 'default';

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE fdw_type_int;
DROP FOREIGN TABLE fdw_type_bigint;
DROP FOREIGN TABLE fdw_type_decimal;
DROP FOREIGN TABLE fdw_type_decimal_p;
DROP FOREIGN TABLE fdw_type_decimal_ps;
DROP FOREIGN TABLE fdw_type_decimal_ps0;
DROP FOREIGN TABLE fdw_type_decimal_ps38;
DROP FOREIGN TABLE fdw_type_numeric;
DROP FOREIGN TABLE fdw_type_numeric_p;
DROP FOREIGN TABLE fdw_type_numeric_ps;
DROP FOREIGN TABLE fdw_type_numeric_ps0;
DROP FOREIGN TABLE fdw_type_numeric_ps38;
DROP FOREIGN TABLE fdw_type_real;
DROP FOREIGN TABLE fdw_type_double;
DROP FOREIGN TABLE fdw_type_char;
DROP FOREIGN TABLE fdw_type_char_l;
DROP FOREIGN TABLE fdw_type_varchar;
DROP FOREIGN TABLE fdw_type_varchar_l;
DROP FOREIGN TABLE fdw_type_text;
DROP FOREIGN TABLE fdw_type_date;
DROP FOREIGN TABLE fdw_type_time;
DROP FOREIGN TABLE fdw_type_timestamp;
DROP FOREIGN TABLE fdw_type_timestamp_wo_tz;
DROP FOREIGN TABLE fdw_type_timestamp_tz;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE fdw_type_int', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_bigint', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_ps', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_ps0', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_decimal_ps38', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_p', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_ps', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_ps0', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_numeric_ps38', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_real', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_double', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_char', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_char_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_text', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_date', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_time', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_wo_tz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');
