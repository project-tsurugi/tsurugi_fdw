CREATE EXTENSION IF NOT EXISTS ogawayama_fdw;
CREATE SERVER IF NOT EXISTS ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;
CREATE TABLE test14_0 (
col0 int ,
col1 int ,
col2 int ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_1 (
col0 int NOT NULL,
col1 int ,
col2 int ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_2 (
col0 int ,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_3 (
col0 int ,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_4 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_5 (
col0 int ,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_6 (
col0 int NOT NULL,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_7 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE test14_8 (
col0 int ,
col1 int ,
col2 int ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_9 (
col0 int NOT NULL,
col1 int ,
col2 int ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_10 (
col0 int ,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_11 (
col0 int ,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_12 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_13 (
col0 int ,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_14 (
col0 int NOT NULL,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_15 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE test14_16 (
col0 int ,
col1 int ,
col2 int ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_17 (
col0 int NOT NULL,
col1 int ,
col2 int ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_18 (
col0 int ,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_19 (
col0 int ,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_20 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_21 (
col0 int ,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_22 (
col0 int NOT NULL,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_23 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE test14_24 (
col0 int ,
col1 int ,
col2 int ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_25 (
col0 int NOT NULL,
col1 int ,
col2 int ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_26 (
col0 int ,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_27 (
col0 int ,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_28 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_29 (
col0 int ,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_30 (
col0 int NOT NULL,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_31 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE test14_32 (
col0 int ,
col1 int ,
col2 int ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_33 (
col0 int NOT NULL,
col1 int ,
col2 int ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_34 (
col0 int ,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_35 (
col0 int ,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_36 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_37 (
col0 int ,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_38 (
col0 int NOT NULL,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_39 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_40 (
col0 int ,
col1 int ,
col2 int ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_41 (
col0 int NOT NULL,
col1 int ,
col2 int ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_42 (
col0 int ,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_43 (
col0 int ,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_44 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_45 (
col0 int ,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_46 (
col0 int NOT NULL,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_47 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE test14_48 (
col0 int ,
col1 int ,
col2 int ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_49 (
col0 int NOT NULL,
col1 int ,
col2 int ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_50 (
col0 int ,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_51 (
col0 int ,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_52 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_53 (
col0 int ,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_54 (
col0 int NOT NULL,
col1 int ,
col2 int NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE test14_55 (
col0 int NOT NULL,
col1 int NOT NULL,
col2 int NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE FOREIGN TABLE test14_0 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_1 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_2 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_3 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_4 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_5 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_6 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_7 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_8 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_9 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_10 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_11 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_12 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_13 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_14 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_15 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_16 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_17 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_18 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_19 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_20 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_21 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_22 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_23 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_24 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_25 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_26 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_27 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_28 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_29 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_30 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_31 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_32 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_33 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_34 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_35 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_36 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_37 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_38 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_39 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_40 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_41 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_42 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_43 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_44 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_45 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_46 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_47 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_48 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_49 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_50 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_51 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_52 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_53 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_54 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test14_55 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
--test14_0
SELECT * from test14_0;
--ok
INSERT INTO test14_0 VALUES(1, 1, 1);
SELECT * from test14_0;
--PKEY col0 null error 
INSERT INTO test14_0(col1,col2) VALUES(3,3);
SELECT * from test14_0;
--PKEY col0 null error 
INSERT INTO test14_0(col1,col2) VALUES(3,3);
SELECT * from test14_0;
--PKEY col0 not unique error
INSERT INTO test14_0(col0) VALUES(1);
SELECT * from test14_0;
--ok
INSERT INTO test14_0(col0) VALUES(2);
SELECT * from test14_0;

--test14_1
SELECT * from test14_1;
--ok
INSERT INTO test14_1 VALUES(1, 1, 1);
SELECT * from test14_1;
--PKEY col0 null error 
INSERT INTO test14_1(col1,col2) VALUES(3,3);
SELECT * from test14_1;
--PKEY col0 null error 
INSERT INTO test14_1(col1,col2) VALUES(3,3);
SELECT * from test14_1;
--PKEY col0 not unique error
INSERT INTO test14_1(col0) VALUES(1);
SELECT * from test14_1;
--not null constraint col0 error
INSERT INTO test14_1(col1,col2) VALUES(5,5);
SELECT * from test14_1;
--ok
INSERT INTO test14_1(col0) VALUES(2);
SELECT * from test14_1;

--test14_2
SELECT * from test14_2;
--ok
INSERT INTO test14_2 VALUES(1, 1, 1);
SELECT * from test14_2;
--PKEY col0 null error 
INSERT INTO test14_2(col1,col2) VALUES(3,3);
SELECT * from test14_2;
--PKEY col0 null error 
INSERT INTO test14_2(col1,col2) VALUES(3,3);
SELECT * from test14_2;
--PKEY col0 not unique error
INSERT INTO test14_2(col0,col1) VALUES(1,3);
SELECT * from test14_2;
--not null constraint col1 error
INSERT INTO test14_2(col0,col2) VALUES(5,5);
SELECT * from test14_2;
--ok
INSERT INTO test14_2(col0,col1) VALUES(2,6);
SELECT * from test14_2;

--test14_3
SELECT * from test14_3;
--ok
INSERT INTO test14_3 VALUES(1, 1, 1);
SELECT * from test14_3;
--PKEY col0 null error 
INSERT INTO test14_3(col1,col2) VALUES(3,3);
SELECT * from test14_3;
--PKEY col0 null error 
INSERT INTO test14_3(col1,col2) VALUES(3,3);
SELECT * from test14_3;
--PKEY col0 not unique error
INSERT INTO test14_3(col0,col2) VALUES(1,3);
SELECT * from test14_3;
--not null constraint col2 error
INSERT INTO test14_3(col0,col1) VALUES(5,5);
SELECT * from test14_3;
--ok
INSERT INTO test14_3(col0,col2) VALUES(2,6);
SELECT * from test14_3;

--test14_4
SELECT * from test14_4;
--ok
INSERT INTO test14_4 VALUES(1, 1, 1);
SELECT * from test14_4;
--PKEY col0 null error 
INSERT INTO test14_4(col1,col2) VALUES(3,3);
SELECT * from test14_4;
--PKEY col0 null error 
INSERT INTO test14_4(col1,col2) VALUES(3,3);
SELECT * from test14_4;
--PKEY col0 not unique error
INSERT INTO test14_4(col0,col1) VALUES(1,3);
SELECT * from test14_4;
--not null constraint col0 error
INSERT INTO test14_4(col1,col2) VALUES(5,5);
SELECT * from test14_4;
--not null constraint col1 error
INSERT INTO test14_4(col0,col2) VALUES(5,5);
SELECT * from test14_4;
--ok
INSERT INTO test14_4(col0,col1) VALUES(2,6);
SELECT * from test14_4;

--test14_5
SELECT * from test14_5;
--ok
INSERT INTO test14_5 VALUES(1, 1, 1);
SELECT * from test14_5;
--PKEY col0 null error 
INSERT INTO test14_5(col1,col2) VALUES(3,3);
SELECT * from test14_5;
--PKEY col0 null error 
INSERT INTO test14_5(col1,col2) VALUES(3,3);
SELECT * from test14_5;
--PKEY col0 not unique error
INSERT INTO test14_5(col0,col1,col2) VALUES(1,3,3);
SELECT * from test14_5;
--not null constraint col1 error
INSERT INTO test14_5(col0,col2) VALUES(5,5);
SELECT * from test14_5;
--not null constraint col2 error
INSERT INTO test14_5(col0,col1) VALUES(5,5);
SELECT * from test14_5;
--ok
INSERT INTO test14_5(col0,col1,col2) VALUES(2,6,6);
SELECT * from test14_5;

--test14_6
SELECT * from test14_6;
--ok
INSERT INTO test14_6 VALUES(1, 1, 1);
SELECT * from test14_6;
--PKEY col0 null error 
INSERT INTO test14_6(col1,col2) VALUES(3,3);
SELECT * from test14_6;
--PKEY col0 null error 
INSERT INTO test14_6(col1,col2) VALUES(3,3);
SELECT * from test14_6;
--PKEY col0 not unique error
INSERT INTO test14_6(col0,col2) VALUES(1,3);
SELECT * from test14_6;
--not null constraint col0 error
INSERT INTO test14_6(col1,col2) VALUES(5,5);
SELECT * from test14_6;
--not null constraint col2 error
INSERT INTO test14_6(col0,col1) VALUES(5,5);
SELECT * from test14_6;
--ok
INSERT INTO test14_6(col0,col2) VALUES(2,6);
SELECT * from test14_6;

--test14_7
SELECT * from test14_7;
--ok
INSERT INTO test14_7 VALUES(1, 1, 1);
SELECT * from test14_7;
--PKEY col0 null error 
INSERT INTO test14_7(col1,col2) VALUES(3,3);
SELECT * from test14_7;
--PKEY col0 null error 
INSERT INTO test14_7(col1,col2) VALUES(3,3);
SELECT * from test14_7;
--PKEY col0 not unique error
INSERT INTO test14_7(col0,col1,col2) VALUES(1,3,3);
SELECT * from test14_7;
--not null constraint col0 error
INSERT INTO test14_7(col1,col2) VALUES(5,5);
SELECT * from test14_7;
--not null constraint col1 error
INSERT INTO test14_7(col0,col2) VALUES(5,5);
SELECT * from test14_7;
--not null constraint col2 error
INSERT INTO test14_7(col0,col1) VALUES(5,5);
SELECT * from test14_7;
--ok
INSERT INTO test14_7(col0,col1,col2) VALUES(2,6,6);
SELECT * from test14_7;

--test14_8
SELECT * from test14_8;
--ok
INSERT INTO test14_8 VALUES(1, 1, 1);
SELECT * from test14_8;
--PKEY col1 null error 
INSERT INTO test14_8(col0,col2) VALUES(3,3);
SELECT * from test14_8;
--PKEY col1 null error 
INSERT INTO test14_8(col0,col2) VALUES(3,3);
SELECT * from test14_8;
--PKEY col1 not unique error
INSERT INTO test14_8(col1) VALUES(1);
SELECT * from test14_8;
--ok
INSERT INTO test14_8(col1) VALUES(2);
SELECT * from test14_8;

--test14_9
SELECT * from test14_9;
--ok
INSERT INTO test14_9 VALUES(1, 1, 1);
SELECT * from test14_9;
--PKEY col1 null error 
INSERT INTO test14_9(col0,col2) VALUES(3,3);
SELECT * from test14_9;
--PKEY col1 null error 
INSERT INTO test14_9(col0,col2) VALUES(3,3);
SELECT * from test14_9;
--PKEY col1 not unique error
INSERT INTO test14_9(col0,col1) VALUES(3,1);
SELECT * from test14_9;
--not null constraint col0 error
INSERT INTO test14_9(col1,col2) VALUES(5,5);
SELECT * from test14_9;
--ok
INSERT INTO test14_9(col0,col1) VALUES(6,2);
SELECT * from test14_9;

--test14_10
SELECT * from test14_10;
--ok
INSERT INTO test14_10 VALUES(1, 1, 1);
SELECT * from test14_10;
--PKEY col1 null error 
INSERT INTO test14_10(col0,col2) VALUES(3,3);
SELECT * from test14_10;
--PKEY col1 null error 
INSERT INTO test14_10(col0,col2) VALUES(3,3);
SELECT * from test14_10;
--PKEY col1 not unique error
INSERT INTO test14_10(col1) VALUES(1);
SELECT * from test14_10;
--not null constraint col1 error
INSERT INTO test14_10(col0,col2) VALUES(5,5);
SELECT * from test14_10;
--ok
INSERT INTO test14_10(col1) VALUES(2);
SELECT * from test14_10;

--test14_11
SELECT * from test14_11;
--ok
INSERT INTO test14_11 VALUES(1, 1, 1);
SELECT * from test14_11;
--PKEY col1 null error 
INSERT INTO test14_11(col0,col2) VALUES(3,3);
SELECT * from test14_11;
--PKEY col1 null error 
INSERT INTO test14_11(col0,col2) VALUES(3,3);
SELECT * from test14_11;
--PKEY col1 not unique error
INSERT INTO test14_11(col1,col2) VALUES(1,3);
SELECT * from test14_11;
--not null constraint col2 error
INSERT INTO test14_11(col0,col1) VALUES(5,5);
SELECT * from test14_11;
--ok
INSERT INTO test14_11(col1,col2) VALUES(2,6);
SELECT * from test14_11;

--test14_12
SELECT * from test14_12;
--ok
INSERT INTO test14_12 VALUES(1, 1, 1);
SELECT * from test14_12;
--PKEY col1 null error 
INSERT INTO test14_12(col0,col2) VALUES(3,3);
SELECT * from test14_12;
--PKEY col1 null error 
INSERT INTO test14_12(col0,col2) VALUES(3,3);
SELECT * from test14_12;
--PKEY col1 not unique error
INSERT INTO test14_12(col0,col1) VALUES(3,1);
SELECT * from test14_12;
--not null constraint col0 error
INSERT INTO test14_12(col1,col2) VALUES(5,5);
SELECT * from test14_12;
--not null constraint col1 error
INSERT INTO test14_12(col0,col2) VALUES(5,5);
SELECT * from test14_12;
--ok
INSERT INTO test14_12(col0,col1) VALUES(6,2);
SELECT * from test14_12;

--test14_13
SELECT * from test14_13;
--ok
INSERT INTO test14_13 VALUES(1, 1, 1);
SELECT * from test14_13;
--PKEY col1 null error 
INSERT INTO test14_13(col0,col2) VALUES(3,3);
SELECT * from test14_13;
--PKEY col1 null error 
INSERT INTO test14_13(col0,col2) VALUES(3,3);
SELECT * from test14_13;
--PKEY col1 not unique error
INSERT INTO test14_13(col1,col2) VALUES(1,3);
SELECT * from test14_13;
--not null constraint col1 error
INSERT INTO test14_13(col0,col2) VALUES(5,5);
SELECT * from test14_13;
--not null constraint col2 error
INSERT INTO test14_13(col0,col1) VALUES(5,5);
SELECT * from test14_13;
--ok
INSERT INTO test14_13(col1,col2) VALUES(2,6);
SELECT * from test14_13;

--test14_14
SELECT * from test14_14;
--ok
INSERT INTO test14_14 VALUES(1, 1, 1);
SELECT * from test14_14;
--PKEY col1 null error 
INSERT INTO test14_14(col0,col2) VALUES(3,3);
SELECT * from test14_14;
--PKEY col1 null error 
INSERT INTO test14_14(col0,col2) VALUES(3,3);
SELECT * from test14_14;
--PKEY col1 not unique error
INSERT INTO test14_14(col0,col1,col2) VALUES(3,1,3);
SELECT * from test14_14;
--not null constraint col0 error
INSERT INTO test14_14(col1,col2) VALUES(5,5);
SELECT * from test14_14;
--not null constraint col2 error
INSERT INTO test14_14(col0,col1) VALUES(5,5);
SELECT * from test14_14;
--ok
INSERT INTO test14_14(col0,col1,col2) VALUES(6,2,6);
SELECT * from test14_14;

--test14_15
SELECT * from test14_15;
--ok
INSERT INTO test14_15 VALUES(1, 1, 1);
SELECT * from test14_15;
--PKEY col1 null error 
INSERT INTO test14_15(col0,col2) VALUES(3,3);
SELECT * from test14_15;
--PKEY col1 null error 
INSERT INTO test14_15(col0,col2) VALUES(3,3);
SELECT * from test14_15;
--PKEY col1 not unique error
INSERT INTO test14_15(col0,col1,col2) VALUES(3,1,3);
SELECT * from test14_15;
--not null constraint col0 error
INSERT INTO test14_15(col1,col2) VALUES(5,5);
SELECT * from test14_15;
--not null constraint col1 error
INSERT INTO test14_15(col0,col2) VALUES(5,5);
SELECT * from test14_15;
--not null constraint col2 error
INSERT INTO test14_15(col0,col1) VALUES(5,5);
SELECT * from test14_15;
--ok
INSERT INTO test14_15(col0,col1,col2) VALUES(6,2,6);
SELECT * from test14_15;

--test14_16
SELECT * from test14_16;
--ok
INSERT INTO test14_16 VALUES(1, 1, 1);
SELECT * from test14_16;
--PKEY col2 null error 
INSERT INTO test14_16(col0,col1) VALUES(3,3);
SELECT * from test14_16;
--PKEY col2 null error 
INSERT INTO test14_16(col0,col1) VALUES(3,3);
SELECT * from test14_16;
--PKEY col2 not unique error
INSERT INTO test14_16(col2) VALUES(1);
SELECT * from test14_16;
--ok
INSERT INTO test14_16(col2) VALUES(2);
SELECT * from test14_16;

--test14_17
SELECT * from test14_17;
--ok
INSERT INTO test14_17 VALUES(1, 1, 1);
SELECT * from test14_17;
--PKEY col2 null error 
INSERT INTO test14_17(col0,col1) VALUES(3,3);
SELECT * from test14_17;
--PKEY col2 null error 
INSERT INTO test14_17(col0,col1) VALUES(3,3);
SELECT * from test14_17;
--PKEY col2 not unique error
INSERT INTO test14_17(col0,col2) VALUES(3,1);
SELECT * from test14_17;
--not null constraint col0 error
INSERT INTO test14_17(col1,col2) VALUES(5,5);
SELECT * from test14_17;
--ok
INSERT INTO test14_17(col0,col2) VALUES(6,2);
SELECT * from test14_17;

--test14_18
SELECT * from test14_18;
--ok
INSERT INTO test14_18 VALUES(1, 1, 1);
SELECT * from test14_18;
--PKEY col2 null error 
INSERT INTO test14_18(col0,col1) VALUES(3,3);
SELECT * from test14_18;
--PKEY col2 null error 
INSERT INTO test14_18(col0,col1) VALUES(3,3);
SELECT * from test14_18;
--PKEY col2 not unique error
INSERT INTO test14_18(col1,col2) VALUES(3,1);
SELECT * from test14_18;
--not null constraint col1 error
INSERT INTO test14_18(col0,col2) VALUES(5,5);
SELECT * from test14_18;
--ok
INSERT INTO test14_18(col1,col2) VALUES(6,2);
SELECT * from test14_18;

--test14_19
SELECT * from test14_19;
--ok
INSERT INTO test14_19 VALUES(1, 1, 1);
SELECT * from test14_19;
--PKEY col2 null error 
INSERT INTO test14_19(col0,col1) VALUES(3,3);
SELECT * from test14_19;
--PKEY col2 null error 
INSERT INTO test14_19(col0,col1) VALUES(3,3);
SELECT * from test14_19;
--PKEY col2 not unique error
INSERT INTO test14_19(col2) VALUES(1);
SELECT * from test14_19;
--not null constraint col2 error
INSERT INTO test14_19(col0,col1) VALUES(5,5);
SELECT * from test14_19;
--ok
INSERT INTO test14_19(col2) VALUES(2);
SELECT * from test14_19;

--test14_20
SELECT * from test14_20;
--ok
INSERT INTO test14_20 VALUES(1, 1, 1);
SELECT * from test14_20;
--PKEY col2 null error 
INSERT INTO test14_20(col0,col1) VALUES(3,3);
SELECT * from test14_20;
--PKEY col2 null error 
INSERT INTO test14_20(col0,col1) VALUES(3,3);
SELECT * from test14_20;
--PKEY col2 not unique error
INSERT INTO test14_20(col0,col1,col2) VALUES(3,3,1);
SELECT * from test14_20;
--not null constraint col0 error
INSERT INTO test14_20(col1,col2) VALUES(5,5);
SELECT * from test14_20;
--not null constraint col1 error
INSERT INTO test14_20(col0,col2) VALUES(5,5);
SELECT * from test14_20;
--ok
INSERT INTO test14_20(col0,col1,col2) VALUES(6,6,2);
SELECT * from test14_20;

--test14_21
SELECT * from test14_21;
--ok
INSERT INTO test14_21 VALUES(1, 1, 1);
SELECT * from test14_21;
--PKEY col2 null error 
INSERT INTO test14_21(col0,col1) VALUES(3,3);
SELECT * from test14_21;
--PKEY col2 null error 
INSERT INTO test14_21(col0,col1) VALUES(3,3);
SELECT * from test14_21;
--PKEY col2 not unique error
INSERT INTO test14_21(col1,col2) VALUES(3,1);
SELECT * from test14_21;
--not null constraint col1 error
INSERT INTO test14_21(col0,col2) VALUES(5,5);
SELECT * from test14_21;
--not null constraint col2 error
INSERT INTO test14_21(col0,col1) VALUES(5,5);
SELECT * from test14_21;
--ok
INSERT INTO test14_21(col1,col2) VALUES(6,2);
SELECT * from test14_21;

--test14_22
SELECT * from test14_22;
--ok
INSERT INTO test14_22 VALUES(1, 1, 1);
SELECT * from test14_22;
--PKEY col2 null error 
INSERT INTO test14_22(col0,col1) VALUES(3,3);
SELECT * from test14_22;
--PKEY col2 null error 
INSERT INTO test14_22(col0,col1) VALUES(3,3);
SELECT * from test14_22;
--PKEY col2 not unique error
INSERT INTO test14_22(col0,col2) VALUES(3,1);
SELECT * from test14_22;
--not null constraint col0 error
INSERT INTO test14_22(col1,col2) VALUES(5,5);
SELECT * from test14_22;
--not null constraint col2 error
INSERT INTO test14_22(col0,col1) VALUES(5,5);
SELECT * from test14_22;
--ok
INSERT INTO test14_22(col0,col2) VALUES(6,2);
SELECT * from test14_22;

--test14_23
SELECT * from test14_23;
--ok
INSERT INTO test14_23 VALUES(1, 1, 1);
SELECT * from test14_23;
--PKEY col2 null error 
INSERT INTO test14_23(col0,col1) VALUES(3,3);
SELECT * from test14_23;
--PKEY col2 null error 
INSERT INTO test14_23(col0,col1) VALUES(3,3);
SELECT * from test14_23;
--PKEY col2 not unique error
INSERT INTO test14_23(col0,col1,col2) VALUES(3,3,1);
SELECT * from test14_23;
--not null constraint col0 error
INSERT INTO test14_23(col1,col2) VALUES(5,5);
SELECT * from test14_23;
--not null constraint col1 error
INSERT INTO test14_23(col0,col2) VALUES(5,5);
SELECT * from test14_23;
--not null constraint col2 error
INSERT INTO test14_23(col0,col1) VALUES(5,5);
SELECT * from test14_23;
--ok
INSERT INTO test14_23(col0,col1,col2) VALUES(6,6,2);
SELECT * from test14_23;

--test14_24
SELECT * from test14_24;
--ok
INSERT INTO test14_24 VALUES(1, 1, 1);
SELECT * from test14_24;
--PKEY col0 col1 null error 
INSERT INTO test14_24(col2) VALUES(3);
SELECT * from test14_24;
--PKEY col0 null error 
INSERT INTO test14_24(col1,col2) VALUES(3,3);
SELECT * from test14_24;
--PKEY col1 null error 
INSERT INTO test14_24(col0,col2) VALUES(3,3);
SELECT * from test14_24;
--PKEY col0 col1 not unique error
INSERT INTO test14_24(col0,col1) VALUES(1,1);
SELECT * from test14_24;
--ok
INSERT INTO test14_24(col0,col1) VALUES(2,2);
SELECT * from test14_24;

--test14_25
SELECT * from test14_25;
--ok
INSERT INTO test14_25 VALUES(1, 1, 1);
SELECT * from test14_25;
--PKEY col0 col1 null error 
INSERT INTO test14_25(col2) VALUES(3);
SELECT * from test14_25;
--PKEY col0 null error 
INSERT INTO test14_25(col1,col2) VALUES(3,3);
SELECT * from test14_25;
--PKEY col1 null error 
INSERT INTO test14_25(col0,col2) VALUES(3,3);
SELECT * from test14_25;
--PKEY col0 col1 not unique error
INSERT INTO test14_25(col0,col1) VALUES(1,1);
SELECT * from test14_25;
--not null constraint col0 error
INSERT INTO test14_25(col1,col2) VALUES(5,5);
SELECT * from test14_25;
--ok
INSERT INTO test14_25(col0,col1) VALUES(2,2);
SELECT * from test14_25;

--test14_26
SELECT * from test14_26;
--ok
INSERT INTO test14_26 VALUES(1, 1, 1);
SELECT * from test14_26;
--PKEY col0 col1 null error 
INSERT INTO test14_26(col2) VALUES(3);
SELECT * from test14_26;
--PKEY col0 null error 
INSERT INTO test14_26(col1,col2) VALUES(3,3);
SELECT * from test14_26;
--PKEY col1 null error 
INSERT INTO test14_26(col0,col2) VALUES(3,3);
SELECT * from test14_26;
--PKEY col0 col1 not unique error
INSERT INTO test14_26(col0,col1) VALUES(1,1);
SELECT * from test14_26;
--not null constraint col1 error
INSERT INTO test14_26(col0,col2) VALUES(5,5);
SELECT * from test14_26;
--ok
INSERT INTO test14_26(col0,col1) VALUES(2,2);
SELECT * from test14_26;

--test14_27
SELECT * from test14_27;
--ok
INSERT INTO test14_27 VALUES(1, 1, 1);
SELECT * from test14_27;
--PKEY col0 col1 null error 
INSERT INTO test14_27(col2) VALUES(3);
SELECT * from test14_27;
--PKEY col0 null error 
INSERT INTO test14_27(col1,col2) VALUES(3,3);
SELECT * from test14_27;
--PKEY col1 null error 
INSERT INTO test14_27(col0,col2) VALUES(3,3);
SELECT * from test14_27;
--PKEY col0 col1 not unique error
INSERT INTO test14_27(col0,col1,col2) VALUES(1,1,3);
SELECT * from test14_27;
--not null constraint col2 error
INSERT INTO test14_27(col0,col1) VALUES(5,5);
SELECT * from test14_27;
--ok
INSERT INTO test14_27(col0,col1,col2) VALUES(2,2,6);
SELECT * from test14_27;

--test14_28
SELECT * from test14_28;
--ok
INSERT INTO test14_28 VALUES(1, 1, 1);
SELECT * from test14_28;
--PKEY col0 col1 null error 
INSERT INTO test14_28(col2) VALUES(3);
SELECT * from test14_28;
--PKEY col0 null error 
INSERT INTO test14_28(col1,col2) VALUES(3,3);
SELECT * from test14_28;
--PKEY col1 null error 
INSERT INTO test14_28(col0,col2) VALUES(3,3);
SELECT * from test14_28;
--PKEY col0 col1 not unique error
INSERT INTO test14_28(col0,col1) VALUES(1,1);
SELECT * from test14_28;
--not null constraint col0 error
INSERT INTO test14_28(col1,col2) VALUES(5,5);
SELECT * from test14_28;
--not null constraint col1 error
INSERT INTO test14_28(col0,col2) VALUES(5,5);
SELECT * from test14_28;
--ok
INSERT INTO test14_28(col0,col1) VALUES(2,2);
SELECT * from test14_28;

--test14_29
SELECT * from test14_29;
--ok
INSERT INTO test14_29 VALUES(1, 1, 1);
SELECT * from test14_29;
--PKEY col0 col1 null error 
INSERT INTO test14_29(col2) VALUES(3);
SELECT * from test14_29;
--PKEY col0 null error 
INSERT INTO test14_29(col1,col2) VALUES(3,3);
SELECT * from test14_29;
--PKEY col1 null error 
INSERT INTO test14_29(col0,col2) VALUES(3,3);
SELECT * from test14_29;
--PKEY col0 col1 not unique error
INSERT INTO test14_29(col0,col1,col2) VALUES(1,1,3);
SELECT * from test14_29;
--not null constraint col1 error
INSERT INTO test14_29(col0,col2) VALUES(5,5);
SELECT * from test14_29;
--not null constraint col2 error
INSERT INTO test14_29(col0,col1) VALUES(5,5);
SELECT * from test14_29;
--ok
INSERT INTO test14_29(col0,col1,col2) VALUES(2,2,6);
SELECT * from test14_29;

--test14_30
SELECT * from test14_30;
--ok
INSERT INTO test14_30 VALUES(1, 1, 1);
SELECT * from test14_30;
--PKEY col0 col1 null error 
INSERT INTO test14_30(col2) VALUES(3);
SELECT * from test14_30;
--PKEY col0 null error 
INSERT INTO test14_30(col1,col2) VALUES(3,3);
SELECT * from test14_30;
--PKEY col1 null error 
INSERT INTO test14_30(col0,col2) VALUES(3,3);
SELECT * from test14_30;
--PKEY col0 col1 not unique error
INSERT INTO test14_30(col0,col1,col2) VALUES(1,1,3);
SELECT * from test14_30;
--not null constraint col0 error
INSERT INTO test14_30(col1,col2) VALUES(5,5);
SELECT * from test14_30;
--not null constraint col2 error
INSERT INTO test14_30(col0,col1) VALUES(5,5);
SELECT * from test14_30;
--ok
INSERT INTO test14_30(col0,col1,col2) VALUES(2,2,6);
SELECT * from test14_30;

--test14_31
SELECT * from test14_31;
--ok
INSERT INTO test14_31 VALUES(1, 1, 1);
SELECT * from test14_31;
--PKEY col0 col1 null error 
INSERT INTO test14_31(col2) VALUES(3);
SELECT * from test14_31;
--PKEY col0 null error 
INSERT INTO test14_31(col1,col2) VALUES(3,3);
SELECT * from test14_31;
--PKEY col1 null error 
INSERT INTO test14_31(col0,col2) VALUES(3,3);
SELECT * from test14_31;
--PKEY col0 col1 not unique error
INSERT INTO test14_31(col0,col1,col2) VALUES(1,1,3);
SELECT * from test14_31;
--not null constraint col0 error
INSERT INTO test14_31(col1,col2) VALUES(5,5);
SELECT * from test14_31;
--not null constraint col1 error
INSERT INTO test14_31(col0,col2) VALUES(5,5);
SELECT * from test14_31;
--not null constraint col2 error
INSERT INTO test14_31(col0,col1) VALUES(5,5);
SELECT * from test14_31;
--ok
INSERT INTO test14_31(col0,col1,col2) VALUES(2,2,6);
SELECT * from test14_31;

--test14_32
SELECT * from test14_32;
--ok
INSERT INTO test14_32 VALUES(1, 1, 1);
SELECT * from test14_32;
--PKEY col1 col2 null error 
INSERT INTO test14_32(col0) VALUES(3);
SELECT * from test14_32;
--PKEY col1 null error 
INSERT INTO test14_32(col0,col2) VALUES(3,3);
SELECT * from test14_32;
--PKEY col2 null error 
INSERT INTO test14_32(col0,col1) VALUES(3,3);
SELECT * from test14_32;
--PKEY col1 col2 not unique error
INSERT INTO test14_32(col1,col2) VALUES(1,1);
SELECT * from test14_32;
--ok
INSERT INTO test14_32(col1,col2) VALUES(2,2);
SELECT * from test14_32;

--test14_33
SELECT * from test14_33;
--ok
INSERT INTO test14_33 VALUES(1, 1, 1);
SELECT * from test14_33;
--PKEY col1 col2 null error 
INSERT INTO test14_33(col0) VALUES(3);
SELECT * from test14_33;
--PKEY col1 null error 
INSERT INTO test14_33(col0,col2) VALUES(3,3);
SELECT * from test14_33;
--PKEY col2 null error 
INSERT INTO test14_33(col0,col1) VALUES(3,3);
SELECT * from test14_33;
--PKEY col1 col2 not unique error
INSERT INTO test14_33(col0,col1,col2) VALUES(3,1,1);
SELECT * from test14_33;
--not null constraint col0 error
INSERT INTO test14_33(col1,col2) VALUES(5,5);
SELECT * from test14_33;
--ok
INSERT INTO test14_33(col0,col1,col2) VALUES(6,2,2);
SELECT * from test14_33;

--test14_34
SELECT * from test14_34;
--ok
INSERT INTO test14_34 VALUES(1, 1, 1);
SELECT * from test14_34;
--PKEY col1 col2 null error 
INSERT INTO test14_34(col0) VALUES(3);
SELECT * from test14_34;
--PKEY col1 null error 
INSERT INTO test14_34(col0,col2) VALUES(3,3);
SELECT * from test14_34;
--PKEY col2 null error 
INSERT INTO test14_34(col0,col1) VALUES(3,3);
SELECT * from test14_34;
--PKEY col1 col2 not unique error
INSERT INTO test14_34(col1,col2) VALUES(1,1);
SELECT * from test14_34;
--not null constraint col1 error
INSERT INTO test14_34(col0,col2) VALUES(5,5);
SELECT * from test14_34;
--ok
INSERT INTO test14_34(col1,col2) VALUES(2,2);
SELECT * from test14_34;

--test14_35
SELECT * from test14_35;
--ok
INSERT INTO test14_35 VALUES(1, 1, 1);
SELECT * from test14_35;
--PKEY col1 col2 null error 
INSERT INTO test14_35(col0) VALUES(3);
SELECT * from test14_35;
--PKEY col1 null error 
INSERT INTO test14_35(col0,col2) VALUES(3,3);
SELECT * from test14_35;
--PKEY col2 null error 
INSERT INTO test14_35(col0,col1) VALUES(3,3);
SELECT * from test14_35;
--PKEY col1 col2 not unique error
INSERT INTO test14_35(col1,col2) VALUES(1,1);
SELECT * from test14_35;
--not null constraint col2 error
INSERT INTO test14_35(col0,col1) VALUES(5,5);
SELECT * from test14_35;
--ok
INSERT INTO test14_35(col1,col2) VALUES(2,2);
SELECT * from test14_35;

--test14_36
SELECT * from test14_36;
--ok
INSERT INTO test14_36 VALUES(1, 1, 1);
SELECT * from test14_36;
--PKEY col1 col2 null error 
INSERT INTO test14_36(col0) VALUES(3);
SELECT * from test14_36;
--PKEY col1 null error 
INSERT INTO test14_36(col0,col2) VALUES(3,3);
SELECT * from test14_36;
--PKEY col2 null error 
INSERT INTO test14_36(col0,col1) VALUES(3,3);
SELECT * from test14_36;
--PKEY col1 col2 not unique error
INSERT INTO test14_36(col0,col1,col2) VALUES(3,1,1);
SELECT * from test14_36;
--not null constraint col0 error
INSERT INTO test14_36(col1,col2) VALUES(5,5);
SELECT * from test14_36;
--not null constraint col1 error
INSERT INTO test14_36(col0,col2) VALUES(5,5);
SELECT * from test14_36;
--ok
INSERT INTO test14_36(col0,col1,col2) VALUES(6,2,2);
SELECT * from test14_36;

--test14_37
SELECT * from test14_37;
--ok
INSERT INTO test14_37 VALUES(1, 1, 1);
SELECT * from test14_37;
--PKEY col1 col2 null error 
INSERT INTO test14_37(col0) VALUES(3);
SELECT * from test14_37;
--PKEY col1 null error 
INSERT INTO test14_37(col0,col2) VALUES(3,3);
SELECT * from test14_37;
--PKEY col2 null error 
INSERT INTO test14_37(col0,col1) VALUES(3,3);
SELECT * from test14_37;
--PKEY col1 col2 not unique error
INSERT INTO test14_37(col1,col2) VALUES(1,1);
SELECT * from test14_37;
--not null constraint col1 error
INSERT INTO test14_37(col0,col2) VALUES(5,5);
SELECT * from test14_37;
--not null constraint col2 error
INSERT INTO test14_37(col0,col1) VALUES(5,5);
SELECT * from test14_37;
--ok
INSERT INTO test14_37(col1,col2) VALUES(2,2);
SELECT * from test14_37;

--test14_38
SELECT * from test14_38;
--ok
INSERT INTO test14_38 VALUES(1, 1, 1);
SELECT * from test14_38;
--PKEY col1 col2 null error 
INSERT INTO test14_38(col0) VALUES(3);
SELECT * from test14_38;
--PKEY col1 null error 
INSERT INTO test14_38(col0,col2) VALUES(3,3);
SELECT * from test14_38;
--PKEY col2 null error 
INSERT INTO test14_38(col0,col1) VALUES(3,3);
SELECT * from test14_38;
--PKEY col1 col2 not unique error
INSERT INTO test14_38(col0,col1,col2) VALUES(3,1,1);
SELECT * from test14_38;
--not null constraint col0 error
INSERT INTO test14_38(col1,col2) VALUES(5,5);
SELECT * from test14_38;
--not null constraint col2 error
INSERT INTO test14_38(col0,col1) VALUES(5,5);
SELECT * from test14_38;
--ok
INSERT INTO test14_38(col0,col1,col2) VALUES(6,2,2);
SELECT * from test14_38;

--test14_39
SELECT * from test14_39;
--ok
INSERT INTO test14_39 VALUES(1, 1, 1);
SELECT * from test14_39;
--PKEY col1 col2 null error 
INSERT INTO test14_39(col0) VALUES(3);
SELECT * from test14_39;
--PKEY col1 null error 
INSERT INTO test14_39(col0,col2) VALUES(3,3);
SELECT * from test14_39;
--PKEY col2 null error 
INSERT INTO test14_39(col0,col1) VALUES(3,3);
SELECT * from test14_39;
--PKEY col1 col2 not unique error
INSERT INTO test14_39(col0,col1,col2) VALUES(3,1,1);
SELECT * from test14_39;
--not null constraint col0 error
INSERT INTO test14_39(col1,col2) VALUES(5,5);
SELECT * from test14_39;
--not null constraint col1 error
INSERT INTO test14_39(col0,col2) VALUES(5,5);
SELECT * from test14_39;
--not null constraint col2 error
INSERT INTO test14_39(col0,col1) VALUES(5,5);
SELECT * from test14_39;
--ok
INSERT INTO test14_39(col0,col1,col2) VALUES(6,2,2);
SELECT * from test14_39;

--test14_40
SELECT * from test14_40;
--ok
INSERT INTO test14_40 VALUES(1, 1, 1);
SELECT * from test14_40;
--PKEY col0 col2 null error 
INSERT INTO test14_40(col1) VALUES(3);
SELECT * from test14_40;
--PKEY col0 null error 
INSERT INTO test14_40(col1,col2) VALUES(3,3);
SELECT * from test14_40;
--PKEY col2 null error 
INSERT INTO test14_40(col0,col1) VALUES(3,3);
SELECT * from test14_40;
--PKEY col0 col2 not unique error
INSERT INTO test14_40(col0,col2) VALUES(1,1);
SELECT * from test14_40;
--ok
INSERT INTO test14_40(col0,col2) VALUES(2,2);
SELECT * from test14_40;

--test14_41
SELECT * from test14_41;
--ok
INSERT INTO test14_41 VALUES(1, 1, 1);
SELECT * from test14_41;
--PKEY col0 col2 null error 
INSERT INTO test14_41(col1) VALUES(3);
SELECT * from test14_41;
--PKEY col0 null error 
INSERT INTO test14_41(col1,col2) VALUES(3,3);
SELECT * from test14_41;
--PKEY col2 null error 
INSERT INTO test14_41(col0,col1) VALUES(3,3);
SELECT * from test14_41;
--PKEY col0 col2 not unique error
INSERT INTO test14_41(col0,col2) VALUES(1,1);
SELECT * from test14_41;
--not null constraint col0 error
INSERT INTO test14_41(col1,col2) VALUES(5,5);
SELECT * from test14_41;
--ok
INSERT INTO test14_41(col0,col2) VALUES(2,2);
SELECT * from test14_41;

--test14_42
SELECT * from test14_42;
--ok
INSERT INTO test14_42 VALUES(1, 1, 1);
SELECT * from test14_42;
--PKEY col0 col2 null error 
INSERT INTO test14_42(col1) VALUES(3);
SELECT * from test14_42;
--PKEY col0 null error 
INSERT INTO test14_42(col1,col2) VALUES(3,3);
SELECT * from test14_42;
--PKEY col2 null error 
INSERT INTO test14_42(col0,col1) VALUES(3,3);
SELECT * from test14_42;
--PKEY col0 col2 not unique error
INSERT INTO test14_42(col0,col1,col2) VALUES(1,3,1);
SELECT * from test14_42;
--not null constraint col1 error
INSERT INTO test14_42(col0,col2) VALUES(5,5);
SELECT * from test14_42;
--ok
INSERT INTO test14_42(col0,col1,col2) VALUES(2,6,2);
SELECT * from test14_42;

--test14_43
SELECT * from test14_43;
--ok
INSERT INTO test14_43 VALUES(1, 1, 1);
SELECT * from test14_43;
--PKEY col0 col2 null error 
INSERT INTO test14_43(col1) VALUES(3);
SELECT * from test14_43;
--PKEY col0 null error 
INSERT INTO test14_43(col1,col2) VALUES(3,3);
SELECT * from test14_43;
--PKEY col2 null error 
INSERT INTO test14_43(col0,col1) VALUES(3,3);
SELECT * from test14_43;
--PKEY col0 col2 not unique error
INSERT INTO test14_43(col0,col2) VALUES(1,1);
SELECT * from test14_43;
--not null constraint col2 error
INSERT INTO test14_43(col0,col1) VALUES(5,5);
SELECT * from test14_43;
--ok
INSERT INTO test14_43(col0,col2) VALUES(2,2);
SELECT * from test14_43;

--test14_44
SELECT * from test14_44;
--ok
INSERT INTO test14_44 VALUES(1, 1, 1);
SELECT * from test14_44;
--PKEY col0 col2 null error 
INSERT INTO test14_44(col1) VALUES(3);
SELECT * from test14_44;
--PKEY col0 null error 
INSERT INTO test14_44(col1,col2) VALUES(3,3);
SELECT * from test14_44;
--PKEY col2 null error 
INSERT INTO test14_44(col0,col1) VALUES(3,3);
SELECT * from test14_44;
--PKEY col0 col2 not unique error
INSERT INTO test14_44(col0,col1,col2) VALUES(1,3,1);
SELECT * from test14_44;
--not null constraint col0 error
INSERT INTO test14_44(col1,col2) VALUES(5,5);
SELECT * from test14_44;
--not null constraint col1 error
INSERT INTO test14_44(col0,col2) VALUES(5,5);
SELECT * from test14_44;
--ok
INSERT INTO test14_44(col0,col1,col2) VALUES(2,6,2);
SELECT * from test14_44;

--test14_45
SELECT * from test14_45;
--ok
INSERT INTO test14_45 VALUES(1, 1, 1);
SELECT * from test14_45;
--PKEY col0 col2 null error 
INSERT INTO test14_45(col1) VALUES(3);
SELECT * from test14_45;
--PKEY col0 null error 
INSERT INTO test14_45(col1,col2) VALUES(3,3);
SELECT * from test14_45;
--PKEY col2 null error 
INSERT INTO test14_45(col0,col1) VALUES(3,3);
SELECT * from test14_45;
--PKEY col0 col2 not unique error
INSERT INTO test14_45(col0,col1,col2) VALUES(1,3,1);
SELECT * from test14_45;
--not null constraint col1 error
INSERT INTO test14_45(col0,col2) VALUES(5,5);
SELECT * from test14_45;
--not null constraint col2 error
INSERT INTO test14_45(col0,col1) VALUES(5,5);
SELECT * from test14_45;
--ok
INSERT INTO test14_45(col0,col1,col2) VALUES(2,6,2);
SELECT * from test14_45;

--test14_46
SELECT * from test14_46;
--ok
INSERT INTO test14_46 VALUES(1, 1, 1);
SELECT * from test14_46;
--PKEY col0 col2 null error 
INSERT INTO test14_46(col1) VALUES(3);
SELECT * from test14_46;
--PKEY col0 null error 
INSERT INTO test14_46(col1,col2) VALUES(3,3);
SELECT * from test14_46;
--PKEY col2 null error 
INSERT INTO test14_46(col0,col1) VALUES(3,3);
SELECT * from test14_46;
--PKEY col0 col2 not unique error
INSERT INTO test14_46(col0,col2) VALUES(1,1);
SELECT * from test14_46;
--not null constraint col0 error
INSERT INTO test14_46(col1,col2) VALUES(5,5);
SELECT * from test14_46;
--not null constraint col2 error
INSERT INTO test14_46(col0,col1) VALUES(5,5);
SELECT * from test14_46;
--ok
INSERT INTO test14_46(col0,col2) VALUES(2,2);
SELECT * from test14_46;

--test14_47
SELECT * from test14_47;
--ok
INSERT INTO test14_47 VALUES(1, 1, 1);
SELECT * from test14_47;
--PKEY col0 col2 null error 
INSERT INTO test14_47(col1) VALUES(3);
SELECT * from test14_47;
--PKEY col0 null error 
INSERT INTO test14_47(col1,col2) VALUES(3,3);
SELECT * from test14_47;
--PKEY col2 null error 
INSERT INTO test14_47(col0,col1) VALUES(3,3);
SELECT * from test14_47;
--PKEY col0 col2 not unique error
INSERT INTO test14_47(col0,col1,col2) VALUES(1,3,1);
SELECT * from test14_47;
--not null constraint col0 error
INSERT INTO test14_47(col1,col2) VALUES(5,5);
SELECT * from test14_47;
--not null constraint col1 error
INSERT INTO test14_47(col0,col2) VALUES(5,5);
SELECT * from test14_47;
--not null constraint col2 error
INSERT INTO test14_47(col0,col1) VALUES(5,5);
SELECT * from test14_47;
--ok
INSERT INTO test14_47(col0,col1,col2) VALUES(2,6,2);
SELECT * from test14_47;

--test14_48
SELECT * from test14_48;
--ok
INSERT INTO test14_48 VALUES(1, 1, 1);
SELECT * from test14_48;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_48() VALUES();
SELECT * from test14_48;
--PKEY col0 null error 
INSERT INTO test14_48(col1,col2) VALUES(3,3);
SELECT * from test14_48;
--PKEY col1 null error 
INSERT INTO test14_48(col0,col2) VALUES(3,3);
SELECT * from test14_48;
--PKEY col2 null error 
INSERT INTO test14_48(col0,col1) VALUES(3,3);
SELECT * from test14_48;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_48(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_48;
--ok
INSERT INTO test14_48(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_48;

--test14_49
SELECT * from test14_49;
--ok
INSERT INTO test14_49 VALUES(1, 1, 1);
SELECT * from test14_49;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_49() VALUES();
SELECT * from test14_49;
--PKEY col0 null error 
INSERT INTO test14_49(col1,col2) VALUES(3,3);
SELECT * from test14_49;
--PKEY col1 null error 
INSERT INTO test14_49(col0,col2) VALUES(3,3);
SELECT * from test14_49;
--PKEY col2 null error 
INSERT INTO test14_49(col0,col1) VALUES(3,3);
SELECT * from test14_49;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_49(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_49;
--not null constraint col0 error
INSERT INTO test14_49(col1,col2) VALUES(5,5);
SELECT * from test14_49;
--ok
INSERT INTO test14_49(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_49;

--test14_50
SELECT * from test14_50;
--ok
INSERT INTO test14_50 VALUES(1, 1, 1);
SELECT * from test14_50;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_50() VALUES();
SELECT * from test14_50;
--PKEY col0 null error 
INSERT INTO test14_50(col1,col2) VALUES(3,3);
SELECT * from test14_50;
--PKEY col1 null error 
INSERT INTO test14_50(col0,col2) VALUES(3,3);
SELECT * from test14_50;
--PKEY col2 null error 
INSERT INTO test14_50(col0,col1) VALUES(3,3);
SELECT * from test14_50;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_50(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_50;
--not null constraint col1 error
INSERT INTO test14_50(col0,col2) VALUES(5,5);
SELECT * from test14_50;
--ok
INSERT INTO test14_50(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_50;

--test14_51
SELECT * from test14_51;
--ok
INSERT INTO test14_51 VALUES(1, 1, 1);
SELECT * from test14_51;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_51() VALUES();
SELECT * from test14_51;
--PKEY col0 null error 
INSERT INTO test14_51(col1,col2) VALUES(3,3);
SELECT * from test14_51;
--PKEY col1 null error 
INSERT INTO test14_51(col0,col2) VALUES(3,3);
SELECT * from test14_51;
--PKEY col2 null error 
INSERT INTO test14_51(col0,col1) VALUES(3,3);
SELECT * from test14_51;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_51(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_51;
--not null constraint col2 error
INSERT INTO test14_51(col0,col1) VALUES(5,5);
SELECT * from test14_51;
--ok
INSERT INTO test14_51(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_51;

--test14_52
SELECT * from test14_52;
--ok
INSERT INTO test14_52 VALUES(1, 1, 1);
SELECT * from test14_52;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_52() VALUES();
SELECT * from test14_52;
--PKEY col0 null error 
INSERT INTO test14_52(col1,col2) VALUES(3,3);
SELECT * from test14_52;
--PKEY col1 null error 
INSERT INTO test14_52(col0,col2) VALUES(3,3);
SELECT * from test14_52;
--PKEY col2 null error 
INSERT INTO test14_52(col0,col1) VALUES(3,3);
SELECT * from test14_52;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_52(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_52;
--not null constraint col0 error
INSERT INTO test14_52(col1,col2) VALUES(5,5);
SELECT * from test14_52;
--not null constraint col1 error
INSERT INTO test14_52(col0,col2) VALUES(5,5);
SELECT * from test14_52;
--ok
INSERT INTO test14_52(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_52;

--test14_53
SELECT * from test14_53;
--ok
INSERT INTO test14_53 VALUES(1, 1, 1);
SELECT * from test14_53;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_53() VALUES();
SELECT * from test14_53;
--PKEY col0 null error 
INSERT INTO test14_53(col1,col2) VALUES(3,3);
SELECT * from test14_53;
--PKEY col1 null error 
INSERT INTO test14_53(col0,col2) VALUES(3,3);
SELECT * from test14_53;
--PKEY col2 null error 
INSERT INTO test14_53(col0,col1) VALUES(3,3);
SELECT * from test14_53;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_53(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_53;
--not null constraint col1 error
INSERT INTO test14_53(col0,col2) VALUES(5,5);
SELECT * from test14_53;
--not null constraint col2 error
INSERT INTO test14_53(col0,col1) VALUES(5,5);
SELECT * from test14_53;
--ok
INSERT INTO test14_53(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_53;

--test14_54
SELECT * from test14_54;
--ok
INSERT INTO test14_54 VALUES(1, 1, 1);
SELECT * from test14_54;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_54() VALUES();
SELECT * from test14_54;
--PKEY col0 null error 
INSERT INTO test14_54(col1,col2) VALUES(3,3);
SELECT * from test14_54;
--PKEY col1 null error 
INSERT INTO test14_54(col0,col2) VALUES(3,3);
SELECT * from test14_54;
--PKEY col2 null error 
INSERT INTO test14_54(col0,col1) VALUES(3,3);
SELECT * from test14_54;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_54(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_54;
--not null constraint col0 error
INSERT INTO test14_54(col1,col2) VALUES(5,5);
SELECT * from test14_54;
--not null constraint col2 error
INSERT INTO test14_54(col0,col1) VALUES(5,5);
SELECT * from test14_54;
--ok
INSERT INTO test14_54(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_54;

--test14_55
SELECT * from test14_55;
--ok
INSERT INTO test14_55 VALUES(1, 1, 1);
SELECT * from test14_55;
--PKEY col0 col1 col2 null error 
INSERT INTO test14_55() VALUES();
SELECT * from test14_55;
--PKEY col0 null error 
INSERT INTO test14_55(col1,col2) VALUES(3,3);
SELECT * from test14_55;
--PKEY col1 null error 
INSERT INTO test14_55(col0,col2) VALUES(3,3);
SELECT * from test14_55;
--PKEY col2 null error 
INSERT INTO test14_55(col0,col1) VALUES(3,3);
SELECT * from test14_55;
--PKEY col0 col1 col2 not unique error
INSERT INTO test14_55(col0,col1,col2) VALUES(1,1,1);
SELECT * from test14_55;
--not null constraint col0 error
INSERT INTO test14_55(col1,col2) VALUES(5,5);
SELECT * from test14_55;
--not null constraint col1 error
INSERT INTO test14_55(col0,col2) VALUES(5,5);
SELECT * from test14_55;
--not null constraint col2 error
INSERT INTO test14_55(col0,col1) VALUES(5,5);
SELECT * from test14_55;
--ok
INSERT INTO test14_55(col0,col1,col2) VALUES(2,2,2);
SELECT * from test14_55;

