/* Test case: happy path - IMPORT FOREIGN SCHEMA functionality */
-- Test setup: PostgreSQL environment
SET datestyle TO ISO, YMD;
SET timezone TO 'Asia/Tokyo';

-- Test setup: PostgreSQL functions
CREATE OR REPLACE FUNCTION drop_foreign_tables()
RETURNS text AS $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT n.nspname, c.relname
    FROM pg_foreign_table ft
      JOIN pg_class c ON c.oid = ft.ftrelid
      JOIN pg_namespace n ON n.oid = c.relnamespace
  LOOP
    EXECUTE format('DROP FOREIGN TABLE %I.%I;', r.nspname, r.relname);
  END LOOP;
  RETURN 'DROP FOREIGN TABLE';
END;
$$ LANGUAGE plpgsql;

-- Test case: 1-1-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');

-- Test case: 1-1-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id BIGINT, since DATE)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');

-- Test case: 1-1-3
--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();

-- Test case: 1-1-4
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');

-- Test case: 1-1-5
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE SCHEMA other_schema;

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO other_schema;
\det fdw_test_*
\det other_schema.fdw_test_*
\d other_schema.fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
DROP SCHEMA other_schema;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');

-- Test case: 1-2-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_2)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-2-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_1, fdw_test_table_3)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-2-3
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (not_exist) FROM SERVER tsurugidb INTO public;
\det fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-2-4
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (not_exist, fdw_test_table_2)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-2-5
--- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_1)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();

-- Test case: 1-3-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_2)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-3-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_1, fdw_test_table_3)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-3-3
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public EXCEPT (not_exist)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-3-4
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_2 (id INT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public EXCEPT (not_exist, fdw_test_table_2)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_3', 'tsurugidb');

-- Test case: 1-3-5
--- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_1)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();

-- Test case: 2-1-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
INSERT INTO "fdw_test_table_A" VALUES (1, 'information');
INSERT INTO "fdw_test_Table_A" VALUES (1, DATE '2025-01-02');
INSERT INTO "fdw_test_table_a" VALUES (1, TIME '11:22:33');
\det fdw_test_*
\d "fdw_test_table_A"
\d "fdw_test_Table_A"
\d "fdw_test_table_a"
SELECT * FROM "fdw_test_table_A";
SELECT * FROM "fdw_test_Table_A";
SELECT * FROM "fdw_test_table_a";

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_Table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_a', 'tsurugidb');

-- Test case: 2-1-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_a (col_a INT, Col_a CHAR(64), COL_A DATE)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
INSERT INTO fdw_test_table_a VALUES (111, 'abcdefg', DATE '2025-01-02');
\det fdw_test_*
\d fdw_test_table_a
SELECT * FROM fdw_test_table_a;

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_a', 'tsurugidb');

-- Test case: 2-3-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_a (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_TABLE_B (id INT, since DATE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE "fdw_test_TABLE_A" (col1 INT, col2 VARCHAR)
  SERVER tsurugidb;
CREATE FOREIGN TABLE "fdw_test_table_b" (col1 INT, col2 DATE)
  SERVER tsurugidb;

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d "fdw_test_table_a"
\d "fdw_test_TABLE_B"

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_a', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_TABLE_B', 'tsurugidb');

-- Test case: 2-4-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_Table_A)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_Table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_a', 'tsurugidb');

-- Test case: 2-4-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public LIMIT TO ("fdw_test_Table_A")
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_*

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_Table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_a', 'tsurugidb');

-- Test case: 2-5-1
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_Table_A)
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d "fdw_test_table_A"
\d "fdw_test_Table_A"

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_Table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_a', 'tsurugidb');

-- Test case: 2-5-2
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)
', 'tsurugidb');
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public EXCEPT ("fdw_test_Table_A")
  FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d "fdw_test_table_A"
\d "fdw_test_table_a"

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_Table_A', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE fdw_test_table_a', 'tsurugidb');

-- Test case: 3-1-1_4
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_type_num (
    col_int INT,
    col_bigint BIGINT,
    col_real REAL,
    col_float FLOAT,
    col_double DOUBLE,
    col_double_precision DOUBLE PRECISION,
    col_decimal DECIMAL,
    col_decimal_p DECIMAL(2),
    col_decimal_ps DECIMAL(3, 2),
    col_decimal_max DECIMAL(*)
  )
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_type_num;

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_type_num', 'tsurugidb');

-- Test case: 3-2-1_4
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_type_str (
    col_char CHAR,
    col_char_l CHAR(64),
    col_character CHARACTER,
    col_character_l CHARACTER(64),
    col_varchar VARCHAR,
    col_varchar_l VARCHAR(64),
    col_char_varying CHAR VARYING,
    col_char_varying_l CHAR VARYING(64),
    col_character_varying CHARACTER VARYING,
    col_character_varying_l CHARACTER VARYING(64)
  )
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_type_str;

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_type_str', 'tsurugidb');

-- Test case: 3-3-1_4
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_type_datetime (
    col_date DATE,
    col_time TIME,
    col_time_tz TIME WITH TIME ZONE,
    col_timestamp TIMESTAMP,
    col_timestamp_tz TIMESTAMP WITH TIME ZONE
  )
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_type_datetime;

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_type_datetime', 'tsurugidb');

-- Test case: 3-4-1_4
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_test_type_binary (
    col_binary BINARY,
    col_varbinary VARBINARY,
    col_binary_var BINARY VARYING
  )
', 'tsurugidb');

--- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\det fdw_test_*
\d fdw_test_type_binary;

--- Test teardown: DDL of the PostgreSQL
SELECT drop_foreign_tables();
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_test_type_binary', 'tsurugidb');
