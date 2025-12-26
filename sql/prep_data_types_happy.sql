/* Test case: happy path - Supported data types (preparation) */

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
PREPARE prep_update (integer, integer) AS
  UPDATE fdw_type_int SET c = $1 WHERE c = $2;
PREPARE prep_update_nul (integer) AS
  UPDATE fdw_type_int SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (integer) AS
  DELETE FROM fdw_type_int WHERE c = $1;
PREPARE prep_select (integer) AS
  SELECT * FROM fdw_type_int WHERE c = $1 ORDER BY c;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_int ORDER BY c;

EXECUTE prep_insert (12345);
EXECUTE prep_insert (-12345);
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (2147483644);  --max-3
EXECUTE prep_insert (2147483645);  --max-2
EXECUTE prep_insert (2147483646);  --max-1
EXECUTE prep_insert (2147483647);  --max
EXECUTE prep_insert (-2147483645);  --min+3
EXECUTE prep_insert (-2147483646);  --min+2
EXECUTE prep_insert (-2147483647);  --min+1
EXECUTE prep_insert (-2147483648);  --min
EXECUTE prep_insert (1.1);  -- auto-cast

PREPARE prep_insert_ex AS
  INSERT INTO fdw_type_int VALUES (CAST(0.1 AS int));
EXECUTE prep_insert_ex;
DEALLOCATE prep_insert_ex;

EXECUTE prep_select_all;
EXECUTE prep_select (2147483647);
EXECUTE prep_select (-2147483648);

EXECUTE prep_update (2147483647, -2147483648);
EXECUTE prep_select (2147483647);

EXECUTE prep_update (-2147483648, 2147483647);
EXECUTE prep_select (-2147483648);
EXECUTE prep_delete (-2147483648);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (2147483647);
EXECUTE prep_delete (2147483647);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select;
DEALLOCATE prep_select_all;

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
PREPARE prep_update (bigint, bigint) AS
  UPDATE fdw_type_bigint SET c = $1 WHERE c = $2;
PREPARE prep_update_nul (bigint) AS
  UPDATE fdw_type_bigint SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (bigint) AS
  DELETE FROM fdw_type_bigint WHERE c = $1;
PREPARE prep_select (bigint) AS
  SELECT * FROM fdw_type_bigint WHERE c = $1 ORDER BY c;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_bigint ORDER BY c;

EXECUTE prep_insert (12345);
EXECUTE prep_insert (-12345);
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (9223372036854775804);  --max-3
EXECUTE prep_insert (9223372036854775805);  --max-2
EXECUTE prep_insert (9223372036854775806);  --max-1
EXECUTE prep_insert (9223372036854775807);  --max
EXECUTE prep_insert (-9223372036854775805);  --min+3
EXECUTE prep_insert (-9223372036854775806);  --min+2
EXECUTE prep_insert (-9223372036854775807);  --min+1
EXECUTE prep_insert (-9223372036854775808);  --min
EXECUTE prep_insert (1.1);  -- auto-cast

PREPARE prep_insert_ex AS
  INSERT INTO fdw_type_bigint VALUES (CAST(0.1 AS int));
EXECUTE prep_insert_ex;
DEALLOCATE prep_insert_ex;

EXECUTE prep_select_all;
EXECUTE prep_select (9223372036854775807);
EXECUTE prep_select (-9223372036854775808);

EXECUTE prep_update (9223372036854775807, -9223372036854775808);
EXECUTE prep_select (9223372036854775807);

EXECUTE prep_update (-9223372036854775808, 9223372036854775807);
EXECUTE prep_delete (-9223372036854775808);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (9223372036854775807);
EXECUTE prep_delete (9223372036854775807);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select;
DEALLOCATE prep_select_all;

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
PREPARE prep_update (decimal) AS
  UPDATE fdw_type_decimal SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (decimal) AS
  UPDATE fdw_type_decimal SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (decimal) AS
  DELETE FROM fdw_type_decimal WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_decimal ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_decimal ORDER BY c DESC;

EXECUTE prep_insert (12345);
EXECUTE prep_insert (-12345);
EXECUTE prep_insert (NULL);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (987654);
EXECUTE prep_select_all;
EXECUTE prep_update (987654);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (-987654);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_update (decimal(5)) AS
  UPDATE fdw_type_decimal_p SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (decimal(5)) AS
  UPDATE fdw_type_decimal_p SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (decimal(5)) AS
  DELETE FROM fdw_type_decimal_p WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_decimal_p ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_decimal_p ORDER BY c DESC;

EXECUTE prep_insert (12345);
EXECUTE prep_insert (-12345);
EXECUTE prep_insert (NULL);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (98765);
EXECUTE prep_select_all;
EXECUTE prep_update (98765);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (-98765);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_update (decimal(5, 2)) AS
  UPDATE fdw_type_decimal_ps SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (decimal(5, 2)) AS
  UPDATE fdw_type_decimal_ps SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (decimal(5, 2)) AS
  DELETE FROM fdw_type_decimal_ps WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_decimal_ps ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_decimal_ps ORDER BY c DESC;

EXECUTE prep_insert (123.45);
EXECUTE prep_insert (-123.45);
EXECUTE prep_insert (NULL);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (987.65);
EXECUTE prep_select_all;
EXECUTE prep_update (987.65);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (-987.65);
EXECUTE prep_select_all;

EXECUTE prep_insert (abs(-17.4));
EXECUTE prep_insert (ceil(-42.8));
EXECUTE prep_insert (floor(-42.8));
EXECUTE prep_insert (mod(9, 4));
EXECUTE prep_insert (round(42.4));
EXECUTE prep_insert (round(42.4382, 2));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_insert (numeric(38, 0)) AS
  INSERT INTO fdw_type_decimal_ps0 VALUES ($1);
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_decimal_ps0 ORDER BY c;

EXECUTE prep_insert (0);
EXECUTE prep_insert (1);
EXECUTE prep_insert (18446744073709551615);
EXECUTE prep_insert (18446744073709551616);
EXECUTE prep_insert (99999999999999999999999999999999999999);
EXECUTE prep_insert (-1);
EXECUTE prep_insert (-18446744073709551615);
EXECUTE prep_insert (-18446744073709551616);
EXECUTE prep_insert (-99999999999999999999999999999999999999);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_select_all;

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
PREPARE prep_insert (numeric(38, 38)) AS
  INSERT INTO fdw_type_decimal_ps38 VALUES ($1);
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_decimal_ps38 ORDER BY c;

EXECUTE prep_insert (0);
EXECUTE prep_insert (0.00000000000000000000000000000000000001);
EXECUTE prep_insert (0.00000000000000000018446744073709551615);
EXECUTE prep_insert (0.00000000000000000018446744073709551616);
EXECUTE prep_insert (0.99999999999999999999999999999999999999);
EXECUTE prep_insert (-0.00000000000000000000000000000000000001);
EXECUTE prep_insert (-0.00000000000000000018446744073709551615);
EXECUTE prep_insert (-0.00000000000000000018446744073709551616);
EXECUTE prep_insert (-0.99999999999999999999999999999999999999);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_select_all;

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
PREPARE prep_update (numeric) AS
  UPDATE fdw_type_numeric SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (numeric) AS
  UPDATE fdw_type_numeric SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (numeric) AS
  DELETE FROM fdw_type_numeric WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_numeric ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_numeric ORDER BY c DESC;

EXECUTE prep_insert (12345);
EXECUTE prep_insert (-12345);
EXECUTE prep_insert (NULL);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (987654);
EXECUTE prep_select_all;
EXECUTE prep_update (987654);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (-987654);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_update (numeric(5)) AS
  UPDATE fdw_type_numeric_p SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (numeric(5)) AS
  UPDATE fdw_type_numeric_p SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (numeric(5)) AS
  DELETE FROM fdw_type_numeric_p WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_numeric_p ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_numeric_p ORDER BY c DESC;

EXECUTE prep_insert (12345);
EXECUTE prep_insert (-12345);
EXECUTE prep_insert (NULL);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (98765);
EXECUTE prep_select_all;
EXECUTE prep_update (98765);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (-98765);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_update (numeric(5, 2)) AS
  UPDATE fdw_type_numeric_ps SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (numeric(5, 2)) AS
  UPDATE fdw_type_numeric_ps SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (numeric(5, 2)) AS
  DELETE FROM fdw_type_numeric_ps WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_numeric_ps ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_numeric_ps ORDER BY c DESC;

EXECUTE prep_insert (123.45);
EXECUTE prep_insert (-123.45);
EXECUTE prep_insert (NULL);
EXECUTE prep_select_all;

EXECUTE prep_update_nul (987.65);
EXECUTE prep_select_all;
EXECUTE prep_update (987.65);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (-987.65);
EXECUTE prep_select_all;

EXECUTE prep_insert (abs(-17.4));
EXECUTE prep_insert (CAST(cbrt(27.0) AS DECIMAL(5, 2)));
EXECUTE prep_insert (ceil(-42.8));
EXECUTE prep_insert (ceiling(-95.3));
EXECUTE prep_insert (CAST(degrees(0.5) AS DECIMAL(5, 2)));
EXECUTE prep_insert (div(9,4));
EXECUTE prep_insert (CAST(exp(1.0) AS DECIMAL(5, 2)));
EXECUTE prep_insert (factorial(5));
EXECUTE prep_insert (floor(-42.8));
EXECUTE prep_insert (CAST(ln(2.0) AS DECIMAL(5, 2)));
EXECUTE prep_insert (log(100.0));
EXECUTE prep_insert (log10(100.0));
EXECUTE prep_insert (log(2.0, 64.0));
EXECUTE prep_insert (mod(9, 4));
EXECUTE prep_insert (CAST(pi() AS DECIMAL(5, 2)));
EXECUTE prep_insert (power(9.0, 3.0));
EXECUTE prep_insert (CAST(radians(45.0) AS DECIMAL(5, 2)));
EXECUTE prep_insert (round(42.4));
EXECUTE prep_insert (round(42.4382, 2));
EXECUTE prep_insert (sign(-8.4));
EXECUTE prep_insert (CAST(scale(8.41) AS DECIMAL(5, 2)));
EXECUTE prep_insert (CAST(sqrt(2.0) AS DECIMAL(5, 2)));
EXECUTE prep_insert (trunc(42.8));
EXECUTE prep_insert (trunc(42.4382, 2));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_insert (numeric(38, 0)) AS
  INSERT INTO fdw_type_numeric_ps0 VALUES ($1);
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_numeric_ps0 ORDER BY c;

EXECUTE prep_insert (0);
EXECUTE prep_insert (1);
EXECUTE prep_insert (18446744073709551615);
EXECUTE prep_insert (18446744073709551616);
EXECUTE prep_insert (99999999999999999999999999999999999999);
EXECUTE prep_insert (-1);
EXECUTE prep_insert (-18446744073709551615);
EXECUTE prep_insert (-18446744073709551616);
EXECUTE prep_insert (-99999999999999999999999999999999999999);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_select_all;

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
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_numeric_ps38 ORDER BY c;

EXECUTE prep_insert (0);  -- see tsurugi-issues#736
EXECUTE prep_insert (0.00000000000000000000000000000000000001);
EXECUTE prep_insert (0.00000000000000000018446744073709551615);
EXECUTE prep_insert (0.00000000000000000018446744073709551616);
EXECUTE prep_insert (0.99999999999999999999999999999999999999);
EXECUTE prep_insert (-0.00000000000000000000000000000000000001);
EXECUTE prep_insert (-0.00000000000000000018446744073709551615);
EXECUTE prep_insert (-0.00000000000000000018446744073709551616);
EXECUTE prep_insert (-0.99999999999999999999999999999999999999);
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_select_all;

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
PREPARE prep_update (real) AS
  UPDATE fdw_type_real SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (real) AS
  UPDATE fdw_type_real SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (real) AS
  DELETE FROM fdw_type_real WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_real ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_real ORDER BY c DESC;

EXECUTE prep_insert (0.1);
EXECUTE prep_insert (1.1);
EXECUTE prep_insert (1.2345);
EXECUTE prep_insert (-1.2345);
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (12.345678901234567890); --20 digits
EXECUTE prep_select_all;

EXECUTE prep_update_nul (9.87654);
EXECUTE prep_select_all;
EXECUTE prep_update (9.87654::real);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (CAST(-9.87654 AS real));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_update (double precision) AS
  UPDATE fdw_type_double SET c = c * -1 WHERE c = $1;
PREPARE prep_update_nul (double precision) AS
  UPDATE fdw_type_double SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (double precision) AS
  DELETE FROM fdw_type_double WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_double ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_double ORDER BY c DESC;

EXECUTE prep_insert (0.1);
EXECUTE prep_insert (1.1);
EXECUTE prep_insert (1.2345);
EXECUTE prep_insert (-1.2345);
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (12.345678901234567890); --20 digits
EXECUTE prep_select_all;

EXECUTE prep_update_nul (9.87654);
EXECUTE prep_select_all;
EXECUTE prep_update (9.87654::double precision);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (CAST(-9.87654 AS double precision));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_update (char, char) AS
  UPDATE fdw_type_char SET c = $1 WHERE c = $2;
PREPARE prep_update_nul (char) AS
  UPDATE fdw_type_char SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (char) AS
  DELETE FROM fdw_type_char WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_char ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_char ORDER BY c DESC;

EXECUTE prep_insert ('a');
EXECUTE prep_insert ('');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (1);  -- auto-cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('X');
EXECUTE prep_select_all;
EXECUTE prep_update ('z', 'X');
EXECUTE prep_select_all_d;
EXECUTE prep_delete ('z');
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_update (char(10), char(10)) AS
  UPDATE fdw_type_char_l SET c = $1 WHERE c = $2;
PREPARE prep_update_nul (char(10)) AS
  UPDATE fdw_type_char_l SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (char(10)) AS
  DELETE FROM fdw_type_char_l WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_char_l ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_char_l ORDER BY c DESC;

EXECUTE prep_insert ('abcdef');
EXECUTE prep_insert ('PostgreSQL');
EXECUTE prep_insert ('');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (12345);  -- auto-cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('NULL');
EXECUTE prep_select_all;
EXECUTE prep_update ('update', CAST('NULL' AS char(10)));
EXECUTE prep_select_all_d;
EXECUTE prep_delete ('update'::char(10));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_char_l;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_char_l', 'tsurugidb');

-- Character Types - varchar
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_varchar (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_varchar (
  c varchar
) SERVER tsurugidb;

--- Test
PREPARE prep_insert (varchar) AS
  INSERT INTO fdw_type_varchar VALUES ($1);
PREPARE prep_update (varchar, varchar) AS
  UPDATE fdw_type_varchar SET c = c || '_' || $1 WHERE c = $2;
PREPARE prep_update_nul (varchar) AS
  UPDATE fdw_type_varchar SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (varchar) AS
  DELETE FROM fdw_type_varchar WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_varchar ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_varchar ORDER BY c DESC;

EXECUTE prep_insert ('abcdef');
EXECUTE prep_insert ('');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (12345);  -- auto-cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('NULL');
EXECUTE prep_select_all;
EXECUTE prep_update ('updated', 'NULL');
EXECUTE prep_select_all_d;
EXECUTE prep_delete ('NULL_updated');
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_varchar;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar', 'tsurugidb');

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
PREPARE prep_update (varchar(10), varchar(10)) AS
  UPDATE fdw_type_varchar_l SET c = $1 WHERE c = $2;
PREPARE prep_update_nul (varchar(10)) AS
  UPDATE fdw_type_varchar_l SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (varchar(10)) AS
  DELETE FROM fdw_type_varchar_l WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_varchar_l ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_varchar_l ORDER BY c DESC;

EXECUTE prep_insert ('abcdef');
EXECUTE prep_insert ('PostgreSQL');
EXECUTE prep_insert ('');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (12345);  -- auto-cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('NULL');
EXECUTE prep_select_all;
EXECUTE prep_update ('update', 'NULL');
EXECUTE prep_select_all_d;
EXECUTE prep_delete ('update');
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_varchar_l;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_varchar_l', 'tsurugidb');

-- Character Types - text
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_text (c VARCHAR)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_text (
  c text
) SERVER tsurugidb;

--- Test
PREPARE prep_insert (text) AS
  INSERT INTO fdw_type_text VALUES ($1);
PREPARE prep_update (text, text) AS
  UPDATE fdw_type_text SET c = c || '_' || $1 WHERE c = $2;
PREPARE prep_update_nul (text) AS
  UPDATE fdw_type_text SET c = $1 WHERE c IS NULL;
PREPARE prep_delete (text) AS
  DELETE FROM fdw_type_text WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_text ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_text ORDER BY c DESC;

EXECUTE prep_insert ('abcdef');
EXECUTE prep_insert ('');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert (12345);  -- auto-cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('NULL');
EXECUTE prep_select_all;
EXECUTE prep_update ('updated', 'NULL');
EXECUTE prep_select_all_d;
EXECUTE prep_delete ('NULL_updated');
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_text;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_text', 'tsurugidb');

-- Date/Time Types - Test setup: PostgreSQL environment
SET TIMEZONE TO 'UTC';
SET DATESTYLE TO ISO, YMD;

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
PREPARE prep_insert (date) AS
  INSERT INTO fdw_type_date VALUES ($1);
PREPARE prep_update_nul (date) AS
  UPDATE fdw_type_date SET c = $1 WHERE c IS NULL;
PREPARE prep_update (date, date) AS
  UPDATE fdw_type_date SET c = $1 WHERE c = $2;
PREPARE prep_delete (date) AS
  DELETE FROM fdw_type_date WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_date ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_date ORDER BY c DESC;

EXECUTE prep_insert (date '2025-01-01');
EXECUTE prep_insert ('2025-01-02'::date);
EXECUTE prep_insert (CAST('2025-01-03' AS date));
EXECUTE prep_insert (date '0001-01-01');
EXECUTE prep_insert (date '9999-12-31');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert ('2024-12-31');  -- auto cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('2025-02-01');
EXECUTE prep_select_all;
EXECUTE prep_update ('2025-03-10'::date, '2025-02-01'::date);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (CAST('2025-03-10' AS date));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_insert (time) AS
  INSERT INTO fdw_type_time VALUES ($1);
PREPARE prep_update_nul (time) AS
  UPDATE fdw_type_time SET c = $1 WHERE c IS NULL;
PREPARE prep_update (time, time) AS
  UPDATE fdw_type_time SET c = $1 WHERE c = $2;
PREPARE prep_delete (time) AS
  DELETE FROM fdw_type_time WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_time ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_time ORDER BY c DESC;

EXECUTE prep_insert (time '01:02:03.456');
EXECUTE prep_insert ('03:02:01.456'::time);
EXECUTE prep_insert (CAST('02:01:03.456' AS time));
EXECUTE prep_insert (time '01:02:03.456789012');
EXECUTE prep_insert (time '00:00:00');
EXECUTE prep_insert (time '23:59:59.999999');
EXECUTE prep_insert (time '050607.890123456');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert ('04:05:06.789');  -- auto cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('00:00:00.001');
EXECUTE prep_select_all;
EXECUTE prep_update ('07:08:12.345'::time, '00:00:00.001'::time);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (CAST('07:08:12.345' AS time));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_insert (timestamp) AS
  INSERT INTO fdw_type_timestamp VALUES ($1);
PREPARE prep_update_nul (timestamp) AS
  UPDATE fdw_type_timestamp SET c = $1 WHERE c IS NULL;
PREPARE prep_update (timestamp, timestamp) AS
  UPDATE fdw_type_timestamp SET c = $1 WHERE c = $2;
PREPARE prep_delete (timestamp) AS
  DELETE FROM fdw_type_timestamp WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_timestamp ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_timestamp ORDER BY c DESC;

EXECUTE prep_insert (timestamp '2025-01-01 00:00:00');
EXECUTE prep_insert ('2025-01-02 00:00:00'::timestamp);
EXECUTE prep_insert (CAST('2025-01-03 00:00:00' AS timestamp));
EXECUTE prep_insert (timestamp '1887-12-31 15:00:00');
EXECUTE prep_insert (timestamp '9999-12-31 23:59:59.999999');
EXECUTE prep_insert (timestamp '2025/01/01');
EXECUTE prep_insert (timestamp '2025/01/01 12:00');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert ('2024-08-30 04:05:06.789');  -- auto cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('2025-01-01 00:00:00.001');
EXECUTE prep_select_all;
EXECUTE prep_update
  ('2025-03-02 05:06:12.345'::timestamp, '2025-01-01 00:00:00.001'::timestamp);
EXECUTE prep_select_all_d;
EXECUTE prep_delete (CAST('2025-03-02 05:06:12.345' AS timestamp));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_insert (timestamp without time zone) AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES ($1);
PREPARE prep_update_nul (timestamp without time zone) AS
  UPDATE fdw_type_timestamp_wo_tz SET c = $1 WHERE c IS NULL;
PREPARE prep_update
  (timestamp without time zone, timestamp without time zone) AS
  UPDATE fdw_type_timestamp_wo_tz SET c = $1 WHERE c = $2;
PREPARE prep_delete (timestamp without time zone) AS
  DELETE FROM fdw_type_timestamp_wo_tz WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c DESC;

EXECUTE prep_insert (timestamp without time zone '2025-01-01 00:00:00');
EXECUTE prep_insert ('2025-01-02 00:00:00'::timestamp without time zone);
EXECUTE prep_insert
  (CAST('2025-01-03 00:00:00' AS timestamp without time zone));
EXECUTE prep_insert (timestamp without time zone '1887-12-31 15:00:00');
EXECUTE prep_insert
  (timestamp without time zone '9999-12-31 23:59:59.999999');
EXECUTE prep_insert (timestamp without time zone '2025/01/01');
EXECUTE prep_insert (timestamp without time zone '2025/01/01 12:00');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert ('2024-08-30 04:05:06.789');  -- auto cast
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('2025-01-01 00:00:00.001');
EXECUTE prep_select_all;
EXECUTE prep_update
  ('2025-03-02 05:06:12.345'::timestamp without time zone,
   '2025-01-01 00:00:00.001'::timestamp without time zone);
EXECUTE prep_select_all_d;
EXECUTE prep_delete
  (CAST('2025-03-02 05:06:12.345' AS timestamp without time zone));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

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
PREPARE prep_insert (timestamp with time zone) AS
  INSERT INTO fdw_type_timestamp_tz VALUES ($1);
PREPARE prep_update_nul (timestamp with time zone) AS
  UPDATE fdw_type_timestamp_tz SET c = $1 WHERE c IS NULL;
PREPARE prep_update (timestamp with time zone, timestamp with time zone) AS
  UPDATE fdw_type_timestamp_tz SET c = $1 WHERE c = $2;
PREPARE prep_delete (timestamp with time zone) AS
  DELETE FROM fdw_type_timestamp_tz WHERE c = $1;
PREPARE prep_select_all AS
  SELECT * FROM fdw_type_timestamp_tz ORDER BY c;
PREPARE prep_select_all_d AS
  SELECT * FROM fdw_type_timestamp_tz ORDER BY c DESC;

EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:01:02.34567+9:00');
EXECUTE prep_insert
  ('2025-01-02 12:01:02.34567+9:00'::timestamp with time zone);
EXECUTE prep_insert
  (CAST('2025-01-03 12:01:02.34567+9:00' AS timestamp with time zone));
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:01:02.34567+900');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:01:02.34567+9');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:01:02.34567JST');
EXECUTE prep_insert
  (timestamp with time zone '2025-02-01 00:00:00.001 America/New_York');
EXECUTE prep_insert
  (timestamp with time zone '2025-02-01 00:00:00.002 PST8PDT');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:01:02.34567Z');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01T12:01:02.34567 Z');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01T12:01:02.34567 ZULU');
EXECUTE prep_insert
  (timestamp with time zone '1887-12-31 15:00:00+00');
EXECUTE prep_insert
  (timestamp with time zone '9999-12-31 23:59:59.999999+14');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:01:02.34567 UTC');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:01:02.34567 Universal');
EXECUTE prep_insert
  (timestamp with time zone '2025-01-01 12:00');
EXECUTE prep_insert (NULL);
EXECUTE prep_insert ('2024-08-30 04:05:06.789+9:00');   -- auto cast

SET SESSION TIMEZONE TO 'UTC';  -- check time zone in UTC
EXECUTE prep_select_all;

SET SESSION TIMEZONE TO 'Asia/Tokyo';  -- check time zone in Asia/Tokyo
EXECUTE prep_select_all;

EXECUTE prep_update_nul ('2025-01-01 00:00:00.001+900');
EXECUTE prep_select_all;
EXECUTE prep_update
  ('2025-03-02 05:06:12.345+900'::timestamp with time zone,
   '2025-01-01 00:00:00.001+900'::timestamp with time zone);
EXECUTE prep_select_all_d;
EXECUTE prep_delete
  (CAST('2025-03-02 05:06:12.345+900' AS timestamp with time zone));
EXECUTE prep_select_all;

DEALLOCATE prep_insert;
DEALLOCATE prep_update;
DEALLOCATE prep_update_nul;
DEALLOCATE prep_delete;
DEALLOCATE prep_select_all;
DEALLOCATE prep_select_all_d;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');

-- Date/Time Types - Test teardown: PostgreSQL environment
SET TIMEZONE TO 'UTC';
SET DATESTYLE TO 'default';

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
PREPARE prep_select_all AS SELECT * FROM fdw_type_bytea ORDER BY c;

---- INSERT
PREPARE prep_insert (bytea) AS INSERT INTO fdw_type_bytea VALUES ($1);
EXECUTE prep_insert ('\x3132330a');
EXECUTE prep_insert ('');
EXECUTE prep_insert ('\x');
EXECUTE prep_insert (NULL);

EXECUTE prep_insert ('\x00 ');
EXECUTE prep_insert ('abc');

EXECUTE prep_select_all;

DEALLOCATE prep_insert;

---- SELECT
PREPARE prep_select_eq (bytea) AS
  SELECT * FROM fdw_type_bytea WHERE c = $1 ORDER BY c;
PREPARE prep_select_ne (bytea) AS
  SELECT * FROM fdw_type_bytea WHERE c <> $1 ORDER BY c;
PREPARE prep_select_nl AS
  SELECT * FROM fdw_type_bytea WHERE c IS NULL ORDER BY c;
PREPARE prep_select_nn AS
  SELECT * FROM fdw_type_bytea WHERE c IS NOT NULL ORDER BY c;

EXECUTE prep_select_eq ('\x3132330a');
EXECUTE prep_select_ne ('\x3132330a');
EXECUTE prep_select_nl;
EXECUTE prep_select_nn;
EXECUTE prep_select_eq ('\x');
EXECUTE prep_select_ne ('\x');

EXECUTE prep_select_eq ('\x00 ');
EXECUTE prep_select_eq ('abc');
EXECUTE prep_select_eq ('');

DEALLOCATE prep_select_eq;
DEALLOCATE prep_select_ne;
DEALLOCATE prep_select_nl;
DEALLOCATE prep_select_nn;

---- UPDATE
PREPARE prep_update_eq (bytea, bytea) AS
  UPDATE fdw_type_bytea SET c = $1 WHERE c = $2;
PREPARE prep_update_ne (bytea, bytea) AS
  UPDATE fdw_type_bytea SET c = $1 WHERE (c <> $2);
PREPARE prep_update_nl (bytea) AS
  UPDATE fdw_type_bytea SET c = $1 WHERE c IS NULL;
PREPARE prep_update_nn (bytea, bytea) AS
  UPDATE fdw_type_bytea SET c = $1 WHERE (c IS NOT NULL) AND (c = $2);

EXECUTE prep_update_eq ('\x41424300', '\x3132330a');
EXECUTE prep_select_all;

EXECUTE prep_update_ne ('\x314263ff', '\x');
EXECUTE prep_select_all;

EXECUTE prep_update_nl ('\x00');
EXECUTE prep_select_all;

EXECUTE prep_update_nn (NULL, '\x00');
EXECUTE prep_select_all;

EXECUTE prep_update_eq ('\x4e554c4c', '\x');
EXECUTE prep_select_all;

EXECUTE prep_update_eq ('\x00', '\x4e554c4c');
EXECUTE prep_select_all;

EXECUTE prep_update_eq ('abc', '\x00 ');
EXECUTE prep_select_all;

EXECUTE prep_update_eq ('', 'abc');
EXECUTE prep_select_all;

EXECUTE prep_update_eq ('\x7f', '');
EXECUTE prep_select_all;

EXECUTE prep_update_eq ('\x00 ', '\x7f');
EXECUTE prep_select_all;

EXECUTE prep_update_eq ('abc', '\x00');
EXECUTE prep_select_all;

DEALLOCATE prep_update_eq;
DEALLOCATE prep_update_ne;
DEALLOCATE prep_update_nl;
DEALLOCATE prep_update_nn;

---- DELETE
PREPARE prep_delete_all AS DELETE FROM fdw_type_bytea;
PREPARE prep_delete_eq (bytea) AS DELETE FROM fdw_type_bytea WHERE c = $1;
PREPARE prep_delete_ne (bytea) AS DELETE FROM fdw_type_bytea WHERE c <> $1;
PREPARE prep_delete_nl AS DELETE FROM fdw_type_bytea WHERE c IS NULL;
PREPARE prep_delete_nn AS DELETE FROM fdw_type_bytea WHERE c IS NOT NULL;

EXECUTE prep_delete_all;
EXECUTE prep_select_all;

INSERT INTO fdw_type_bytea VALUES
  ('\x616263ff'),
  ('\x'),
  ('\x00'),
  ('\xff'),
  (NULL);

EXECUTE prep_delete_eq ('\x616263ff');
EXECUTE prep_select_all;

EXECUTE prep_delete_ne ('\x');
EXECUTE prep_select_all;

EXECUTE prep_delete_eq ('\x');
EXECUTE prep_select_all;

INSERT INTO fdw_type_bytea VALUES ('\x00'), ('\xff');
EXECUTE prep_delete_nn;
EXECUTE prep_select_all;

EXECUTE prep_delete_nl;
EXECUTE prep_select_all;

INSERT INTO fdw_type_bytea VALUES ('\x616263'), ('\x'), ('\x00'), (NULL);
EXECUTE prep_delete_eq ('\x00 ');
EXECUTE prep_select_all;

EXECUTE prep_delete_eq ('abc');
EXECUTE prep_select_all;

EXECUTE prep_delete_eq ('');
EXECUTE prep_select_all;

DEALLOCATE prep_delete_all;
DEALLOCATE prep_delete_eq;
DEALLOCATE prep_delete_ne;
DEALLOCATE prep_delete_nl;
DEALLOCATE prep_delete_nn;

DEALLOCATE prep_select_all;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_bytea;

--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_bytea', 'tsurugidb');
