SET datestyle TO ISO, YMD;
SET timezone TO 'Asia/Tokyo';

/* Test case: 1-1-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_1;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');

/* Test case: 1-1-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id BIGINT, since DATE)');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_1;
DROP FOREIGN TABLE fdw_test_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');

/* Test case: 1-1-3 */
-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE

/* Test case: 1-1-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT)');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_1;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');

/* Test case: 1-1-5 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');

-- Test setup: DDL of the PostgreSQL
CREATE SCHEMA other_schema;

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO other_schema;
\dE
\dE other_schema.*
\d other_schema.fdw_test_table_1

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE other_schema.fdw_test_table_1;
DROP SCHEMA other_schema;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');

/* Test case: 1-2-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_2) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-2-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_1, fdw_test_table_3) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*
DROP FOREIGN TABLE fdw_test_table_1;
DROP FOREIGN TABLE fdw_test_table_3;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-2-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (not_exist) FROM SERVER tsurugidb INTO public;
\dE

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-2-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (not_exist, fdw_test_table_2) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-2-5 */
-- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_1) FROM SERVER tsurugidb INTO public;
\dE

/* Test case: 1-3-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_2) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_1;
DROP FOREIGN TABLE fdw_test_table_3;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-3-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_1, fdw_test_table_3) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-3-3 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public EXCEPT (not_exist) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_1;
DROP FOREIGN TABLE fdw_test_table_2;
DROP FOREIGN TABLE fdw_test_table_3;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-3-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public EXCEPT (not_exist, fdw_test_table_2) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_1;
DROP FOREIGN TABLE fdw_test_table_3;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 1-3-5 */
-- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_1) FROM SERVER tsurugidb INTO public;
\dE

/* Test case: 2-1-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
INSERT INTO "fdw_test_table_A" VALUES (1, 'information');
INSERT INTO "fdw_test_Table_A" VALUES (1, DATE '2025-01-02');
INSERT INTO "fdw_test_table_a" VALUES (1, TIME '11:22:33');
\dE
\d "fdw_test_table_A"
\d "fdw_test_Table_A"
\d "fdw_test_table_a"
SELECT * FROM "fdw_test_table_A";
SELECT * FROM "fdw_test_Table_A";
SELECT * FROM "fdw_test_table_a";

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE "fdw_test_table_A";
DROP FOREIGN TABLE "fdw_test_Table_A";
DROP FOREIGN TABLE "fdw_test_table_a";

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_Table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_a');

/* Test case: 2-1-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_a (col_a INT, Col_a CHAR(64), COL_A DATE)');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
INSERT INTO fdw_test_table_a VALUES (111, 'abcdefg', DATE '2025-01-02');
\dE
\d fdw_test_table_a
SELECT * FROM fdw_test_table_a;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_a;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_a');

/* Test case: 2-3-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_2 (id INT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_3 (id INT, timer TIME)');
CREATE FOREIGN TABLE fdw_test_table_2 (id INT, since DATE) SERVER tsurugidb;

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_2;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_2');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_3');

/* Test case: 2-3-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_a (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_TABLE_B (id INT, since DATE)');
CREATE FOREIGN TABLE "fdw_test_TABLE_A" (col1 INT, col2 VARCHAR) SERVER tsurugidb;
CREATE FOREIGN TABLE "fdw_test_table_b" (col1 INT, col2 DATE) SERVER tsurugidb;

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d "fdw_test_table_a"
\d "fdw_test_TABLE_B"

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE "fdw_test_TABLE_A";
DROP FOREIGN TABLE "fdw_test_table_b";
DROP FOREIGN TABLE "fdw_test_table_a";
DROP FOREIGN TABLE "fdw_test_TABLE_B";

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_a');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_TABLE_B');

/* Test case: 2-4-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_Table_A) FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_table_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_table_a;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_Table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_a');

/* Test case: 2-4-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public LIMIT TO ("fdw_test_Table_A") FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_*

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE "fdw_test_Table_A";

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_Table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_a');

/* Test case: 2-5-1 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_Table_A) FROM SERVER tsurugidb INTO public;
\dE
\d "fdw_test_table_A"
\d "fdw_test_Table_A"

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE "fdw_test_table_A";
DROP FOREIGN TABLE "fdw_test_Table_A";

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_Table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_a');

/* Test case: 2-5-2 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_A (id INT, name CHAR(64))');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE)');
SELECT tg_execute_ddl('tsurugidb', 'CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME)');

-- Test
IMPORT FOREIGN SCHEMA public EXCEPT ("fdw_test_Table_A") FROM SERVER tsurugidb INTO public;
\dE
\d "fdw_test_table_A"
\d "fdw_test_table_a"

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE "fdw_test_table_A";
DROP FOREIGN TABLE "fdw_test_table_a";

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_Table_A');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_table_a');

/* Test case: 3-1-1_4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
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
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_type_num;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_type_num;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_num');

/* Test case: 3-2-1_4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
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
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_type_str;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_type_str;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_str');

/* Test case: 3-3-1_4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_type_datetime (
    col_date DATE,
    col_time TIME,
    col_time_tz TIME WITH TIME ZONE,
    col_timestamp TIMESTAMP,
    col_timestamp_tz TIMESTAMP WITH TIME ZONE
  )
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;
\dE
\d fdw_test_type_datetime;

-- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_test_type_datetime;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_datetime');

/* Test case: 3-4 */
-- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', '
  CREATE TABLE fdw_test_type_invalid (col_binary BINARY)
');

-- Test
IMPORT FOREIGN SCHEMA public FROM SERVER tsurugidb INTO public;

-- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE fdw_test_type_invalid');
