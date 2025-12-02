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
PREPARE fdw_prepare_ins (integer) AS
  INSERT INTO fdw_type_int VALUES ($1);
PREPARE fdw_prepare_upd (integer, integer) AS
  UPDATE fdw_type_int SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_upd_nul (integer) AS
  UPDATE fdw_type_int SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (integer) AS
  DELETE FROM fdw_type_int WHERE c = $1;
PREPARE fdw_prepare_sel (integer) AS
  SELECT * FROM fdw_type_int WHERE c = $1 ORDER BY c;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_int ORDER BY c;

EXECUTE fdw_prepare_ins (12345);
EXECUTE fdw_prepare_ins (-12345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (2147483644);  --max-3
EXECUTE fdw_prepare_ins (2147483645);  --max-2
EXECUTE fdw_prepare_ins (2147483646);  --max-1
EXECUTE fdw_prepare_ins (2147483647);  --max
EXECUTE fdw_prepare_ins (-2147483645);  --min+3
EXECUTE fdw_prepare_ins (-2147483646);  --min+2
EXECUTE fdw_prepare_ins (-2147483647);  --min+1
EXECUTE fdw_prepare_ins (-2147483648);  --min
EXECUTE fdw_prepare_ins (1.1);  -- auto-cast

PREPARE fdw_prepare_ins_ex AS
  INSERT INTO fdw_type_int VALUES (CAST(0.1 AS int));
EXECUTE fdw_prepare_ins_ex;
DEALLOCATE fdw_prepare_ins_ex;

EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_sel (2147483647);
EXECUTE fdw_prepare_sel (-2147483648);

EXECUTE fdw_prepare_upd (2147483647, -2147483648);
EXECUTE fdw_prepare_sel (2147483647);

EXECUTE fdw_prepare_upd (-2147483648, 2147483647);
EXECUTE fdw_prepare_sel (-2147483648);
EXECUTE fdw_prepare_del (-2147483648);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (2147483647);
EXECUTE fdw_prepare_del (2147483647);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel_all;

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
PREPARE fdw_prepare_upd (bigint, bigint) AS
  UPDATE fdw_type_bigint SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_upd_nul (bigint) AS
  UPDATE fdw_type_bigint SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (bigint) AS
  DELETE FROM fdw_type_bigint WHERE c = $1;
PREPARE fdw_prepare_sel (bigint) AS
  SELECT * FROM fdw_type_bigint WHERE c = $1 ORDER BY c;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_bigint ORDER BY c;

EXECUTE fdw_prepare_ins (12345);
EXECUTE fdw_prepare_ins (-12345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (9223372036854775804);  --max-3
EXECUTE fdw_prepare_ins (9223372036854775805);  --max-2
EXECUTE fdw_prepare_ins (9223372036854775806);  --max-1
EXECUTE fdw_prepare_ins (9223372036854775807);  --max
EXECUTE fdw_prepare_ins (-9223372036854775805);  --min+3
EXECUTE fdw_prepare_ins (-9223372036854775806);  --min+2
EXECUTE fdw_prepare_ins (-9223372036854775807);  --min+1
EXECUTE fdw_prepare_ins (-9223372036854775808);  --min
EXECUTE fdw_prepare_ins (1.1);  -- auto-cast

PREPARE fdw_prepare_ins_ex AS
  INSERT INTO fdw_type_bigint VALUES (CAST(0.1 AS int));
EXECUTE fdw_prepare_ins_ex;
DEALLOCATE fdw_prepare_ins_ex;

EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_sel (9223372036854775807);
EXECUTE fdw_prepare_sel (-9223372036854775808);

EXECUTE fdw_prepare_upd (9223372036854775807, -9223372036854775808);
EXECUTE fdw_prepare_sel (9223372036854775807);

EXECUTE fdw_prepare_upd (-9223372036854775808, 9223372036854775807);
EXECUTE fdw_prepare_del (-9223372036854775808);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (9223372036854775807);
EXECUTE fdw_prepare_del (9223372036854775807);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel;
DEALLOCATE fdw_prepare_sel_all;

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
PREPARE fdw_prepare_upd (decimal) AS
  UPDATE fdw_type_decimal SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (decimal) AS
  UPDATE fdw_type_decimal SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (decimal) AS
  DELETE FROM fdw_type_decimal WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_decimal ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_decimal ORDER BY c DESC;

EXECUTE fdw_prepare_ins (12345);
EXECUTE fdw_prepare_ins (-12345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (987654);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (987654);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (-987654);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_upd (decimal(5)) AS
  UPDATE fdw_type_decimal_p SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (decimal(5)) AS
  UPDATE fdw_type_decimal_p SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (decimal(5)) AS
  DELETE FROM fdw_type_decimal_p WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_decimal_p ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_decimal_p ORDER BY c DESC;

EXECUTE fdw_prepare_ins (12345);
EXECUTE fdw_prepare_ins (-12345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (98765);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (98765);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (-98765);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_upd (decimal(5, 2)) AS
  UPDATE fdw_type_decimal_ps SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (decimal(5, 2)) AS
  UPDATE fdw_type_decimal_ps SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (decimal(5, 2)) AS
  DELETE FROM fdw_type_decimal_ps WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_decimal_ps ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_decimal_ps ORDER BY c DESC;

EXECUTE fdw_prepare_ins (123.45);
EXECUTE fdw_prepare_ins (-123.45);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (987.65);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (987.65);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (-987.65);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_ins (abs(-17.4));
EXECUTE fdw_prepare_ins (ceil(-42.8));
EXECUTE fdw_prepare_ins (floor(-42.8));
EXECUTE fdw_prepare_ins (mod(9, 4));
EXECUTE fdw_prepare_ins (round(42.4));
EXECUTE fdw_prepare_ins (round(42.4382, 2));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (numeric(38, 0)) AS
  INSERT INTO fdw_type_decimal_ps0 VALUES ($1);
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_decimal_ps0 ORDER BY c;

EXECUTE fdw_prepare_ins (0);
EXECUTE fdw_prepare_ins (1);
EXECUTE fdw_prepare_ins (18446744073709551615);
EXECUTE fdw_prepare_ins (18446744073709551616);
EXECUTE fdw_prepare_ins (99999999999999999999999999999999999999);
EXECUTE fdw_prepare_ins (-1);
EXECUTE fdw_prepare_ins (-18446744073709551615);
EXECUTE fdw_prepare_ins (-18446744073709551616);
EXECUTE fdw_prepare_ins (-99999999999999999999999999999999999999);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel_all;

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
PREPARE fdw_prepare_ins (numeric(38, 38)) AS
  INSERT INTO fdw_type_decimal_ps38 VALUES ($1);
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_decimal_ps38 ORDER BY c;

EXECUTE fdw_prepare_ins (0);
EXECUTE fdw_prepare_ins (0.00000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins (0.00000000000000000018446744073709551615);
EXECUTE fdw_prepare_ins (0.00000000000000000018446744073709551616);
EXECUTE fdw_prepare_ins (0.99999999999999999999999999999999999999);
EXECUTE fdw_prepare_ins (-0.00000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins (-0.00000000000000000018446744073709551615);
EXECUTE fdw_prepare_ins (-0.00000000000000000018446744073709551616);
EXECUTE fdw_prepare_ins (-0.99999999999999999999999999999999999999);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel_all;

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
PREPARE fdw_prepare_upd (numeric) AS
  UPDATE fdw_type_numeric SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (numeric) AS
  UPDATE fdw_type_numeric SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (numeric) AS
  DELETE FROM fdw_type_numeric WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_numeric ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_numeric ORDER BY c DESC;

EXECUTE fdw_prepare_ins (12345);
EXECUTE fdw_prepare_ins (-12345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (987654);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (987654);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (-987654);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_upd (numeric(5)) AS
  UPDATE fdw_type_numeric_p SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (numeric(5)) AS
  UPDATE fdw_type_numeric_p SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (numeric(5)) AS
  DELETE FROM fdw_type_numeric_p WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_numeric_p ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_numeric_p ORDER BY c DESC;

EXECUTE fdw_prepare_ins (12345);
EXECUTE fdw_prepare_ins (-12345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (98765);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (98765);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (-98765);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_upd (numeric(5, 2)) AS
  UPDATE fdw_type_numeric_ps SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (numeric(5, 2)) AS
  UPDATE fdw_type_numeric_ps SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (numeric(5, 2)) AS
  DELETE FROM fdw_type_numeric_ps WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_numeric_ps ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_numeric_ps ORDER BY c DESC;

EXECUTE fdw_prepare_ins (123.45);
EXECUTE fdw_prepare_ins (-123.45);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (987.65);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (987.65);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (-987.65);
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_ins (abs(-17.4));
EXECUTE fdw_prepare_ins (CAST(cbrt(27.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (ceil(-42.8));
EXECUTE fdw_prepare_ins (ceiling(-95.3));
EXECUTE fdw_prepare_ins (CAST(degrees(0.5) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (div(9,4));
EXECUTE fdw_prepare_ins (CAST(exp(1.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (factorial(5));
EXECUTE fdw_prepare_ins (floor(-42.8));
EXECUTE fdw_prepare_ins (CAST(ln(2.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (log(100.0));
EXECUTE fdw_prepare_ins (log10(100.0));
EXECUTE fdw_prepare_ins (log(2.0, 64.0));
EXECUTE fdw_prepare_ins (mod(9, 4));
EXECUTE fdw_prepare_ins (CAST(pi() AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (power(9.0, 3.0));
EXECUTE fdw_prepare_ins (CAST(radians(45.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (round(42.4));
EXECUTE fdw_prepare_ins (round(42.4382, 2));
EXECUTE fdw_prepare_ins (sign(-8.4));
EXECUTE fdw_prepare_ins (CAST(scale(8.41) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (CAST(sqrt(2.0) AS DECIMAL(5, 2)));
EXECUTE fdw_prepare_ins (trunc(42.8));
EXECUTE fdw_prepare_ins (trunc(42.4382, 2));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (numeric(38, 0)) AS
  INSERT INTO fdw_type_numeric_ps0 VALUES ($1);
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_numeric_ps0 ORDER BY c;

EXECUTE fdw_prepare_ins (0);
EXECUTE fdw_prepare_ins (1);
EXECUTE fdw_prepare_ins (18446744073709551615);
EXECUTE fdw_prepare_ins (18446744073709551616);
EXECUTE fdw_prepare_ins (99999999999999999999999999999999999999);
EXECUTE fdw_prepare_ins (-1);
EXECUTE fdw_prepare_ins (-18446744073709551615);
EXECUTE fdw_prepare_ins (-18446744073709551616);
EXECUTE fdw_prepare_ins (-99999999999999999999999999999999999999);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel_all;

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
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_numeric_ps38 ORDER BY c;

EXECUTE fdw_prepare_ins (0);  -- see tsurugi-issues#736
EXECUTE fdw_prepare_ins (0.00000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins (0.00000000000000000018446744073709551615);
EXECUTE fdw_prepare_ins (0.00000000000000000018446744073709551616);
EXECUTE fdw_prepare_ins (0.99999999999999999999999999999999999999);
EXECUTE fdw_prepare_ins (-0.00000000000000000000000000000000000001);
EXECUTE fdw_prepare_ins (-0.00000000000000000018446744073709551615);
EXECUTE fdw_prepare_ins (-0.00000000000000000018446744073709551616);
EXECUTE fdw_prepare_ins (-0.99999999999999999999999999999999999999);
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_sel_all;

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
PREPARE fdw_prepare_upd (real) AS
  UPDATE fdw_type_real SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (real) AS
  UPDATE fdw_type_real SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (real) AS
  DELETE FROM fdw_type_real WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_real ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_real ORDER BY c DESC;

EXECUTE fdw_prepare_ins (0.1);
EXECUTE fdw_prepare_ins (1.1);
EXECUTE fdw_prepare_ins (1.2345);
EXECUTE fdw_prepare_ins (-1.2345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (12.345678901234567890); --20 digits
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (9.87654);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (9.87654::real);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (CAST(-9.87654 AS real));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_upd (double precision) AS
  UPDATE fdw_type_double SET c = c * -1 WHERE c = $1;
PREPARE fdw_prepare_upd_nul (double precision) AS
  UPDATE fdw_type_double SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (double precision) AS
  DELETE FROM fdw_type_double WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_double ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_double ORDER BY c DESC;

EXECUTE fdw_prepare_ins (0.1);
EXECUTE fdw_prepare_ins (1.1);
EXECUTE fdw_prepare_ins (1.2345);
EXECUTE fdw_prepare_ins (-1.2345);
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (12.345678901234567890); --20 digits
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul (9.87654);
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd (9.87654::double precision);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (CAST(-9.87654 AS double precision));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_upd (char, char) AS
  UPDATE fdw_type_char SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_upd_nul (char) AS
  UPDATE fdw_type_char SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (char) AS
  DELETE FROM fdw_type_char WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_char ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_char ORDER BY c DESC;

EXECUTE fdw_prepare_ins ('a');
EXECUTE fdw_prepare_ins ('');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (1);  -- auto-cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('X');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd ('z', 'X');
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del ('z');
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_upd (char(10), char(10)) AS
  UPDATE fdw_type_char_l SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_upd_nul (char(10)) AS
  UPDATE fdw_type_char_l SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (char(10)) AS
  DELETE FROM fdw_type_char_l WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_char_l ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_char_l ORDER BY c DESC;

EXECUTE fdw_prepare_ins ('abcdef');
EXECUTE fdw_prepare_ins ('PostgreSQL');
EXECUTE fdw_prepare_ins ('');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (12345);  -- auto-cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('NULL');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd ('update', CAST('NULL' AS char(10)));
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del ('update'::char(10));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (varchar) AS
  INSERT INTO fdw_type_varchar VALUES ($1);
PREPARE fdw_prepare_upd (varchar, varchar) AS
  UPDATE fdw_type_varchar SET c = c || '_' || $1 WHERE c = $2;
PREPARE fdw_prepare_upd_nul (varchar) AS
  UPDATE fdw_type_varchar SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (varchar) AS
  DELETE FROM fdw_type_varchar WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_varchar ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_varchar ORDER BY c DESC;

EXECUTE fdw_prepare_ins ('abcdef');
EXECUTE fdw_prepare_ins ('');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (12345);  -- auto-cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('NULL');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd ('updated', 'NULL');
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del ('NULL_updated');
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (varchar(10)) AS
  INSERT INTO fdw_type_varchar_l VALUES ($1);
PREPARE fdw_prepare_upd (varchar(10), varchar(10)) AS
  UPDATE fdw_type_varchar_l SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_upd_nul (varchar(10)) AS
  UPDATE fdw_type_varchar_l SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (varchar(10)) AS
  DELETE FROM fdw_type_varchar_l WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_varchar_l ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_varchar_l ORDER BY c DESC;

EXECUTE fdw_prepare_ins ('abcdef');
EXECUTE fdw_prepare_ins ('PostgreSQL');
EXECUTE fdw_prepare_ins ('');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (12345);  -- auto-cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('NULL');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd ('update', 'NULL');
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del ('update');
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (text) AS
  INSERT INTO fdw_type_text VALUES ($1);
PREPARE fdw_prepare_upd (text, text) AS
  UPDATE fdw_type_text SET c = c || '_' || $1 WHERE c = $2;
PREPARE fdw_prepare_upd_nul (text) AS
  UPDATE fdw_type_text SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_del (text) AS
  DELETE FROM fdw_type_text WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_text ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_text ORDER BY c DESC;

EXECUTE fdw_prepare_ins ('abcdef');
EXECUTE fdw_prepare_ins ('');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins (12345);  -- auto-cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('NULL');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd ('updated', 'NULL');
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del ('NULL_updated');
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (date) AS
  INSERT INTO fdw_type_date VALUES ($1);
PREPARE fdw_prepare_upd_nul (date) AS
  UPDATE fdw_type_date SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_upd (date, date) AS
  UPDATE fdw_type_date SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_del (date) AS
  DELETE FROM fdw_type_date WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_date ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_date ORDER BY c DESC;

EXECUTE fdw_prepare_ins (date '2025-01-01');
EXECUTE fdw_prepare_ins ('2025-01-02'::date);
EXECUTE fdw_prepare_ins (CAST('2025-01-03' AS date));
EXECUTE fdw_prepare_ins (date '0001-01-01');
EXECUTE fdw_prepare_ins (date '9999-12-31');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins ('2024-12-31');  -- auto cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('2025-02-01');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd ('2025-03-10'::date, '2025-02-01'::date);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (CAST('2025-03-10' AS date));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (time) AS
  INSERT INTO fdw_type_time VALUES ($1);
PREPARE fdw_prepare_upd_nul (time) AS
  UPDATE fdw_type_time SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_upd (time, time) AS
  UPDATE fdw_type_time SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_del (time) AS
  DELETE FROM fdw_type_time WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_time ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_time ORDER BY c DESC;

EXECUTE fdw_prepare_ins (time '01:02:03.456');
EXECUTE fdw_prepare_ins ('03:02:01.456'::time);
EXECUTE fdw_prepare_ins (CAST('02:01:03.456' AS time));
EXECUTE fdw_prepare_ins (time '01:02:03.456789012');
EXECUTE fdw_prepare_ins (time '00:00:00');
EXECUTE fdw_prepare_ins (time '23:59:59.999999');
EXECUTE fdw_prepare_ins (time '050607.890123456');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins ('04:05:06.789');  -- auto cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('00:00:00.001');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd ('07:08:12.345'::time, '00:00:00.001'::time);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (CAST('07:08:12.345' AS time));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (timestamp) AS
  INSERT INTO fdw_type_timestamp VALUES ($1);
PREPARE fdw_prepare_upd_nul (timestamp) AS
  UPDATE fdw_type_timestamp SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_upd (timestamp, timestamp) AS
  UPDATE fdw_type_timestamp SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_del (timestamp) AS
  DELETE FROM fdw_type_timestamp WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_timestamp ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_timestamp ORDER BY c DESC;

EXECUTE fdw_prepare_ins (timestamp '2025-01-01 00:00:00');
EXECUTE fdw_prepare_ins ('2025-01-02 00:00:00'::timestamp);
EXECUTE fdw_prepare_ins (CAST('2025-01-03 00:00:00' AS timestamp));
EXECUTE fdw_prepare_ins (timestamp '1887-12-31 15:00:00');
EXECUTE fdw_prepare_ins (timestamp '9999-12-31 23:59:59.999999');
EXECUTE fdw_prepare_ins (timestamp '2025/01/01');
EXECUTE fdw_prepare_ins (timestamp '2025/01/01 12:00');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins ('2024-08-30 04:05:06.789');  -- auto cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('2025-01-01 00:00:00.001');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd
  ('2025-03-02 05:06:12.345'::timestamp, '2025-01-01 00:00:00.001'::timestamp);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del (CAST('2025-03-02 05:06:12.345' AS timestamp));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (timestamp without time zone) AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES ($1);
PREPARE fdw_prepare_upd_nul (timestamp without time zone) AS
  UPDATE fdw_type_timestamp_wo_tz SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_upd
  (timestamp without time zone, timestamp without time zone) AS
  UPDATE fdw_type_timestamp_wo_tz SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_del (timestamp without time zone) AS
  DELETE FROM fdw_type_timestamp_wo_tz WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_timestamp_wo_tz ORDER BY c DESC;

EXECUTE fdw_prepare_ins (timestamp without time zone '2025-01-01 00:00:00');
EXECUTE fdw_prepare_ins ('2025-01-02 00:00:00'::timestamp without time zone);
EXECUTE fdw_prepare_ins
  (CAST('2025-01-03 00:00:00' AS timestamp without time zone));
EXECUTE fdw_prepare_ins (timestamp without time zone '1887-12-31 15:00:00');
EXECUTE fdw_prepare_ins
  (timestamp without time zone '9999-12-31 23:59:59.999999');
EXECUTE fdw_prepare_ins (timestamp without time zone '2025/01/01');
EXECUTE fdw_prepare_ins (timestamp without time zone '2025/01/01 12:00');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins ('2024-08-30 04:05:06.789');  -- auto cast
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('2025-01-01 00:00:00.001');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd
  ('2025-03-02 05:06:12.345'::timestamp without time zone,
   '2025-01-01 00:00:00.001'::timestamp without time zone);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del
  (CAST('2025-03-02 05:06:12.345' AS timestamp without time zone));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

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
PREPARE fdw_prepare_ins (timestamp with time zone) AS
  INSERT INTO fdw_type_timestamp_tz VALUES ($1);
PREPARE fdw_prepare_upd_nul (timestamp with time zone) AS
  UPDATE fdw_type_timestamp_tz SET c = $1 WHERE c IS NULL;
PREPARE fdw_prepare_upd (timestamp with time zone, timestamp with time zone) AS
  UPDATE fdw_type_timestamp_tz SET c = $1 WHERE c = $2;
PREPARE fdw_prepare_del (timestamp with time zone) AS
  DELETE FROM fdw_type_timestamp_tz WHERE c = $1;
PREPARE fdw_prepare_sel_all AS
  SELECT * FROM fdw_type_timestamp_tz ORDER BY c;
PREPARE fdw_prepare_sel_all_d AS
  SELECT * FROM fdw_type_timestamp_tz ORDER BY c DESC;

EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:01:02.34567+9:00');
EXECUTE fdw_prepare_ins
  ('2025-01-02 12:01:02.34567+9:00'::timestamp with time zone);
EXECUTE fdw_prepare_ins
  (CAST('2025-01-03 12:01:02.34567+9:00' AS timestamp with time zone));
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:01:02.34567+900');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:01:02.34567+9');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:01:02.34567JST');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-02-01 00:00:00.001 America/New_York');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-02-01 00:00:00.002 PST8PDT');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:01:02.34567Z');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01T12:01:02.34567 Z');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01T12:01:02.34567 ZULU');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '1887-12-31 15:00:00+00');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '9999-12-31 23:59:59.999999+14');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:01:02.34567 UTC');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:01:02.34567 Universal');
EXECUTE fdw_prepare_ins
  (timestamp with time zone '2025-01-01 12:00');
EXECUTE fdw_prepare_ins (NULL);
EXECUTE fdw_prepare_ins ('2024-08-30 04:05:06.789+9:00');   -- auto cast

SET SESSION TIMEZONE TO 'UTC';  -- check time zone in UTC
EXECUTE fdw_prepare_sel_all;

SET SESSION TIMEZONE TO 'Asia/Tokyo';  -- check time zone in Asia/Tokyo
EXECUTE fdw_prepare_sel_all;

EXECUTE fdw_prepare_upd_nul ('2025-01-01 00:00:00.001+900');
EXECUTE fdw_prepare_sel_all;
EXECUTE fdw_prepare_upd
  ('2025-03-02 05:06:12.345+900'::timestamp with time zone,
   '2025-01-01 00:00:00.001+900'::timestamp with time zone);
EXECUTE fdw_prepare_sel_all_d;
EXECUTE fdw_prepare_del
  (CAST('2025-03-02 05:06:12.345+900' AS timestamp with time zone));
EXECUTE fdw_prepare_sel_all;

DEALLOCATE fdw_prepare_ins;
DEALLOCATE fdw_prepare_upd;
DEALLOCATE fdw_prepare_upd_nul;
DEALLOCATE fdw_prepare_del;
DEALLOCATE fdw_prepare_sel_all;
DEALLOCATE fdw_prepare_sel_all_d;

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');

-- Date/Time Types - Test teardown: PostgreSQL environment
SET TIMEZONE TO 'UTC';
SET DATESTYLE TO 'default';
