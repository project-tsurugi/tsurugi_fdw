CREATE EXTENSION IF NOT EXISTS ogawayama_fdw;
CREATE SERVER IF NOT EXISTS ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;
CREATE TABLE test13_0 (
col0 int PRIMARY KEY,col1 int ,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_1 (
col0 int PRIMARY KEY,col1 int ,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_2 (
col0 int PRIMARY KEY,col1 int NOT NULL,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_3 (
col0 int PRIMARY KEY,col1 int NOT NULL,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_4 (
col0 int ,col1 int PRIMARY KEY,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_5 (
col0 int NOT NULL,col1 int PRIMARY KEY,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_6 (
col0 int ,col1 int PRIMARY KEY,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_7 (
col0 int NOT NULL,col1 int PRIMARY KEY,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_8 (
col0 int ,col1 int ,col2 int PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_9 (
col0 int ,col1 int NOT NULL,col2 int PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_10 (
col0 int NOT NULL,col1 int ,col2 int PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_11 (
col0 int NOT NULL,col1 int NOT NULL,col2 int PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_12 (
col0 int NOT NULL PRIMARY KEY,col1 int ,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_13 (
col0 int NOT NULL PRIMARY KEY,col1 int ,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_14 (
col0 int NOT NULL PRIMARY KEY,col1 int NOT NULL,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_15 (
col0 int NOT NULL PRIMARY KEY,col1 int NOT NULL,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_16 (
col0 int ,col1 int NOT NULL PRIMARY KEY,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_17 (
col0 int NOT NULL,col1 int NOT NULL PRIMARY KEY,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_18 (
col0 int ,col1 int NOT NULL PRIMARY KEY,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_19 (
col0 int NOT NULL,col1 int NOT NULL PRIMARY KEY,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_20 (
col0 int ,col1 int ,col2 int NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_21 (
col0 int ,col1 int NOT NULL,col2 int NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_22 (
col0 int NOT NULL,col1 int ,col2 int NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_23 (
col0 int NOT NULL,col1 int NOT NULL,col2 int NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE test13_24 (
col0 int PRIMARY KEY NOT NULL,col1 int ,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_25 (
col0 int PRIMARY KEY NOT NULL,col1 int ,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_26 (
col0 int PRIMARY KEY NOT NULL,col1 int NOT NULL,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_27 (
col0 int PRIMARY KEY NOT NULL,col1 int NOT NULL,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_28 (
col0 int ,col1 int PRIMARY KEY NOT NULL,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_29 (
col0 int NOT NULL,col1 int PRIMARY KEY NOT NULL,col2 int 
) tablespace tsurugi;
CREATE TABLE test13_30 (
col0 int ,col1 int PRIMARY KEY NOT NULL,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_31 (
col0 int NOT NULL,col1 int PRIMARY KEY NOT NULL,col2 int NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_32 (
col0 int ,col1 int ,col2 int PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_33 (
col0 int ,col1 int NOT NULL,col2 int PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_34 (
col0 int NOT NULL,col1 int ,col2 int PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE test13_35 (
col0 int NOT NULL,col1 int NOT NULL,col2 int PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE FOREIGN TABLE test13_0 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_1 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_2 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_3 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_4 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_5 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_6 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_7 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_8 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_9 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_10 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_11 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_12 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_13 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_14 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_15 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_16 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_17 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_18 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_19 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_20 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_21 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_22 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_23 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_24 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_25 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_26 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_27 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_28 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_29 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_30 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_31 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_32 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_33 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_34 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
CREATE FOREIGN TABLE test13_35 (
col0 int ,col1 int ,col2 int 
) SERVER ogawayama;
--test13_0
SELECT * from test13_0;
--ok
INSERT INTO test13_0 VALUES(1, 1, 1);
SELECT * from test13_0;
--PKEY col0 null error 
INSERT INTO test13_0(col1, col2) VALUES(3, 3);
SELECT * from test13_0;
--PKEY col0 not unique error
INSERT INTO test13_0(col0) VALUES(1);
SELECT * from test13_0;
--ok
INSERT INTO test13_0(col0) VALUES(2);
SELECT * from test13_0;

--test13_1
SELECT * from test13_1;
--ok
INSERT INTO test13_1 VALUES(1, 1, 1);
SELECT * from test13_1;
--PKEY col0 null error 
INSERT INTO test13_1(col1, col2) VALUES(3, 3);
SELECT * from test13_1;
--PKEY col0 not unique error
INSERT INTO test13_1(col0,col2) VALUES(1,3);
SELECT * from test13_1;
--not null constraint col2 error
INSERT INTO test13_1(col0,col1) VALUES(5,5);
SELECT * from test13_1;
--ok
INSERT INTO test13_1(col0,col2) VALUES(2,6);
SELECT * from test13_1;

--test13_2
SELECT * from test13_2;
--ok
INSERT INTO test13_2 VALUES(1, 1, 1);
SELECT * from test13_2;
--PKEY col0 null error 
INSERT INTO test13_2(col1, col2) VALUES(3, 3);
SELECT * from test13_2;
--PKEY col0 not unique error
INSERT INTO test13_2(col0,col1) VALUES(1,3);
SELECT * from test13_2;
--not null constraint col1 error
INSERT INTO test13_2(col0,col2) VALUES(5,5);
SELECT * from test13_2;
--ok
INSERT INTO test13_2(col0,col1) VALUES(2,6);
SELECT * from test13_2;

--test13_3
SELECT * from test13_3;
--ok
INSERT INTO test13_3 VALUES(1, 1, 1);
SELECT * from test13_3;
--PKEY col0 null error 
INSERT INTO test13_3(col1, col2) VALUES(3, 3);
SELECT * from test13_3;
--PKEY col0 not unique error
INSERT INTO test13_3(col0,col1,col2) VALUES(1,3,3);
SELECT * from test13_3;
--not null constraint col1 error
INSERT INTO test13_3(col0,col2) VALUES(5,5);
SELECT * from test13_3;
--not null constraint col2 error
INSERT INTO test13_3(col0,col1) VALUES(5,5);
SELECT * from test13_3;
--ok
INSERT INTO test13_3(col0,col1,col2) VALUES(2,6,6);
SELECT * from test13_3;

--test13_4
SELECT * from test13_4;
--ok
INSERT INTO test13_4 VALUES(1, 1, 1);
SELECT * from test13_4;
--PKEY col1 null error 
INSERT INTO test13_4(col2, col0) VALUES(3, 3);
SELECT * from test13_4;
--PKEY col1 not unique error
INSERT INTO test13_4(col1) VALUES(1);
SELECT * from test13_4;
--ok
INSERT INTO test13_4(col1) VALUES(2);
SELECT * from test13_4;

--test13_5
SELECT * from test13_5;
--ok
INSERT INTO test13_5 VALUES(1, 1, 1);
SELECT * from test13_5;
--PKEY col1 null error 
INSERT INTO test13_5(col2, col0) VALUES(3, 3);
SELECT * from test13_5;
--PKEY col1 not unique error
INSERT INTO test13_5(col0,col1) VALUES(3,1);
SELECT * from test13_5;
--not null constraint col0 error
INSERT INTO test13_5(col1,col2) VALUES(5,5);
SELECT * from test13_5;
--ok
INSERT INTO test13_5(col0,col1) VALUES(6,2);
SELECT * from test13_5;

--test13_6
SELECT * from test13_6;
--ok
INSERT INTO test13_6 VALUES(1, 1, 1);
SELECT * from test13_6;
--PKEY col1 null error 
INSERT INTO test13_6(col2, col0) VALUES(3, 3);
SELECT * from test13_6;
--PKEY col1 not unique error
INSERT INTO test13_6(col1,col2) VALUES(1,3);
SELECT * from test13_6;
--not null constraint col2 error
INSERT INTO test13_6(col0,col1) VALUES(5,5);
SELECT * from test13_6;
--ok
INSERT INTO test13_6(col1,col2) VALUES(2,6);
SELECT * from test13_6;

--test13_7
SELECT * from test13_7;
--ok
INSERT INTO test13_7 VALUES(1, 1, 1);
SELECT * from test13_7;
--PKEY col1 null error 
INSERT INTO test13_7(col2, col0) VALUES(3, 3);
SELECT * from test13_7;
--PKEY col1 not unique error
INSERT INTO test13_7(col0,col1,col2) VALUES(3,1,3);
SELECT * from test13_7;
--not null constraint col0 error
INSERT INTO test13_7(col1,col2) VALUES(5,5);
SELECT * from test13_7;
--not null constraint col2 error
INSERT INTO test13_7(col0,col1) VALUES(5,5);
SELECT * from test13_7;
--ok
INSERT INTO test13_7(col0,col1,col2) VALUES(6,2,6);
SELECT * from test13_7;

--test13_8
SELECT * from test13_8;
--ok
INSERT INTO test13_8 VALUES(1, 1, 1);
SELECT * from test13_8;
--PKEY col2 null error 
INSERT INTO test13_8(col0, col1) VALUES(3, 3);
SELECT * from test13_8;
--PKEY col2 not unique error
INSERT INTO test13_8(col2) VALUES(1);
SELECT * from test13_8;
--ok
INSERT INTO test13_8(col2) VALUES(2);
SELECT * from test13_8;

--test13_9
SELECT * from test13_9;
--ok
INSERT INTO test13_9 VALUES(1, 1, 1);
SELECT * from test13_9;
--PKEY col2 null error 
INSERT INTO test13_9(col0, col1) VALUES(3, 3);
SELECT * from test13_9;
--PKEY col2 not unique error
INSERT INTO test13_9(col1,col2) VALUES(3,1);
SELECT * from test13_9;
--not null constraint col1 error
INSERT INTO test13_9(col0,col2) VALUES(5,5);
SELECT * from test13_9;
--ok
INSERT INTO test13_9(col1,col2) VALUES(6,2);
SELECT * from test13_9;

--test13_10
SELECT * from test13_10;
--ok
INSERT INTO test13_10 VALUES(1, 1, 1);
SELECT * from test13_10;
--PKEY col2 null error 
INSERT INTO test13_10(col0, col1) VALUES(3, 3);
SELECT * from test13_10;
--PKEY col2 not unique error
INSERT INTO test13_10(col0,col2) VALUES(3,1);
SELECT * from test13_10;
--not null constraint col0 error
INSERT INTO test13_10(col1,col2) VALUES(5,5);
SELECT * from test13_10;
--ok
INSERT INTO test13_10(col0,col2) VALUES(6,2);
SELECT * from test13_10;

--test13_11
SELECT * from test13_11;
--ok
INSERT INTO test13_11 VALUES(1, 1, 1);
SELECT * from test13_11;
--PKEY col2 null error 
INSERT INTO test13_11(col0, col1) VALUES(3, 3);
SELECT * from test13_11;
--PKEY col2 not unique error
INSERT INTO test13_11(col0,col1,col2) VALUES(3,3,1);
SELECT * from test13_11;
--not null constraint col0 error
INSERT INTO test13_11(col1,col2) VALUES(5,5);
SELECT * from test13_11;
--not null constraint col1 error
INSERT INTO test13_11(col0,col2) VALUES(5,5);
SELECT * from test13_11;
--ok
INSERT INTO test13_11(col0,col1,col2) VALUES(6,6,2);
SELECT * from test13_11;

--test13_12
SELECT * from test13_12;
--ok
INSERT INTO test13_12 VALUES(1, 1, 1);
SELECT * from test13_12;
--PKEY col0 null error 
INSERT INTO test13_12(col1, col2) VALUES(3, 3);
SELECT * from test13_12;
--PKEY col0 not unique error
INSERT INTO test13_12(col0) VALUES(1);
SELECT * from test13_12;
--ok
INSERT INTO test13_12(col0) VALUES(2);
SELECT * from test13_12;

--test13_13
SELECT * from test13_13;
--ok
INSERT INTO test13_13 VALUES(1, 1, 1);
SELECT * from test13_13;
--PKEY col0 null error 
INSERT INTO test13_13(col1, col2) VALUES(3, 3);
SELECT * from test13_13;
--PKEY col0 not unique error
INSERT INTO test13_13(col0,col2) VALUES(1,3);
SELECT * from test13_13;
--not null constraint col2 error
INSERT INTO test13_13(col0,col1) VALUES(5,5);
SELECT * from test13_13;
--ok
INSERT INTO test13_13(col0,col2) VALUES(2,6);
SELECT * from test13_13;

--test13_14
SELECT * from test13_14;
--ok
INSERT INTO test13_14 VALUES(1, 1, 1);
SELECT * from test13_14;
--PKEY col0 null error 
INSERT INTO test13_14(col1, col2) VALUES(3, 3);
SELECT * from test13_14;
--PKEY col0 not unique error
INSERT INTO test13_14(col0,col1) VALUES(1,3);
SELECT * from test13_14;
--not null constraint col1 error
INSERT INTO test13_14(col0,col2) VALUES(5,5);
SELECT * from test13_14;
--ok
INSERT INTO test13_14(col0,col1) VALUES(2,6);
SELECT * from test13_14;

--test13_15
SELECT * from test13_15;
--ok
INSERT INTO test13_15 VALUES(1, 1, 1);
SELECT * from test13_15;
--PKEY col0 null error 
INSERT INTO test13_15(col1, col2) VALUES(3, 3);
SELECT * from test13_15;
--PKEY col0 not unique error
INSERT INTO test13_15(col0,col1,col2) VALUES(1,3,3);
SELECT * from test13_15;
--not null constraint col1 error
INSERT INTO test13_15(col0,col2) VALUES(5,5);
SELECT * from test13_15;
--not null constraint col2 error
INSERT INTO test13_15(col0,col1) VALUES(5,5);
SELECT * from test13_15;
--ok
INSERT INTO test13_15(col0,col1,col2) VALUES(2,6,6);
SELECT * from test13_15;

--test13_16
SELECT * from test13_16;
--ok
INSERT INTO test13_16 VALUES(1, 1, 1);
SELECT * from test13_16;
--PKEY col1 null error 
INSERT INTO test13_16(col2, col0) VALUES(3, 3);
SELECT * from test13_16;
--PKEY col1 not unique error
INSERT INTO test13_16(col1) VALUES(1);
SELECT * from test13_16;
--ok
INSERT INTO test13_16(col1) VALUES(2);
SELECT * from test13_16;

--test13_17
SELECT * from test13_17;
--ok
INSERT INTO test13_17 VALUES(1, 1, 1);
SELECT * from test13_17;
--PKEY col1 null error 
INSERT INTO test13_17(col2, col0) VALUES(3, 3);
SELECT * from test13_17;
--PKEY col1 not unique error
INSERT INTO test13_17(col0,col1) VALUES(3,1);
SELECT * from test13_17;
--not null constraint col0 error
INSERT INTO test13_17(col1,col2) VALUES(5,5);
SELECT * from test13_17;
--ok
INSERT INTO test13_17(col0,col1) VALUES(6,2);
SELECT * from test13_17;

--test13_18
SELECT * from test13_18;
--ok
INSERT INTO test13_18 VALUES(1, 1, 1);
SELECT * from test13_18;
--PKEY col1 null error 
INSERT INTO test13_18(col2, col0) VALUES(3, 3);
SELECT * from test13_18;
--PKEY col1 not unique error
INSERT INTO test13_18(col1,col2) VALUES(1,3);
SELECT * from test13_18;
--not null constraint col2 error
INSERT INTO test13_18(col0,col1) VALUES(5,5);
SELECT * from test13_18;
--ok
INSERT INTO test13_18(col1,col2) VALUES(2,6);
SELECT * from test13_18;

--test13_19
SELECT * from test13_19;
--ok
INSERT INTO test13_19 VALUES(1, 1, 1);
SELECT * from test13_19;
--PKEY col1 null error 
INSERT INTO test13_19(col2, col0) VALUES(3, 3);
SELECT * from test13_19;
--PKEY col1 not unique error
INSERT INTO test13_19(col0,col1,col2) VALUES(3,1,3);
SELECT * from test13_19;
--not null constraint col0 error
INSERT INTO test13_19(col1,col2) VALUES(5,5);
SELECT * from test13_19;
--not null constraint col2 error
INSERT INTO test13_19(col0,col1) VALUES(5,5);
SELECT * from test13_19;
--ok
INSERT INTO test13_19(col0,col1,col2) VALUES(6,2,6);
SELECT * from test13_19;

--test13_20
SELECT * from test13_20;
--ok
INSERT INTO test13_20 VALUES(1, 1, 1);
SELECT * from test13_20;
--PKEY col2 null error 
INSERT INTO test13_20(col0, col1) VALUES(3, 3);
SELECT * from test13_20;
--PKEY col2 not unique error
INSERT INTO test13_20(col2) VALUES(1);
SELECT * from test13_20;
--ok
INSERT INTO test13_20(col2) VALUES(2);
SELECT * from test13_20;

--test13_21
SELECT * from test13_21;
--ok
INSERT INTO test13_21 VALUES(1, 1, 1);
SELECT * from test13_21;
--PKEY col2 null error 
INSERT INTO test13_21(col0, col1) VALUES(3, 3);
SELECT * from test13_21;
--PKEY col2 not unique error
INSERT INTO test13_21(col1,col2) VALUES(3,1);
SELECT * from test13_21;
--not null constraint col1 error
INSERT INTO test13_21(col0,col2) VALUES(5,5);
SELECT * from test13_21;
--ok
INSERT INTO test13_21(col1,col2) VALUES(6,2);
SELECT * from test13_21;

--test13_22
SELECT * from test13_22;
--ok
INSERT INTO test13_22 VALUES(1, 1, 1);
SELECT * from test13_22;
--PKEY col2 null error 
INSERT INTO test13_22(col0, col1) VALUES(3, 3);
SELECT * from test13_22;
--PKEY col2 not unique error
INSERT INTO test13_22(col0,col2) VALUES(3,1);
SELECT * from test13_22;
--not null constraint col0 error
INSERT INTO test13_22(col1,col2) VALUES(5,5);
SELECT * from test13_22;
--ok
INSERT INTO test13_22(col0,col2) VALUES(6,2);
SELECT * from test13_22;

--test13_23
SELECT * from test13_23;
--ok
INSERT INTO test13_23 VALUES(1, 1, 1);
SELECT * from test13_23;
--PKEY col2 null error 
INSERT INTO test13_23(col0, col1) VALUES(3, 3);
SELECT * from test13_23;
--PKEY col2 not unique error
INSERT INTO test13_23(col0,col1,col2) VALUES(3,3,1);
SELECT * from test13_23;
--not null constraint col0 error
INSERT INTO test13_23(col1,col2) VALUES(5,5);
SELECT * from test13_23;
--not null constraint col1 error
INSERT INTO test13_23(col0,col2) VALUES(5,5);
SELECT * from test13_23;
--ok
INSERT INTO test13_23(col0,col1,col2) VALUES(6,6,2);
SELECT * from test13_23;

--test13_24
SELECT * from test13_24;
--ok
INSERT INTO test13_24 VALUES(1, 1, 1);
SELECT * from test13_24;
--PKEY col0 null error 
INSERT INTO test13_24(col1, col2) VALUES(3, 3);
SELECT * from test13_24;
--PKEY col0 not unique error
INSERT INTO test13_24(col0) VALUES(1);
SELECT * from test13_24;
--ok
INSERT INTO test13_24(col0) VALUES(2);
SELECT * from test13_24;

--test13_25
SELECT * from test13_25;
--ok
INSERT INTO test13_25 VALUES(1, 1, 1);
SELECT * from test13_25;
--PKEY col0 null error 
INSERT INTO test13_25(col1, col2) VALUES(3, 3);
SELECT * from test13_25;
--PKEY col0 not unique error
INSERT INTO test13_25(col0,col2) VALUES(1,3);
SELECT * from test13_25;
--not null constraint col2 error
INSERT INTO test13_25(col0,col1) VALUES(5,5);
SELECT * from test13_25;
--ok
INSERT INTO test13_25(col0,col2) VALUES(2,6);
SELECT * from test13_25;

--test13_26
SELECT * from test13_26;
--ok
INSERT INTO test13_26 VALUES(1, 1, 1);
SELECT * from test13_26;
--PKEY col0 null error 
INSERT INTO test13_26(col1, col2) VALUES(3, 3);
SELECT * from test13_26;
--PKEY col0 not unique error
INSERT INTO test13_26(col0,col1) VALUES(1,3);
SELECT * from test13_26;
--not null constraint col1 error
INSERT INTO test13_26(col0,col2) VALUES(5,5);
SELECT * from test13_26;
--ok
INSERT INTO test13_26(col0,col1) VALUES(2,6);
SELECT * from test13_26;

--test13_27
SELECT * from test13_27;
--ok
INSERT INTO test13_27 VALUES(1, 1, 1);
SELECT * from test13_27;
--PKEY col0 null error 
INSERT INTO test13_27(col1, col2) VALUES(3, 3);
SELECT * from test13_27;
--PKEY col0 not unique error
INSERT INTO test13_27(col0,col1,col2) VALUES(1,3,3);
SELECT * from test13_27;
--not null constraint col1 error
INSERT INTO test13_27(col0,col2) VALUES(5,5);
SELECT * from test13_27;
--not null constraint col2 error
INSERT INTO test13_27(col0,col1) VALUES(5,5);
SELECT * from test13_27;
--ok
INSERT INTO test13_27(col0,col1,col2) VALUES(2,6,6);
SELECT * from test13_27;

--test13_28
SELECT * from test13_28;
--ok
INSERT INTO test13_28 VALUES(1, 1, 1);
SELECT * from test13_28;
--PKEY col1 null error 
INSERT INTO test13_28(col2, col0) VALUES(3, 3);
SELECT * from test13_28;
--PKEY col1 not unique error
INSERT INTO test13_28(col1) VALUES(1);
SELECT * from test13_28;
--ok
INSERT INTO test13_28(col1) VALUES(2);
SELECT * from test13_28;

--test13_29
SELECT * from test13_29;
--ok
INSERT INTO test13_29 VALUES(1, 1, 1);
SELECT * from test13_29;
--PKEY col1 null error 
INSERT INTO test13_29(col2, col0) VALUES(3, 3);
SELECT * from test13_29;
--PKEY col1 not unique error
INSERT INTO test13_29(col0,col1) VALUES(3,1);
SELECT * from test13_29;
--not null constraint col0 error
INSERT INTO test13_29(col1,col2) VALUES(5,5);
SELECT * from test13_29;
--ok
INSERT INTO test13_29(col0,col1) VALUES(6,2);
SELECT * from test13_29;

--test13_30
SELECT * from test13_30;
--ok
INSERT INTO test13_30 VALUES(1, 1, 1);
SELECT * from test13_30;
--PKEY col1 null error 
INSERT INTO test13_30(col2, col0) VALUES(3, 3);
SELECT * from test13_30;
--PKEY col1 not unique error
INSERT INTO test13_30(col1,col2) VALUES(1,3);
SELECT * from test13_30;
--not null constraint col2 error
INSERT INTO test13_30(col0,col1) VALUES(5,5);
SELECT * from test13_30;
--ok
INSERT INTO test13_30(col1,col2) VALUES(2,6);
SELECT * from test13_30;

--test13_31
SELECT * from test13_31;
--ok
INSERT INTO test13_31 VALUES(1, 1, 1);
SELECT * from test13_31;
--PKEY col1 null error 
INSERT INTO test13_31(col2, col0) VALUES(3, 3);
SELECT * from test13_31;
--PKEY col1 not unique error
INSERT INTO test13_31(col0,col1,col2) VALUES(3,1,3);
SELECT * from test13_31;
--not null constraint col0 error
INSERT INTO test13_31(col1,col2) VALUES(5,5);
SELECT * from test13_31;
--not null constraint col2 error
INSERT INTO test13_31(col0,col1) VALUES(5,5);
SELECT * from test13_31;
--ok
INSERT INTO test13_31(col0,col1,col2) VALUES(6,2,6);
SELECT * from test13_31;

--test13_32
SELECT * from test13_32;
--ok
INSERT INTO test13_32 VALUES(1, 1, 1);
SELECT * from test13_32;
--PKEY col2 null error 
INSERT INTO test13_32(col0, col1) VALUES(3, 3);
SELECT * from test13_32;
--PKEY col2 not unique error
INSERT INTO test13_32(col2) VALUES(1);
SELECT * from test13_32;
--ok
INSERT INTO test13_32(col2) VALUES(2);
SELECT * from test13_32;

--test13_33
SELECT * from test13_33;
--ok
INSERT INTO test13_33 VALUES(1, 1, 1);
SELECT * from test13_33;
--PKEY col2 null error 
INSERT INTO test13_33(col0, col1) VALUES(3, 3);
SELECT * from test13_33;
--PKEY col2 not unique error
INSERT INTO test13_33(col1,col2) VALUES(3,1);
SELECT * from test13_33;
--not null constraint col1 error
INSERT INTO test13_33(col0,col2) VALUES(5,5);
SELECT * from test13_33;
--ok
INSERT INTO test13_33(col1,col2) VALUES(6,2);
SELECT * from test13_33;

--test13_34
SELECT * from test13_34;
--ok
INSERT INTO test13_34 VALUES(1, 1, 1);
SELECT * from test13_34;
--PKEY col2 null error 
INSERT INTO test13_34(col0, col1) VALUES(3, 3);
SELECT * from test13_34;
--PKEY col2 not unique error
INSERT INTO test13_34(col0,col2) VALUES(3,1);
SELECT * from test13_34;
--not null constraint col0 error
INSERT INTO test13_34(col1,col2) VALUES(5,5);
SELECT * from test13_34;
--ok
INSERT INTO test13_34(col0,col2) VALUES(6,2);
SELECT * from test13_34;

--test13_35
SELECT * from test13_35;
--ok
INSERT INTO test13_35 VALUES(1, 1, 1);
SELECT * from test13_35;
--PKEY col2 null error 
INSERT INTO test13_35(col0, col1) VALUES(3, 3);
SELECT * from test13_35;
--PKEY col2 not unique error
INSERT INTO test13_35(col0,col1,col2) VALUES(3,3,1);
SELECT * from test13_35;
--not null constraint col0 error
INSERT INTO test13_35(col1,col2) VALUES(5,5);
SELECT * from test13_35;
--not null constraint col1 error
INSERT INTO test13_35(col0,col2) VALUES(5,5);
SELECT * from test13_35;
--ok
INSERT INTO test13_35(col0,col1,col2) VALUES(6,6,2);
SELECT * from test13_35;

