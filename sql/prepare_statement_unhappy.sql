/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE tg_timedate (
        id INTEGER NOT NULL PRIMARY KEY,
        tms TIMESTAMP DEFAULT TIMESTAMP ''2023-03-03 23:59:35.123456'',
        dt DATE DEFAULT DATE ''2023-03-03'',
        tm TIME DEFAULT TIME ''23:59:35.123456789''
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE employee_1 (
        id INTEGER DEFAULT 1,
        name VARCHAR(100) DEFAULT ''Unknown'',
        salary NUMERIC(10, 2) DEFAULT 30000.00
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE employee_2 (
        id INTEGER DEFAULT 1,
        name VARCHAR(100) DEFAULT ''Unknown'',
        salary NUMERIC(10, 2) DEFAULT 30000.00
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE employee_i (
        id INTEGER DEFAULT 1,
        name VARCHAR(100) DEFAULT ''Unknown'',
        salary NUMERIC(10, 2) DEFAULT 30000.00
    )
', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE tg_timedate (
    id INTEGER NOT NULL,
    tms TIMESTAMP DEFAULT '2023-03-03 23:59:35.123456',
    dt DATE DEFAULT '2023-03-03',
    tm TIME DEFAULT '23:59:35.123456789'
) SERVER tsurugidb;
CREATE FOREIGN TABLE employee_1 (
    id INTEGER DEFAULT 1,
    name VARCHAR(100) DEFAULT 'Unknown',
    salary NUMERIC(10, 2) DEFAULT 30000.00
) SERVER tsurugidb;
CREATE FOREIGN TABLE employee_2 (
    id INTEGER DEFAULT 1,
    name VARCHAR(100) DEFAULT 'Unknown',
    salary NUMERIC(10, 2) DEFAULT 30000.00
) SERVER tsurugidb;
CREATE FOREIGN TABLE employee_i (
    id INTEGER DEFAULT 1,
    name VARCHAR(100) DEFAULT 'Unknown',
    salary NUMERIC(10, 2) DEFAULT 30000.00
) SERVER tsurugidb;

/* SET DATASTYLE */
SET datestyle TO ISO, ymd;

/* PREPARE */
PREPARE add_tg_timedate_dt (int, date) AS INSERT INTO tg_timedate (id, dt) VALUES ($1, $2);
EXECUTE add_tg_timedate_dt (9999, '1/8/1999');  -- error
EXECUTE add_tg_timedate_dt (9999, '1/18/1999');  -- error
EXECUTE add_tg_timedate_dt (9999, '08-Jan-99');  -- error
EXECUTE add_tg_timedate_dt (9999, 'Jan-08-99');  -- error
EXECUTE add_tg_timedate_dt (9999, 'January 8, 99 BC');  -- error

/* limit r682 */
-- Error:SYNTAX_EXCEPTION
PREPARE limit_all AS SELECT * FROM employee_2 ORDER BY id, name limit all;
-- Error:TYPE_ANALYZE_EXCEPTION
PREPARE limit_x (int) AS SELECT * FROM employee_2 ORDER BY id, name limit $1;

/* set operators r687 */
-- Error:UNSUPPORTED_COMPILER_FEATURE_EXCEPTION
PREPARE exce_all AS SELECT * FROM employee_1 except all SELECT * FROM employee_2 ORDER BY id, name;
-- Error:UNSUPPORTED_COMPILER_FEATURE_EXCEPTION
PREPARE inte_all AS SELECT * FROM employee_1 intersect all SELECT * FROM employee_2 ORDER BY id, name;
-- EXECUTE see:r711

/* group by r707 */
-- Error:UNSUPPORTED_COMPILER_FEATURE_EXCEPTION
PREPARE group_num AS SELECT id, count(name), sum(salary) FROM employee_2 GROUP BY 1 ORDER BY id;

/* order by r708 */
-- Error:UNSUPPORTED_COMPILER_FEATURE_EXCEPTION
PREPARE order_num AS SELECT * FROM employee_2 ORDER BY 1, 2;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE tg_timedate;
DROP FOREIGN TABLE employee_1;
DROP FOREIGN TABLE employee_2;
DROP FOREIGN TABLE employee_i;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE tg_timedate', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE employee_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE employee_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE employee_i', 'tsurugidb');
