
CREATE EXTENSION IF NOT EXISTS tsurugi_fdw;
CREATE SERVER IF NOT EXISTS tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;

\dx tsurugi_fdw

/* create_table.sql */
CREATE FOREIGN TABLE t1_create_table(c1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE t2_create_table(c1 INTEGER NOT NULL, c2 BIGINT, c3 DOUBLE PRECISION) SERVER tsurugidb;

/* create_index.sql */
CREATE FOREIGN TABLE t3_create_index(c1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE t4_create_index(c1 INTEGER NOT NULL, c2 BIGINT, c3 DOUBLE PRECISION) SERVER tsurugidb;

/* insert_select_happy.sql */
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

create foreign table integer1 (
  ol_w_id int
) SERVER tsurugidb;

create foreign table bigint1 (
  id int,
  ol_w_id bigint
) SERVER tsurugidb;

create foreign table real1 (
  ol_w_id real
) SERVER tsurugidb;

create foreign table double1 (
  ol_w_id double precision
) SERVER tsurugidb;

create foreign table char_length_1 (
  ol_w_id char(1)
) SERVER tsurugidb;

create foreign table varchar_length_1 (
  ol_w_id varchar(1)
) SERVER tsurugidb;

create foreign table char_length_10 (
  ol_w_id char(10)
) SERVER tsurugidb;

create foreign table varchar_length_10 (
  ol_w_id varchar(10)
) SERVER tsurugidb;

-- temporal_literal : tsurugi-issues#881
CREATE FOREIGN TABLE trg_temporal_literal (
    id          INTEGER NOT NULL,
    dt          DATE,
    tm          TIME,
    tms         TIMESTAMP,
    tms_wo_tz   TIMESTAMP WITHOUT TIME ZONE,
    tms_w_tz    TIMESTAMP WITH TIME ZONE
) SERVER tsurugidb;

/* update_delete.sql */
---int
CREATE FOREIGN TABLE update_delete_int1(col1 int, col2 int) SERVER tsurugidb;

---bigint
CREATE FOREIGN TABLE update_delete_bigint1(col1 int, col2 bigint) SERVER tsurugidb;

---real
CREATE FOREIGN TABLE update_delete_real1(col1 int, col2 real) SERVER tsurugidb;

---double precision
CREATE FOREIGN TABLE update_delete_double1(col1 int, col2 double precision) SERVER tsurugidb;

---char
CREATE FOREIGN TABLE update_delete_char1(col1 int, col2 char(2)) SERVER tsurugidb;

---varchar
CREATE FOREIGN TABLE update_delete_varchar1(col1 int, col2 varchar(2)) SERVER tsurugidb;

/* select_statement.sql */
CREATE FOREIGN TABLE t1_select_statement(
    c1 INTEGER,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE FOREIGN TABLE t2_select_statement(
    c1 INTEGER,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE FOREIGN TABLE t3_select_statement(
    c1 INTEGER,
    c2 CHAR(10)
) SERVER tsurugidb;

/* user_management.sql */
SET ROLE 'postgres';
CREATE FOREIGN TABLE t1_user_management (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE t2_user_management (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE t3_user_management (column1 INTEGER NOT NULL) SERVER tsurugidb;
RESET ROLE;

/* udf_transaction.sql */
CREATE FOREIGN TABLE udf_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE wp_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE wp_table2 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE ri_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE ri_table2 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE re_table1 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE re_table2 (column1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE tg_table (column1 INTEGER NOT NULL) SERVER tsurugidb;

/* prepare_statement.sql */
CREATE FOREIGN TABLE trg_table (id INTEGER NOT NULL, num INTEGER, name VARCHAR(10)) SERVER tsurugidb;

CREATE FOREIGN TABLE trg_timedate (
    id      INTEGER NOT NULL,
    tms     TIMESTAMP  default '2023-03-03 23:59:35.123456',
    dt      DATE       default '2023-03-03',
    tm      TIME       default '23:59:35.123456789'
) SERVER tsurugidb;

CREATE FOREIGN TABLE trg_timetz (
    id      INTEGER NOT NULL,
    tm      TIME,
    tmtz    TIME WITH TIME ZONE
) SERVER tsurugidb;

CREATE FOREIGN TABLE trg_timestamptz (
    id      INTEGER NOT NULL,
    tms     TIMESTAMP,
    tmstz   TIMESTAMP WITH TIME ZONE
) SERVER tsurugidb;

/* prepare_select_statement.sql */
CREATE FOREIGN TABLE t1_prepare_select_statement(
    c1 INTEGER,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE FOREIGN TABLE t2_prepare_select_statement(
    c1 INTEGER,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
) SERVER tsurugidb;

CREATE FOREIGN TABLE t3_prepare_select_statement(
    c1 INTEGER,
    c2 CHAR(10)
) SERVER tsurugidb;

/* prepare_decimal.sql */
CREATE FOREIGN TABLE trg_numeric (id INTEGER NOT NULL, num NUMERIC(10, 6)) SERVER tsurugidb;
CREATE FOREIGN TABLE trg_numeric_s0 (id INTEGER NOT NULL, num NUMERIC(38, 0)) SERVER tsurugidb;
CREATE FOREIGN TABLE trg_numeric_s38 (id INTEGER NOT NULL, num NUMERIC(38, 38)) SERVER tsurugidb;

/* manual_tutorial.sql*/
CREATE FOREIGN TABLE weather (
    id              int,
    city            varchar(80),
    temp_lo         int,           -- 最低気温
    temp_hi         int,           -- 最高気温
    prcp            real,          -- 降水量
    the_date        date default '2023-04-01'
) SERVER tsurugidb;

/* bug fix confirm */
CREATE FOREIGN TABLE employee_1 (id INTEGER DEFAULT 1, name VARCHAR(100) DEFAULT 'Unknown', salary NUMERIC(10, 2) DEFAULT 30000.00) SERVER tsurugidb;
CREATE FOREIGN TABLE employee_2 (id INTEGER DEFAULT 1, name VARCHAR(100) DEFAULT 'Unknown', salary NUMERIC(10, 2) DEFAULT 30000.00) SERVER tsurugidb;
CREATE FOREIGN TABLE employee_i (id INTEGER DEFAULT 1, name VARCHAR(100) DEFAULT 'Unknown', salary NUMERIC(10, 2) DEFAULT 30000.00) SERVER tsurugidb;
