CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE EXTENSION ogawayama_fdw;
CREATE SERVER ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;

CREATE TABLE test1 (
col1  int,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000)
) tablespace tsurugi;

CREATE TABLE test2 (
col1  int PRIMARY KEY,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000)
) tablespace tsurugi;

CREATE TABLE test3 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) tablespace tsurugi;

CREATE TABLE test4_1 (
col1  int PRIMARY KEY NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) tablespace tsurugi;

CREATE TABLE test4_2 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL PRIMARY KEY,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) tablespace tsurugi;

CREATE TABLE test5 (
col1  int,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000),
PRIMARY KEY(col10)
) tablespace tsurugi;

--error
CREATE TABLE test6 (
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
col14 varchar(1000),
col16 character varying(1000),
PRIMARY KEY(col1)
) tablespace tsurugi;

CREATE TABLE test7 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL,
PRIMARY KEY(col3)
) tablespace tsurugi;

--error
CREATE TABLE test8_1 (
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
col14 varchar(1000) NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col4)
) tablespace tsurugi;

--error
CREATE TABLE test8_2 (
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
col14 varchar(1000) NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col5)
) tablespace tsurugi;

CREATE TABLE test9 (
col1  int,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000),
PRIMARY KEY(col1,col3,col5,col10)
) tablespace tsurugi;

--error
CREATE TABLE test10 (
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
col14 varchar(1000),
col16 character varying(1000),
PRIMARY KEY(col1,col2)
) tablespace tsurugi;

CREATE TABLE test11 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL,
PRIMARY KEY(col1,col3,col5,col10,col14)
) tablespace tsurugi;

--error
CREATE TABLE test12_1 (
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
col14 varchar(1000) NOT NULL,
col16 character varying(1000) NOT NULL PRIMARY KEY,
PRIMARY KEY(col7,col8,col9,col10)
) tablespace tsurugi;

--error
CREATE TABLE test12_2 (
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
col14 varchar(1000) NOT NULL,
col16 character varying(1000) PRIMARY KEY NOT NULL,
PRIMARY KEY(col7,col8,col9,col10)
) tablespace tsurugi;

CREATE FOREIGN TABLE test1 (
col1  int,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000)
) SERVER ogawayama;

CREATE FOREIGN TABLE test2 (
col1  int,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000)
) SERVER ogawayama;

CREATE FOREIGN TABLE test3 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test4_1 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test4_2 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test5 (
col1  int,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000)
) SERVER ogawayama;

CREATE FOREIGN TABLE test7 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test9 (
col1  int,
col3  bigint,
col5  real,
col7  double precision,
col10 char(1000),
col14 varchar(1000)
) SERVER ogawayama;

CREATE FOREIGN TABLE test11 (
col1  int NOT NULL,
col3  bigint NOT NULL,
col5  real NOT NULL,
col7  double precision NOT NULL,
col10 char(1000) NOT NULL,
col14 varchar(1000) NOT NULL
) SERVER ogawayama;

SELECT * from test1;
INSERT INTO test1 VALUES (1,1000,3.24,-2.27,'A','ABCDEFABCDEF');
SELECT * from test1;
INSERT INTO test1 (col14) VALUES ('ABCDEFABCDEF');
SELECT * from test1;

SELECT * from test2;
INSERT INTO test2 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2;
INSERT INTO test2 (col3) VALUES (1001);
SELECT * from test2;
INSERT INTO test2 (col1) VALUES (1);
SELECT * from test2;
INSERT INTO test2 (col1) VALUES (2);
SELECT * from test2;

INSERT INTO test3 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test3;
INSERT INTO test3 (col3) VALUES (1);
SELECT * from test3;

INSERT INTO test4_1 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_1;
INSERT INTO test4_1 (col5) VALUES (3.24);
SELECT * from test4_1;
INSERT INTO test4_1 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_1;
INSERT INTO test4_1 VALUES (2,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_1;

INSERT INTO test4_2 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;
INSERT INTO test4_2 (col7) VALUES (3.24);
SELECT * from test4_2;
INSERT INTO test4_2 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;
INSERT INTO test4_2 VALUES (2,1000,3.24,-3.24,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;

SELECT * from test5;
INSERT INTO test5 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test5;
INSERT INTO test5 (col14) VALUES ('ABCDEFABCDEF');
SELECT * from test5;
INSERT INTO test5 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test5;
INSERT INTO test5 (col10) VALUES ('AAA');
SELECT * from test5;

INSERT INTO test7 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7;
INSERT INTO test7 (col14) VALUES ('ABC');
SELECT * from test7;
INSERT INTO test7 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7;
INSERT INTO test7 VALUES (1,1001,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7;

SELECT * from test9;
INSERT INTO test9 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test9;
INSERT INTO test9 (col7) VALUES (1,3.24,-2.27,'ABC');
SELECT * from test9;
INSERT INTO test9 (col1,col3,col5,col10) VALUES (1,1000,3.24,'ABC');
SELECT * from test9;
INSERT INTO test9 (col1,col3,col5,col10) VALUES (1,1000,3.24,'A');
SELECT * from test9;

INSERT INTO test11 VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11;
INSERT INTO test11 (col7) VALUES (1.2);
SELECT * from test11;
INSERT INTO test11 (col1,col3,col5,col10,col14) VALUES (1,1000,3.24,'ABC','ABCDEFABCDEF');
SELECT * from test11;
INSERT INTO test11 (col1,col3,col5,col10,col14) VALUES (2,1000,3.24,'ABC','ABCDEFABCDEF');
SELECT * from test11;

\c postgres

DROP DATABASE test;
