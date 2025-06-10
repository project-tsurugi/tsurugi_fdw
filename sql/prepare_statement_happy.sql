/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE tg_table (
        id INTEGER NOT NULL PRIMARY KEY,
        num INTEGER, name VARCHAR(10)
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE tg_timedate (
        id INTEGER NOT NULL PRIMARY KEY,
        tms TIMESTAMP DEFAULT TIMESTAMP ''2023-03-03 23:59:35.123456'',
        dt DATE DEFAULT DATE ''2023-03-03'',
        tm TIME DEFAULT TIME ''23:59:35.123456789''
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE tg_timetz (
        id INTEGER NOT NULL PRIMARY KEY,
        tm TIME,
        tmtz TIME WITH TIME ZONE
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE tg_timestamptz (
        id INTEGER NOT NULL PRIMARY KEY,
        tms TIMESTAMP,
        tmstz TIMESTAMP WITH TIME ZONE
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
CREATE FOREIGN TABLE tg_table (
    id INTEGER NOT NULL,
    num INTEGER,
    name VARCHAR(10)
) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_timedate (
    id INTEGER NOT NULL,
    tms TIMESTAMP DEFAULT '2023-03-03 23:59:35.123456',
    dt DATE DEFAULT '2023-03-03',
    tm TIME DEFAULT '23:59:35.123456789'
) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_timetz (
    id INTEGER NOT NULL,
    tm TIME,
    tmtz TIME WITH TIME ZONE
) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_timestamptz (
    id INTEGER NOT NULL,
    tms TIMESTAMP,
    tmstz TIMESTAMP WITH TIME ZONE
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
PREPARE add_tg_table (int, int, varchar(80))    AS INSERT INTO tg_table (id, num, name) VALUES ($1, $2, $3);
PREPARE add_tg_table_num (int, int)             AS INSERT INTO tg_table (id, num, name) VALUES ($1, $2, 'zzz');
PREPARE add_tg_table_name (int, varchar(80))    AS INSERT INTO tg_table (id, num, name) VALUES ($1, 99, $2);
PREPARE chg_tg_table_name (int, varchar(80))    AS UPDATE tg_table SET name = $2 WHERE id = $1;
PREPARE chg_tg_table_num (int, int)             AS UPDATE tg_table SET num  = $2 WHERE id = $1;
PREPARE chg_tg_table_88_name (int, varchar(80)) AS UPDATE tg_table SET num  = 88, name = $2 WHERE id = $1;
PREPARE chg_tg_table_num_yyy (int, int)         AS UPDATE tg_table SET num  = $2, name = 'yyy' WHERE id = $1;
PREPARE all_chg_tg_table_name (varchar(80))     AS UPDATE tg_table SET name = $1;
PREPARE all_chg_tg_table_num (int)              AS UPDATE tg_table SET num = $1;
PREPARE del_tg_table_num  (int)                 AS DELETE FROM tg_table WHERE num = $1;
PREPARE del_tg_table_name (varchar(80))         AS DELETE FROM tg_table WHERE name = $1;
PREPARE all_select_table                         AS SELECT * FROM tg_table order by id;
PREPARE all_select_table_num (int)               AS SELECT * FROM tg_table WHERE num > $1 order by id;
PREPARE all_select_table_num2 (int, int)         AS SELECT * FROM tg_table WHERE num > $1 AND num < $2 order by id;
PREPARE all_select_table_name (varchar(80))      AS SELECT * FROM tg_table WHERE name = $1 order by id;

select * from tg_table order by id;

EXECUTE add_tg_table (1, 11, 'aaa');
select * from tg_table order by id;
EXECUTE add_tg_table (2, 22, 'bbb');
select * from tg_table order by id;
EXECUTE add_tg_table (3, 33, 'ccc');
select * from tg_table order by id;
EXECUTE add_tg_table (4, 44, 'ddd');
select * from tg_table order by id;
EXECUTE add_tg_table_num (5, 55);
select * from tg_table order by id;
EXECUTE add_tg_table_name (6, 'fff');

select * from tg_table order by id;
EXECUTE all_select_table;
select * from tg_table where num > 30 order by id;
EXECUTE all_select_table_num(30);
select * from tg_table where num > 20 and num < 50 order by id;
EXECUTE all_select_table_num2(20, 50);
select * from tg_table where name = 'fff' order by id;
EXECUTE all_select_table_name('fff');

EXECUTE chg_tg_table_name (1, 'xyz');
select * from tg_table order by id;
EXECUTE chg_tg_table_num (2, 789);
select * from tg_table order by id;
EXECUTE chg_tg_table_88_name (3, 'xyz');
select * from tg_table order by id;
EXECUTE chg_tg_table_88_name (4, 'xyz');
select * from tg_table order by id;

EXECUTE del_tg_table_num  (789);
select * from tg_table order by id;
EXECUTE del_tg_table_name ('xyz');
select * from tg_table order by id;

EXECUTE all_chg_tg_table_name ('abc');
select * from tg_table order by id;
EXECUTE all_chg_tg_table_num (123);
select * from tg_table order by id;

PREPARE add_tg_timedate_def (int) AS INSERT INTO tg_timedate (id) VALUES ($1);
EXECUTE add_tg_timedate_def (1);
select * from tg_timedate order by id;

PREPARE add_tg_timedate_tms (int, timestamp) AS INSERT INTO tg_timedate (id, tms) VALUES ($1, $2);
EXECUTE add_tg_timedate_tms (10, '1999-01-08 04:05:06');
EXECUTE add_tg_timedate_tms (11, '1999-01-08 04:05:06 -8:00');
EXECUTE add_tg_timedate_tms (12, TIMESTAMP '2004-10-19 10:23:54');
EXECUTE add_tg_timedate_tms (13, TIMESTAMP '2004-10-19 10:23:54+02');
EXECUTE add_tg_timedate_tms (14, 'epoch');
EXECUTE add_tg_timedate_tms (15, 'infinity');
-- Can't test with regression EXECUTE add_tg_timedate_tms (9999, 'now');
-- Can't test with regression EXECUTE add_tg_timedate_tms (9999, 'tomorrow');
-- Can't test with regression EXECUTE add_tg_timedate_tms (9999, 'yesterday');
EXECUTE add_tg_timedate_tms (16, '2004-10-19 allballs');
select * from tg_timedate order by id;

PREPARE add_tg_timedate_dt (int, date) AS INSERT INTO tg_timedate (id, dt) VALUES ($1, $2);
EXECUTE add_tg_timedate_dt (20, '1999-01-08');
EXECUTE add_tg_timedate_dt (21, 'January 8, 1999');
EXECUTE add_tg_timedate_dt (22, '01/02/03');
EXECUTE add_tg_timedate_dt (23, '1999-Jan-08');
EXECUTE add_tg_timedate_dt (24, 'Jan-08-1999');
EXECUTE add_tg_timedate_dt (25, '08-Jan-1999');
EXECUTE add_tg_timedate_dt (26, '99-Jan-08');
EXECUTE add_tg_timedate_dt (27, '19990108');
EXECUTE add_tg_timedate_dt (28, '990108');
EXECUTE add_tg_timedate_dt (29, '1999.008');
EXECUTE add_tg_timedate_dt (30, 'J2451187');
select * from tg_timedate order by id;

PREPARE add_tg_timedate_tm (int, time) AS INSERT INTO tg_timedate (id, tm) VALUES ($1, $2);
EXECUTE add_tg_timedate_tm (50, '04:05:06.789');
EXECUTE add_tg_timedate_tm (51, '04:05:06');
EXECUTE add_tg_timedate_tm (52, '04:05');
EXECUTE add_tg_timedate_tm (53, '040506');
EXECUTE add_tg_timedate_tm (54, '04:05 AM');
EXECUTE add_tg_timedate_tm (55, '04:05 PM');
EXECUTE add_tg_timedate_tm (56, '04:05:06.789-8');
EXECUTE add_tg_timedate_tm (57, '04:05:06-08:00');
EXECUTE add_tg_timedate_tm (58, '04:05-08:00');
EXECUTE add_tg_timedate_tm (59, '040506-08');
EXECUTE add_tg_timedate_tm (60, '04:05:06 PST');
EXECUTE add_tg_timedate_tm (61, '2003-04-12 04:05:06 America/New_York');
select * from tg_timedate order by id;

PREPARE tg_timedate_where_tms (timestamp) AS DELETE FROM tg_timedate WHERE tms = $1;
PREPARE tg_timedate_where_dt (date)       AS DELETE FROM tg_timedate WHERE dt = $1;
PREPARE tg_timedate_where_tm (time)       AS DELETE FROM tg_timedate WHERE tm = $1;

EXECUTE tg_timedate_where_tms ('1999-01-08 04:05:06');
EXECUTE tg_timedate_where_tms (TIMESTAMP '2004-10-19 10:23:54');
EXECUTE tg_timedate_where_tms ('epoch');
EXECUTE tg_timedate_where_tms ('infinity');
EXECUTE tg_timedate_where_tms ('2004-10-19 allballs');
select * from tg_timedate order by id;

EXECUTE tg_timedate_where_dt ('1999-01-08');
EXECUTE tg_timedate_where_dt ('01/02/03');
select * from tg_timedate order by id;

EXECUTE tg_timedate_where_tm ('04:05:06.789');
EXECUTE tg_timedate_where_tm ('040506');
EXECUTE tg_timedate_where_tm ('04:05');
EXECUTE tg_timedate_where_tm ('04:05 PM');
select * from tg_timedate order by id;

-- Can't test with regression EXECUTE add_tg_timedate_tms (9901, clock_timestamp());
-- Can't test with regression EXECUTE add_tg_timedate_dt  (9902, current_date);
-- Can't test with regression EXECUTE add_tg_timedate_tm  (9903, current_time);
-- Can't test with regression EXECUTE add_tg_timedate_tms (9904, current_timestamp);
EXECUTE add_tg_timedate_tms (10, date_trunc('hour', timestamp '2001-02-16 20:38:40'));
EXECUTE add_tg_timedate_tms (11, date_trunc('day', timestamptz '2001-02-16 20:38:40+00', 'Australia/Sydney'));
-- Can't test with regression EXECUTE add_tg_timedate_tm  (9905, localtime);
-- Can't test with regression EXECUTE add_tg_timedate_tms (9906, localtimestamp);
EXECUTE add_tg_timedate_dt  (12, make_date(2013, 7, 15));
EXECUTE add_tg_timedate_tm  (13, make_time(8, 15, 23.5));
EXECUTE add_tg_timedate_tms (14, make_timestamp(2013, 7, 15, 8, 15, 23.5));
EXECUTE add_tg_timedate_tms (15, make_timestamptz(2013, 7, 15, 8, 15, 23.5));
-- Can't test with regression EXECUTE add_tg_timedate_tms (9907, now());
-- Can't test with regression EXECUTE add_tg_timedate_tms (9908, statement_timestamp());
-- Can't test with regression EXECUTE add_tg_timedate_tms (9909, transaction_timestamp());
EXECUTE add_tg_timedate_tms (16, to_timestamp(1284352323));
select * from tg_timedate order by id;

EXECUTE tg_timedate_where_tms (date_trunc('hour', timestamp '2001-02-16 20:38:40'));
EXECUTE tg_timedate_where_tms (date_trunc('day', timestamptz '2001-02-16 20:38:40+00', 'Australia/Sydney'));
EXECUTE tg_timedate_where_tms (make_timestamp(2013, 7, 15, 8, 15, 23.5));
EXECUTE tg_timedate_where_tms (to_timestamp(1284352323));
select * from tg_timedate order by id;

EXECUTE tg_timedate_where_dt (make_date(2013, 7, 15));
select * from tg_timedate order by id;

EXECUTE tg_timedate_where_tm (make_time(8, 15, 23.5));
select * from tg_timedate order by id;

PREPARE add_tg_timetz (int, TIME, TIMETZ)
    AS INSERT INTO tg_timetz (id, tm, tmtz) VALUES ($1, $2, $3);

EXECUTE add_tg_timetz  -- UTC-8
        (1, '00:01:23.456789', '00:01:23.456789 PST');
EXECUTE add_tg_timetz  -- UTC-8
        (2, '00:01:23.456789', '00:01:23.456789 -8:00');
EXECUTE add_tg_timetz  -- UTC-8
        (3, '00:01:23.456789', '00:01:23.456789 -800');
EXECUTE add_tg_timetz  -- UTC-8
        (4, '00:01:23.456789', '00:01:23.456789 -8');
EXECUTE add_tg_timetz  -- UTC
        (5, '00:01:23.456789', '00:01:23.456789 zulu');
EXECUTE add_tg_timetz  -- UTC
        (6, '00:01:23.456789', '00:01:23.456789 z');

PREPARE add_tg_timestamptz (int, TIMESTAMP, TIMESTAMPTZ)
    AS INSERT INTO tg_timestamptz (id, tms, tmstz) VALUES ($1, $2, $3);

EXECUTE add_tg_timestamptz  -- UTC-8
        (1, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 PST');
EXECUTE add_tg_timestamptz  -- UTC-4(Daylight Saving Time)
        (2, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 America/New_York');
EXECUTE add_tg_timestamptz  -- UTC-5
        (3, '2023-03-02 00:01:23.456789', '2023-03-02 00:01:23.456789 America/New_York');
EXECUTE add_tg_timestamptz  -- UTC-7(Daylight Saving Time)
        (4, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 PST8PDT');
EXECUTE add_tg_timestamptz  -- UTC-8
        (5, '2023-03-02 00:01:23.456789', '2023-03-02 00:01:23.456789 PST8PDT');
EXECUTE add_tg_timestamptz  -- UTC-8
        (6, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -8:00');
EXECUTE add_tg_timestamptz  -- UTC-8
        (7, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -800');
EXECUTE add_tg_timestamptz  -- UTC-8
        (8, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -8');
EXECUTE add_tg_timestamptz  -- UTC
        (9, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 zulu');
EXECUTE add_tg_timestamptz  -- UTC
        (10, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 z');

/* tsurugi-issues#790 : Tsurugi's time zone is always considered as system time zone */
/* tsurugi-issues#683(issuecomment-2303321622)
select * from tg_timetz; */

/* check timestamp with time zone in UTC */
set session timezone to 'UTC';
select * from tg_timestamptz order by id;

/* check timestamp with time zone in Asia/Tokyo */
set session timezone to 'Asia/Tokyo';
select * from tg_timestamptz order by id;

/************************/
/* bug fix confirm r685 */
/************************/
INSERT INTO employee_1 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (11, 'kf', 50000), (12, 'yy', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (11, 'kf', 50000), (12, 'yy', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
select * from employee_1 order by id, name;

INSERT INTO employee_2 DEFAULT VALUES;
INSERT INTO employee_2 DEFAULT VALUES;
INSERT INTO employee_2 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
INSERT INTO employee_2 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
INSERT INTO employee_2 (id, name, salary) VALUES (3, 'Charile', 47000);
INSERT INTO employee_2 (id, name, salary) VALUES (6, 'Frank', 52000);
INSERT INTO employee_2 (id, name, salary) VALUES (7, 'Grace', 53000);
INSERT INTO employee_2 DEFAULT VALUES;
INSERT INTO employee_2 DEFAULT VALUES;
INSERT INTO employee_2 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
INSERT INTO employee_2 (id, name, salary) VALUES (3, 'Charile', 47000);
INSERT INTO employee_2 (id, name, salary) VALUES (4, 'David', 48000);
INSERT INTO employee_2 (id, name, salary) VALUES (5, 'Eva', 50000);
INSERT INTO employee_2 (id, name, salary) VALUES (6, 'Frank', 52000);
select * from employee_2 order by id, name;

/* limit r682 */
PREPARE limit_5 AS select * from employee_2 order by id, name limit 5;
EXECUTE limit_5;

/* set quantifier r686 */
PREPARE quantifier_distinct AS select distinct * from employee_2 order by id, name;
EXECUTE quantifier_distinct;
PREPARE quantifier_all AS select all * from employee_2 order by id, name;
EXECUTE quantifier_all;

/* set operators r687 */
PREPARE uni AS select * from employee_1 union select * from employee_2 order by id, name;
PREPARE uni_all AS select * from employee_1 union all select * from employee_2 order by id, name;
PREPARE exce AS select * from employee_1 except select * from employee_2 order by id, name;
PREPARE inte AS select * from employee_1 intersect select * from employee_2 order by id, name;

/* set operators r688 */
select * from employee_i order by id, name;
PREPARE ins_def AS insert into employee_i default values;
execute ins_def;
select * from employee_i order by id, name;
select * from employee_1 where id < 10 order by id, name;
PREPARE ins_query AS insert into employee_i select * from employee_1 where id < 10 order by id, name;
execute ins_query;
select * from employee_i order by id, name;

PREPARE pre_emp2 AS select id, name, salary from employee_2 order by id;
EXECUTE pre_emp2;

/* group by r707 */
PREPARE group_name AS select id, count(name), sum(salary) from employee_2 group by id order by id;
EXECUTE group_name;

/* order by r708 */
PREPARE order_name AS select * from employee_2 order by id, name;
EXECUTE order_name;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE tg_table;
DROP FOREIGN TABLE tg_timedate;
DROP FOREIGN TABLE tg_timetz;
DROP FOREIGN TABLE tg_timestamptz;
DROP FOREIGN TABLE employee_1;
DROP FOREIGN TABLE employee_2;
DROP FOREIGN TABLE employee_i;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE tg_table', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE tg_timedate', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE tg_timetz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE tg_timestamptz', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE employee_1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE employee_2', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE employee_i', 'tsurugidb');
