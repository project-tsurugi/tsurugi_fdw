CREATE DATABASE test;

\c test

CREATE SCHEMA tmp;

CREATE TABLE tmp.test1 (
col0  integer,
col1  int,
col2  int4,
col3  bigint,
col4  int8,
col5  real,
col6  float4,
col7  double precision,
col8  float8,
col9  char,
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000)
) tablespace tsurugi;

CREATE TABLE tmp.test2 (
col0  integer PRIMARY KEY,
col1  int,
col2  int4,
col3  bigint,
col4  int8,
col5  real,
col6  float4,
col7  double precision,
col8  float8,
col9  char,
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000)
) tablespace tsurugi;

CREATE TABLE tmp.test3 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL
) tablespace tsurugi;

CREATE TABLE tmp.test4_1 (
col0  integer PRIMARY KEY NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL
) tablespace tsurugi;

CREATE TABLE tmp.test4_2 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL PRIMARY KEY,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL
) tablespace tsurugi;

CREATE TABLE tmp.test5 (
col0  integer,
col1  int,
col2  int4,
col3  bigint,
col4  int8,
col5  real,
col6  float4,
col7  double precision,
col8  float8,
col9  char,
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col9)
) tablespace tsurugi;

--error
CREATE TABLE tmp.test6 (
col0  integer,
col1  int,
col2  int4,
col3  bigint,
col4  int8,
col5  real,
col6  float4,
col7  double precision,
col8  float8,
col9  char,
col10 char(1000) PRIMARY KEY,
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col1)
) tablespace tsurugi;

CREATE TABLE tmp.test7 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col4)
) tablespace tsurugi;

--error
CREATE TABLE tmp.test8_1 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL PRIMARY KEY,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col4)
) tablespace tsurugi;

--error
CREATE TABLE tmp.test8_2 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint PRIMARY KEY NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col5)
) tablespace tsurugi;

CREATE TABLE tmp.test9 (
col0  integer,
col1  int,
col2  int4,
col3  bigint,
col4  int8,
col5  real,
col6  float4,
col7  double precision,
col8  float8,
col9  char,
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col1,col2,col5,col15)
) tablespace tsurugi;

--error
CREATE TABLE tmp.test10 (
col0  integer,
col1  int,
col2  int4,
col3  bigint PRIMARY KEY,
col4  int8,
col5  real,
col6  float4,
col7  double precision,
col8  float8,
col9  char,
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col1,col2)
) tablespace tsurugi;

CREATE TABLE tmp.test11 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col3,col4,col5,col14,col15)
) tablespace tsurugi;

--error
CREATE TABLE tmp.test12_1 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL PRIMARY KEY,
PRIMARY KEY(col7,col8,col9,col10)
) tablespace tsurugi;

--error
CREATE TABLE tmp.test12_2 (
col0  integer NOT NULL,
col1  int NOT NULL,
col2  int4 NOT NULL,
col3  bigint NOT NULL,
col4  int8 NOT NULL,
col5  real NOT NULL,
col6  float4 NOT NULL,
col7  double precision NOT NULL,
col8  float8 NOT NULL,
col9  char NOT NULL,
col10 char(1000) NOT NULL,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) PRIMARY KEY NOT NULL,
PRIMARY KEY(col7,col8,col9,col10)
) tablespace tsurugi;

DROP SCHEMA tmp CASCADE;

\c postgres

DROP DATABASE test;
