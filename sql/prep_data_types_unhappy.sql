/* Test case: unhappy path - Unsupported data types (preparation) */

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
PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_type_int VALUES ($1);

EXECUTE fdw_prepare_ins (2147483648);
EXECUTE fdw_prepare_ins (-2147483649);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins_ex AS INSERT INTO fdw_type_int VALUES (2.1);
EXECUTE fdw_prepare_ins_ex;
DEALLOCATE fdw_prepare_ins_ex;

INSERT INTO fdw_type_int VALUES (0);
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
PREPARE fdw_prepare_ins (bigint) AS
  INSERT INTO fdw_type_bigint VALUES ($1);
EXECUTE fdw_prepare_ins (9223372036854775808);
EXECUTE fdw_prepare_ins (-9223372036854775809);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_ins_ex AS INSERT INTO fdw_type_bigint VALUES (2.1);
EXECUTE fdw_prepare_ins_ex;
DEALLOCATE fdw_prepare_ins_ex;

INSERT INTO fdw_type_bigint VALUES (0);
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
PREPARE fdw_prepare_ins (decimal(5)) AS
  INSERT INTO fdw_type_decimal_p VALUES ($1);
EXECUTE fdw_prepare_ins (123456);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal_p SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal_p SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
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
PREPARE fdw_prepare_ins (decimal(5, 2)) AS
  INSERT INTO fdw_type_decimal_ps VALUES ($1);
EXECUTE fdw_prepare_ins (1234);
EXECUTE fdw_prepare_ins (1234.56);
EXECUTE fdw_prepare_ins (123.567);
EXECUTE fdw_prepare_ins ('invalid');
DEALLOCATE fdw_prepare_ins;

PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal_ps SET invalid = 2 WHERE c >= 1;
PREPARE fdw_prepare_upd AS
  UPDATE fdw_type_decimal_ps SET c = 2 WHERE invalid = 1;
PREPARE fdw_prepare_del AS
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
PREPARE fdw_prepare_ins (decimal(38, 0)) AS
  INSERT INTO fdw_type_decimal_ps0 VALUES ($1);
EXECUTE fdw_prepare_ins (100000000000000000000000000000000000000);
EXECUTE fdw_prepare_ins (340282366920938463463374607431768211455);
EXECUTE fdw_prepare_ins (340282366920938463463374607431768211456);
DEALLOCATE fdw_prepare_ins;

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
PREPARE fdw_prepare_ins (decimal(38, 38)) AS
  INSERT INTO fdw_type_decimal_ps38 VALUES ($1);
EXECUTE fdw_prepare_ins (1);
EXECUTE fdw_prepare_ins (0.000000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins (0.340282366920938463463374607431768211455);
EXECUTE fdw_prepare_ins (0.340282366920938463463374607431768211456);
DEALLOCATE fdw_prepare_ins;

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
PREPARE fdw_prepare_ins (numeric(38, 38)) AS
  INSERT INTO fdw_type_numeric_ps38 VALUES ($1);
EXECUTE fdw_prepare_ins (1);
EXECUTE fdw_prepare_ins (0.000000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins (0.340282366920938463463374607431768211455);
EXECUTE fdw_prepare_ins (0.340282366920938463463374607431768211456);
DEALLOCATE fdw_prepare_ins;

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
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (date '2025/01/01');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (time '2025/01/01');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_time VALUES (time '25:00:00');
PREPARE fdw_prepare_ins AS
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
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp '01:02:03.456');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp VALUES (date '2021-02-30');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp
    VALUES (timestamp '2021-02-30 04:05:06.789');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp '2025-01-01 25:00:00');
PREPARE fdw_prepare_ins AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE fdw_prepare_ins (timestamp) AS
  INSERT INTO fdw_type_timestamp VALUES ($1);
EXECUTE fdw_prepare_ins (timestamp '1/8/1999 01:02:03');
EXECUTE fdw_prepare_ins (timestamp '1/18/1999 01:02:03');
EXECUTE fdw_prepare_ins (timestamp '08-Jan-99 01:02:03');
EXECUTE fdw_prepare_ins (timestamp 'Jan-08-99 01:02:03');
EXECUTE fdw_prepare_ins (timestamp 'January 8, 99 BC 01:02:03');
DEALLOCATE fdw_prepare_ins;
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

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');

-- PostgreSQL Types - smallint (Tsurugi type DECIMAL(5))
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c DECIMAL(5))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c smallint) SERVER tsurugidb;

--- Test
PREPARE fdw_prepare_ins (smallint) AS
  INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE fdw_prepare_ins (1);
DEALLOCATE fdw_prepare_ins;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - serial
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c1 INTEGER, c2 CHAR(14))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c1 serial, c2 char(14)) SERVER tsurugidb;

--- Test
PREPARE fdw_prepare_ins (char(14)) AS
  INSERT INTO fdw_type_unsupported (c2) VALUES ($1);
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_unsupported ORDER BY c1;

EXECUTE fdw_prepare_ins ('serial is null');
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel_all;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - smallserial
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c1 DECIMAL(5), c2 CHAR(14))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c1 smallserial, c2 char(14))
  SERVER tsurugidb;

-- Test
PREPARE fdw_prepare_ins (char(14)) AS
  INSERT INTO fdw_type_unsupported (c2) VALUES ($1);
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_unsupported ORDER BY c1;

EXECUTE fdw_prepare_ins ('serial is null');
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel_all;

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
PREPARE fdw_prepare_ins (char(14)) AS
  INSERT INTO fdw_type_unsupported (c2) VALUES ($1);
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_unsupported ORDER BY c1;

EXECUTE fdw_prepare_ins ('serial is null');
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel_all;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');
