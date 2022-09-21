CREATE EXTENSION IF NOT EXISTS ogawayama_fdw;
CREATE SERVER IF NOT EXISTS ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;

--error
CREATE TABLE test1 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test2_1 (
col1  int PRIMARY KEY,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test2_2 (
col1  int,
col2  bigint PRIMARY KEY,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test2_3 (
col1  int,
col2  bigint,
col3  real PRIMARY KEY,
col4  double precision,
col5 char(20),
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test2_4 (
col1  int,
col2  bigint,
col3  real,
col4  double precision PRIMARY KEY,
col5 char(20),
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test2_5 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20) PRIMARY KEY,
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test2_6 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20) PRIMARY KEY
) tablespace tsurugi;

--error
CREATE TABLE test3 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) tablespace tsurugi;

CREATE TABLE test4_1 (
col1  int PRIMARY KEY NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) tablespace tsurugi;

CREATE TABLE test4_2 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL PRIMARY KEY,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) tablespace tsurugi;

CREATE TABLE test4_3 (
col1  int NOT NULL,
col2  bigint,
col3  real,
col4  double precision PRIMARY KEY,
col5 char(20),
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test4_4 (
col1  int,
col2  bigint,
col3  real,
col4  double precision PRIMARY KEY NOT NULL,
col5 char(20),
col6 varchar(20)
) tablespace tsurugi;

CREATE TABLE test5 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20),
PRIMARY KEY(col5)
) tablespace tsurugi;

--error
CREATE TABLE test6 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20) PRIMARY KEY,
col6 varchar(20),
PRIMARY KEY(col1)
) tablespace tsurugi;

CREATE TABLE test7_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;

CREATE TABLE test7_2 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;

CREATE TABLE test7_3 (
col1  int,
col2  bigint NOT NULL,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20),
PRIMARY KEY(col2)
) tablespace tsurugi;

--error
CREATE TABLE test8_1 (
col1  int NOT NULL,
col2  bigint NOT NULL PRIMARY KEY,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL,
PRIMARY KEY(col4)
) tablespace tsurugi;

--error
CREATE TABLE test8_2 (
col1  int NOT NULL,
col2  bigint PRIMARY KEY NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL,
PRIMARY KEY(col3)
) tablespace tsurugi;

CREATE TABLE test9 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20),
PRIMARY KEY(col1,col2,col3,col5)
) tablespace tsurugi;

--error
CREATE TABLE test10 (
col1  int,
col2  bigint PRIMARY KEY,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20),
PRIMARY KEY(col1,col2)
) tablespace tsurugi;

CREATE TABLE test11_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL,
PRIMARY KEY(col1,col2,col3,col5,col6)
) tablespace tsurugi;

CREATE TABLE test11_2 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL,
PRIMARY KEY(col1,col2,col3,col5,col6)
) tablespace tsurugi;

CREATE TABLE test11_3 (
col1  int,
col2  bigint,
col3  real,
col4  double precision NOT NULL,
col5 char(20),
col6 varchar(20),
PRIMARY KEY(col1,col2,col3,col5,col6)
) tablespace tsurugi;

--error
CREATE TABLE test12_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL PRIMARY KEY,
PRIMARY KEY(col1,col2,col5,col6)
) tablespace tsurugi;

--error
CREATE TABLE test12_2 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) PRIMARY KEY NOT NULL,
PRIMARY KEY(col1,col2,col5,col6)
) tablespace tsurugi;

--error
CREATE FOREIGN TABLE test1 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test2_1 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test2_2 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test2_3 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test2_4 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test2_5 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test2_6 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

--error
CREATE FOREIGN TABLE test3 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test4_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test4_2 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test4_3 (
col1  int NOT NULL,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test4_4 (
col1  int,
col2  bigint,
col3  real,
col4  double precision NOT NULL,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test5 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

--error
CREATE FOREIGN TABLE test6 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test7_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test7_2 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test7_3 (
col1  int,
col2  bigint NOT NULL,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

--error
CREATE FOREIGN TABLE test8_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

--error
CREATE FOREIGN TABLE test8_2 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test9 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

--error
CREATE FOREIGN TABLE test10 (
col1  int,
col2  bigint,
col3  real,
col4  double precision,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

CREATE FOREIGN TABLE test11_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test11_2 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE test11_3 (
col1  int,
col2  bigint,
col3  real,
col4  double precision NOT NULL,
col5 char(20),
col6 varchar(20)
) SERVER ogawayama;

--error
CREATE FOREIGN TABLE test12_1 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

--error
CREATE FOREIGN TABLE test12_2 (
col1  int NOT NULL,
col2  bigint NOT NULL,
col3  real NOT NULL,
col4  double precision NOT NULL,
col5 char(20) NOT NULL,
col6 varchar(20) NOT NULL
) SERVER ogawayama;

--test1 all error
SELECT * from test1;
INSERT INTO test1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'A','ABCDEFABCDEF');
SELECT * from test1;
INSERT INTO test1 (col6) VALUES ('ABCDEFABCDEF');
SELECT * from test1;

--test2_1
SELECT * from test2_1;
--ok
INSERT INTO test2_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_1;
--PKEY col1 null error
INSERT INTO test2_1 (col2,col3,col4,col5,col6) VALUES (1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_1;
--PKEY col1 not unique error
INSERT INTO test2_1 (col1) VALUES (1);
SELECT * from test2_1;
--ok
INSERT INTO test2_1 (col1) VALUES (2);
SELECT * from test2_1;

--test2_2
SELECT * from test2_2;
--ok
INSERT INTO test2_2 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_2;
--PKEY col2 null error
INSERT INTO test2_2 (col1,col3,col4,col5,col6) VALUES (1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_2;
--PKEY col2 not unique error
INSERT INTO test2_2 (col1, col2) VALUES (1, 1000);
SELECT * from test2_2;
--ok
INSERT INTO test2_2 (col1, col2) VALUES (1, 2);
SELECT * from test2_2;

--test2_3
SELECT * from test2_3;
--ok
INSERT INTO test2_3 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_3;
--PKEY col3 null error
INSERT INTO test2_3 (col1,col2,col4,col5,col6) VALUES (1,1000,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_3;
--PKEY col3 not unique error
INSERT INTO test2_3 (col2, col3) VALUES (1000,3.24);
SELECT * from test2_3;
--ok
INSERT INTO test2_3 (col2, col3) VALUES (1000,3.25);
SELECT * from test2_3;

--test2_4
SELECT * from test2_4;
--ok
INSERT INTO test2_4 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_4;
--PKEY col4 null error
INSERT INTO test2_4 (col1,col2,col3,col5,col6) VALUES (1,1000,3.24,'ABC','ABCDEFABCDEF');
SELECT * from test2_4;
--PKEY col4 not unique error
INSERT INTO test2_4 (col4,col6) VALUES (-2.27,'ABCDEFABCDEF');
SELECT * from test2_4;
--ok
INSERT INTO test2_4 (col4,col6) VALUES (-2.28,'ABCDEFABCDEF');
SELECT * from test2_4;

--test2_5
SELECT * from test2_5;
--ok
INSERT INTO test2_5 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_5;
--PKEY col5 null error
INSERT INTO test2_5 (col1,col2,col3,col4,col6) VALUES (1,1000,3.24,-2.27,'ABCDEFABCDEF');
SELECT * from test2_5;
--PKEY col5 not unique error
INSERT INTO test2_5 (col2, col5, col6) VALUES (1000,'ABC','ABCDEFABCDEF');
SELECT * from test2_5;
--ok
INSERT INTO test2_5 (col2, col5, col6) VALUES (1000,'ABD','ABCDEFABCDEF');
SELECT * from test2_5;

--test2_6
SELECT * from test2_6;
--ok
INSERT INTO test2_6 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test2_6;
--PKEY col6 null error
INSERT INTO test2_6 (col1,col2,col3,col4,col5) VALUES (1,1000,3.24,-2.27,'ABC');
SELECT * from test2_6;
--PKEY col6 not unique error
INSERT INTO test2_6 (col1, col4, col6) VALUES (1,-2.27,'ABCDEFABCDEF');
SELECT * from test2_6;
--ok
INSERT INTO test2_6 (col1, col4, col6) VALUES (1,-2.27,'ABCDEFABCDEFG');
SELECT * from test2_6;

--test3 all error
INSERT INTO test3 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test3;
INSERT INTO test3 (col2) VALUES (1);
SELECT * from test3;

--test4_1
SELECT * from test4_1;
--ok
INSERT INTO test4_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_1;
--NOT NULL constraint null error
INSERT INTO test4_1 (col1) VALUES (3);
SELECT * from test4_1;
--PKEY col1 null error
INSERT INTO test4_1 (col3) VALUES (3.24);
SELECT * from test4_1;
--PKEY col1 not unique error
INSERT INTO test4_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_1;
--ok
INSERT INTO test4_1 (col1,col2,col3,col4,col5,col6) VALUES (2,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_1;

--test4_2
SELECT * from test4_2;
--ok
INSERT INTO test4_2 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;
--PKEY col4 null error
INSERT INTO test4_2 (col1,col2,col3,col5,col6) VALUES (1,1000,3.24,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;
--NOT NULL constraint null error
INSERT INTO test4_2 (col2,col3,col4,col5,col6) VALUES (1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;
--PKEY col4 not unique error
INSERT INTO test4_2 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;
--ok
INSERT INTO test4_2 (col1,col2,col3,col4,col5,col6) VALUES (2,1000,3.24,-3.24,'ABC','ABCDEFABCDEF');
SELECT * from test4_2;

--test4_3
SELECT * from test4_3;
--ok
INSERT INTO test4_3 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_3;
--PKEY col4 null error
INSERT INTO test4_3 (col1) VALUES (1);
SELECT * from test4_3;
--NOT NULL constraint null error
INSERT INTO test4_3 (col2,col3,col4,col5,col6) VALUES (1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_3;
--PKEY col4 not unique error
INSERT INTO test4_3 (col1,col4) VALUES (1,-2.27);
SELECT * from test4_3;
--ok
INSERT INTO test4_3 (col1,col4) VALUES (1,-3.24);
SELECT * from test4_3;

--test4_4
SELECT * from test4_4;
--ok
INSERT INTO test4_4 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test4_4;
--PKEY col4 null error
INSERT INTO test4_4 (col5) VALUES ('ABC');
SELECT * from test4_4;
--NOT NULL constraint null error
INSERT INTO test4_4 (col6) VALUES ('ABCDEFABCDEF');
SELECT * from test4_4;
--PKEY col4 not unique error
INSERT INTO test4_4 (col4) VALUES (-2.27);
SELECT * from test4_4;
--ok
INSERT INTO test4_4 (col4) VALUES (-3.24);
SELECT * from test4_4;

--test5
SELECT * from test5;
--ok
INSERT INTO test5 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test5;
--PKEY col5 null error
INSERT INTO test5 (col1,col2,col3,col4,col6) VALUES (1,1000,3.24,-2.27,'ABCDEFABCDEF');
SELECT * from test5;
--PKEY col5 not unique error
INSERT INTO test5 (col5) VALUES ('ABC');
SELECT * from test5;
--ok
INSERT INTO test5 (col5) VALUES ('AAA');
SELECT * from test5;

--test6 error
SELECT * from test6;

--test7_1
SELECT * from test7_1;
--ok
INSERT INTO test7_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7_1;
-- NOT NULL constraint null error
INSERT INTO test7_1 (col1,col2,col3,col4,col5) VALUES (1,1000,3.24,-2.27,'ABC');
SELECT * from test7_1;
--PKEY col2 null error
INSERT INTO test7_1 (col1,col3,col4,col5,col6) VALUES (1,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7_1;
--PKEY col2 not unique error
INSERT INTO test7_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7_1;
--ok
INSERT INTO test7_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1001,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7_1;

--test7_2
SELECT * from test7_2;
--ok
INSERT INTO test7_2 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7_2;
-- NOT NULL constraint null error
INSERT INTO test7_2 (col2) VALUES (1000);
SELECT * from test7_2;
--PKEY col2 null error
INSERT INTO test7_2 (col6) VALUES ('ABCDEFABCDEF');
SELECT * from test7_2;
--PKEY col2 not unique error
INSERT INTO test7_2 (col2,col6) VALUES (1000,'ABCDEFABCDEF');
SELECT * from test7_2;
--ok
INSERT INTO test7_2 (col2,col6) VALUES (1001,'ABCDEFABCDEF');
SELECT * from test7_2;

--test7_3
SELECT * from test7_3;
--ok
INSERT INTO test7_3 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test7_3;
-- NOT NULL constraint null error
INSERT INTO test7_3 (col3) VALUES (3.24);
SELECT * from test7_3;
--PKEY col2 null error
INSERT INTO test7_3 (col4) VALUES (-2.27);
SELECT * from test7_3;
--PKEY col2 not unique error
INSERT INTO test7_3 (col2) VALUES (1000);
SELECT * from test7_3;
--ok
INSERT INTO test7_3 (col2) VALUES (1001);
SELECT * from test7_3;

--test8 all error
SELECT * from test8_1;
SELECT * from test8_2;

--test9
SELECT * from test9;
--ok
INSERT INTO test9 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test9;
--PKEY (col1,col2,col3,col5) null error
INSERT INTO test9 (col1,col2,col3) VALUES (2,1000,3.24);
SELECT * from test9;
--PKEY (col1,col2,col3,col5) not unique error
INSERT INTO test9 (col1,col2,col3,col5) VALUES (1,1000,3.24,'ABC');
SELECT * from test9;
--ok
INSERT INTO test9 (col1,col2,col3,col5) VALUES (1,1000,3.24,'A');
SELECT * from test9;

--test10 error
SELECT * from test10;

--test11_1
SELECT * from test11_1;
--ok
INSERT INTO test11_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_1;
--NOT NULL constraint null error
INSERT INTO test11_1 (col1,col2,col3,col5,col6) VALUES (3,1000,3.24,'ABC','ABCDEFABCDEF');
--PKEY (col1,col2,col3,col5,col6) null error
INSERT INTO test11_1 (col1,col3,col4,col5,col6) VALUES (1,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_1;
--PKEY (col1,col2,col3,col5,col6) not unique error
INSERT INTO test11_1 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_1;
--ok
INSERT INTO test11_1 (col1,col2,col3,col4,col5,col6) VALUES (2,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_1;

--test11_2
SELECT * from test11_2;
--ok
INSERT INTO test11_2 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_2;
--NOT NULL constraint null error
INSERT INTO test11_2 (col1,col2,col3,col5) VALUES (3,1000,3.24,'ABC');
--PKEY (col1,col2,col3,col5,col6) null error
INSERT INTO test11_2 (col1,col2,col3,col6) VALUES (1,1000,3.24,'ABCDEFABCDEF');
SELECT * from test11_2;
--PKEY (col1,col2,col3,col5,col6) not unique error
INSERT INTO test11_2 (col1,col2,col3,col5,col6) VALUES (1,1000,3.24,'ABC','ABCDEFABCDEF');
SELECT * from test11_2;
--ok
INSERT INTO test11_2 (col1,col2,col3,col5,col6) VALUES (2,1000,3.24,'ABC','ABCDEFABCDEF');
SELECT * from test11_2;

--test11_3
SELECT * from test11_3;
--ok
INSERT INTO test11_3 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_3;
--NOT NULL constraint null error
INSERT INTO test11_3 (col1,col2,col3,col5,col6) VALUES (3,1000,3.24,'ABC','ABCDEFABCDEF');
--PKEY (col1,col2,col3,col5,col6) null error
INSERT INTO test11_3 (col1,col2,col3,col4,col5) VALUES (1,1001,3.24,-2.27,'ABC');
SELECT * from test11_3;
--PKEY (col1,col2,col3,col5,col6) not unique error
INSERT INTO test11_3 (col1,col2,col3,col4,col5,col6) VALUES (1,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_3;
--ok
INSERT INTO test11_3 (col1,col2,col3,col4,col5,col6) VALUES (2,1000,3.24,-2.27,'ABC','ABCDEFABCDEF');
SELECT * from test11_3;

--test12 error
SELECT * from test12_1;
SELECT * from test12_2;
