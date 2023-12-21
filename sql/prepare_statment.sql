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

/* clean up */
DROP FOREIGN TABLE trg_timedate;
DROP TABLE trg_timedate;
DROP FOREIGN TABLE trg_table;
DROP TABLE trg_table;
