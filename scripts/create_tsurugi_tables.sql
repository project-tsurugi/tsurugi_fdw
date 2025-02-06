/* create_table.sql */
CREATE TABLE t1_create_table(c1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE t2_create_table(c1 INTEGER NOT NULL PRIMARY KEY, c2 BIGINT, c3 DOUBLE PRECISION);

/* create_index.sql */
CREATE TABLE t3_create_index(c1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE t4_create_index(c1 INTEGER NOT NULL PRIMARY KEY, c2 BIGINT, c3 DOUBLE PRECISION);
CREATE INDEX t3_c1_secondary_index ON t3_create_index(c1);
CREATE INDEX t4_c3_secondary_index ON t4_create_index(c3);

/* insert_select_happy.sql */
create table insert_select_happy (
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
);
create table integer1 (ol_w_id int PRIMARY KEY);
create table bigint1 (id int PRIMARY KEY,ol_w_id bigint);
create table real1 (ol_w_id real PRIMARY KEY);
create table double1 (ol_w_id double precision PRIMARY KEY);
create table char_length_1 (ol_w_id char(1) PRIMARY KEY);
create table varchar_length_1 (ol_w_id varchar(1) PRIMARY KEY);
create table char_length_10 (ol_w_id char(10) PRIMARY KEY);
create table varchar_length_10 (ol_w_id varchar(10) PRIMARY KEY);
CREATE TABLE trg_temporal_literal (
    id          INTEGER NOT NULL PRIMARY KEY,
    dt          DATE,
    tm          TIME,
    tms         TIMESTAMP,
    tms_wo_tz   TIMESTAMP WITHOUT TIME ZONE,
    tms_w_tz    TIMESTAMP WITH TIME ZONE
);

/* update_delete.sql */
CREATE TABLE update_delete_int1(col1 int PRIMARY KEY, col2 int);
CREATE TABLE update_delete_bigint1(col1 int PRIMARY KEY, col2 bigint);
CREATE TABLE update_delete_real1(col1 int PRIMARY KEY, col2 real);
CREATE TABLE update_delete_double1(col1 int PRIMARY KEY, col2 double precision);
CREATE TABLE update_delete_char1(col1 int PRIMARY KEY, col2 char(2));
CREATE TABLE update_delete_varchar1(col1 int PRIMARY KEY, col2 varchar(2));

/* select_statement.sql */
CREATE TABLE t1_select_statement(
    c1 INTEGER PRIMARY KEY, 
    c2 INTEGER, 
    c3 BIGINT,
    c4 REAL, 
    c5 DOUBLE PRECISION, 
    c6 CHAR(10),
    c7 VARCHAR(26)
);
CREATE TABLE t2_select_statement(
    c1 INTEGER PRIMARY KEY,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
);
CREATE TABLE t3_select_statement(
    c1 INTEGER PRIMARY KEY,
    c2 CHAR(10)
);

/* user_management.sql */
CREATE TABLE t1_user_management (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE t2_user_management (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE t3_user_management (column1 INTEGER NOT NULL PRIMARY KEY);

/* udf_transaction.sql */
CREATE TABLE udf_table1 (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE wp_table1 (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE wp_table2 (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE ri_table1 (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE ri_table2 (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE re_table1 (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE re_table2 (column1 INTEGER NOT NULL PRIMARY KEY);
CREATE TABLE tg_table (column1 INTEGER NOT NULL PRIMARY KEY);

/* prepare_statement.sql */
CREATE TABLE trg_table (id INTEGER NOT NULL PRIMARY KEY, num INTEGER, name VARCHAR(10));
CREATE TABLE trg_timedate (
    id      INTEGER NOT NULL PRIMARY KEY,
    tms     TIMESTAMP  default TIMESTAMP '2023-03-03 23:59:35.123456',
    dt      DATE       default DATE '2023-03-03',
    tm      TIME       default TIME '23:59:35.123456789'
);
CREATE TABLE trg_timetz (
    id      INTEGER NOT NULL PRIMARY KEY,
    tm      TIME,
    tmtz    TIME WITH TIME ZONE
);
CREATE TABLE trg_timestamptz (
    id      INTEGER NOT NULL PRIMARY KEY,
    tms     TIMESTAMP,
    tmstz   TIMESTAMP WITH TIME ZONE
);

/* prepare_select_statement */
CREATE TABLE t1_prepare_select_statement(
    c1 INTEGER PRIMARY KEY,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
);

CREATE TABLE t2_prepare_select_statement(
    c1 INTEGER PRIMARY KEY,
    c2 INTEGER,
    c3 BIGINT,
    c4 REAL,
    c5 DOUBLE PRECISION,
    c6 CHAR(10),
    c7 VARCHAR(26)
);

CREATE TABLE t3_prepare_select_statement(
    c1 INTEGER PRIMARY KEY,
    c2 CHAR(10)
);

/* prepare_decimal.sql */
CREATE TABLE trg_numeric (id INTEGER NOT NULL PRIMARY KEY, num NUMERIC(10, 6));
CREATE TABLE trg_numeric_s0 (id INTEGER NOT NULL PRIMARY KEY, num NUMERIC(38, 0));
CREATE TABLE trg_numeric_s38 (id INTEGER NOT NULL PRIMARY KEY, num NUMERIC(38, 38));

/* manual_tutorial.sql */
CREATE TABLE weather (
    id              int primary key,
    city            varchar(80),
    temp_lo         int,
    temp_hi         int,
    prcp            real,
    the_date        date default DATE '2023-04-01'
);

/* bug fix confirm */
CREATE TABLE employee_1 (id INTEGER DEFAULT 1, name VARCHAR(100) DEFAULT 'Unknown', salary NUMERIC(10, 2) DEFAULT 30000.00);
CREATE TABLE employee_2 (id INTEGER DEFAULT 1, name VARCHAR(100) DEFAULT 'Unknown', salary NUMERIC(10, 2) DEFAULT 30000.00);
CREATE TABLE employee_i (id INTEGER DEFAULT 1, name VARCHAR(100) DEFAULT 'Unknown', salary NUMERIC(10, 2) DEFAULT 30000.00);
INSERT INTO employee_1 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (11, 'kf', 50000), (12, 'yy', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (11, 'kf', 50000), (12, 'yy', 55000);
INSERT INTO employee_1 (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 55000);
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
