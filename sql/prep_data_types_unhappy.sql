/* Test case: unhappy path - Unsupported data types (preparation) */
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
  CREATE TABLE fdw_type_varchar_l (c VARCHAR(10))
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
CREATE FOREIGN TABLE fdw_type_varchar_l (
  c varchar(10)
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
PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_type_int VALUES ($1);

EXECUTE fdw_prepare_ins (2147483648);
EXECUTE fdw_prepare_ins (-2147483649);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS INSERT INTO fdw_type_int VALUES (1.1);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS INSERT INTO fdw_type_int VALUES (0.1);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_int VALUES (CAST(0.1 AS int));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd (integer) AS UPDATE fdw_type_int SET c = $1;
EXECUTE fdw_prepare_upd (2147483648);
EXECUTE fdw_prepare_upd (1 + 2147483648);
EXECUTE fdw_prepare_upd (-2147483649);
EXECUTE fdw_prepare_upd (-1 - -2147483649);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_int SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_int SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_int WHERE invalid >= 1;

--- bigint
PREPARE fdw_prepare_ins (bigint) AS
  INSERT INTO fdw_type_bigint VALUES ($1);
EXECUTE fdw_prepare_ins (9223372036854775808);
EXECUTE fdw_prepare_ins (-9223372036854775809);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS INSERT INTO fdw_type_bigint VALUES (1.1);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS INSERT INTO fdw_type_bigint VALUES (0.1);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_bigint VALUES (CAST(0.1 AS bigint));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd (bigint) AS UPDATE fdw_type_bigint SET c = $1;
EXECUTE fdw_prepare_upd (9223372036854775808);
EXECUTE fdw_prepare_upd (1 + 9223372036854775808);
EXECUTE fdw_prepare_upd (-9223372036854775809);
EXECUTE fdw_prepare_upd (-1 - -9223372036854775809);
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_bigint SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_bigint SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_bigint WHERE invalid >= 1;

--- decimal
PREPARE fdw_prepare_ins (decimal) AS
  INSERT INTO fdw_type_decimal VALUES ($1);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_decimal WHERE invalid >= 1;

--- decimal(5)
PREPARE fdw_prepare_ins (decimal(5)) AS
  INSERT INTO fdw_type_decimal_p VALUES ($1);
EXECUTE fdw_prepare_ins (123456);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_decimal WHERE invalid >= 1;

--- decimal(5, 2)
PREPARE fdw_prepare_ins (decimal(5, 2)) AS
  INSERT INTO fdw_type_decimal_ps VALUES ($1);
EXECUTE fdw_prepare_ins (1234);
EXECUTE fdw_prepare_ins (1234.56);
EXECUTE fdw_prepare_ins (123.567);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_decimal WHERE invalid >= 1;

--- decimal(38, 0)
PREPARE fdw_prepare_ins (decimal(38, 0)) AS
  INSERT INTO fdw_type_decimal_ps0 VALUES ($1);
EXECUTE fdw_prepare_ins (100000000000000000000000000000000000000);
EXECUTE fdw_prepare_ins (340282366920938463463374607431768211455);
EXECUTE fdw_prepare_ins (340282366920938463463374607431768211456);
DEALLOCATE fdw_prepare_ins;

--- decimal(38, 38)
PREPARE fdw_prepare_ins (decimal(38, 38)) AS
  INSERT INTO fdw_type_decimal_ps38 VALUES ($1);
EXECUTE fdw_prepare_ins (1);
EXECUTE fdw_prepare_ins (0.000000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins (0.340282366920938463463374607431768211455);
EXECUTE fdw_prepare_ins (0.340282366920938463463374607431768211456);
DEALLOCATE fdw_prepare_ins;

--- numeric
PREPARE fdw_prepare_ins (numeric) AS
  INSERT INTO fdw_type_numeric VALUES ($1);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_numeric SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_numeric SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_numeric WHERE invalid >= 1;

--- numeric(5)
PREPARE fdw_prepare_ins (numeric(5)) AS
  INSERT INTO fdw_type_numeric_p VALUES ($1);
EXECUTE fdw_prepare_ins (123456);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_numeric_p SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_numeric_p SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_numeric_p WHERE invalid >= 1;

--- numeric(5, 2)
PREPARE fdw_prepare_ins (numeric(5, 2)) AS
  INSERT INTO fdw_type_numeric_ps VALUES ($1);
EXECUTE fdw_prepare_ins (1234);
EXECUTE fdw_prepare_ins (1234.56);
EXECUTE fdw_prepare_ins (123.567);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_numeric_ps SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_numeric_ps SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_numeric_ps WHERE invalid >= 1;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (ceiling(-95.3));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (div(9,4));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (CAST(exp(1.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (factorial(5));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (CAST(ln(2.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (log(100.0));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (log10(100.0));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (log(2.0, 64.0));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (power(9.0, 3.0));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (sign(-8.4));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (CAST(sqrt(2.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (trunc(42.8));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (trunc(42.4382, 2));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (CAST(cbrt(27.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps
    VALUES (CAST(degrees(0.5) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps VALUES (CAST(pi() AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps
    VALUES (CAST(radians(45.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps
    VALUES (CAST(scale(8.41) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps
    VALUES (CAST(width_bucket(5.35, 0.024, 5, 2, 5) AS DECIMAL(5, 2)));

--- numeric(38, 0)
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps0
    VALUES (100000000000000000000000000000000000000);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps0
    VALUES (340282366920938463463374607431768211455);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps0
    VALUES (340282366920938463463374607431768211456);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

--- numeric(38, 38)
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps38 VALUES (1);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps38
    VALUES (0.000000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps38
    VALUES (0.340282366920938463463374607431768211455);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_numeric_ps38
    VALUES (0.340282366920938463463374607431768211456);
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

--- real
PREPARE fdw_prepare_ins (real) AS
  INSERT INTO fdw_type_real VALUES ($1);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_real SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_real SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_real WHERE invalid >= 1;

--- double precision
PREPARE fdw_prepare_ins (double precision) AS
  INSERT INTO fdw_type_double VALUES ($1);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_double SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_double SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_double WHERE invalid >= 1;

-- Character Types
--- char
PREPARE fdw_prepare_ins (char) AS
  INSERT INTO fdw_type_char VALUES ($1);
EXECUTE fdw_prepare_ins ('iX');
EXECUTE fdw_prepare_ins ('i');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd (char) AS UPDATE fdw_type_char SET c = $1;
EXECUTE fdw_prepare_upd ('uX');
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_char SET invalid = 'u' WHERE c = 'i';
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_char SET c = 'u' WHERE invalid = 'i';
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_char WHERE invalid = 'i';

--- char(length)
PREPARE fdw_prepare_ins (char(10)) AS
  INSERT INTO fdw_type_char_l VALUES ($1);
EXECUTE fdw_prepare_ins ('insert_valX');
EXECUTE fdw_prepare_ins ('insert_val');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS UPDATE fdw_type_char_l SET c = $1;
EXECUTE fdw_prepare_upd ('update_valX');
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_char_l SET invalid = 'update_val' WHERE c = 'insert_val';
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_char_l SET c = 'update_valX' WHERE invalid = 'insert_val';
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_char_l WHERE invalid = 'insert_val';

--- varchar(length)
PREPARE fdw_prepare_ins (varchar(10)) AS
  INSERT INTO fdw_type_varchar_l VALUES ($1);
EXECUTE fdw_prepare_ins ('insert_valX');
EXECUTE fdw_prepare_ins ('insert_val');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd (varchar(10)) AS
  UPDATE fdw_type_varchar_l SET c = $1;
EXECUTE fdw_prepare_upd ('update_valX');
DEALLOCATE fdw_prepare_upd;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_varchar_l SET invalid = 'update_val' WHERE c = 'insert_val';
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_varchar_l SET c = 'update_valX' WHERE invalid = 'insert_val';
PREPARE fdw_prepare_del AS
  DELETE FROM fdw_type_varchar_l WHERE invalid = 'insert_val';

-- Date/Time Types
--- date
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date '1/8/1999');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date '1/18/1999');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date '08-Jan-99');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date 'Jan-08-99');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date 'January 8, 99 BC');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date '01:02:03.456');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (time '01:02:03.456');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date '2021-02-30');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_date VALUES (date 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE fdw_prepare_ins (date) AS
  INSERT INTO fdw_type_date VALUES ($1);
EXECUTE fdw_prepare_ins (date '1/8/1999');
EXECUTE fdw_prepare_ins (date '1/18/1999');
EXECUTE fdw_prepare_ins (date '08-Jan-99');
EXECUTE fdw_prepare_ins (date 'Jan-08-99');
EXECUTE fdw_prepare_ins (date 'January 8, 99 BC');
DEALLOCATE fdw_prepare_ins;
SET DATESTYLE TO 'default';

--- time
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (date '2025/01/01');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (time '2025/01/01');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (time '25:00:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (time 'invalid');

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (time '010203.456789012');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

--- timestamp
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES (timestamp '2025/01/01');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES (timestamp '2025/01/01 12:00');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES (timestamp '01:02:03.456');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES (date '2021-02-30');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp '2021-02-30 04:05:06.789');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES (timestamp '2025-01-01 25:00:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES (timestamp 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE fdw_prepare_ins (timestamp) AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES ($1);
EXECUTE fdw_prepare_ins (timestamp '1/8/1999 01:02:03');
EXECUTE fdw_prepare_ins (timestamp '1/18/1999 01:02:03');
EXECUTE fdw_prepare_ins (timestamp '08-Jan-99 01:02:03');
EXECUTE fdw_prepare_ins (timestamp 'Jan-08-99 01:02:03');
EXECUTE fdw_prepare_ins (timestamp 'January 8, 99 BC 01:02:03');
DEALLOCATE fdw_prepare_ins;
SET DATESTYLE TO 'default';

--- timestamp without time zone
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2025/01/01');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2025/01/01 12:00');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '01:02:03.456');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (date '2021-02-30');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2021-02-30 04:05:06.789');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2025-01-01 25:00:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE fdw_prepare_ins (timestamp without time zone) AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES ($1);
EXECUTE fdw_prepare_ins (timestamp without time zone '1/8/1999 01:02:03');
EXECUTE fdw_prepare_ins (timestamp without time zone '1/18/1999 01:02:03');
EXECUTE fdw_prepare_ins (timestamp without time zone '08-Jan-99 01:02:03');
EXECUTE fdw_prepare_ins (timestamp without time zone 'Jan-08-99 01:02:03');
EXECUTE fdw_prepare_ins
  (timestamp without time zone 'January 8, 99 BC 01:02:03');
DEALLOCATE fdw_prepare_ins;
SET DATESTYLE TO 'default';

--- timestamp with time zone
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:01:02.34567 UTC');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:01:02.34567 Universal');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:00');
EXECUTE fdw_prepare_ins;
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (time with time zone '04:05:06.789+9:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:00-16:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:00+16:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2021-02-30 04:05:06.789+9:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone 'invalid+tz');

SET DATESTYLE TO ISO, YMD;
PREPARE fdw_prepare_ins (timestamp with time zone) AS
  INSERT INTO fdw_type_timestamp_tz VALUES ($1);
EXECUTE fdw_prepare_ins (timestamp with time zone '1/8/1999 01:02:03+0900');
EXECUTE fdw_prepare_ins (timestamp with time zone '1/18/1999 01:02:03+0900');
EXECUTE fdw_prepare_ins (timestamp with time zone '08-Jan-99 01:02:03+0900');
EXECUTE fdw_prepare_ins (timestamp with time zone 'Jan-08-99 01:02:03+0900');
EXECUTE fdw_prepare_ins
  (timestamp with time zone 'January 8, 99 BC 01:02:03+0900');
DEALLOCATE fdw_prepare_ins;
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
DROP FOREIGN TABLE fdw_type_varchar_l;
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
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar_l', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_date', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_time', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_wo_tz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');
