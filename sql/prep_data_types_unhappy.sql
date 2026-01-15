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
PREPARE prep_insert (integer) AS
  INSERT INTO fdw_type_int VALUES ($1);

EXECUTE prep_insert (2147483648);
EXECUTE prep_insert (-2147483649);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_insert_ex AS INSERT INTO fdw_type_int VALUES (2.1);
EXECUTE prep_insert_ex;
DEALLOCATE prep_insert_ex;

INSERT INTO fdw_type_int VALUES (0);
PREPARE prep_update (integer) AS UPDATE fdw_type_int SET c = $1;
EXECUTE prep_update (2147483648);
EXECUTE prep_update (1 + 2147483648);
EXECUTE prep_update (-2147483649);
EXECUTE prep_update (-1 - -2147483649);
DEALLOCATE prep_update;

PREPARE prep_update AS
  UPDATE fdw_type_int SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_int SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (bigint) AS
  INSERT INTO fdw_type_bigint VALUES ($1);
EXECUTE prep_insert (9223372036854775808);
EXECUTE prep_insert (-9223372036854775809);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_insert_ex AS INSERT INTO fdw_type_bigint VALUES (2.1);
EXECUTE prep_insert_ex;
DEALLOCATE prep_insert_ex;

INSERT INTO fdw_type_bigint VALUES (0);
PREPARE prep_update (bigint) AS UPDATE fdw_type_bigint SET c = $1;
EXECUTE prep_update (9223372036854775808);
EXECUTE prep_update (1 + 9223372036854775808);
EXECUTE prep_update (-9223372036854775809);
EXECUTE prep_update (-1 - -9223372036854775809);
DEALLOCATE prep_update;

PREPARE prep_update AS
  UPDATE fdw_type_bigint SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_bigint SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (decimal) AS
  INSERT INTO fdw_type_decimal VALUES ($1);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_decimal SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_decimal SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (decimal(5)) AS
  INSERT INTO fdw_type_decimal_p VALUES ($1);
EXECUTE prep_insert (123456);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_decimal_p SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_decimal_p SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (decimal(5, 2)) AS
  INSERT INTO fdw_type_decimal_ps VALUES ($1);
EXECUTE prep_insert (1234);
EXECUTE prep_insert (1234.56);
EXECUTE prep_insert (123.567);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_decimal_ps SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_decimal_ps SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (decimal(38, 0)) AS
  INSERT INTO fdw_type_decimal_ps0 VALUES ($1);
EXECUTE prep_insert (100000000000000000000000000000000000000);
EXECUTE prep_insert (340282366920938463463374607431768211455);
EXECUTE prep_insert (340282366920938463463374607431768211456);
DEALLOCATE prep_insert;

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
PREPARE prep_insert (decimal(38, 38)) AS
  INSERT INTO fdw_type_decimal_ps38 VALUES ($1);
EXECUTE prep_insert (1);
EXECUTE prep_insert (0.000000000000000000000000000000000000001);
EXECUTE prep_insert (0.340282366920938463463374607431768211455);
EXECUTE prep_insert (0.340282366920938463463374607431768211456);
DEALLOCATE prep_insert;

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
PREPARE prep_insert (numeric) AS
  INSERT INTO fdw_type_numeric VALUES ($1);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_numeric SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_numeric SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (numeric(5)) AS
  INSERT INTO fdw_type_numeric_p VALUES ($1);
EXECUTE prep_insert (123456);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_numeric_p SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_numeric_p SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (numeric(5, 2)) AS
  INSERT INTO fdw_type_numeric_ps VALUES ($1);
EXECUTE prep_insert (1234);
EXECUTE prep_insert (1234.56);
EXECUTE prep_insert (123.567);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_numeric_ps SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_numeric_ps SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
  DELETE FROM fdw_type_numeric_ps WHERE invalid >= 1;

PREPARE prep_insert AS
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
PREPARE prep_insert AS
  INSERT INTO fdw_type_numeric_ps0
    VALUES (100000000000000000000000000000000000000);
EXECUTE prep_insert;
DEALLOCATE prep_insert;

PREPARE prep_insert AS
  INSERT INTO fdw_type_numeric_ps0
    VALUES (340282366920938463463374607431768211455);
EXECUTE prep_insert;
DEALLOCATE prep_insert;

PREPARE prep_insert AS
  INSERT INTO fdw_type_numeric_ps0
    VALUES (340282366920938463463374607431768211456);
EXECUTE prep_insert;
DEALLOCATE prep_insert;

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
PREPARE prep_insert (numeric(38, 38)) AS
  INSERT INTO fdw_type_numeric_ps38 VALUES ($1);
EXECUTE prep_insert (1);
EXECUTE prep_insert (0.000000000000000000000000000000000000001);
EXECUTE prep_insert (0.340282366920938463463374607431768211455);
EXECUTE prep_insert (0.340282366920938463463374607431768211456);
DEALLOCATE prep_insert;

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
PREPARE prep_insert (real) AS
  INSERT INTO fdw_type_real VALUES ($1);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_real SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_real SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (double precision) AS
  INSERT INTO fdw_type_double VALUES ($1);
EXECUTE prep_insert ('invalid');
DEALLOCATE prep_insert;

PREPARE prep_update AS
  UPDATE fdw_type_double SET invalid = 2 WHERE c >= 1;
PREPARE prep_update AS
  UPDATE fdw_type_double SET c = 2 WHERE invalid = 1;
PREPARE prep_delete AS
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
PREPARE prep_insert (char) AS
  INSERT INTO fdw_type_char VALUES ($1);
EXECUTE prep_insert ('iX');
EXECUTE prep_insert ('i');
DEALLOCATE prep_insert;

PREPARE prep_update (char) AS UPDATE fdw_type_char SET c = $1;
EXECUTE prep_update ('uX');
DEALLOCATE prep_update;

PREPARE prep_update AS
  UPDATE fdw_type_char SET invalid = 'u' WHERE c = 'i';
PREPARE prep_update AS
  UPDATE fdw_type_char SET c = 'u' WHERE invalid = 'i';
PREPARE prep_delete AS
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
PREPARE prep_insert (char(10)) AS
  INSERT INTO fdw_type_char_l VALUES ($1);
EXECUTE prep_insert ('insert_valX');
EXECUTE prep_insert ('insert_val');
DEALLOCATE prep_insert;

PREPARE prep_update AS UPDATE fdw_type_char_l SET c = $1;
EXECUTE prep_update ('update_valX');
DEALLOCATE prep_update;

PREPARE prep_update AS
  UPDATE fdw_type_char_l SET invalid = 'update_val' WHERE c = 'insert_val';
PREPARE prep_update AS
  UPDATE fdw_type_char_l SET c = 'update_valX' WHERE invalid = 'insert_val';
PREPARE prep_delete AS
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
PREPARE prep_insert (varchar(10)) AS
  INSERT INTO fdw_type_varchar_l VALUES ($1);
EXECUTE prep_insert ('insert_valX');
EXECUTE prep_insert ('insert_val');
DEALLOCATE prep_insert;

PREPARE prep_update (varchar(10)) AS
  UPDATE fdw_type_varchar_l SET c = $1;
EXECUTE prep_update ('update_valX');
DEALLOCATE prep_update;

PREPARE prep_update AS
  UPDATE fdw_type_varchar_l SET invalid = 'update_val' WHERE c = 'insert_val';
PREPARE prep_update AS
  UPDATE fdw_type_varchar_l SET c = 'update_valX' WHERE invalid = 'insert_val';
PREPARE prep_delete AS
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
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (date '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (time '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (date '2021-02-30');
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (date 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (date) AS
  INSERT INTO fdw_type_date VALUES ($1);
EXECUTE prep_insert (date '1/8/1999');
EXECUTE prep_insert (date '1/18/1999');
EXECUTE prep_insert (date '08-Jan-99');
EXECUTE prep_insert (date 'Jan-08-99');
EXECUTE prep_insert (date 'January 8, 99 BC');
DEALLOCATE prep_insert;
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
PREPARE prep_insert AS
  INSERT INTO fdw_type_time VALUES (date '2025/01/01');
PREPARE prep_insert AS
  INSERT INTO fdw_type_time VALUES (time '2025/01/01');
PREPARE prep_insert AS
  INSERT INTO fdw_type_time VALUES (time '25:00:00');
PREPARE prep_insert AS
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
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (date '2021-02-30');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp
    VALUES (timestamp '2021-02-30 04:05:06.789');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp '2025-01-01 25:00:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (timestamp) AS
  INSERT INTO fdw_type_timestamp VALUES ($1);
EXECUTE prep_insert (timestamp '1/8/1999 01:02:03');
EXECUTE prep_insert (timestamp '1/18/1999 01:02:03');
EXECUTE prep_insert (timestamp '08-Jan-99 01:02:03');
EXECUTE prep_insert (timestamp 'Jan-08-99 01:02:03');
EXECUTE prep_insert (timestamp 'January 8, 99 BC 01:02:03');
DEALLOCATE prep_insert;
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
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (date '2021-02-30');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2021-02-30 04:05:06.789');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2025-01-01 25:00:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (timestamp without time zone) AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES ($1);
EXECUTE prep_insert (timestamp without time zone '1/8/1999 01:02:03');
EXECUTE prep_insert (timestamp without time zone '1/18/1999 01:02:03');
EXECUTE prep_insert (timestamp without time zone '08-Jan-99 01:02:03');
EXECUTE prep_insert (timestamp without time zone 'Jan-08-99 01:02:03');
EXECUTE prep_insert
  (timestamp without time zone 'January 8, 99 BC 01:02:03');
DEALLOCATE prep_insert;
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
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (time with time zone '04:05:06.789+9:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:00-16:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:00+16:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2021-02-30 04:05:06.789+9:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone 'invalid+tz');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (timestamp with time zone) AS
  INSERT INTO fdw_type_timestamp_tz VALUES ($1);
EXECUTE prep_insert (timestamp with time zone '1/8/1999 01:02:03+0900');
EXECUTE prep_insert (timestamp with time zone '1/18/1999 01:02:03+0900');
EXECUTE prep_insert (timestamp with time zone '08-Jan-99 01:02:03+0900');
EXECUTE prep_insert (timestamp with time zone 'Jan-08-99 01:02:03+0900');
EXECUTE prep_insert
  (timestamp with time zone 'January 8, 99 BC 01:02:03+0900');
DEALLOCATE prep_insert;
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');

-- Binary Types - bytea
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_bytea (c VARBINARY)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_bytea (
  c bytea
) SERVER tsurugidb;

--- Test
PREPARE prep_insert (bytea) AS INSERT INTO fdw_type_bytea VALUES ($1);
EXECUTE prep_insert (' \x00');
EXECUTE prep_insert ('\x00\x23');
EXECUTE prep_insert ('\x0');
EXECUTE prep_insert ('\x001');
EXECUTE prep_insert ('\xqw');
DEALLOCATE prep_insert;

PREPARE prep_select (bytea) AS
  SELECT * FROM fdw_type_bytea WHERE c = $1 ORDER BY c;
EXECUTE prep_select (' \x00');
EXECUTE prep_select ('\x00\x23');
EXECUTE prep_select ('\x0');
EXECUTE prep_select ('\x001');
EXECUTE prep_select ('\xqw');
DEALLOCATE prep_select;

INSERT INTO fdw_type_bytea VALUES ('\x7f');
PREPARE prep_update (bytea, bytea) AS
  UPDATE fdw_type_bytea SET c = $1 WHERE c = $2;
EXECUTE prep_update ('\x31', ' \x00');
EXECUTE prep_update ('\x31', '\x00\x23');
EXECUTE prep_update ('\x31', '\x0');
EXECUTE prep_update ('\x31', '\x001');
EXECUTE prep_update ('\x31', '\xqw');
EXECUTE prep_update (' \x00', '\x7f');
EXECUTE prep_update ('\x00\x23', '\x7f');
EXECUTE prep_update ('\x0', '\x7f');
EXECUTE prep_update ('\x001', '\x7f');
EXECUTE prep_update ('\xqw', '\x7f');
DEALLOCATE prep_update;

PREPARE prep_delete (bytea) AS DELETE FROM fdw_type_bytea WHERE c = $1;
EXECUTE prep_delete (' \x00');
EXECUTE prep_delete ('\x00\x23');
EXECUTE prep_delete ('\x0');
EXECUTE prep_delete ('\x001');
EXECUTE prep_delete ('\xqw');
DEALLOCATE prep_delete;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_bytea;

--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_bytea', 'tsurugidb');

-- Unsupported Types - serial
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c1 INTEGER, c2 CHAR(14))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c1 serial, c2 char(14)) SERVER tsurugidb;

--- Test
PREPARE prep_insert (char(14)) AS
  INSERT INTO fdw_type_unsupported (c2) VALUES ($1);
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_unsupported ORDER BY c1;

EXECUTE prep_insert ('serial is null');
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_select_all;

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
PREPARE prep_insert (char(14)) AS
  INSERT INTO fdw_type_unsupported (c2) VALUES ($1);
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_unsupported ORDER BY c1;

EXECUTE prep_insert ('serial is null');
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_select_all;

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
PREPARE prep_insert (char(14)) AS
  INSERT INTO fdw_type_unsupported (c2) VALUES ($1);
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_unsupported ORDER BY c1;

EXECUTE prep_insert ('serial is null');
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_select_all;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - bit
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c BINARY(4))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c bit(4)) SERVER tsurugidb;

--- Test
PREPARE prep_insert (bit(4)) AS
  INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert (B'1010');
EXECUTE prep_insert ('1010');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - bit varying
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARBINARY(4))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c bit varying(4)) SERVER tsurugidb;

--- Test
PREPARE prep_insert (bit varying(4)) AS
  INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert (B'1010');
EXECUTE prep_insert ('1010');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - boolean
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c DECIMAL(1))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c boolean) SERVER tsurugidb;

--- Test
PREPARE prep_insert (boolean) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert (true::boolean);
EXECUTE prep_insert (true);
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - box
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c box) SERVER tsurugidb;

--- Test
PREPARE prep_insert (box) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('(1,2),(3,4)'::box);
EXECUTE prep_insert ('(1,2),(3,4)');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - cidr
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c cidr) SERVER tsurugidb;

--- Test
PREPARE prep_insert (cidr) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('192.168.0.0/24'::cidr);
EXECUTE prep_insert ('192.168.0.0/24');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - circle
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c circle) SERVER tsurugidb;

--- Test
PREPARE prep_insert (circle) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('<(3,4),5>'::circle);
EXECUTE prep_insert ('<(3,4),5>');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - inet
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c inet) SERVER tsurugidb;

--- Test
PREPARE prep_insert (inet) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('192.168.0.1'::inet);
EXECUTE prep_insert ('192.168.0.1');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - interval
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c interval) SERVER tsurugidb;

--- Test
PREPARE prep_insert (interval) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('1 day'::interval);
EXECUTE prep_insert ('1 day');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - json
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c json) SERVER tsurugidb;

--- Test
PREPARE prep_insert (json) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('{"key":"value"}'::json);
EXECUTE prep_insert ('{"key":"value"}');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - jsonb
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c jsonb) SERVER tsurugidb;

--- Test
PREPARE prep_insert (jsonb) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('{"key":"value"}'::jsonb);
EXECUTE prep_insert ('{"key":"value"}');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - line
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c line) SERVER tsurugidb;

--- Test
PREPARE prep_insert (line) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('{1,2,3}'::line);
EXECUTE prep_insert ('{1,2,3}');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - lseg
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c lseg) SERVER tsurugidb;

--- Test
PREPARE prep_insert (lseg) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('[(1,2),(3,4)]'::lseg);
EXECUTE prep_insert ('[(1,2),(3,4)]');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - macaddr
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c macaddr) SERVER tsurugidb;

--- Test
PREPARE prep_insert (macaddr) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('08:00:2b:01:02:03'::macaddr);
EXECUTE prep_insert ('08:00:2b:01:02:03');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - macaddr8
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c macaddr8) SERVER tsurugidb;

--- Test
PREPARE prep_insert (macaddr8) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('08:00:2b:01:02:03:04:05'::macaddr8);
EXECUTE prep_insert ('08:00:2b:01:02:03:04:05');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - money
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c money) SERVER tsurugidb;

--- Test
PREPARE prep_insert (money) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('$123.45'::money);
EXECUTE prep_insert ('$123.45');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - path
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c path) SERVER tsurugidb;

--- Test
PREPARE prep_insert (path) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('[(1,2),(3,4)]'::path);
EXECUTE prep_insert ('[(1,2),(3,4)]');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - pg_lsn
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c pg_lsn) SERVER tsurugidb;

--- Test
PREPARE prep_insert (pg_lsn) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('16/B374D848'::pg_lsn);
EXECUTE prep_insert ('16/B374D848');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - point
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c point) SERVER tsurugidb;

--- Test
PREPARE prep_insert (point) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('(1,2)'::point);
EXECUTE prep_insert ('(1,2)');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - polygon
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c polygon) SERVER tsurugidb;

--- Test
PREPARE prep_insert (polygon) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('((1,2),(3,4),(5,6))'::polygon);
EXECUTE prep_insert ('((1,2),(3,4),(5,6))');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - smallint
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c DECIMAL(5))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c smallint) SERVER tsurugidb;

--- Test
PREPARE prep_insert (smallint) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert (1::smallint);
EXECUTE prep_insert (1);
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - tsquery
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c tsquery) SERVER tsurugidb;

--- Test
PREPARE prep_insert (tsquery) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('value'::tsquery);
EXECUTE prep_insert ('value');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - tsvector
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c tsvector) SERVER tsurugidb;

--- Test
PREPARE prep_insert (tsvector) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('value:1'::tsvector);
EXECUTE prep_insert ('value:1');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - txid_snapshot
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c txid_snapshot) SERVER tsurugidb;

--- Test
PREPARE prep_insert (txid_snapshot) AS
  INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('10:20:10,14,15'::txid_snapshot);
EXECUTE prep_insert ('10:20:10,14,15');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');

-- Unsupported Types - uuid
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_unsupported (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_unsupported (c uuid) SERVER tsurugidb;

--- Test
PREPARE prep_insert (uuid) AS INSERT INTO fdw_type_unsupported VALUES ($1);
EXECUTE prep_insert ('f3d4b1ce-f2e0-49ce-8cd4-da5c8f29bff2'::uuid);
EXECUTE prep_insert ('f3d4b1ce-f2e0-49ce-8cd4-da5c8f29bff2');
DEALLOCATE prep_insert;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_unsupported;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_unsupported', 'tsurugidb');
