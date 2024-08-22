/* SET DATASTYLE */
SET datestyle TO ISO, ymd;

/* preparation */
-- table preparation
CREATE TABLE trg_table (id INTEGER NOT NULL PRIMARY KEY, num INTEGER, name VARCHAR(10)) TABLESPACE tsurugi;
CREATE FOREIGN TABLE trg_table (id INTEGER NOT NULL, num INTEGER, name VARCHAR(10)) SERVER tsurugidb;
CREATE TABLE trg_timedate (
    id      INTEGER NOT NULL PRIMARY KEY,
    tms     TIMESTAMP  default '2023-03-03 23:59:35.123456',
    dt      DATE       default '2023-03-03',
    tm      TIME       default '23:59:35.123456789'
) TABLESPACE tsurugi;

CREATE FOREIGN TABLE trg_timedate (
    id      INTEGER NOT NULL,
    tms     TIMESTAMP  default '2023-03-03 23:59:35.123456',
    dt      DATE       default '2023-03-03',
    tm      TIME       default '23:59:35.123456789'
) SERVER tsurugidb;

CREATE TABLE pg_timetz_reference (
    id      INTEGER NOT NULL PRIMARY KEY,
    tm      TIME,
    tmtz    TIME WITH TIME ZONE
);

CREATE TABLE pg_timestamptz_reference (
    id      INTEGER NOT NULL PRIMARY KEY,
    tms     TIMESTAMP,
    tmstz   TIMESTAMP WITH TIME ZONE
);

CREATE TABLE trg_timetz (
    id      INTEGER NOT NULL PRIMARY KEY,
    tm      TIME,
    tmtz    TIME WITH TIME ZONE
) TABLESPACE tsurugi;

CREATE FOREIGN TABLE trg_timetz (
    id      INTEGER NOT NULL,
    tm      TIME,
    tmtz    TIME WITH TIME ZONE
) SERVER tsurugidb;

CREATE TABLE trg_timestamptz (
    id      INTEGER NOT NULL PRIMARY KEY,
    tms     TIMESTAMP,
    tmstz   TIMESTAMP WITH TIME ZONE
) TABLESPACE tsurugi;

CREATE FOREIGN TABLE trg_timestamptz (
    id      INTEGER NOT NULL,
    tms     TIMESTAMP,
    tmstz   TIMESTAMP WITH TIME ZONE
) SERVER tsurugidb;

PREPARE add_trg_table (int, int, varchar(80)) 		AS INSERT INTO trg_table (id, num, name) VALUES ($1, $2, $3);
PREPARE add_trg_table_num (int, int) 				AS INSERT INTO trg_table (id, num, name) VALUES ($1, $2, 'zzz');
PREPARE add_trg_table_name (int, varchar(80))		AS INSERT INTO trg_table (id, num, name) VALUES ($1, 99, $2);
PREPARE chg_trg_table_name (int, varchar(80)) 		AS UPDATE trg_table SET name = $2 WHERE id = $1;
PREPARE chg_trg_table_num (int, int)         		AS UPDATE trg_table SET num  = $2 WHERE id = $1;
PREPARE chg_trg_table_88_name (int, varchar(80))	AS UPDATE trg_table SET num  = 88, name = $2 WHERE id = $1;
PREPARE chg_trg_table_num_yyy (int, int)    		AS UPDATE trg_table SET num  = $2, name = 'yyy' WHERE id = $1;
PREPARE all_chg_trg_table_name (varchar(80))      	AS UPDATE trg_table SET name = $1;
PREPARE all_chg_trg_table_num (int)      			AS UPDATE trg_table SET num = $1;
PREPARE del_trg_table_num  (int)              		AS DELETE FROM trg_table WHERE num = $1;
PREPARE del_trg_table_name (varchar(80))      		AS DELETE FROM trg_table WHERE name = $1;
PREPARE all_select_table							AS SELECT * FROM trg_table;
PREPARE all_select_table_num (int)					AS SELECT * FROM trg_table WHERE num > $1;
PREPARE all_select_table_num2 (int, int)			AS SELECT * FROM trg_table WHERE num > $1 AND num < $2;
PREPARE all_select_table_name (varchar(80))			AS SELECT * FROM trg_table WHERE name = $1;

select * from trg_table;

EXECUTE add_trg_table (1, 11, 'aaa');
select * from trg_table;
EXECUTE add_trg_table (2, 22, 'bbb');
select * from trg_table;
EXECUTE add_trg_table (3, 33, 'ccc');
select * from trg_table;
EXECUTE add_trg_table (4, 44, 'ddd');
select * from trg_table;
EXECUTE add_trg_table_num (5, 55);
select * from trg_table;
EXECUTE add_trg_table_name (6, 'fff');

select * from trg_table;
EXECUTE all_select_table;
select * from trg_table where num > 30;
EXECUTE all_select_table_num(30);
select * from trg_table where num > 20 and num < 50;
EXECUTE all_select_table_num2(20, 50);
select * from trg_table where name = 'fff';
EXECUTE all_select_table_name('fff');

EXECUTE chg_trg_table_name (1, 'xyz');
select * from trg_table;
EXECUTE chg_trg_table_num (2, 789);
select * from trg_table;
EXECUTE chg_trg_table_88_name (3, 'xyz');
select * from trg_table;
EXECUTE chg_trg_table_88_name (4, 'xyz');
select * from trg_table;

EXECUTE del_trg_table_num  (789);
select * from trg_table;
EXECUTE del_trg_table_name ('xyz');
select * from trg_table;

EXECUTE all_chg_trg_table_name ('abc');
select * from trg_table;
EXECUTE all_chg_trg_table_num (123);
select * from trg_table;

PREPARE add_trg_timedate_def (int)						AS INSERT INTO trg_timedate (id) VALUES ($1);
EXECUTE add_trg_timedate_def (1);
select * from trg_timedate;

PREPARE add_trg_timedate_tms (int, timestamp)			AS INSERT INTO trg_timedate (id, tms) VALUES ($1, $2);
EXECUTE add_trg_timedate_tms (10, '1999-01-08 04:05:06');
EXECUTE add_trg_timedate_tms (11, '1999-01-08 04:05:06 -8:00');
EXECUTE add_trg_timedate_tms (12, TIMESTAMP '2004-10-19 10:23:54');
EXECUTE add_trg_timedate_tms (13, TIMESTAMP '2004-10-19 10:23:54+02');
EXECUTE add_trg_timedate_tms (14, 'epoch');
EXECUTE add_trg_timedate_tms (15, 'infinity');
-- Can't test with regression EXECUTE add_trg_timedate_tms (9999, 'now');
-- Can't test with regression EXECUTE add_trg_timedate_tms (9999, 'tomorrow');
-- Can't test with regression EXECUTE add_trg_timedate_tms (9999, 'yesterday');
EXECUTE add_trg_timedate_tms (16, '2004-10-19 allballs');
select * from trg_timedate;

PREPARE add_trg_timedate_dt (int, date)					AS INSERT INTO trg_timedate (id, dt) VALUES ($1, $2);
EXECUTE add_trg_timedate_dt (20, '1999-01-08');
EXECUTE add_trg_timedate_dt (21, 'January 8, 1999');
EXECUTE add_trg_timedate_dt (9999, '1/8/1999');  -- error
EXECUTE add_trg_timedate_dt (9999, '1/18/1999');  -- error
EXECUTE add_trg_timedate_dt (22, '01/02/03');
EXECUTE add_trg_timedate_dt (23, '1999-Jan-08');
EXECUTE add_trg_timedate_dt (24, 'Jan-08-1999');
EXECUTE add_trg_timedate_dt (25, '08-Jan-1999');
EXECUTE add_trg_timedate_dt (26, '99-Jan-08');
EXECUTE add_trg_timedate_dt (9999, '08-Jan-99');  -- error
EXECUTE add_trg_timedate_dt (9999, 'Jan-08-99');  -- error
EXECUTE add_trg_timedate_dt (27, '19990108');
EXECUTE add_trg_timedate_dt (28, '990108');
EXECUTE add_trg_timedate_dt (29, '1999.008');
EXECUTE add_trg_timedate_dt (30, 'J2451187');
EXECUTE add_trg_timedate_dt (9999, 'January 8, 99 BC');  -- error
select * from trg_timedate;

PREPARE add_trg_timedate_tm (int, time)					AS INSERT INTO trg_timedate (id, tm) VALUES ($1, $2);
EXECUTE add_trg_timedate_tm (50, '04:05:06.789');
EXECUTE add_trg_timedate_tm (51, '04:05:06');
EXECUTE add_trg_timedate_tm (52, '04:05');
EXECUTE add_trg_timedate_tm (53, '040506');
EXECUTE add_trg_timedate_tm (54, '04:05 AM');
EXECUTE add_trg_timedate_tm (55, '04:05 PM');
EXECUTE add_trg_timedate_tm (56, '04:05:06.789-8');
EXECUTE add_trg_timedate_tm (57, '04:05:06-08:00');
EXECUTE add_trg_timedate_tm (58, '04:05-08:00');
EXECUTE add_trg_timedate_tm (59, '040506-08');
EXECUTE add_trg_timedate_tm (60, '04:05:06 PST');
EXECUTE add_trg_timedate_tm (61, '2003-04-12 04:05:06 America/New_York');
select * from trg_timedate;

PREPARE trg_timedate_where_tms (timestamp)				AS DELETE FROM trg_timedate WHERE tms = $1;
PREPARE trg_timedate_where_dt (date)					AS DELETE FROM trg_timedate WHERE dt = $1;
PREPARE trg_timedate_where_tm (time)					AS DELETE FROM trg_timedate WHERE tm = $1;

EXECUTE trg_timedate_where_tms ('1999-01-08 04:05:06');
EXECUTE trg_timedate_where_tms (TIMESTAMP '2004-10-19 10:23:54');
EXECUTE trg_timedate_where_tms ('epoch');
EXECUTE trg_timedate_where_tms ('infinity');
EXECUTE trg_timedate_where_tms ('2004-10-19 allballs');
select * from trg_timedate;

EXECUTE trg_timedate_where_dt ('1999-01-08');
EXECUTE trg_timedate_where_dt ('01/02/03');
select * from trg_timedate;

EXECUTE trg_timedate_where_tm ('04:05:06.789');
EXECUTE trg_timedate_where_tm ('040506');
EXECUTE trg_timedate_where_tm ('04:05');
EXECUTE trg_timedate_where_tm ('04:05 PM');
select * from trg_timedate;

-- Can't test with regression EXECUTE add_trg_timedate_tms (9901, clock_timestamp());
-- Can't test with regression EXECUTE add_trg_timedate_dt  (9902, current_date);
-- Can't test with regression EXECUTE add_trg_timedate_tm  (9903, current_time);
-- Can't test with regression EXECUTE add_trg_timedate_tms (9904, current_timestamp);
EXECUTE add_trg_timedate_tms (10, date_trunc('hour', timestamp '2001-02-16 20:38:40'));
EXECUTE add_trg_timedate_tms (11, date_trunc('day', timestamptz '2001-02-16 20:38:40+00', 'Australia/Sydney'));
-- Can't test with regression EXECUTE add_trg_timedate_tm  (9905, localtime);
-- Can't test with regression EXECUTE add_trg_timedate_tms (9906, localtimestamp);
EXECUTE add_trg_timedate_dt  (12, make_date(2013, 7, 15));
EXECUTE add_trg_timedate_tm  (13, make_time(8, 15, 23.5));
EXECUTE add_trg_timedate_tms (14, make_timestamp(2013, 7, 15, 8, 15, 23.5));
EXECUTE add_trg_timedate_tms (15, make_timestamptz(2013, 7, 15, 8, 15, 23.5));
-- Can't test with regression EXECUTE add_trg_timedate_tms (9907, now());
-- Can't test with regression EXECUTE add_trg_timedate_tms (9908, statement_timestamp());
-- Can't test with regression EXECUTE add_trg_timedate_tms (9909, transaction_timestamp());
EXECUTE add_trg_timedate_tms (16, to_timestamp(1284352323));
select * from trg_timedate;

EXECUTE trg_timedate_where_tms (date_trunc('hour', timestamp '2001-02-16 20:38:40'));
EXECUTE trg_timedate_where_tms (date_trunc('day', timestamptz '2001-02-16 20:38:40+00', 'Australia/Sydney'));
EXECUTE trg_timedate_where_tms (make_timestamp(2013, 7, 15, 8, 15, 23.5));
EXECUTE trg_timedate_where_tms (to_timestamp(1284352323));
select * from trg_timedate;

EXECUTE trg_timedate_where_dt (make_date(2013, 7, 15));
select * from trg_timedate;

EXECUTE trg_timedate_where_tm (make_time(8, 15, 23.5));
select * from trg_timedate;

/* PostgreSQL Time Zone Reference */

INSERT INTO pg_timetz_reference (id, tm, tmtz) VALUES  -- UTC-8
        (1, '00:01:23.456789', '00:01:23.456789 PST');
INSERT INTO pg_timetz_reference (id, tm, tmtz) VALUES  -- UTC-8
        (2, '00:01:23.456789', '00:01:23.456789 -8:00');
INSERT INTO pg_timetz_reference (id, tm, tmtz) VALUES  -- UTC-8
        (3, '00:01:23.456789', '00:01:23.456789 -800');
INSERT INTO pg_timetz_reference (id, tm, tmtz) VALUES  -- UTC-8
        (4, '00:01:23.456789', '00:01:23.456789 -8');
INSERT INTO pg_timetz_reference (id, tm, tmtz) VALUES  -- UTC
        (5, '00:01:23.456789', '00:01:23.456789 zulu');
INSERT INTO pg_timetz_reference (id, tm, tmtz) VALUES  -- UTC
        (6, '00:01:23.456789', '00:01:23.456789 z');

INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-8
        (1, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 PST');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-4(Daylight Saving Time)
        (2, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 America/New_York');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-5
        (3, '2023-03-02 00:01:23.456789', '2023-03-02 00:01:23.456789 America/New_York');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-7(Daylight Saving Time)
        (4, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 PST8PDT');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-8
        (5, '2023-03-02 00:01:23.456789', '2023-03-02 00:01:23.456789 PST8PDT');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-8
        (6, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -8:00');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-8
        (7, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -800');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC-8
        (8, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -8');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC
        (9, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 zulu');
INSERT INTO pg_timestamptz_reference (id, tms, tmstz) VALUES  -- UTC
        (10, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 z');

PREPARE add_trg_timetz (int, TIME, TIMETZ)
                    AS INSERT INTO trg_timetz (id, tm, tmtz) VALUES ($1, $2, $3);

EXECUTE add_trg_timetz  -- UTC-8
        (1, '00:01:23.456789', '00:01:23.456789 PST');
EXECUTE add_trg_timetz  -- UTC-8
        (2, '00:01:23.456789', '00:01:23.456789 -8:00');
EXECUTE add_trg_timetz  -- UTC-8
        (3, '00:01:23.456789', '00:01:23.456789 -800');
EXECUTE add_trg_timetz  -- UTC-8
        (4, '00:01:23.456789', '00:01:23.456789 -8');
EXECUTE add_trg_timetz  -- UTC
        (5, '00:01:23.456789', '00:01:23.456789 zulu');
EXECUTE add_trg_timetz  -- UTC
        (6, '00:01:23.456789', '00:01:23.456789 z');

PREPARE add_trg_timestamptz (int, TIMESTAMP, TIMESTAMPTZ)
                    AS INSERT INTO trg_timestamptz (id, tms, tmstz) VALUES ($1, $2, $3);

EXECUTE add_trg_timestamptz  -- UTC-8
        (1, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 PST');
EXECUTE add_trg_timestamptz  -- UTC-4(Daylight Saving Time)
        (2, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 America/New_York');
EXECUTE add_trg_timestamptz  -- UTC-5
        (3, '2023-03-02 00:01:23.456789', '2023-03-02 00:01:23.456789 America/New_York');
EXECUTE add_trg_timestamptz  -- UTC-7(Daylight Saving Time)
        (4, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 PST8PDT');
EXECUTE add_trg_timestamptz  -- UTC-8
        (5, '2023-03-02 00:01:23.456789', '2023-03-02 00:01:23.456789 PST8PDT');
EXECUTE add_trg_timestamptz  -- UTC-8
        (6, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -8:00');
EXECUTE add_trg_timestamptz  -- UTC-8
        (7, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -800');
EXECUTE add_trg_timestamptz  -- UTC-8
        (8, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 -8');
EXECUTE add_trg_timestamptz  -- UTC
        (9, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 zulu');
EXECUTE add_trg_timestamptz  -- UTC
        (10, '2023-08-02 00:01:23.456789', '2023-08-02 00:01:23.456789 z');

/* check time with time zone */
select * from pg_timetz_reference;
/* tsurugi-issues#790 : Tsurugi's time zone is always considered as system time zone */
/* tsurugi-issues#683(issuecomment-2303321622)
select * from trg_timetz; */

/* check timestamp with time zone in UTC */
set session timezone to 'UTC';
select * from pg_timestamptz_reference;
select * from trg_timestamptz;

/* check timestamp with time zone in Asia/Tokyo */
set session timezone to 'Asia/Tokyo';
select * from pg_timestamptz_reference;
select * from trg_timestamptz;

/* clean up */
DROP FOREIGN TABLE trg_timetz;
DROP TABLE trg_timetz;
DROP FOREIGN TABLE trg_timestamptz;
DROP TABLE trg_timestamptz;
DROP TABLE pg_timetz_reference;
DROP TABLE pg_timestamptz_reference;
DROP FOREIGN TABLE trg_timedate;
DROP TABLE trg_timedate;
DROP FOREIGN TABLE trg_table;
DROP TABLE trg_table;
