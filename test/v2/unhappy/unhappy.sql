CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

-- double quote in default constraint
CREATE TABLE tmp.default_constr_double_quote (
  "c_credit" char(2) DEFAULT "apple"
) tablespace tsurugi;

-- default constraint serial
CREATE TABLE tmp.default_constr_serial (
  id serial
) tablespace tsurugi;

-- multiple column pkey
create table tmp.multiple_col_pkey (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int not null primary key,
  ol_number int not null primary key
) tablespace tsurugi;

-- same column name
create table tmp.same_col_name (
  ol_w_id int,
  ol_w_id int,
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- varchar data length is empty
create table tmp.varchar_length_empty (
  ol_w_id int,
  ol_d_id varchar(),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- varchar data length is zero
create table tmp.varchar_length_0 (
  ol_w_id int ,
  ol_d_id varchar(0),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- type of ol_w_id is not specified
create table tmp.type_is_not_specified (
  ol_w_id,
  ol_d_id varchar(100),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- column name is not specified
create table tmp.col_name_is_not_specified (
  int
) tablespace tsurugi;

-- table name is not specified
create table (
  column int
) tablespace tsurugi;

-- char data length is zero
create table tmp.char_length_0 (
  ol_w_id int ,
  ol_d_id char(0),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- column name is 1
create table tmp.col_name_is_1 (
  1 int
) tablespace tsurugi;

-- column name is 1c
create table tmp.col_name_is_1 (
  1c int
) tablespace tsurugi;

-- column name is japanese
create table tmp.col_name_is_japanese (
  ??? int
) tablespace tsurugi;

-- *** same table name is specified ***

-- success to create table in the schema "tmp"
create table tmp.same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp2;

-- If same table name is defined in another schema,
-- fail to create table.
create table tmp2.same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE DATABASE test2 TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test2

-- If same table name is defined in another database,
-- fail to create table.
create table same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp;

-- If same table name is defined in another schema of another database,
-- fail to create table.
create table tmp.same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

-- primary key is not specified
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

-- primary key column does not exist
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

DROP SCHEMA tmp CASCADE;

\c test

DROP SCHEMA tmp CASCADE;
DROP SCHEMA tmp2 CASCADE;

\c postgres

DROP DATABASE test;
DROP DATABASE test2;