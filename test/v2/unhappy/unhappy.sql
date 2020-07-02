CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

-- default constraint
CREATE TABLE tmp.customer2 (
  "c_credit" char(2) DEFAULT "apple"
) tablespace tsurugi;

-- default constraint
CREATE TABLE tmp.customer3 (
  id serial
) tablespace tsurugi;

-- multiple column pkey
create table tmp.oorder1 (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int not null primary key,
  ol_number int not null primary key
) tablespace tsurugi;

-- same column name
create table tmp.oorder2 (
  ol_w_id int,
  ol_w_id int,
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.oorder3 (
  ol_w_id int,
  ol_d_id varchar(),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.order4 (
  ol_w_id int ,
  ol_d_id varchar(0),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.oorder5 (
  ol_w_id,
  ol_d_id varchar(100),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.order6 (
  int
) tablespace tsurugi;

create table (
  column int
) tablespace tsurugi;

create table tmp.order7 (
  ol_w_id int ,
  ol_d_id char(0),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.order8 (
  1 int
) tablespace tsurugi;

create table tmp.order9 (
  ??? int
) tablespace tsurugi;

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp2;

create table tmp2.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE DATABASE test2 TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test2

create table oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp;

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE TABLE TMP.pkey_not_specified (
COL0  INTEGER                 ,
COL1  INT                     ,
COL2  INT4                    ,
COL3  BIGINT                  ,
COL4  INT8                    ,
COL5  REAL                    ,
COL6  FLOAT4                  ,
COL7  DOUBLE PRECISION        ,
COL8  FLOAT8                  ,
COL9  CHAR                    ,
COL10 CHAR(1000)              ,
COL11 CHARACTER               ,
COL12 CHARACTER(1000)         ,
COL13 VARCHAR                 ,
COL14 VARCHAR(1000)           ,
COL15 CHARACTER VARYING       ,
COL16 CHARACTER VARYING(1000) ,
CONSTRAINT pkey_not_specified PRIMARY KEY()
) TABLESPACE TSURUGI;

CREATE TABLE TMP.pkey_not_exists (
COL0  INTEGER                 ,
COL1  INT                     ,
COL2  INT4                    ,
COL3  BIGINT                  ,
COL4  INT8                    ,
COL5  REAL                    ,
COL6  FLOAT4                  ,
COL7  DOUBLE PRECISION        ,
COL8  FLOAT8                  ,
COL9  CHAR                    ,
COL10 CHAR(1000)              ,
COL11 CHARACTER               ,
COL12 CHARACTER(1000)         ,
COL13 VARCHAR                 ,
COL14 VARCHAR(1000)           ,
COL15 CHARACTER VARYING       ,
COL16 CHARACTER VARYING(1000) ,
CONSTRAINT pkey_not_specified PRIMARY KEY(COL17)
) TABLESPACE TSURUGI;

drop table oorder_dummy;

DROP SCHEMA tmp CASCADE;

\c test

DROP SCHEMA tmp CASCADE;
DROP SCHEMA tmp2 CASCADE;

\c postgres

DROP DATABASE test;
DROP DATABASE test2;
