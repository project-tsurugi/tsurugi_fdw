/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE insert_select_happy (
        col0  integer                 constraint nn0 not null PRIMARY KEY,
        col1  int                     constraint nn1 not null,
        col2  int                     constraint nn2 not null,
        col3  bigint                  constraint nn3 not null,
        col4  bigint                  constraint nn4 not null,
        col5  real                    constraint nn5 not null,
        col6  float                   constraint nn6 not null,
        col7  double precision        constraint nn7 not null,
        col8  double precision        constraint nn8 not null,
        col9  char                    constraint nn9 not null,
        col10 char(1)                 constraint nn10 not null,
        col11 character               constraint nn11 not null,
        col12 character(10)           constraint nn12 not null,
        col13 character(1000)         constraint nn13 not null,
        col14 varchar(1000)           constraint nn14 not null,
        col15 varchar(1000)           constraint nn15 not null,
        col16 character varying(1000) constraint nn16 not null
    )'
);
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE integer1 (
        ol_w_id int PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE bigint1 (
        id int PRIMARY KEY,
        ol_w_id bigint
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE real1 (
        ol_w_id real PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE double1 (
        ol_w_id double precision PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE char_length_1 (
        ol_w_id char(1) PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE varchar_length_1 (
        ol_w_id varchar(1) PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE char_length_10 (
        ol_w_id char(10) PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE varchar_length_10 (
        ol_w_id varchar(10) PRIMARY KEY
    )
');
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE tg_temporal_literal (
        id        INTEGER NOT NULL PRIMARY KEY,
        dt        DATE,
        tm        TIME,
        tms       TIMESTAMP,
        tms_wo_tz TIMESTAMP WITHOUT TIME ZONE,
        tms_w_tz  TIMESTAMP WITH TIME ZONE
    )'
);

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE insert_select_happy (
    col0  integer                 constraint nn0 not null,
    col1  int                     constraint nn1 not null,
    col2  int4                    constraint nn2 not null,
    col3  bigint                  constraint nn3 not null,
    col4  int8                    constraint nn4 not null,
    col5  real                    constraint nn5 not null,
    col6  float4                  constraint nn6 not null,
    col7  double precision        constraint nn7 not null,
    col8  float8                  constraint nn8 not null,
    col9  char                    constraint nn9 not null,
    col10 char(1)                 constraint nn10 not null,
    col11 character               constraint nn11 not null,
    col12 character(10)           constraint nn12 not null,
    col13 character(1000)         constraint nn13 not null,
    col14 varchar(1000)           constraint nn14 not null,
    col15 varchar(1000)           constraint nn15 not null,
    col16 character varying(1000) constraint nn16 not null
) SERVER tsurugidb;
CREATE FOREIGN TABLE integer1 (
    ol_w_id int
) SERVER tsurugidb;
CREATE FOREIGN TABLE bigint1 (
    id int,
    ol_w_id bigint
) SERVER tsurugidb;
CREATE FOREIGN TABLE real1 (
    ol_w_id real
) SERVER tsurugidb;
CREATE FOREIGN TABLE double1 (
    ol_w_id double precision
) SERVER tsurugidb;
CREATE FOREIGN TABLE char_length_1 (
    ol_w_id char(1)
) SERVER tsurugidb;
CREATE FOREIGN TABLE varchar_length_1 (
    ol_w_id varchar(1)
) SERVER tsurugidb;
CREATE FOREIGN TABLE char_length_10 (
    ol_w_id char(10)
) SERVER tsurugidb;
CREATE FOREIGN TABLE varchar_length_10 (
    ol_w_id varchar(10)
) SERVER tsurugidb;
-- temporal_literal : tsurugi-issues#881
CREATE FOREIGN TABLE tg_temporal_literal (
    id        INTEGER NOT NULL,
    dt        DATE,
    tm        TIME,
    tms       TIMESTAMP,
    tms_wo_tz TIMESTAMP WITHOUT TIME ZONE,
    tms_w_tz  TIMESTAMP WITH TIME ZONE
) SERVER tsurugidb;

/* DML */
SELECT * FROM insert_select_happy ORDER BY col0;
--ok
INSERT INTO insert_select_happy (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (-2147483648, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789', 'b','KLMNOPQRST','ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKL');
SELECT * FROM insert_select_happy ORDER BY col0;
---INSERT column of char(1000) INTO 1 characters
INSERT INTO insert_select_happy (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (1, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','a', 'b','a','a');
SELECT * FROM insert_select_happy ORDER BY col0;
---INSERT column of char(1000) INTO 10 characters
INSERT INTO insert_select_happy (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (2, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','abcdefghij', 'b','a','a');
SELECT * FROM insert_select_happy ORDER BY col0;

--- int
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (2147483644); --max-3
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (2147483645); --max-2
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (2147483646); --max-1
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (2147483647); --max

INSERT INTO integer1 (ol_w_id) VALUES (-2147483645); --min+3
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (-2147483646); --min+2
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (-2147483647); --min+1
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (-2147483648); --min
SELECT * FROM integer1 ORDER BY ol_w_id;

INSERT INTO integer1 (ol_w_id) VALUES (9), (8), (7);  -- see tsurugi-issues#770

--- bigint
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (1, 9223372036854775804);  --max-3
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (2, 9223372036854775805);  --max-2
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (3, 9223372036854775806);  --max-1
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (4, 9223372036854775807);  --max
SELECT * FROM bigint1 ORDER BY id;

INSERT INTO bigint1 (id, ol_w_id) VALUES (8, -9223372036854775805);  --min+3
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (9, -9223372036854775806);  --min+2
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (10, -9223372036854775807);  --min+1
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (11, -9223372036854775807-1); --min
SELECT * FROM bigint1 ORDER BY id;

--- real
SELECT * FROM real1 ORDER BY ol_w_id;
INSERT INTO real1 (ol_w_id) VALUES (12.345678901234567890); --20 digits
SELECT * FROM real1 ORDER BY ol_w_id;
INSERT INTO real1 (ol_w_id) VALUES (0.1);
SELECT * FROM real1 ORDER BY ol_w_id;
INSERT INTO real1 (ol_w_id) VALUES (1.1);
SELECT * FROM real1 ORDER BY ol_w_id;

--- double precision
SELECT * FROM double1 ORDER BY ol_w_id;
INSERT INTO double1 (ol_w_id) VALUES (12.345678901234567890); --20 digits
SELECT * FROM double1 ORDER BY ol_w_id;
INSERT INTO double1 (ol_w_id) VALUES (0.1);
SELECT * FROM double1 ORDER BY ol_w_id;
INSERT INTO double1 (ol_w_id) VALUES (1.1);
SELECT * FROM double1 ORDER BY ol_w_id;

--- char(1)
SELECT * FROM char_length_1 ORDER BY ol_w_id;
INSERT INTO char_length_1 (ol_w_id) VALUES ('P');
SELECT * FROM char_length_1 ORDER BY ol_w_id;

--- varchar(1)
SELECT * FROM varchar_length_1 ORDER BY ol_w_id;
INSERT INTO varchar_length_1 (ol_w_id) VALUES ('P');
SELECT * FROM varchar_length_1 ORDER BY ol_w_id;

--- char(10)
SELECT * FROM char_length_10 ORDER BY ol_w_id;
INSERT INTO char_length_10 (ol_w_id) VALUES ('PostgreSQL');
SELECT * FROM char_length_10 ORDER BY ol_w_id;

--- varchar(10)
SELECT * FROM varchar_length_10 ORDER BY ol_w_id;
INSERT INTO varchar_length_10 (ol_w_id) VALUES ('PostgreSQL');
SELECT * FROM varchar_length_10 ORDER BY ol_w_id;

--- temporal_literal : tsurugi-issues#881
/* SET DATASTYLE */
SET datestyle TO ISO, ymd;

SELECT * FROM tg_temporal_literal ORDER BY id;
INSERT INTO tg_temporal_literal (id, dt) VALUES (1, DATE '2024-08-30');
INSERT INTO tg_temporal_literal (id, tm) VALUES (2, TIME '04:05:06.789');
INSERT INTO tg_temporal_literal (id, tms) VALUES (3, TIMESTAMP '2024-08-30 04:05:06.789');
INSERT INTO tg_temporal_literal (id, tms_wo_tz) VALUES (4, TIMESTAMP WITHOUT TIME ZONE '2024-08-30 04:05:06.789');
INSERT INTO tg_temporal_literal (id, tms_w_tz) VALUES (5, TIMESTAMP WITH TIME ZONE '2024-08-30 04:05:06.789+9:00');

/* check timestamp with time zone in UTC */
set session timezone to 'UTC';
SELECT * FROM tg_temporal_literal ORDER BY id;
/* check timestamp with time zone in Asia/Tokyo */
set session timezone to 'Asia/Tokyo';
SELECT * FROM tg_temporal_literal ORDER BY id;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE insert_select_happy;
DROP FOREIGN TABLE integer1;
DROP FOREIGN TABLE bigint1;
DROP FOREIGN TABLE real1;
DROP FOREIGN TABLE double1;
DROP FOREIGN TABLE char_length_1;
DROP FOREIGN TABLE varchar_length_1;
DROP FOREIGN TABLE char_length_10;
DROP FOREIGN TABLE varchar_length_10;
DROP FOREIGN TABLE tg_temporal_literal;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE insert_select_happy');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE integer1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE bigint1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE real1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE double1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE char_length_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE varchar_length_1');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE char_length_10');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE varchar_length_10');
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE tg_temporal_literal');
