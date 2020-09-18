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

CREATE TABLE bigint_test13_0 (
col0 bigint PRIMARY KEY,col1 bigint ,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_1 (
col0 bigint PRIMARY KEY,col1 bigint ,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_2 (
col0 bigint PRIMARY KEY,col1 bigint NOT NULL,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_3 (
col0 bigint PRIMARY KEY,col1 bigint NOT NULL,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_4 (
col0 bigint ,col1 bigint PRIMARY KEY,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_5 (
col0 bigint NOT NULL,col1 bigint PRIMARY KEY,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_6 (
col0 bigint ,col1 bigint PRIMARY KEY,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_7 (
col0 bigint NOT NULL,col1 bigint PRIMARY KEY,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_8 (
col0 bigint ,col1 bigint ,col2 bigint PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_9 (
col0 bigint ,col1 bigint NOT NULL,col2 bigint PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_10 (
col0 bigint NOT NULL,col1 bigint ,col2 bigint PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_11 (
col0 bigint NOT NULL,col1 bigint NOT NULL,col2 bigint PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_12 (
col0 bigint NOT NULL PRIMARY KEY,col1 bigint ,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_13 (
col0 bigint NOT NULL PRIMARY KEY,col1 bigint ,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_14 (
col0 bigint NOT NULL PRIMARY KEY,col1 bigint NOT NULL,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_15 (
col0 bigint NOT NULL PRIMARY KEY,col1 bigint NOT NULL,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_16 (
col0 bigint ,col1 bigint NOT NULL PRIMARY KEY,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_17 (
col0 bigint NOT NULL,col1 bigint NOT NULL PRIMARY KEY,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_18 (
col0 bigint ,col1 bigint NOT NULL PRIMARY KEY,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_19 (
col0 bigint NOT NULL,col1 bigint NOT NULL PRIMARY KEY,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_20 (
col0 bigint ,col1 bigint ,col2 bigint NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_21 (
col0 bigint ,col1 bigint NOT NULL,col2 bigint NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_22 (
col0 bigint NOT NULL,col1 bigint ,col2 bigint NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_23 (
col0 bigint NOT NULL,col1 bigint NOT NULL,col2 bigint NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE bigint_test13_24 (
col0 bigint PRIMARY KEY NOT NULL,col1 bigint ,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_25 (
col0 bigint PRIMARY KEY NOT NULL,col1 bigint ,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_26 (
col0 bigint PRIMARY KEY NOT NULL,col1 bigint NOT NULL,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_27 (
col0 bigint PRIMARY KEY NOT NULL,col1 bigint NOT NULL,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_28 (
col0 bigint ,col1 bigint PRIMARY KEY NOT NULL,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_29 (
col0 bigint NOT NULL,col1 bigint PRIMARY KEY NOT NULL,col2 bigint 
) tablespace tsurugi;
CREATE TABLE bigint_test13_30 (
col0 bigint ,col1 bigint PRIMARY KEY NOT NULL,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_31 (
col0 bigint NOT NULL,col1 bigint PRIMARY KEY NOT NULL,col2 bigint NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_32 (
col0 bigint ,col1 bigint ,col2 bigint PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_33 (
col0 bigint ,col1 bigint NOT NULL,col2 bigint PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_34 (
col0 bigint NOT NULL,col1 bigint ,col2 bigint PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE bigint_test13_35 (
col0 bigint NOT NULL,col1 bigint NOT NULL,col2 bigint PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE FOREIGN TABLE bigint_test13_0 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_1 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_2 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_3 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_4 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_5 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_6 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_7 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_8 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_9 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_10 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_11 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_12 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_13 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_14 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_15 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_16 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_17 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_18 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_19 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_20 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_21 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_22 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_23 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_24 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_25 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_26 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_27 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_28 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_29 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_30 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_31 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_32 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_33 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_34 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test13_35 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
--bigint_test13_0
SELECT * from bigint_test13_0;
--ok
INSERT INTO bigint_test13_0 VALUES(1, 1, 1);
SELECT * from bigint_test13_0;
--PKEY col0 null error 
INSERT INTO bigint_test13_0(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_0;
--PKEY col0 not unique error
INSERT INTO bigint_test13_0(col0) VALUES(1);
SELECT * from bigint_test13_0;
--ok
INSERT INTO bigint_test13_0(col0) VALUES(2);
SELECT * from bigint_test13_0;

--bigint_test13_1
SELECT * from bigint_test13_1;
--ok
INSERT INTO bigint_test13_1 VALUES(1, 1, 1);
SELECT * from bigint_test13_1;
--PKEY col0 null error 
INSERT INTO bigint_test13_1(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_1;
--PKEY col0 not unique error
INSERT INTO bigint_test13_1(col0,col2) VALUES(1,3);
SELECT * from bigint_test13_1;
--not null constrabigint col2 error
INSERT INTO bigint_test13_1(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_1;
--ok
INSERT INTO bigint_test13_1(col0,col2) VALUES(2,6);
SELECT * from bigint_test13_1;

--bigint_test13_2
SELECT * from bigint_test13_2;
--ok
INSERT INTO bigint_test13_2 VALUES(1, 1, 1);
SELECT * from bigint_test13_2;
--PKEY col0 null error 
INSERT INTO bigint_test13_2(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_2;
--PKEY col0 not unique error
INSERT INTO bigint_test13_2(col0,col1) VALUES(1,3);
SELECT * from bigint_test13_2;
--not null constrabigint col1 error
INSERT INTO bigint_test13_2(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_2;
--ok
INSERT INTO bigint_test13_2(col0,col1) VALUES(2,6);
SELECT * from bigint_test13_2;

--bigint_test13_3
SELECT * from bigint_test13_3;
--ok
INSERT INTO bigint_test13_3 VALUES(1, 1, 1);
SELECT * from bigint_test13_3;
--PKEY col0 null error 
INSERT INTO bigint_test13_3(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_3;
--PKEY col0 not unique error
INSERT INTO bigint_test13_3(col0,col1,col2) VALUES(1,3,3);
SELECT * from bigint_test13_3;
--not null constrabigint col1 error
INSERT INTO bigint_test13_3(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_3;
--not null constrabigint col2 error
INSERT INTO bigint_test13_3(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_3;
--ok
INSERT INTO bigint_test13_3(col0,col1,col2) VALUES(2,6,6);
SELECT * from bigint_test13_3;

--bigint_test13_4
SELECT * from bigint_test13_4;
--ok
INSERT INTO bigint_test13_4 VALUES(1, 1, 1);
SELECT * from bigint_test13_4;
--PKEY col1 null error 
INSERT INTO bigint_test13_4(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_4;
--PKEY col1 not unique error
INSERT INTO bigint_test13_4(col1) VALUES(1);
SELECT * from bigint_test13_4;
--ok
INSERT INTO bigint_test13_4(col1) VALUES(2);
SELECT * from bigint_test13_4;

--bigint_test13_5
SELECT * from bigint_test13_5;
--ok
INSERT INTO bigint_test13_5 VALUES(1, 1, 1);
SELECT * from bigint_test13_5;
--PKEY col1 null error 
INSERT INTO bigint_test13_5(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_5;
--PKEY col1 not unique error
INSERT INTO bigint_test13_5(col0,col1) VALUES(3,1);
SELECT * from bigint_test13_5;
--not null constrabigint col0 error
INSERT INTO bigint_test13_5(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_5;
--ok
INSERT INTO bigint_test13_5(col0,col1) VALUES(6,2);
SELECT * from bigint_test13_5;

--bigint_test13_6
SELECT * from bigint_test13_6;
--ok
INSERT INTO bigint_test13_6 VALUES(1, 1, 1);
SELECT * from bigint_test13_6;
--PKEY col1 null error 
INSERT INTO bigint_test13_6(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_6;
--PKEY col1 not unique error
INSERT INTO bigint_test13_6(col1,col2) VALUES(1,3);
SELECT * from bigint_test13_6;
--not null constrabigint col2 error
INSERT INTO bigint_test13_6(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_6;
--ok
INSERT INTO bigint_test13_6(col1,col2) VALUES(2,6);
SELECT * from bigint_test13_6;

--bigint_test13_7
SELECT * from bigint_test13_7;
--ok
INSERT INTO bigint_test13_7 VALUES(1, 1, 1);
SELECT * from bigint_test13_7;
--PKEY col1 null error 
INSERT INTO bigint_test13_7(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_7;
--PKEY col1 not unique error
INSERT INTO bigint_test13_7(col0,col1,col2) VALUES(3,1,3);
SELECT * from bigint_test13_7;
--not null constrabigint col0 error
INSERT INTO bigint_test13_7(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_7;
--not null constrabigint col2 error
INSERT INTO bigint_test13_7(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_7;
--ok
INSERT INTO bigint_test13_7(col0,col1,col2) VALUES(6,2,6);
SELECT * from bigint_test13_7;

--bigint_test13_8
SELECT * from bigint_test13_8;
--ok
INSERT INTO bigint_test13_8 VALUES(1, 1, 1);
SELECT * from bigint_test13_8;
--PKEY col2 null error 
INSERT INTO bigint_test13_8(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_8;
--PKEY col2 not unique error
INSERT INTO bigint_test13_8(col2) VALUES(1);
SELECT * from bigint_test13_8;
--ok
INSERT INTO bigint_test13_8(col2) VALUES(2);
SELECT * from bigint_test13_8;

--bigint_test13_9
SELECT * from bigint_test13_9;
--ok
INSERT INTO bigint_test13_9 VALUES(1, 1, 1);
SELECT * from bigint_test13_9;
--PKEY col2 null error 
INSERT INTO bigint_test13_9(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_9;
--PKEY col2 not unique error
INSERT INTO bigint_test13_9(col1,col2) VALUES(3,1);
SELECT * from bigint_test13_9;
--not null constrabigint col1 error
INSERT INTO bigint_test13_9(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_9;
--ok
INSERT INTO bigint_test13_9(col1,col2) VALUES(6,2);
SELECT * from bigint_test13_9;

--bigint_test13_10
SELECT * from bigint_test13_10;
--ok
INSERT INTO bigint_test13_10 VALUES(1, 1, 1);
SELECT * from bigint_test13_10;
--PKEY col2 null error 
INSERT INTO bigint_test13_10(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_10;
--PKEY col2 not unique error
INSERT INTO bigint_test13_10(col0,col2) VALUES(3,1);
SELECT * from bigint_test13_10;
--not null constrabigint col0 error
INSERT INTO bigint_test13_10(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_10;
--ok
INSERT INTO bigint_test13_10(col0,col2) VALUES(6,2);
SELECT * from bigint_test13_10;

--bigint_test13_11
SELECT * from bigint_test13_11;
--ok
INSERT INTO bigint_test13_11 VALUES(1, 1, 1);
SELECT * from bigint_test13_11;
--PKEY col2 null error 
INSERT INTO bigint_test13_11(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_11;
--PKEY col2 not unique error
INSERT INTO bigint_test13_11(col0,col1,col2) VALUES(3,3,1);
SELECT * from bigint_test13_11;
--not null constrabigint col0 error
INSERT INTO bigint_test13_11(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_11;
--not null constrabigint col1 error
INSERT INTO bigint_test13_11(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_11;
--ok
INSERT INTO bigint_test13_11(col0,col1,col2) VALUES(6,6,2);
SELECT * from bigint_test13_11;

--bigint_test13_12
SELECT * from bigint_test13_12;
--ok
INSERT INTO bigint_test13_12 VALUES(1, 1, 1);
SELECT * from bigint_test13_12;
--PKEY col0 null error 
INSERT INTO bigint_test13_12(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_12;
--PKEY col0 not unique error
INSERT INTO bigint_test13_12(col0) VALUES(1);
SELECT * from bigint_test13_12;
--ok
INSERT INTO bigint_test13_12(col0) VALUES(2);
SELECT * from bigint_test13_12;

--bigint_test13_13
SELECT * from bigint_test13_13;
--ok
INSERT INTO bigint_test13_13 VALUES(1, 1, 1);
SELECT * from bigint_test13_13;
--PKEY col0 null error 
INSERT INTO bigint_test13_13(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_13;
--PKEY col0 not unique error
INSERT INTO bigint_test13_13(col0,col2) VALUES(1,3);
SELECT * from bigint_test13_13;
--not null constrabigint col2 error
INSERT INTO bigint_test13_13(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_13;
--ok
INSERT INTO bigint_test13_13(col0,col2) VALUES(2,6);
SELECT * from bigint_test13_13;

--bigint_test13_14
SELECT * from bigint_test13_14;
--ok
INSERT INTO bigint_test13_14 VALUES(1, 1, 1);
SELECT * from bigint_test13_14;
--PKEY col0 null error 
INSERT INTO bigint_test13_14(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_14;
--PKEY col0 not unique error
INSERT INTO bigint_test13_14(col0,col1) VALUES(1,3);
SELECT * from bigint_test13_14;
--not null constrabigint col1 error
INSERT INTO bigint_test13_14(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_14;
--ok
INSERT INTO bigint_test13_14(col0,col1) VALUES(2,6);
SELECT * from bigint_test13_14;

--bigint_test13_15
SELECT * from bigint_test13_15;
--ok
INSERT INTO bigint_test13_15 VALUES(1, 1, 1);
SELECT * from bigint_test13_15;
--PKEY col0 null error 
INSERT INTO bigint_test13_15(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_15;
--PKEY col0 not unique error
INSERT INTO bigint_test13_15(col0,col1,col2) VALUES(1,3,3);
SELECT * from bigint_test13_15;
--not null constrabigint col1 error
INSERT INTO bigint_test13_15(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_15;
--not null constrabigint col2 error
INSERT INTO bigint_test13_15(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_15;
--ok
INSERT INTO bigint_test13_15(col0,col1,col2) VALUES(2,6,6);
SELECT * from bigint_test13_15;

--bigint_test13_16
SELECT * from bigint_test13_16;
--ok
INSERT INTO bigint_test13_16 VALUES(1, 1, 1);
SELECT * from bigint_test13_16;
--PKEY col1 null error 
INSERT INTO bigint_test13_16(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_16;
--PKEY col1 not unique error
INSERT INTO bigint_test13_16(col1) VALUES(1);
SELECT * from bigint_test13_16;
--ok
INSERT INTO bigint_test13_16(col1) VALUES(2);
SELECT * from bigint_test13_16;

--bigint_test13_17
SELECT * from bigint_test13_17;
--ok
INSERT INTO bigint_test13_17 VALUES(1, 1, 1);
SELECT * from bigint_test13_17;
--PKEY col1 null error 
INSERT INTO bigint_test13_17(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_17;
--PKEY col1 not unique error
INSERT INTO bigint_test13_17(col0,col1) VALUES(3,1);
SELECT * from bigint_test13_17;
--not null constrabigint col0 error
INSERT INTO bigint_test13_17(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_17;
--ok
INSERT INTO bigint_test13_17(col0,col1) VALUES(6,2);
SELECT * from bigint_test13_17;

--bigint_test13_18
SELECT * from bigint_test13_18;
--ok
INSERT INTO bigint_test13_18 VALUES(1, 1, 1);
SELECT * from bigint_test13_18;
--PKEY col1 null error 
INSERT INTO bigint_test13_18(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_18;
--PKEY col1 not unique error
INSERT INTO bigint_test13_18(col1,col2) VALUES(1,3);
SELECT * from bigint_test13_18;
--not null constrabigint col2 error
INSERT INTO bigint_test13_18(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_18;
--ok
INSERT INTO bigint_test13_18(col1,col2) VALUES(2,6);
SELECT * from bigint_test13_18;

--bigint_test13_19
SELECT * from bigint_test13_19;
--ok
INSERT INTO bigint_test13_19 VALUES(1, 1, 1);
SELECT * from bigint_test13_19;
--PKEY col1 null error 
INSERT INTO bigint_test13_19(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_19;
--PKEY col1 not unique error
INSERT INTO bigint_test13_19(col0,col1,col2) VALUES(3,1,3);
SELECT * from bigint_test13_19;
--not null constrabigint col0 error
INSERT INTO bigint_test13_19(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_19;
--not null constrabigint col2 error
INSERT INTO bigint_test13_19(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_19;
--ok
INSERT INTO bigint_test13_19(col0,col1,col2) VALUES(6,2,6);
SELECT * from bigint_test13_19;

--bigint_test13_20
SELECT * from bigint_test13_20;
--ok
INSERT INTO bigint_test13_20 VALUES(1, 1, 1);
SELECT * from bigint_test13_20;
--PKEY col2 null error 
INSERT INTO bigint_test13_20(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_20;
--PKEY col2 not unique error
INSERT INTO bigint_test13_20(col2) VALUES(1);
SELECT * from bigint_test13_20;
--ok
INSERT INTO bigint_test13_20(col2) VALUES(2);
SELECT * from bigint_test13_20;

--bigint_test13_21
SELECT * from bigint_test13_21;
--ok
INSERT INTO bigint_test13_21 VALUES(1, 1, 1);
SELECT * from bigint_test13_21;
--PKEY col2 null error 
INSERT INTO bigint_test13_21(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_21;
--PKEY col2 not unique error
INSERT INTO bigint_test13_21(col1,col2) VALUES(3,1);
SELECT * from bigint_test13_21;
--not null constrabigint col1 error
INSERT INTO bigint_test13_21(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_21;
--ok
INSERT INTO bigint_test13_21(col1,col2) VALUES(6,2);
SELECT * from bigint_test13_21;

--bigint_test13_22
SELECT * from bigint_test13_22;
--ok
INSERT INTO bigint_test13_22 VALUES(1, 1, 1);
SELECT * from bigint_test13_22;
--PKEY col2 null error 
INSERT INTO bigint_test13_22(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_22;
--PKEY col2 not unique error
INSERT INTO bigint_test13_22(col0,col2) VALUES(3,1);
SELECT * from bigint_test13_22;
--not null constrabigint col0 error
INSERT INTO bigint_test13_22(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_22;
--ok
INSERT INTO bigint_test13_22(col0,col2) VALUES(6,2);
SELECT * from bigint_test13_22;

--bigint_test13_23
SELECT * from bigint_test13_23;
--ok
INSERT INTO bigint_test13_23 VALUES(1, 1, 1);
SELECT * from bigint_test13_23;
--PKEY col2 null error 
INSERT INTO bigint_test13_23(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_23;
--PKEY col2 not unique error
INSERT INTO bigint_test13_23(col0,col1,col2) VALUES(3,3,1);
SELECT * from bigint_test13_23;
--not null constrabigint col0 error
INSERT INTO bigint_test13_23(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_23;
--not null constrabigint col1 error
INSERT INTO bigint_test13_23(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_23;
--ok
INSERT INTO bigint_test13_23(col0,col1,col2) VALUES(6,6,2);
SELECT * from bigint_test13_23;

--bigint_test13_24
SELECT * from bigint_test13_24;
--ok
INSERT INTO bigint_test13_24 VALUES(1, 1, 1);
SELECT * from bigint_test13_24;
--PKEY col0 null error 
INSERT INTO bigint_test13_24(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_24;
--PKEY col0 not unique error
INSERT INTO bigint_test13_24(col0) VALUES(1);
SELECT * from bigint_test13_24;
--ok
INSERT INTO bigint_test13_24(col0) VALUES(2);
SELECT * from bigint_test13_24;

--bigint_test13_25
SELECT * from bigint_test13_25;
--ok
INSERT INTO bigint_test13_25 VALUES(1, 1, 1);
SELECT * from bigint_test13_25;
--PKEY col0 null error 
INSERT INTO bigint_test13_25(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_25;
--PKEY col0 not unique error
INSERT INTO bigint_test13_25(col0,col2) VALUES(1,3);
SELECT * from bigint_test13_25;
--not null constrabigint col2 error
INSERT INTO bigint_test13_25(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_25;
--ok
INSERT INTO bigint_test13_25(col0,col2) VALUES(2,6);
SELECT * from bigint_test13_25;

--bigint_test13_26
SELECT * from bigint_test13_26;
--ok
INSERT INTO bigint_test13_26 VALUES(1, 1, 1);
SELECT * from bigint_test13_26;
--PKEY col0 null error 
INSERT INTO bigint_test13_26(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_26;
--PKEY col0 not unique error
INSERT INTO bigint_test13_26(col0,col1) VALUES(1,3);
SELECT * from bigint_test13_26;
--not null constrabigint col1 error
INSERT INTO bigint_test13_26(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_26;
--ok
INSERT INTO bigint_test13_26(col0,col1) VALUES(2,6);
SELECT * from bigint_test13_26;

--bigint_test13_27
SELECT * from bigint_test13_27;
--ok
INSERT INTO bigint_test13_27 VALUES(1, 1, 1);
SELECT * from bigint_test13_27;
--PKEY col0 null error 
INSERT INTO bigint_test13_27(col1, col2) VALUES(3, 3);
SELECT * from bigint_test13_27;
--PKEY col0 not unique error
INSERT INTO bigint_test13_27(col0,col1,col2) VALUES(1,3,3);
SELECT * from bigint_test13_27;
--not null constrabigint col1 error
INSERT INTO bigint_test13_27(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_27;
--not null constrabigint col2 error
INSERT INTO bigint_test13_27(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_27;
--ok
INSERT INTO bigint_test13_27(col0,col1,col2) VALUES(2,6,6);
SELECT * from bigint_test13_27;

--bigint_test13_28
SELECT * from bigint_test13_28;
--ok
INSERT INTO bigint_test13_28 VALUES(1, 1, 1);
SELECT * from bigint_test13_28;
--PKEY col1 null error 
INSERT INTO bigint_test13_28(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_28;
--PKEY col1 not unique error
INSERT INTO bigint_test13_28(col1) VALUES(1);
SELECT * from bigint_test13_28;
--ok
INSERT INTO bigint_test13_28(col1) VALUES(2);
SELECT * from bigint_test13_28;

--bigint_test13_29
SELECT * from bigint_test13_29;
--ok
INSERT INTO bigint_test13_29 VALUES(1, 1, 1);
SELECT * from bigint_test13_29;
--PKEY col1 null error 
INSERT INTO bigint_test13_29(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_29;
--PKEY col1 not unique error
INSERT INTO bigint_test13_29(col0,col1) VALUES(3,1);
SELECT * from bigint_test13_29;
--not null constrabigint col0 error
INSERT INTO bigint_test13_29(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_29;
--ok
INSERT INTO bigint_test13_29(col0,col1) VALUES(6,2);
SELECT * from bigint_test13_29;

--bigint_test13_30
SELECT * from bigint_test13_30;
--ok
INSERT INTO bigint_test13_30 VALUES(1, 1, 1);
SELECT * from bigint_test13_30;
--PKEY col1 null error 
INSERT INTO bigint_test13_30(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_30;
--PKEY col1 not unique error
INSERT INTO bigint_test13_30(col1,col2) VALUES(1,3);
SELECT * from bigint_test13_30;
--not null constrabigint col2 error
INSERT INTO bigint_test13_30(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_30;
--ok
INSERT INTO bigint_test13_30(col1,col2) VALUES(2,6);
SELECT * from bigint_test13_30;

--bigint_test13_31
SELECT * from bigint_test13_31;
--ok
INSERT INTO bigint_test13_31 VALUES(1, 1, 1);
SELECT * from bigint_test13_31;
--PKEY col1 null error 
INSERT INTO bigint_test13_31(col2, col0) VALUES(3, 3);
SELECT * from bigint_test13_31;
--PKEY col1 not unique error
INSERT INTO bigint_test13_31(col0,col1,col2) VALUES(3,1,3);
SELECT * from bigint_test13_31;
--not null constrabigint col0 error
INSERT INTO bigint_test13_31(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_31;
--not null constrabigint col2 error
INSERT INTO bigint_test13_31(col0,col1) VALUES(5,5);
SELECT * from bigint_test13_31;
--ok
INSERT INTO bigint_test13_31(col0,col1,col2) VALUES(6,2,6);
SELECT * from bigint_test13_31;

--bigint_test13_32
SELECT * from bigint_test13_32;
--ok
INSERT INTO bigint_test13_32 VALUES(1, 1, 1);
SELECT * from bigint_test13_32;
--PKEY col2 null error 
INSERT INTO bigint_test13_32(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_32;
--PKEY col2 not unique error
INSERT INTO bigint_test13_32(col2) VALUES(1);
SELECT * from bigint_test13_32;
--ok
INSERT INTO bigint_test13_32(col2) VALUES(2);
SELECT * from bigint_test13_32;

--bigint_test13_33
SELECT * from bigint_test13_33;
--ok
INSERT INTO bigint_test13_33 VALUES(1, 1, 1);
SELECT * from bigint_test13_33;
--PKEY col2 null error 
INSERT INTO bigint_test13_33(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_33;
--PKEY col2 not unique error
INSERT INTO bigint_test13_33(col1,col2) VALUES(3,1);
SELECT * from bigint_test13_33;
--not null constrabigint col1 error
INSERT INTO bigint_test13_33(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_33;
--ok
INSERT INTO bigint_test13_33(col1,col2) VALUES(6,2);
SELECT * from bigint_test13_33;

--bigint_test13_34
SELECT * from bigint_test13_34;
--ok
INSERT INTO bigint_test13_34 VALUES(1, 1, 1);
SELECT * from bigint_test13_34;
--PKEY col2 null error 
INSERT INTO bigint_test13_34(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_34;
--PKEY col2 not unique error
INSERT INTO bigint_test13_34(col0,col2) VALUES(3,1);
SELECT * from bigint_test13_34;
--not null constrabigint col0 error
INSERT INTO bigint_test13_34(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_34;
--ok
INSERT INTO bigint_test13_34(col0,col2) VALUES(6,2);
SELECT * from bigint_test13_34;

--bigint_test13_35
SELECT * from bigint_test13_35;
--ok
INSERT INTO bigint_test13_35 VALUES(1, 1, 1);
SELECT * from bigint_test13_35;
--PKEY col2 null error 
INSERT INTO bigint_test13_35(col0, col1) VALUES(3, 3);
SELECT * from bigint_test13_35;
--PKEY col2 not unique error
INSERT INTO bigint_test13_35(col0,col1,col2) VALUES(3,3,1);
SELECT * from bigint_test13_35;
--not null constrabigint col0 error
INSERT INTO bigint_test13_35(col1,col2) VALUES(5,5);
SELECT * from bigint_test13_35;
--not null constrabigint col1 error
INSERT INTO bigint_test13_35(col0,col2) VALUES(5,5);
SELECT * from bigint_test13_35;
--ok
INSERT INTO bigint_test13_35(col0,col1,col2) VALUES(6,6,2);
SELECT * from bigint_test13_35;

CREATE TABLE real_test13_0 (
col0 real PRIMARY KEY,col1 real ,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_1 (
col0 real PRIMARY KEY,col1 real ,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_2 (
col0 real PRIMARY KEY,col1 real NOT NULL,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_3 (
col0 real PRIMARY KEY,col1 real NOT NULL,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_4 (
col0 real ,col1 real PRIMARY KEY,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_5 (
col0 real NOT NULL,col1 real PRIMARY KEY,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_6 (
col0 real ,col1 real PRIMARY KEY,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_7 (
col0 real NOT NULL,col1 real PRIMARY KEY,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_8 (
col0 real ,col1 real ,col2 real PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_9 (
col0 real ,col1 real NOT NULL,col2 real PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_10 (
col0 real NOT NULL,col1 real ,col2 real PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_11 (
col0 real NOT NULL,col1 real NOT NULL,col2 real PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_12 (
col0 real NOT NULL PRIMARY KEY,col1 real ,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_13 (
col0 real NOT NULL PRIMARY KEY,col1 real ,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_14 (
col0 real NOT NULL PRIMARY KEY,col1 real NOT NULL,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_15 (
col0 real NOT NULL PRIMARY KEY,col1 real NOT NULL,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_16 (
col0 real ,col1 real NOT NULL PRIMARY KEY,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_17 (
col0 real NOT NULL,col1 real NOT NULL PRIMARY KEY,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_18 (
col0 real ,col1 real NOT NULL PRIMARY KEY,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_19 (
col0 real NOT NULL,col1 real NOT NULL PRIMARY KEY,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_20 (
col0 real ,col1 real ,col2 real NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_21 (
col0 real ,col1 real NOT NULL,col2 real NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_22 (
col0 real NOT NULL,col1 real ,col2 real NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_23 (
col0 real NOT NULL,col1 real NOT NULL,col2 real NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE real_test13_24 (
col0 real PRIMARY KEY NOT NULL,col1 real ,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_25 (
col0 real PRIMARY KEY NOT NULL,col1 real ,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_26 (
col0 real PRIMARY KEY NOT NULL,col1 real NOT NULL,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_27 (
col0 real PRIMARY KEY NOT NULL,col1 real NOT NULL,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_28 (
col0 real ,col1 real PRIMARY KEY NOT NULL,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_29 (
col0 real NOT NULL,col1 real PRIMARY KEY NOT NULL,col2 real 
) tablespace tsurugi;
CREATE TABLE real_test13_30 (
col0 real ,col1 real PRIMARY KEY NOT NULL,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_31 (
col0 real NOT NULL,col1 real PRIMARY KEY NOT NULL,col2 real NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_32 (
col0 real ,col1 real ,col2 real PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_33 (
col0 real ,col1 real NOT NULL,col2 real PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_34 (
col0 real NOT NULL,col1 real ,col2 real PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE real_test13_35 (
col0 real NOT NULL,col1 real NOT NULL,col2 real PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE FOREIGN TABLE real_test13_0 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_1 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_2 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_3 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_4 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_5 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_6 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_7 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_8 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_9 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_10 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_11 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_12 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_13 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_14 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_15 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_16 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_17 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_18 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_19 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_20 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_21 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_22 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_23 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_24 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_25 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_26 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_27 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_28 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_29 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_30 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_31 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_32 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_33 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_34 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test13_35 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
--real_test13_0
SELECT * from real_test13_0;
--ok
INSERT INTO real_test13_0 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_0;
--PKEY col0 null error 
INSERT INTO real_test13_0(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_0;
--PKEY col0 not unique error
INSERT INTO real_test13_0(col0) VALUES(1.1);
SELECT * from real_test13_0;
--ok
INSERT INTO real_test13_0(col0) VALUES(2.2);
SELECT * from real_test13_0;

--real_test13_1
SELECT * from real_test13_1;
--ok
INSERT INTO real_test13_1 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_1;
--PKEY col0 null error 
INSERT INTO real_test13_1(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_1;
--PKEY col0 not unique error
INSERT INTO real_test13_1(col0,col2) VALUES(1.1,3.3);
SELECT * from real_test13_1;
--not null constrabigint col2 error
INSERT INTO real_test13_1(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_1;
--ok
INSERT INTO real_test13_1(col0,col2) VALUES(2.2,6.6);
SELECT * from real_test13_1;

--real_test13_2
SELECT * from real_test13_2;
--ok
INSERT INTO real_test13_2 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_2;
--PKEY col0 null error 
INSERT INTO real_test13_2(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_2;
--PKEY col0 not unique error
INSERT INTO real_test13_2(col0,col1) VALUES(1.1,3.3);
SELECT * from real_test13_2;
--not null constrabigint col1 error
INSERT INTO real_test13_2(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_2;
--ok
INSERT INTO real_test13_2(col0,col1) VALUES(2.2,6.6);
SELECT * from real_test13_2;

--real_test13_3
SELECT * from real_test13_3;
--ok
INSERT INTO real_test13_3 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_3;
--PKEY col0 null error 
INSERT INTO real_test13_3(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_3;
--PKEY col0 not unique error
INSERT INTO real_test13_3(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from real_test13_3;
--not null constrabigint col1 error
INSERT INTO real_test13_3(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_3;
--not null constrabigint col2 error
INSERT INTO real_test13_3(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_3;
--ok
INSERT INTO real_test13_3(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from real_test13_3;

--real_test13_4
SELECT * from real_test13_4;
--ok
INSERT INTO real_test13_4 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_4;
--PKEY col1 null error 
INSERT INTO real_test13_4(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_4;
--PKEY col1 not unique error
INSERT INTO real_test13_4(col1) VALUES(1.1);
SELECT * from real_test13_4;
--ok
INSERT INTO real_test13_4(col1) VALUES(2.2);
SELECT * from real_test13_4;

--real_test13_5
SELECT * from real_test13_5;
--ok
INSERT INTO real_test13_5 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_5;
--PKEY col1 null error 
INSERT INTO real_test13_5(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_5;
--PKEY col1 not unique error
INSERT INTO real_test13_5(col0,col1) VALUES(3.3,1.1);
SELECT * from real_test13_5;
--not null constrabigint col0 error
INSERT INTO real_test13_5(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_5;
--ok
INSERT INTO real_test13_5(col0,col1) VALUES(6.6,2.2);
SELECT * from real_test13_5;

--real_test13_6
SELECT * from real_test13_6;
--ok
INSERT INTO real_test13_6 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_6;
--PKEY col1 null error 
INSERT INTO real_test13_6(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_6;
--PKEY col1 not unique error
INSERT INTO real_test13_6(col1,col2) VALUES(1.1,3.3);
SELECT * from real_test13_6;
--not null constrabigint col2 error
INSERT INTO real_test13_6(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_6;
--ok
INSERT INTO real_test13_6(col1,col2) VALUES(2.2,6.6);
SELECT * from real_test13_6;

--real_test13_7
SELECT * from real_test13_7;
--ok
INSERT INTO real_test13_7 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_7;
--PKEY col1 null error 
INSERT INTO real_test13_7(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_7;
--PKEY col1 not unique error
INSERT INTO real_test13_7(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from real_test13_7;
--not null constrabigint col0 error
INSERT INTO real_test13_7(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_7;
--not null constrabigint col2 error
INSERT INTO real_test13_7(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_7;
--ok
INSERT INTO real_test13_7(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from real_test13_7;

--real_test13_8
SELECT * from real_test13_8;
--ok
INSERT INTO real_test13_8 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_8;
--PKEY col2 null error 
INSERT INTO real_test13_8(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_8;
--PKEY col2 not unique error
INSERT INTO real_test13_8(col2) VALUES(1.1);
SELECT * from real_test13_8;
--ok
INSERT INTO real_test13_8(col2) VALUES(2.2);
SELECT * from real_test13_8;

--real_test13_9
SELECT * from real_test13_9;
--ok
INSERT INTO real_test13_9 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_9;
--PKEY col2 null error 
INSERT INTO real_test13_9(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_9;
--PKEY col2 not unique error
INSERT INTO real_test13_9(col1,col2) VALUES(3.3,1.1);
SELECT * from real_test13_9;
--not null constrabigint col1 error
INSERT INTO real_test13_9(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_9;
--ok
INSERT INTO real_test13_9(col1,col2) VALUES(6.6,2.2);
SELECT * from real_test13_9;

--real_test13_10
SELECT * from real_test13_10;
--ok
INSERT INTO real_test13_10 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_10;
--PKEY col2 null error 
INSERT INTO real_test13_10(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_10;
--PKEY col2 not unique error
INSERT INTO real_test13_10(col0,col2) VALUES(3.3,1.1);
SELECT * from real_test13_10;
--not null constrabigint col0 error
INSERT INTO real_test13_10(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_10;
--ok
INSERT INTO real_test13_10(col0,col2) VALUES(6.6,2.2);
SELECT * from real_test13_10;

--real_test13_11
SELECT * from real_test13_11;
--ok
INSERT INTO real_test13_11 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_11;
--PKEY col2 null error 
INSERT INTO real_test13_11(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_11;
--PKEY col2 not unique error
INSERT INTO real_test13_11(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from real_test13_11;
--not null constrabigint col0 error
INSERT INTO real_test13_11(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_11;
--not null constrabigint col1 error
INSERT INTO real_test13_11(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_11;
--ok
INSERT INTO real_test13_11(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from real_test13_11;

--real_test13_12
SELECT * from real_test13_12;
--ok
INSERT INTO real_test13_12 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_12;
--PKEY col0 null error 
INSERT INTO real_test13_12(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_12;
--PKEY col0 not unique error
INSERT INTO real_test13_12(col0) VALUES(1.1);
SELECT * from real_test13_12;
--ok
INSERT INTO real_test13_12(col0) VALUES(2.2);
SELECT * from real_test13_12;

--real_test13_13
SELECT * from real_test13_13;
--ok
INSERT INTO real_test13_13 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_13;
--PKEY col0 null error 
INSERT INTO real_test13_13(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_13;
--PKEY col0 not unique error
INSERT INTO real_test13_13(col0,col2) VALUES(1.1,3.3);
SELECT * from real_test13_13;
--not null constrabigint col2 error
INSERT INTO real_test13_13(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_13;
--ok
INSERT INTO real_test13_13(col0,col2) VALUES(2.2,6.6);
SELECT * from real_test13_13;

--real_test13_14
SELECT * from real_test13_14;
--ok
INSERT INTO real_test13_14 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_14;
--PKEY col0 null error 
INSERT INTO real_test13_14(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_14;
--PKEY col0 not unique error
INSERT INTO real_test13_14(col0,col1) VALUES(1.1,3.3);
SELECT * from real_test13_14;
--not null constrabigint col1 error
INSERT INTO real_test13_14(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_14;
--ok
INSERT INTO real_test13_14(col0,col1) VALUES(2.2,6.6);
SELECT * from real_test13_14;

--real_test13_15
SELECT * from real_test13_15;
--ok
INSERT INTO real_test13_15 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_15;
--PKEY col0 null error 
INSERT INTO real_test13_15(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_15;
--PKEY col0 not unique error
INSERT INTO real_test13_15(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from real_test13_15;
--not null constrabigint col1 error
INSERT INTO real_test13_15(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_15;
--not null constrabigint col2 error
INSERT INTO real_test13_15(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_15;
--ok
INSERT INTO real_test13_15(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from real_test13_15;

--real_test13_16
SELECT * from real_test13_16;
--ok
INSERT INTO real_test13_16 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_16;
--PKEY col1 null error 
INSERT INTO real_test13_16(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_16;
--PKEY col1 not unique error
INSERT INTO real_test13_16(col1) VALUES(1.1);
SELECT * from real_test13_16;
--ok
INSERT INTO real_test13_16(col1) VALUES(2.2);
SELECT * from real_test13_16;

--real_test13_17
SELECT * from real_test13_17;
--ok
INSERT INTO real_test13_17 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_17;
--PKEY col1 null error 
INSERT INTO real_test13_17(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_17;
--PKEY col1 not unique error
INSERT INTO real_test13_17(col0,col1) VALUES(3.3,1.1);
SELECT * from real_test13_17;
--not null constrabigint col0 error
INSERT INTO real_test13_17(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_17;
--ok
INSERT INTO real_test13_17(col0,col1) VALUES(6.6,2.2);
SELECT * from real_test13_17;

--real_test13_18
SELECT * from real_test13_18;
--ok
INSERT INTO real_test13_18 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_18;
--PKEY col1 null error 
INSERT INTO real_test13_18(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_18;
--PKEY col1 not unique error
INSERT INTO real_test13_18(col1,col2) VALUES(1.1,3.3);
SELECT * from real_test13_18;
--not null constrabigint col2 error
INSERT INTO real_test13_18(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_18;
--ok
INSERT INTO real_test13_18(col1,col2) VALUES(2.2,6.6);
SELECT * from real_test13_18;

--real_test13_19
SELECT * from real_test13_19;
--ok
INSERT INTO real_test13_19 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_19;
--PKEY col1 null error 
INSERT INTO real_test13_19(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_19;
--PKEY col1 not unique error
INSERT INTO real_test13_19(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from real_test13_19;
--not null constrabigint col0 error
INSERT INTO real_test13_19(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_19;
--not null constrabigint col2 error
INSERT INTO real_test13_19(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_19;
--ok
INSERT INTO real_test13_19(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from real_test13_19;

--real_test13_20
SELECT * from real_test13_20;
--ok
INSERT INTO real_test13_20 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_20;
--PKEY col2 null error 
INSERT INTO real_test13_20(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_20;
--PKEY col2 not unique error
INSERT INTO real_test13_20(col2) VALUES(1.1);
SELECT * from real_test13_20;
--ok
INSERT INTO real_test13_20(col2) VALUES(2.2);
SELECT * from real_test13_20;

--real_test13_21
SELECT * from real_test13_21;
--ok
INSERT INTO real_test13_21 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_21;
--PKEY col2 null error 
INSERT INTO real_test13_21(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_21;
--PKEY col2 not unique error
INSERT INTO real_test13_21(col1,col2) VALUES(3.3,1.1);
SELECT * from real_test13_21;
--not null constrabigint col1 error
INSERT INTO real_test13_21(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_21;
--ok
INSERT INTO real_test13_21(col1,col2) VALUES(6.6,2.2);
SELECT * from real_test13_21;

--real_test13_22
SELECT * from real_test13_22;
--ok
INSERT INTO real_test13_22 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_22;
--PKEY col2 null error 
INSERT INTO real_test13_22(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_22;
--PKEY col2 not unique error
INSERT INTO real_test13_22(col0,col2) VALUES(3.3,1.1);
SELECT * from real_test13_22;
--not null constrabigint col0 error
INSERT INTO real_test13_22(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_22;
--ok
INSERT INTO real_test13_22(col0,col2) VALUES(6.6,2.2);
SELECT * from real_test13_22;

--real_test13_23
SELECT * from real_test13_23;
--ok
INSERT INTO real_test13_23 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_23;
--PKEY col2 null error 
INSERT INTO real_test13_23(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_23;
--PKEY col2 not unique error
INSERT INTO real_test13_23(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from real_test13_23;
--not null constrabigint col0 error
INSERT INTO real_test13_23(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_23;
--not null constrabigint col1 error
INSERT INTO real_test13_23(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_23;
--ok
INSERT INTO real_test13_23(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from real_test13_23;

--real_test13_24
SELECT * from real_test13_24;
--ok
INSERT INTO real_test13_24 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_24;
--PKEY col0 null error 
INSERT INTO real_test13_24(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_24;
--PKEY col0 not unique error
INSERT INTO real_test13_24(col0) VALUES(1.1);
SELECT * from real_test13_24;
--ok
INSERT INTO real_test13_24(col0) VALUES(2.2);
SELECT * from real_test13_24;

--real_test13_25
SELECT * from real_test13_25;
--ok
INSERT INTO real_test13_25 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_25;
--PKEY col0 null error 
INSERT INTO real_test13_25(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_25;
--PKEY col0 not unique error
INSERT INTO real_test13_25(col0,col2) VALUES(1.1,3.3);
SELECT * from real_test13_25;
--not null constrabigint col2 error
INSERT INTO real_test13_25(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_25;
--ok
INSERT INTO real_test13_25(col0,col2) VALUES(2.2,6.6);
SELECT * from real_test13_25;

--real_test13_26
SELECT * from real_test13_26;
--ok
INSERT INTO real_test13_26 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_26;
--PKEY col0 null error 
INSERT INTO real_test13_26(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_26;
--PKEY col0 not unique error
INSERT INTO real_test13_26(col0,col1) VALUES(1.1,3.3);
SELECT * from real_test13_26;
--not null constrabigint col1 error
INSERT INTO real_test13_26(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_26;
--ok
INSERT INTO real_test13_26(col0,col1) VALUES(2.2,6.6);
SELECT * from real_test13_26;

--real_test13_27
SELECT * from real_test13_27;
--ok
INSERT INTO real_test13_27 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_27;
--PKEY col0 null error 
INSERT INTO real_test13_27(col1, col2) VALUES(3.3, 3.3);
SELECT * from real_test13_27;
--PKEY col0 not unique error
INSERT INTO real_test13_27(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from real_test13_27;
--not null constrabigint col1 error
INSERT INTO real_test13_27(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_27;
--not null constrabigint col2 error
INSERT INTO real_test13_27(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_27;
--ok
INSERT INTO real_test13_27(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from real_test13_27;

--real_test13_28
SELECT * from real_test13_28;
--ok
INSERT INTO real_test13_28 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_28;
--PKEY col1 null error 
INSERT INTO real_test13_28(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_28;
--PKEY col1 not unique error
INSERT INTO real_test13_28(col1) VALUES(1.1);
SELECT * from real_test13_28;
--ok
INSERT INTO real_test13_28(col1) VALUES(2.2);
SELECT * from real_test13_28;

--real_test13_29
SELECT * from real_test13_29;
--ok
INSERT INTO real_test13_29 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_29;
--PKEY col1 null error 
INSERT INTO real_test13_29(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_29;
--PKEY col1 not unique error
INSERT INTO real_test13_29(col0,col1) VALUES(3.3,1.1);
SELECT * from real_test13_29;
--not null constrabigint col0 error
INSERT INTO real_test13_29(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_29;
--ok
INSERT INTO real_test13_29(col0,col1) VALUES(6.6,2.2);
SELECT * from real_test13_29;

--real_test13_30
SELECT * from real_test13_30;
--ok
INSERT INTO real_test13_30 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_30;
--PKEY col1 null error 
INSERT INTO real_test13_30(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_30;
--PKEY col1 not unique error
INSERT INTO real_test13_30(col1,col2) VALUES(1.1,3.3);
SELECT * from real_test13_30;
--not null constrabigint col2 error
INSERT INTO real_test13_30(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_30;
--ok
INSERT INTO real_test13_30(col1,col2) VALUES(2.2,6.6);
SELECT * from real_test13_30;

--real_test13_31
SELECT * from real_test13_31;
--ok
INSERT INTO real_test13_31 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_31;
--PKEY col1 null error 
INSERT INTO real_test13_31(col2, col0) VALUES(3.3, 3.3);
SELECT * from real_test13_31;
--PKEY col1 not unique error
INSERT INTO real_test13_31(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from real_test13_31;
--not null constrabigint col0 error
INSERT INTO real_test13_31(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_31;
--not null constrabigint col2 error
INSERT INTO real_test13_31(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test13_31;
--ok
INSERT INTO real_test13_31(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from real_test13_31;

--real_test13_32
SELECT * from real_test13_32;
--ok
INSERT INTO real_test13_32 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_32;
--PKEY col2 null error 
INSERT INTO real_test13_32(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_32;
--PKEY col2 not unique error
INSERT INTO real_test13_32(col2) VALUES(1.1);
SELECT * from real_test13_32;
--ok
INSERT INTO real_test13_32(col2) VALUES(2.2);
SELECT * from real_test13_32;

--real_test13_33
SELECT * from real_test13_33;
--ok
INSERT INTO real_test13_33 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_33;
--PKEY col2 null error 
INSERT INTO real_test13_33(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_33;
--PKEY col2 not unique error
INSERT INTO real_test13_33(col1,col2) VALUES(3.3,1.1);
SELECT * from real_test13_33;
--not null constrabigint col1 error
INSERT INTO real_test13_33(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_33;
--ok
INSERT INTO real_test13_33(col1,col2) VALUES(6.6,2.2);
SELECT * from real_test13_33;

--real_test13_34
SELECT * from real_test13_34;
--ok
INSERT INTO real_test13_34 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_34;
--PKEY col2 null error 
INSERT INTO real_test13_34(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_34;
--PKEY col2 not unique error
INSERT INTO real_test13_34(col0,col2) VALUES(3.3,1.1);
SELECT * from real_test13_34;
--not null constrabigint col0 error
INSERT INTO real_test13_34(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_34;
--ok
INSERT INTO real_test13_34(col0,col2) VALUES(6.6,2.2);
SELECT * from real_test13_34;

--real_test13_35
SELECT * from real_test13_35;
--ok
INSERT INTO real_test13_35 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test13_35;
--PKEY col2 null error 
INSERT INTO real_test13_35(col0, col1) VALUES(3.3, 3.3);
SELECT * from real_test13_35;
--PKEY col2 not unique error
INSERT INTO real_test13_35(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from real_test13_35;
--not null constrabigint col0 error
INSERT INTO real_test13_35(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test13_35;
--not null constrabigint col1 error
INSERT INTO real_test13_35(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test13_35;
--ok
INSERT INTO real_test13_35(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from real_test13_35;

CREATE TABLE double_test13_0 (
col0 double precision PRIMARY KEY,col1 double precision ,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_1 (
col0 double precision PRIMARY KEY,col1 double precision ,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_2 (
col0 double precision PRIMARY KEY,col1 double precision NOT NULL,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_3 (
col0 double precision PRIMARY KEY,col1 double precision NOT NULL,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_4 (
col0 double precision ,col1 double precision PRIMARY KEY,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_5 (
col0 double precision NOT NULL,col1 double precision PRIMARY KEY,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_6 (
col0 double precision ,col1 double precision PRIMARY KEY,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_7 (
col0 double precision NOT NULL,col1 double precision PRIMARY KEY,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_8 (
col0 double precision ,col1 double precision ,col2 double precision PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_9 (
col0 double precision ,col1 double precision NOT NULL,col2 double precision PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_10 (
col0 double precision NOT NULL,col1 double precision ,col2 double precision PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_11 (
col0 double precision NOT NULL,col1 double precision NOT NULL,col2 double precision PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_12 (
col0 double precision NOT NULL PRIMARY KEY,col1 double precision ,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_13 (
col0 double precision NOT NULL PRIMARY KEY,col1 double precision ,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_14 (
col0 double precision NOT NULL PRIMARY KEY,col1 double precision NOT NULL,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_15 (
col0 double precision NOT NULL PRIMARY KEY,col1 double precision NOT NULL,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_16 (
col0 double precision ,col1 double precision NOT NULL PRIMARY KEY,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_17 (
col0 double precision NOT NULL,col1 double precision NOT NULL PRIMARY KEY,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_18 (
col0 double precision ,col1 double precision NOT NULL PRIMARY KEY,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_19 (
col0 double precision NOT NULL,col1 double precision NOT NULL PRIMARY KEY,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_20 (
col0 double precision ,col1 double precision ,col2 double precision NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_21 (
col0 double precision ,col1 double precision NOT NULL,col2 double precision NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_22 (
col0 double precision NOT NULL,col1 double precision ,col2 double precision NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_23 (
col0 double precision NOT NULL,col1 double precision NOT NULL,col2 double precision NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE double_test13_24 (
col0 double precision PRIMARY KEY NOT NULL,col1 double precision ,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_25 (
col0 double precision PRIMARY KEY NOT NULL,col1 double precision ,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_26 (
col0 double precision PRIMARY KEY NOT NULL,col1 double precision NOT NULL,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_27 (
col0 double precision PRIMARY KEY NOT NULL,col1 double precision NOT NULL,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_28 (
col0 double precision ,col1 double precision PRIMARY KEY NOT NULL,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_29 (
col0 double precision NOT NULL,col1 double precision PRIMARY KEY NOT NULL,col2 double precision 
) tablespace tsurugi;
CREATE TABLE double_test13_30 (
col0 double precision ,col1 double precision PRIMARY KEY NOT NULL,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_31 (
col0 double precision NOT NULL,col1 double precision PRIMARY KEY NOT NULL,col2 double precision NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_32 (
col0 double precision ,col1 double precision ,col2 double precision PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_33 (
col0 double precision ,col1 double precision NOT NULL,col2 double precision PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_34 (
col0 double precision NOT NULL,col1 double precision ,col2 double precision PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE double_test13_35 (
col0 double precision NOT NULL,col1 double precision NOT NULL,col2 double precision PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE FOREIGN TABLE double_test13_0 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_1 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_2 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_3 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_4 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_5 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_6 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_7 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_8 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_9 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_10 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_11 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_12 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_13 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_14 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_15 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_16 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_17 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_18 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_19 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_20 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_21 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_22 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_23 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_24 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_25 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_26 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_27 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_28 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_29 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_30 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_31 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_32 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_33 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_34 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test13_35 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
--double_test13_0
SELECT * from double_test13_0;
--ok
INSERT INTO double_test13_0 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_0;
--PKEY col0 null error 
INSERT INTO double_test13_0(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_0;
--PKEY col0 not unique error
INSERT INTO double_test13_0(col0) VALUES(1.1);
SELECT * from double_test13_0;
--ok
INSERT INTO double_test13_0(col0) VALUES(2.2);
SELECT * from double_test13_0;

--double_test13_1
SELECT * from double_test13_1;
--ok
INSERT INTO double_test13_1 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_1;
--PKEY col0 null error 
INSERT INTO double_test13_1(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_1;
--PKEY col0 not unique error
INSERT INTO double_test13_1(col0,col2) VALUES(1.1,3.3);
SELECT * from double_test13_1;
--not null constrabigint col2 error
INSERT INTO double_test13_1(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_1;
--ok
INSERT INTO double_test13_1(col0,col2) VALUES(2.2,6.6);
SELECT * from double_test13_1;

--double_test13_2
SELECT * from double_test13_2;
--ok
INSERT INTO double_test13_2 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_2;
--PKEY col0 null error 
INSERT INTO double_test13_2(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_2;
--PKEY col0 not unique error
INSERT INTO double_test13_2(col0,col1) VALUES(1.1,3.3);
SELECT * from double_test13_2;
--not null constrabigint col1 error
INSERT INTO double_test13_2(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_2;
--ok
INSERT INTO double_test13_2(col0,col1) VALUES(2.2,6.6);
SELECT * from double_test13_2;

--double_test13_3
SELECT * from double_test13_3;
--ok
INSERT INTO double_test13_3 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_3;
--PKEY col0 null error 
INSERT INTO double_test13_3(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_3;
--PKEY col0 not unique error
INSERT INTO double_test13_3(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from double_test13_3;
--not null constrabigint col1 error
INSERT INTO double_test13_3(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_3;
--not null constrabigint col2 error
INSERT INTO double_test13_3(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_3;
--ok
INSERT INTO double_test13_3(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from double_test13_3;

--double_test13_4
SELECT * from double_test13_4;
--ok
INSERT INTO double_test13_4 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_4;
--PKEY col1 null error 
INSERT INTO double_test13_4(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_4;
--PKEY col1 not unique error
INSERT INTO double_test13_4(col1) VALUES(1.1);
SELECT * from double_test13_4;
--ok
INSERT INTO double_test13_4(col1) VALUES(2.2);
SELECT * from double_test13_4;

--double_test13_5
SELECT * from double_test13_5;
--ok
INSERT INTO double_test13_5 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_5;
--PKEY col1 null error 
INSERT INTO double_test13_5(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_5;
--PKEY col1 not unique error
INSERT INTO double_test13_5(col0,col1) VALUES(3.3,1.1);
SELECT * from double_test13_5;
--not null constrabigint col0 error
INSERT INTO double_test13_5(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_5;
--ok
INSERT INTO double_test13_5(col0,col1) VALUES(6.6,2.2);
SELECT * from double_test13_5;

--double_test13_6
SELECT * from double_test13_6;
--ok
INSERT INTO double_test13_6 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_6;
--PKEY col1 null error 
INSERT INTO double_test13_6(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_6;
--PKEY col1 not unique error
INSERT INTO double_test13_6(col1,col2) VALUES(1.1,3.3);
SELECT * from double_test13_6;
--not null constrabigint col2 error
INSERT INTO double_test13_6(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_6;
--ok
INSERT INTO double_test13_6(col1,col2) VALUES(2.2,6.6);
SELECT * from double_test13_6;

--double_test13_7
SELECT * from double_test13_7;
--ok
INSERT INTO double_test13_7 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_7;
--PKEY col1 null error 
INSERT INTO double_test13_7(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_7;
--PKEY col1 not unique error
INSERT INTO double_test13_7(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from double_test13_7;
--not null constrabigint col0 error
INSERT INTO double_test13_7(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_7;
--not null constrabigint col2 error
INSERT INTO double_test13_7(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_7;
--ok
INSERT INTO double_test13_7(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from double_test13_7;

--double_test13_8
SELECT * from double_test13_8;
--ok
INSERT INTO double_test13_8 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_8;
--PKEY col2 null error 
INSERT INTO double_test13_8(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_8;
--PKEY col2 not unique error
INSERT INTO double_test13_8(col2) VALUES(1.1);
SELECT * from double_test13_8;
--ok
INSERT INTO double_test13_8(col2) VALUES(2.2);
SELECT * from double_test13_8;

--double_test13_9
SELECT * from double_test13_9;
--ok
INSERT INTO double_test13_9 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_9;
--PKEY col2 null error 
INSERT INTO double_test13_9(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_9;
--PKEY col2 not unique error
INSERT INTO double_test13_9(col1,col2) VALUES(3.3,1.1);
SELECT * from double_test13_9;
--not null constrabigint col1 error
INSERT INTO double_test13_9(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_9;
--ok
INSERT INTO double_test13_9(col1,col2) VALUES(6.6,2.2);
SELECT * from double_test13_9;

--double_test13_10
SELECT * from double_test13_10;
--ok
INSERT INTO double_test13_10 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_10;
--PKEY col2 null error 
INSERT INTO double_test13_10(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_10;
--PKEY col2 not unique error
INSERT INTO double_test13_10(col0,col2) VALUES(3.3,1.1);
SELECT * from double_test13_10;
--not null constrabigint col0 error
INSERT INTO double_test13_10(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_10;
--ok
INSERT INTO double_test13_10(col0,col2) VALUES(6.6,2.2);
SELECT * from double_test13_10;

--double_test13_11
SELECT * from double_test13_11;
--ok
INSERT INTO double_test13_11 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_11;
--PKEY col2 null error 
INSERT INTO double_test13_11(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_11;
--PKEY col2 not unique error
INSERT INTO double_test13_11(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from double_test13_11;
--not null constrabigint col0 error
INSERT INTO double_test13_11(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_11;
--not null constrabigint col1 error
INSERT INTO double_test13_11(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_11;
--ok
INSERT INTO double_test13_11(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from double_test13_11;

--double_test13_12
SELECT * from double_test13_12;
--ok
INSERT INTO double_test13_12 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_12;
--PKEY col0 null error 
INSERT INTO double_test13_12(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_12;
--PKEY col0 not unique error
INSERT INTO double_test13_12(col0) VALUES(1.1);
SELECT * from double_test13_12;
--ok
INSERT INTO double_test13_12(col0) VALUES(2.2);
SELECT * from double_test13_12;

--double_test13_13
SELECT * from double_test13_13;
--ok
INSERT INTO double_test13_13 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_13;
--PKEY col0 null error 
INSERT INTO double_test13_13(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_13;
--PKEY col0 not unique error
INSERT INTO double_test13_13(col0,col2) VALUES(1.1,3.3);
SELECT * from double_test13_13;
--not null constrabigint col2 error
INSERT INTO double_test13_13(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_13;
--ok
INSERT INTO double_test13_13(col0,col2) VALUES(2.2,6.6);
SELECT * from double_test13_13;

--double_test13_14
SELECT * from double_test13_14;
--ok
INSERT INTO double_test13_14 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_14;
--PKEY col0 null error 
INSERT INTO double_test13_14(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_14;
--PKEY col0 not unique error
INSERT INTO double_test13_14(col0,col1) VALUES(1.1,3.3);
SELECT * from double_test13_14;
--not null constrabigint col1 error
INSERT INTO double_test13_14(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_14;
--ok
INSERT INTO double_test13_14(col0,col1) VALUES(2.2,6.6);
SELECT * from double_test13_14;

--double_test13_15
SELECT * from double_test13_15;
--ok
INSERT INTO double_test13_15 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_15;
--PKEY col0 null error 
INSERT INTO double_test13_15(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_15;
--PKEY col0 not unique error
INSERT INTO double_test13_15(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from double_test13_15;
--not null constrabigint col1 error
INSERT INTO double_test13_15(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_15;
--not null constrabigint col2 error
INSERT INTO double_test13_15(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_15;
--ok
INSERT INTO double_test13_15(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from double_test13_15;

--double_test13_16
SELECT * from double_test13_16;
--ok
INSERT INTO double_test13_16 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_16;
--PKEY col1 null error 
INSERT INTO double_test13_16(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_16;
--PKEY col1 not unique error
INSERT INTO double_test13_16(col1) VALUES(1.1);
SELECT * from double_test13_16;
--ok
INSERT INTO double_test13_16(col1) VALUES(2.2);
SELECT * from double_test13_16;

--double_test13_17
SELECT * from double_test13_17;
--ok
INSERT INTO double_test13_17 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_17;
--PKEY col1 null error 
INSERT INTO double_test13_17(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_17;
--PKEY col1 not unique error
INSERT INTO double_test13_17(col0,col1) VALUES(3.3,1.1);
SELECT * from double_test13_17;
--not null constrabigint col0 error
INSERT INTO double_test13_17(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_17;
--ok
INSERT INTO double_test13_17(col0,col1) VALUES(6.6,2.2);
SELECT * from double_test13_17;

--double_test13_18
SELECT * from double_test13_18;
--ok
INSERT INTO double_test13_18 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_18;
--PKEY col1 null error 
INSERT INTO double_test13_18(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_18;
--PKEY col1 not unique error
INSERT INTO double_test13_18(col1,col2) VALUES(1.1,3.3);
SELECT * from double_test13_18;
--not null constrabigint col2 error
INSERT INTO double_test13_18(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_18;
--ok
INSERT INTO double_test13_18(col1,col2) VALUES(2.2,6.6);
SELECT * from double_test13_18;

--double_test13_19
SELECT * from double_test13_19;
--ok
INSERT INTO double_test13_19 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_19;
--PKEY col1 null error 
INSERT INTO double_test13_19(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_19;
--PKEY col1 not unique error
INSERT INTO double_test13_19(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from double_test13_19;
--not null constrabigint col0 error
INSERT INTO double_test13_19(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_19;
--not null constrabigint col2 error
INSERT INTO double_test13_19(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_19;
--ok
INSERT INTO double_test13_19(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from double_test13_19;

--double_test13_20
SELECT * from double_test13_20;
--ok
INSERT INTO double_test13_20 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_20;
--PKEY col2 null error 
INSERT INTO double_test13_20(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_20;
--PKEY col2 not unique error
INSERT INTO double_test13_20(col2) VALUES(1.1);
SELECT * from double_test13_20;
--ok
INSERT INTO double_test13_20(col2) VALUES(2.2);
SELECT * from double_test13_20;

--double_test13_21
SELECT * from double_test13_21;
--ok
INSERT INTO double_test13_21 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_21;
--PKEY col2 null error 
INSERT INTO double_test13_21(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_21;
--PKEY col2 not unique error
INSERT INTO double_test13_21(col1,col2) VALUES(3.3,1.1);
SELECT * from double_test13_21;
--not null constrabigint col1 error
INSERT INTO double_test13_21(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_21;
--ok
INSERT INTO double_test13_21(col1,col2) VALUES(6.6,2.2);
SELECT * from double_test13_21;

--double_test13_22
SELECT * from double_test13_22;
--ok
INSERT INTO double_test13_22 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_22;
--PKEY col2 null error 
INSERT INTO double_test13_22(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_22;
--PKEY col2 not unique error
INSERT INTO double_test13_22(col0,col2) VALUES(3.3,1.1);
SELECT * from double_test13_22;
--not null constrabigint col0 error
INSERT INTO double_test13_22(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_22;
--ok
INSERT INTO double_test13_22(col0,col2) VALUES(6.6,2.2);
SELECT * from double_test13_22;

--double_test13_23
SELECT * from double_test13_23;
--ok
INSERT INTO double_test13_23 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_23;
--PKEY col2 null error 
INSERT INTO double_test13_23(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_23;
--PKEY col2 not unique error
INSERT INTO double_test13_23(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from double_test13_23;
--not null constrabigint col0 error
INSERT INTO double_test13_23(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_23;
--not null constrabigint col1 error
INSERT INTO double_test13_23(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_23;
--ok
INSERT INTO double_test13_23(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from double_test13_23;

--double_test13_24
SELECT * from double_test13_24;
--ok
INSERT INTO double_test13_24 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_24;
--PKEY col0 null error 
INSERT INTO double_test13_24(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_24;
--PKEY col0 not unique error
INSERT INTO double_test13_24(col0) VALUES(1.1);
SELECT * from double_test13_24;
--ok
INSERT INTO double_test13_24(col0) VALUES(2.2);
SELECT * from double_test13_24;

--double_test13_25
SELECT * from double_test13_25;
--ok
INSERT INTO double_test13_25 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_25;
--PKEY col0 null error 
INSERT INTO double_test13_25(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_25;
--PKEY col0 not unique error
INSERT INTO double_test13_25(col0,col2) VALUES(1.1,3.3);
SELECT * from double_test13_25;
--not null constrabigint col2 error
INSERT INTO double_test13_25(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_25;
--ok
INSERT INTO double_test13_25(col0,col2) VALUES(2.2,6.6);
SELECT * from double_test13_25;

--double_test13_26
SELECT * from double_test13_26;
--ok
INSERT INTO double_test13_26 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_26;
--PKEY col0 null error 
INSERT INTO double_test13_26(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_26;
--PKEY col0 not unique error
INSERT INTO double_test13_26(col0,col1) VALUES(1.1,3.3);
SELECT * from double_test13_26;
--not null constrabigint col1 error
INSERT INTO double_test13_26(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_26;
--ok
INSERT INTO double_test13_26(col0,col1) VALUES(2.2,6.6);
SELECT * from double_test13_26;

--double_test13_27
SELECT * from double_test13_27;
--ok
INSERT INTO double_test13_27 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_27;
--PKEY col0 null error 
INSERT INTO double_test13_27(col1, col2) VALUES(3.3, 3.3);
SELECT * from double_test13_27;
--PKEY col0 not unique error
INSERT INTO double_test13_27(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from double_test13_27;
--not null constrabigint col1 error
INSERT INTO double_test13_27(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_27;
--not null constrabigint col2 error
INSERT INTO double_test13_27(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_27;
--ok
INSERT INTO double_test13_27(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from double_test13_27;

--double_test13_28
SELECT * from double_test13_28;
--ok
INSERT INTO double_test13_28 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_28;
--PKEY col1 null error 
INSERT INTO double_test13_28(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_28;
--PKEY col1 not unique error
INSERT INTO double_test13_28(col1) VALUES(1.1);
SELECT * from double_test13_28;
--ok
INSERT INTO double_test13_28(col1) VALUES(2.2);
SELECT * from double_test13_28;

--double_test13_29
SELECT * from double_test13_29;
--ok
INSERT INTO double_test13_29 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_29;
--PKEY col1 null error 
INSERT INTO double_test13_29(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_29;
--PKEY col1 not unique error
INSERT INTO double_test13_29(col0,col1) VALUES(3.3,1.1);
SELECT * from double_test13_29;
--not null constrabigint col0 error
INSERT INTO double_test13_29(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_29;
--ok
INSERT INTO double_test13_29(col0,col1) VALUES(6.6,2.2);
SELECT * from double_test13_29;

--double_test13_30
SELECT * from double_test13_30;
--ok
INSERT INTO double_test13_30 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_30;
--PKEY col1 null error 
INSERT INTO double_test13_30(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_30;
--PKEY col1 not unique error
INSERT INTO double_test13_30(col1,col2) VALUES(1.1,3.3);
SELECT * from double_test13_30;
--not null constrabigint col2 error
INSERT INTO double_test13_30(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_30;
--ok
INSERT INTO double_test13_30(col1,col2) VALUES(2.2,6.6);
SELECT * from double_test13_30;

--double_test13_31
SELECT * from double_test13_31;
--ok
INSERT INTO double_test13_31 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_31;
--PKEY col1 null error 
INSERT INTO double_test13_31(col2, col0) VALUES(3.3, 3.3);
SELECT * from double_test13_31;
--PKEY col1 not unique error
INSERT INTO double_test13_31(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from double_test13_31;
--not null constrabigint col0 error
INSERT INTO double_test13_31(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_31;
--not null constrabigint col2 error
INSERT INTO double_test13_31(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test13_31;
--ok
INSERT INTO double_test13_31(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from double_test13_31;

--double_test13_32
SELECT * from double_test13_32;
--ok
INSERT INTO double_test13_32 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_32;
--PKEY col2 null error 
INSERT INTO double_test13_32(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_32;
--PKEY col2 not unique error
INSERT INTO double_test13_32(col2) VALUES(1.1);
SELECT * from double_test13_32;
--ok
INSERT INTO double_test13_32(col2) VALUES(2.2);
SELECT * from double_test13_32;

--double_test13_33
SELECT * from double_test13_33;
--ok
INSERT INTO double_test13_33 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_33;
--PKEY col2 null error 
INSERT INTO double_test13_33(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_33;
--PKEY col2 not unique error
INSERT INTO double_test13_33(col1,col2) VALUES(3.3,1.1);
SELECT * from double_test13_33;
--not null constrabigint col1 error
INSERT INTO double_test13_33(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_33;
--ok
INSERT INTO double_test13_33(col1,col2) VALUES(6.6,2.2);
SELECT * from double_test13_33;

--double_test13_34
SELECT * from double_test13_34;
--ok
INSERT INTO double_test13_34 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_34;
--PKEY col2 null error 
INSERT INTO double_test13_34(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_34;
--PKEY col2 not unique error
INSERT INTO double_test13_34(col0,col2) VALUES(3.3,1.1);
SELECT * from double_test13_34;
--not null constrabigint col0 error
INSERT INTO double_test13_34(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_34;
--ok
INSERT INTO double_test13_34(col0,col2) VALUES(6.6,2.2);
SELECT * from double_test13_34;

--double_test13_35
SELECT * from double_test13_35;
--ok
INSERT INTO double_test13_35 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test13_35;
--PKEY col2 null error 
INSERT INTO double_test13_35(col0, col1) VALUES(3.3, 3.3);
SELECT * from double_test13_35;
--PKEY col2 not unique error
INSERT INTO double_test13_35(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from double_test13_35;
--not null constrabigint col0 error
INSERT INTO double_test13_35(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test13_35;
--not null constrabigint col1 error
INSERT INTO double_test13_35(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test13_35;
--ok
INSERT INTO double_test13_35(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from double_test13_35;

CREATE TABLE char_test13_0 (
col0 char(10) PRIMARY KEY,col1 char(10) ,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_1 (
col0 char(10) PRIMARY KEY,col1 char(10) ,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_2 (
col0 char(10) PRIMARY KEY,col1 char(10) NOT NULL,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_3 (
col0 char(10) PRIMARY KEY,col1 char(10) NOT NULL,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_4 (
col0 char(10) ,col1 char(10) PRIMARY KEY,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_5 (
col0 char(10) NOT NULL,col1 char(10) PRIMARY KEY,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_6 (
col0 char(10) ,col1 char(10) PRIMARY KEY,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_7 (
col0 char(10) NOT NULL,col1 char(10) PRIMARY KEY,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_8 (
col0 char(10) ,col1 char(10) ,col2 char(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_9 (
col0 char(10) ,col1 char(10) NOT NULL,col2 char(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_10 (
col0 char(10) NOT NULL,col1 char(10) ,col2 char(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_11 (
col0 char(10) NOT NULL,col1 char(10) NOT NULL,col2 char(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_12 (
col0 char(10) NOT NULL PRIMARY KEY,col1 char(10) ,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_13 (
col0 char(10) NOT NULL PRIMARY KEY,col1 char(10) ,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_14 (
col0 char(10) NOT NULL PRIMARY KEY,col1 char(10) NOT NULL,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_15 (
col0 char(10) NOT NULL PRIMARY KEY,col1 char(10) NOT NULL,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_16 (
col0 char(10) ,col1 char(10) NOT NULL PRIMARY KEY,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_17 (
col0 char(10) NOT NULL,col1 char(10) NOT NULL PRIMARY KEY,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_18 (
col0 char(10) ,col1 char(10) NOT NULL PRIMARY KEY,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_19 (
col0 char(10) NOT NULL,col1 char(10) NOT NULL PRIMARY KEY,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_20 (
col0 char(10) ,col1 char(10) ,col2 char(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_21 (
col0 char(10) ,col1 char(10) NOT NULL,col2 char(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_22 (
col0 char(10) NOT NULL,col1 char(10) ,col2 char(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_23 (
col0 char(10) NOT NULL,col1 char(10) NOT NULL,col2 char(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE char_test13_24 (
col0 char(10) PRIMARY KEY NOT NULL,col1 char(10) ,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_25 (
col0 char(10) PRIMARY KEY NOT NULL,col1 char(10) ,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_26 (
col0 char(10) PRIMARY KEY NOT NULL,col1 char(10) NOT NULL,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_27 (
col0 char(10) PRIMARY KEY NOT NULL,col1 char(10) NOT NULL,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_28 (
col0 char(10) ,col1 char(10) PRIMARY KEY NOT NULL,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_29 (
col0 char(10) NOT NULL,col1 char(10) PRIMARY KEY NOT NULL,col2 char(10) 
) tablespace tsurugi;
CREATE TABLE char_test13_30 (
col0 char(10) ,col1 char(10) PRIMARY KEY NOT NULL,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_31 (
col0 char(10) NOT NULL,col1 char(10) PRIMARY KEY NOT NULL,col2 char(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_32 (
col0 char(10) ,col1 char(10) ,col2 char(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_33 (
col0 char(10) ,col1 char(10) NOT NULL,col2 char(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_34 (
col0 char(10) NOT NULL,col1 char(10) ,col2 char(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE char_test13_35 (
col0 char(10) NOT NULL,col1 char(10) NOT NULL,col2 char(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE FOREIGN TABLE char_test13_0 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_1 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_2 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_3 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_4 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_5 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_6 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_7 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_8 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_9 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_10 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_11 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_12 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_13 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_14 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_15 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_16 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_17 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_18 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_19 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_20 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_21 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_22 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_23 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_24 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_25 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_26 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_27 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_28 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_29 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_30 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_31 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_32 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_33 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_34 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test13_35 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
--char_test13_0
SELECT * from char_test13_0;
--ok
INSERT INTO char_test13_0 VALUES('1', '1', '1');
SELECT * from char_test13_0;
--PKEY col0 null error 
INSERT INTO char_test13_0(col1, col2) VALUES('3', '3');
SELECT * from char_test13_0;
--PKEY col0 not unique error
INSERT INTO char_test13_0(col0) VALUES('1');
SELECT * from char_test13_0;
--ok
INSERT INTO char_test13_0(col0) VALUES('2');
SELECT * from char_test13_0;

--char_test13_1
SELECT * from char_test13_1;
--ok
INSERT INTO char_test13_1 VALUES('1', '1', '1');
SELECT * from char_test13_1;
--PKEY col0 null error 
INSERT INTO char_test13_1(col1, col2) VALUES('3', '3');
SELECT * from char_test13_1;
--PKEY col0 not unique error
INSERT INTO char_test13_1(col0,col2) VALUES('1','3');
SELECT * from char_test13_1;
--not null constrabigint col2 error
INSERT INTO char_test13_1(col0,col1) VALUES('5','5');
SELECT * from char_test13_1;
--ok
INSERT INTO char_test13_1(col0,col2) VALUES('2','6');
SELECT * from char_test13_1;

--char_test13_2
SELECT * from char_test13_2;
--ok
INSERT INTO char_test13_2 VALUES('1', '1', '1');
SELECT * from char_test13_2;
--PKEY col0 null error 
INSERT INTO char_test13_2(col1, col2) VALUES('3', '3');
SELECT * from char_test13_2;
--PKEY col0 not unique error
INSERT INTO char_test13_2(col0,col1) VALUES('1','3');
SELECT * from char_test13_2;
--not null constrabigint col1 error
INSERT INTO char_test13_2(col0,col2) VALUES('5','5');
SELECT * from char_test13_2;
--ok
INSERT INTO char_test13_2(col0,col1) VALUES('2','6');
SELECT * from char_test13_2;

--char_test13_3
SELECT * from char_test13_3;
--ok
INSERT INTO char_test13_3 VALUES('1', '1', '1');
SELECT * from char_test13_3;
--PKEY col0 null error 
INSERT INTO char_test13_3(col1, col2) VALUES('3', '3');
SELECT * from char_test13_3;
--PKEY col0 not unique error
INSERT INTO char_test13_3(col0,col1,col2) VALUES('1','3','3');
SELECT * from char_test13_3;
--not null constrabigint col1 error
INSERT INTO char_test13_3(col0,col2) VALUES('5','5');
SELECT * from char_test13_3;
--not null constrabigint col2 error
INSERT INTO char_test13_3(col0,col1) VALUES('5','5');
SELECT * from char_test13_3;
--ok
INSERT INTO char_test13_3(col0,col1,col2) VALUES('2','6','6');
SELECT * from char_test13_3;

--char_test13_4
SELECT * from char_test13_4;
--ok
INSERT INTO char_test13_4 VALUES('1', '1', '1');
SELECT * from char_test13_4;
--PKEY col1 null error 
INSERT INTO char_test13_4(col2, col0) VALUES('3', '3');
SELECT * from char_test13_4;
--PKEY col1 not unique error
INSERT INTO char_test13_4(col1) VALUES('1');
SELECT * from char_test13_4;
--ok
INSERT INTO char_test13_4(col1) VALUES('2');
SELECT * from char_test13_4;

--char_test13_5
SELECT * from char_test13_5;
--ok
INSERT INTO char_test13_5 VALUES('1', '1', '1');
SELECT * from char_test13_5;
--PKEY col1 null error 
INSERT INTO char_test13_5(col2, col0) VALUES('3', '3');
SELECT * from char_test13_5;
--PKEY col1 not unique error
INSERT INTO char_test13_5(col0,col1) VALUES('3','1');
SELECT * from char_test13_5;
--not null constrabigint col0 error
INSERT INTO char_test13_5(col1,col2) VALUES('5','5');
SELECT * from char_test13_5;
--ok
INSERT INTO char_test13_5(col0,col1) VALUES('6','2');
SELECT * from char_test13_5;

--char_test13_6
SELECT * from char_test13_6;
--ok
INSERT INTO char_test13_6 VALUES('1', '1', '1');
SELECT * from char_test13_6;
--PKEY col1 null error 
INSERT INTO char_test13_6(col2, col0) VALUES('3', '3');
SELECT * from char_test13_6;
--PKEY col1 not unique error
INSERT INTO char_test13_6(col1,col2) VALUES('1','3');
SELECT * from char_test13_6;
--not null constrabigint col2 error
INSERT INTO char_test13_6(col0,col1) VALUES('5','5');
SELECT * from char_test13_6;
--ok
INSERT INTO char_test13_6(col1,col2) VALUES('2','6');
SELECT * from char_test13_6;

--char_test13_7
SELECT * from char_test13_7;
--ok
INSERT INTO char_test13_7 VALUES('1', '1', '1');
SELECT * from char_test13_7;
--PKEY col1 null error 
INSERT INTO char_test13_7(col2, col0) VALUES('3', '3');
SELECT * from char_test13_7;
--PKEY col1 not unique error
INSERT INTO char_test13_7(col0,col1,col2) VALUES('3','1','3');
SELECT * from char_test13_7;
--not null constrabigint col0 error
INSERT INTO char_test13_7(col1,col2) VALUES('5','5');
SELECT * from char_test13_7;
--not null constrabigint col2 error
INSERT INTO char_test13_7(col0,col1) VALUES('5','5');
SELECT * from char_test13_7;
--ok
INSERT INTO char_test13_7(col0,col1,col2) VALUES('6','2','6');
SELECT * from char_test13_7;

--char_test13_8
SELECT * from char_test13_8;
--ok
INSERT INTO char_test13_8 VALUES('1', '1', '1');
SELECT * from char_test13_8;
--PKEY col2 null error 
INSERT INTO char_test13_8(col0, col1) VALUES('3', '3');
SELECT * from char_test13_8;
--PKEY col2 not unique error
INSERT INTO char_test13_8(col2) VALUES('1');
SELECT * from char_test13_8;
--ok
INSERT INTO char_test13_8(col2) VALUES('2');
SELECT * from char_test13_8;

--char_test13_9
SELECT * from char_test13_9;
--ok
INSERT INTO char_test13_9 VALUES('1', '1', '1');
SELECT * from char_test13_9;
--PKEY col2 null error 
INSERT INTO char_test13_9(col0, col1) VALUES('3', '3');
SELECT * from char_test13_9;
--PKEY col2 not unique error
INSERT INTO char_test13_9(col1,col2) VALUES('3','1');
SELECT * from char_test13_9;
--not null constrabigint col1 error
INSERT INTO char_test13_9(col0,col2) VALUES('5','5');
SELECT * from char_test13_9;
--ok
INSERT INTO char_test13_9(col1,col2) VALUES('6','2');
SELECT * from char_test13_9;

--char_test13_10
SELECT * from char_test13_10;
--ok
INSERT INTO char_test13_10 VALUES('1', '1', '1');
SELECT * from char_test13_10;
--PKEY col2 null error 
INSERT INTO char_test13_10(col0, col1) VALUES('3', '3');
SELECT * from char_test13_10;
--PKEY col2 not unique error
INSERT INTO char_test13_10(col0,col2) VALUES('3','1');
SELECT * from char_test13_10;
--not null constrabigint col0 error
INSERT INTO char_test13_10(col1,col2) VALUES('5','5');
SELECT * from char_test13_10;
--ok
INSERT INTO char_test13_10(col0,col2) VALUES('6','2');
SELECT * from char_test13_10;

--char_test13_11
SELECT * from char_test13_11;
--ok
INSERT INTO char_test13_11 VALUES('1', '1', '1');
SELECT * from char_test13_11;
--PKEY col2 null error 
INSERT INTO char_test13_11(col0, col1) VALUES('3', '3');
SELECT * from char_test13_11;
--PKEY col2 not unique error
INSERT INTO char_test13_11(col0,col1,col2) VALUES('3','3','1');
SELECT * from char_test13_11;
--not null constrabigint col0 error
INSERT INTO char_test13_11(col1,col2) VALUES('5','5');
SELECT * from char_test13_11;
--not null constrabigint col1 error
INSERT INTO char_test13_11(col0,col2) VALUES('5','5');
SELECT * from char_test13_11;
--ok
INSERT INTO char_test13_11(col0,col1,col2) VALUES('6','6','2');
SELECT * from char_test13_11;

--char_test13_12
SELECT * from char_test13_12;
--ok
INSERT INTO char_test13_12 VALUES('1', '1', '1');
SELECT * from char_test13_12;
--PKEY col0 null error 
INSERT INTO char_test13_12(col1, col2) VALUES('3', '3');
SELECT * from char_test13_12;
--PKEY col0 not unique error
INSERT INTO char_test13_12(col0) VALUES('1');
SELECT * from char_test13_12;
--ok
INSERT INTO char_test13_12(col0) VALUES('2');
SELECT * from char_test13_12;

--char_test13_13
SELECT * from char_test13_13;
--ok
INSERT INTO char_test13_13 VALUES('1', '1', '1');
SELECT * from char_test13_13;
--PKEY col0 null error 
INSERT INTO char_test13_13(col1, col2) VALUES('3', '3');
SELECT * from char_test13_13;
--PKEY col0 not unique error
INSERT INTO char_test13_13(col0,col2) VALUES('1','3');
SELECT * from char_test13_13;
--not null constrabigint col2 error
INSERT INTO char_test13_13(col0,col1) VALUES('5','5');
SELECT * from char_test13_13;
--ok
INSERT INTO char_test13_13(col0,col2) VALUES('2','6');
SELECT * from char_test13_13;

--char_test13_14
SELECT * from char_test13_14;
--ok
INSERT INTO char_test13_14 VALUES('1', '1', '1');
SELECT * from char_test13_14;
--PKEY col0 null error 
INSERT INTO char_test13_14(col1, col2) VALUES('3', '3');
SELECT * from char_test13_14;
--PKEY col0 not unique error
INSERT INTO char_test13_14(col0,col1) VALUES('1','3');
SELECT * from char_test13_14;
--not null constrabigint col1 error
INSERT INTO char_test13_14(col0,col2) VALUES('5','5');
SELECT * from char_test13_14;
--ok
INSERT INTO char_test13_14(col0,col1) VALUES('2','6');
SELECT * from char_test13_14;

--char_test13_15
SELECT * from char_test13_15;
--ok
INSERT INTO char_test13_15 VALUES('1', '1', '1');
SELECT * from char_test13_15;
--PKEY col0 null error 
INSERT INTO char_test13_15(col1, col2) VALUES('3', '3');
SELECT * from char_test13_15;
--PKEY col0 not unique error
INSERT INTO char_test13_15(col0,col1,col2) VALUES('1','3','3');
SELECT * from char_test13_15;
--not null constrabigint col1 error
INSERT INTO char_test13_15(col0,col2) VALUES('5','5');
SELECT * from char_test13_15;
--not null constrabigint col2 error
INSERT INTO char_test13_15(col0,col1) VALUES('5','5');
SELECT * from char_test13_15;
--ok
INSERT INTO char_test13_15(col0,col1,col2) VALUES('2','6','6');
SELECT * from char_test13_15;

--char_test13_16
SELECT * from char_test13_16;
--ok
INSERT INTO char_test13_16 VALUES('1', '1', '1');
SELECT * from char_test13_16;
--PKEY col1 null error 
INSERT INTO char_test13_16(col2, col0) VALUES('3', '3');
SELECT * from char_test13_16;
--PKEY col1 not unique error
INSERT INTO char_test13_16(col1) VALUES('1');
SELECT * from char_test13_16;
--ok
INSERT INTO char_test13_16(col1) VALUES('2');
SELECT * from char_test13_16;

--char_test13_17
SELECT * from char_test13_17;
--ok
INSERT INTO char_test13_17 VALUES('1', '1', '1');
SELECT * from char_test13_17;
--PKEY col1 null error 
INSERT INTO char_test13_17(col2, col0) VALUES('3', '3');
SELECT * from char_test13_17;
--PKEY col1 not unique error
INSERT INTO char_test13_17(col0,col1) VALUES('3','1');
SELECT * from char_test13_17;
--not null constrabigint col0 error
INSERT INTO char_test13_17(col1,col2) VALUES('5','5');
SELECT * from char_test13_17;
--ok
INSERT INTO char_test13_17(col0,col1) VALUES('6','2');
SELECT * from char_test13_17;

--char_test13_18
SELECT * from char_test13_18;
--ok
INSERT INTO char_test13_18 VALUES('1', '1', '1');
SELECT * from char_test13_18;
--PKEY col1 null error 
INSERT INTO char_test13_18(col2, col0) VALUES('3', '3');
SELECT * from char_test13_18;
--PKEY col1 not unique error
INSERT INTO char_test13_18(col1,col2) VALUES('1','3');
SELECT * from char_test13_18;
--not null constrabigint col2 error
INSERT INTO char_test13_18(col0,col1) VALUES('5','5');
SELECT * from char_test13_18;
--ok
INSERT INTO char_test13_18(col1,col2) VALUES('2','6');
SELECT * from char_test13_18;

--char_test13_19
SELECT * from char_test13_19;
--ok
INSERT INTO char_test13_19 VALUES('1', '1', '1');
SELECT * from char_test13_19;
--PKEY col1 null error 
INSERT INTO char_test13_19(col2, col0) VALUES('3', '3');
SELECT * from char_test13_19;
--PKEY col1 not unique error
INSERT INTO char_test13_19(col0,col1,col2) VALUES('3','1','3');
SELECT * from char_test13_19;
--not null constrabigint col0 error
INSERT INTO char_test13_19(col1,col2) VALUES('5','5');
SELECT * from char_test13_19;
--not null constrabigint col2 error
INSERT INTO char_test13_19(col0,col1) VALUES('5','5');
SELECT * from char_test13_19;
--ok
INSERT INTO char_test13_19(col0,col1,col2) VALUES('6','2','6');
SELECT * from char_test13_19;

--char_test13_20
SELECT * from char_test13_20;
--ok
INSERT INTO char_test13_20 VALUES('1', '1', '1');
SELECT * from char_test13_20;
--PKEY col2 null error 
INSERT INTO char_test13_20(col0, col1) VALUES('3', '3');
SELECT * from char_test13_20;
--PKEY col2 not unique error
INSERT INTO char_test13_20(col2) VALUES('1');
SELECT * from char_test13_20;
--ok
INSERT INTO char_test13_20(col2) VALUES('2');
SELECT * from char_test13_20;

--char_test13_21
SELECT * from char_test13_21;
--ok
INSERT INTO char_test13_21 VALUES('1', '1', '1');
SELECT * from char_test13_21;
--PKEY col2 null error 
INSERT INTO char_test13_21(col0, col1) VALUES('3', '3');
SELECT * from char_test13_21;
--PKEY col2 not unique error
INSERT INTO char_test13_21(col1,col2) VALUES('3','1');
SELECT * from char_test13_21;
--not null constrabigint col1 error
INSERT INTO char_test13_21(col0,col2) VALUES('5','5');
SELECT * from char_test13_21;
--ok
INSERT INTO char_test13_21(col1,col2) VALUES('6','2');
SELECT * from char_test13_21;

--char_test13_22
SELECT * from char_test13_22;
--ok
INSERT INTO char_test13_22 VALUES('1', '1', '1');
SELECT * from char_test13_22;
--PKEY col2 null error 
INSERT INTO char_test13_22(col0, col1) VALUES('3', '3');
SELECT * from char_test13_22;
--PKEY col2 not unique error
INSERT INTO char_test13_22(col0,col2) VALUES('3','1');
SELECT * from char_test13_22;
--not null constrabigint col0 error
INSERT INTO char_test13_22(col1,col2) VALUES('5','5');
SELECT * from char_test13_22;
--ok
INSERT INTO char_test13_22(col0,col2) VALUES('6','2');
SELECT * from char_test13_22;

--char_test13_23
SELECT * from char_test13_23;
--ok
INSERT INTO char_test13_23 VALUES('1', '1', '1');
SELECT * from char_test13_23;
--PKEY col2 null error 
INSERT INTO char_test13_23(col0, col1) VALUES('3', '3');
SELECT * from char_test13_23;
--PKEY col2 not unique error
INSERT INTO char_test13_23(col0,col1,col2) VALUES('3','3','1');
SELECT * from char_test13_23;
--not null constrabigint col0 error
INSERT INTO char_test13_23(col1,col2) VALUES('5','5');
SELECT * from char_test13_23;
--not null constrabigint col1 error
INSERT INTO char_test13_23(col0,col2) VALUES('5','5');
SELECT * from char_test13_23;
--ok
INSERT INTO char_test13_23(col0,col1,col2) VALUES('6','6','2');
SELECT * from char_test13_23;

--char_test13_24
SELECT * from char_test13_24;
--ok
INSERT INTO char_test13_24 VALUES('1', '1', '1');
SELECT * from char_test13_24;
--PKEY col0 null error 
INSERT INTO char_test13_24(col1, col2) VALUES('3', '3');
SELECT * from char_test13_24;
--PKEY col0 not unique error
INSERT INTO char_test13_24(col0) VALUES('1');
SELECT * from char_test13_24;
--ok
INSERT INTO char_test13_24(col0) VALUES('2');
SELECT * from char_test13_24;

--char_test13_25
SELECT * from char_test13_25;
--ok
INSERT INTO char_test13_25 VALUES('1', '1', '1');
SELECT * from char_test13_25;
--PKEY col0 null error 
INSERT INTO char_test13_25(col1, col2) VALUES('3', '3');
SELECT * from char_test13_25;
--PKEY col0 not unique error
INSERT INTO char_test13_25(col0,col2) VALUES('1','3');
SELECT * from char_test13_25;
--not null constrabigint col2 error
INSERT INTO char_test13_25(col0,col1) VALUES('5','5');
SELECT * from char_test13_25;
--ok
INSERT INTO char_test13_25(col0,col2) VALUES('2','6');
SELECT * from char_test13_25;

--char_test13_26
SELECT * from char_test13_26;
--ok
INSERT INTO char_test13_26 VALUES('1', '1', '1');
SELECT * from char_test13_26;
--PKEY col0 null error 
INSERT INTO char_test13_26(col1, col2) VALUES('3', '3');
SELECT * from char_test13_26;
--PKEY col0 not unique error
INSERT INTO char_test13_26(col0,col1) VALUES('1','3');
SELECT * from char_test13_26;
--not null constrabigint col1 error
INSERT INTO char_test13_26(col0,col2) VALUES('5','5');
SELECT * from char_test13_26;
--ok
INSERT INTO char_test13_26(col0,col1) VALUES('2','6');
SELECT * from char_test13_26;

--char_test13_27
SELECT * from char_test13_27;
--ok
INSERT INTO char_test13_27 VALUES('1', '1', '1');
SELECT * from char_test13_27;
--PKEY col0 null error 
INSERT INTO char_test13_27(col1, col2) VALUES('3', '3');
SELECT * from char_test13_27;
--PKEY col0 not unique error
INSERT INTO char_test13_27(col0,col1,col2) VALUES('1','3','3');
SELECT * from char_test13_27;
--not null constrabigint col1 error
INSERT INTO char_test13_27(col0,col2) VALUES('5','5');
SELECT * from char_test13_27;
--not null constrabigint col2 error
INSERT INTO char_test13_27(col0,col1) VALUES('5','5');
SELECT * from char_test13_27;
--ok
INSERT INTO char_test13_27(col0,col1,col2) VALUES('2','6','6');
SELECT * from char_test13_27;

--char_test13_28
SELECT * from char_test13_28;
--ok
INSERT INTO char_test13_28 VALUES('1', '1', '1');
SELECT * from char_test13_28;
--PKEY col1 null error 
INSERT INTO char_test13_28(col2, col0) VALUES('3', '3');
SELECT * from char_test13_28;
--PKEY col1 not unique error
INSERT INTO char_test13_28(col1) VALUES('1');
SELECT * from char_test13_28;
--ok
INSERT INTO char_test13_28(col1) VALUES('2');
SELECT * from char_test13_28;

--char_test13_29
SELECT * from char_test13_29;
--ok
INSERT INTO char_test13_29 VALUES('1', '1', '1');
SELECT * from char_test13_29;
--PKEY col1 null error 
INSERT INTO char_test13_29(col2, col0) VALUES('3', '3');
SELECT * from char_test13_29;
--PKEY col1 not unique error
INSERT INTO char_test13_29(col0,col1) VALUES('3','1');
SELECT * from char_test13_29;
--not null constrabigint col0 error
INSERT INTO char_test13_29(col1,col2) VALUES('5','5');
SELECT * from char_test13_29;
--ok
INSERT INTO char_test13_29(col0,col1) VALUES('6','2');
SELECT * from char_test13_29;

--char_test13_30
SELECT * from char_test13_30;
--ok
INSERT INTO char_test13_30 VALUES('1', '1', '1');
SELECT * from char_test13_30;
--PKEY col1 null error 
INSERT INTO char_test13_30(col2, col0) VALUES('3', '3');
SELECT * from char_test13_30;
--PKEY col1 not unique error
INSERT INTO char_test13_30(col1,col2) VALUES('1','3');
SELECT * from char_test13_30;
--not null constrabigint col2 error
INSERT INTO char_test13_30(col0,col1) VALUES('5','5');
SELECT * from char_test13_30;
--ok
INSERT INTO char_test13_30(col1,col2) VALUES('2','6');
SELECT * from char_test13_30;

--char_test13_31
SELECT * from char_test13_31;
--ok
INSERT INTO char_test13_31 VALUES('1', '1', '1');
SELECT * from char_test13_31;
--PKEY col1 null error 
INSERT INTO char_test13_31(col2, col0) VALUES('3', '3');
SELECT * from char_test13_31;
--PKEY col1 not unique error
INSERT INTO char_test13_31(col0,col1,col2) VALUES('3','1','3');
SELECT * from char_test13_31;
--not null constrabigint col0 error
INSERT INTO char_test13_31(col1,col2) VALUES('5','5');
SELECT * from char_test13_31;
--not null constrabigint col2 error
INSERT INTO char_test13_31(col0,col1) VALUES('5','5');
SELECT * from char_test13_31;
--ok
INSERT INTO char_test13_31(col0,col1,col2) VALUES('6','2','6');
SELECT * from char_test13_31;

--char_test13_32
SELECT * from char_test13_32;
--ok
INSERT INTO char_test13_32 VALUES('1', '1', '1');
SELECT * from char_test13_32;
--PKEY col2 null error 
INSERT INTO char_test13_32(col0, col1) VALUES('3', '3');
SELECT * from char_test13_32;
--PKEY col2 not unique error
INSERT INTO char_test13_32(col2) VALUES('1');
SELECT * from char_test13_32;
--ok
INSERT INTO char_test13_32(col2) VALUES('2');
SELECT * from char_test13_32;

--char_test13_33
SELECT * from char_test13_33;
--ok
INSERT INTO char_test13_33 VALUES('1', '1', '1');
SELECT * from char_test13_33;
--PKEY col2 null error 
INSERT INTO char_test13_33(col0, col1) VALUES('3', '3');
SELECT * from char_test13_33;
--PKEY col2 not unique error
INSERT INTO char_test13_33(col1,col2) VALUES('3','1');
SELECT * from char_test13_33;
--not null constrabigint col1 error
INSERT INTO char_test13_33(col0,col2) VALUES('5','5');
SELECT * from char_test13_33;
--ok
INSERT INTO char_test13_33(col1,col2) VALUES('6','2');
SELECT * from char_test13_33;

--char_test13_34
SELECT * from char_test13_34;
--ok
INSERT INTO char_test13_34 VALUES('1', '1', '1');
SELECT * from char_test13_34;
--PKEY col2 null error 
INSERT INTO char_test13_34(col0, col1) VALUES('3', '3');
SELECT * from char_test13_34;
--PKEY col2 not unique error
INSERT INTO char_test13_34(col0,col2) VALUES('3','1');
SELECT * from char_test13_34;
--not null constrabigint col0 error
INSERT INTO char_test13_34(col1,col2) VALUES('5','5');
SELECT * from char_test13_34;
--ok
INSERT INTO char_test13_34(col0,col2) VALUES('6','2');
SELECT * from char_test13_34;

--char_test13_35
SELECT * from char_test13_35;
--ok
INSERT INTO char_test13_35 VALUES('1', '1', '1');
SELECT * from char_test13_35;
--PKEY col2 null error 
INSERT INTO char_test13_35(col0, col1) VALUES('3', '3');
SELECT * from char_test13_35;
--PKEY col2 not unique error
INSERT INTO char_test13_35(col0,col1,col2) VALUES('3','3','1');
SELECT * from char_test13_35;
--not null constrabigint col0 error
INSERT INTO char_test13_35(col1,col2) VALUES('5','5');
SELECT * from char_test13_35;
--not null constrabigint col1 error
INSERT INTO char_test13_35(col0,col2) VALUES('5','5');
SELECT * from char_test13_35;
--ok
INSERT INTO char_test13_35(col0,col1,col2) VALUES('6','6','2');
SELECT * from char_test13_35;


CREATE TABLE varchar_test13_0 (
col0 varchar(10) PRIMARY KEY,col1 varchar(10) ,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_1 (
col0 varchar(10) PRIMARY KEY,col1 varchar(10) ,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_2 (
col0 varchar(10) PRIMARY KEY,col1 varchar(10) NOT NULL,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_3 (
col0 varchar(10) PRIMARY KEY,col1 varchar(10) NOT NULL,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_4 (
col0 varchar(10) ,col1 varchar(10) PRIMARY KEY,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_5 (
col0 varchar(10) NOT NULL,col1 varchar(10) PRIMARY KEY,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_6 (
col0 varchar(10) ,col1 varchar(10) PRIMARY KEY,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_7 (
col0 varchar(10) NOT NULL,col1 varchar(10) PRIMARY KEY,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_8 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_9 (
col0 varchar(10) ,col1 varchar(10) NOT NULL,col2 varchar(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_10 (
col0 varchar(10) NOT NULL,col1 varchar(10) ,col2 varchar(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_11 (
col0 varchar(10) NOT NULL,col1 varchar(10) NOT NULL,col2 varchar(10) PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_12 (
col0 varchar(10) NOT NULL PRIMARY KEY,col1 varchar(10) ,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_13 (
col0 varchar(10) NOT NULL PRIMARY KEY,col1 varchar(10) ,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_14 (
col0 varchar(10) NOT NULL PRIMARY KEY,col1 varchar(10) NOT NULL,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_15 (
col0 varchar(10) NOT NULL PRIMARY KEY,col1 varchar(10) NOT NULL,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_16 (
col0 varchar(10) ,col1 varchar(10) NOT NULL PRIMARY KEY,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_17 (
col0 varchar(10) NOT NULL,col1 varchar(10) NOT NULL PRIMARY KEY,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_18 (
col0 varchar(10) ,col1 varchar(10) NOT NULL PRIMARY KEY,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_19 (
col0 varchar(10) NOT NULL,col1 varchar(10) NOT NULL PRIMARY KEY,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_20 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_21 (
col0 varchar(10) ,col1 varchar(10) NOT NULL,col2 varchar(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_22 (
col0 varchar(10) NOT NULL,col1 varchar(10) ,col2 varchar(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_23 (
col0 varchar(10) NOT NULL,col1 varchar(10) NOT NULL,col2 varchar(10) NOT NULL PRIMARY KEY
) tablespace tsurugi;
CREATE TABLE varchar_test13_24 (
col0 varchar(10) PRIMARY KEY NOT NULL,col1 varchar(10) ,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_25 (
col0 varchar(10) PRIMARY KEY NOT NULL,col1 varchar(10) ,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_26 (
col0 varchar(10) PRIMARY KEY NOT NULL,col1 varchar(10) NOT NULL,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_27 (
col0 varchar(10) PRIMARY KEY NOT NULL,col1 varchar(10) NOT NULL,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_28 (
col0 varchar(10) ,col1 varchar(10) PRIMARY KEY NOT NULL,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_29 (
col0 varchar(10) NOT NULL,col1 varchar(10) PRIMARY KEY NOT NULL,col2 varchar(10) 
) tablespace tsurugi;
CREATE TABLE varchar_test13_30 (
col0 varchar(10) ,col1 varchar(10) PRIMARY KEY NOT NULL,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_31 (
col0 varchar(10) NOT NULL,col1 varchar(10) PRIMARY KEY NOT NULL,col2 varchar(10) NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_32 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_33 (
col0 varchar(10) ,col1 varchar(10) NOT NULL,col2 varchar(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_34 (
col0 varchar(10) NOT NULL,col1 varchar(10) ,col2 varchar(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE TABLE varchar_test13_35 (
col0 varchar(10) NOT NULL,col1 varchar(10) NOT NULL,col2 varchar(10) PRIMARY KEY NOT NULL
) tablespace tsurugi;
CREATE FOREIGN TABLE varchar_test13_0 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_1 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_2 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_3 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_4 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_5 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_6 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_7 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_8 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_9 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_10 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_11 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_12 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_13 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_14 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_15 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_16 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_17 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_18 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_19 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_20 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_21 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_22 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_23 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_24 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_25 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_26 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_27 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_28 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_29 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_30 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_31 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_32 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_33 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_34 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test13_35 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
--varchar_test13_0
SELECT * from varchar_test13_0;
--ok
INSERT INTO varchar_test13_0 VALUES('1', '1', '1');
SELECT * from varchar_test13_0;
--PKEY col0 null error 
INSERT INTO varchar_test13_0(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_0;
--PKEY col0 not unique error
INSERT INTO varchar_test13_0(col0) VALUES('1');
SELECT * from varchar_test13_0;
--ok
INSERT INTO varchar_test13_0(col0) VALUES('2');
SELECT * from varchar_test13_0;

--varchar_test13_1
SELECT * from varchar_test13_1;
--ok
INSERT INTO varchar_test13_1 VALUES('1', '1', '1');
SELECT * from varchar_test13_1;
--PKEY col0 null error 
INSERT INTO varchar_test13_1(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_1;
--PKEY col0 not unique error
INSERT INTO varchar_test13_1(col0,col2) VALUES('1','3');
SELECT * from varchar_test13_1;
--not null constrabigint col2 error
INSERT INTO varchar_test13_1(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_1;
--ok
INSERT INTO varchar_test13_1(col0,col2) VALUES('2','6');
SELECT * from varchar_test13_1;

--varchar_test13_2
SELECT * from varchar_test13_2;
--ok
INSERT INTO varchar_test13_2 VALUES('1', '1', '1');
SELECT * from varchar_test13_2;
--PKEY col0 null error 
INSERT INTO varchar_test13_2(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_2;
--PKEY col0 not unique error
INSERT INTO varchar_test13_2(col0,col1) VALUES('1','3');
SELECT * from varchar_test13_2;
--not null constrabigint col1 error
INSERT INTO varchar_test13_2(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_2;
--ok
INSERT INTO varchar_test13_2(col0,col1) VALUES('2','6');
SELECT * from varchar_test13_2;

--varchar_test13_3
SELECT * from varchar_test13_3;
--ok
INSERT INTO varchar_test13_3 VALUES('1', '1', '1');
SELECT * from varchar_test13_3;
--PKEY col0 null error 
INSERT INTO varchar_test13_3(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_3;
--PKEY col0 not unique error
INSERT INTO varchar_test13_3(col0,col1,col2) VALUES('1','3','3');
SELECT * from varchar_test13_3;
--not null constrabigint col1 error
INSERT INTO varchar_test13_3(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_3;
--not null constrabigint col2 error
INSERT INTO varchar_test13_3(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_3;
--ok
INSERT INTO varchar_test13_3(col0,col1,col2) VALUES('2','6','6');
SELECT * from varchar_test13_3;

--varchar_test13_4
SELECT * from varchar_test13_4;
--ok
INSERT INTO varchar_test13_4 VALUES('1', '1', '1');
SELECT * from varchar_test13_4;
--PKEY col1 null error 
INSERT INTO varchar_test13_4(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_4;
--PKEY col1 not unique error
INSERT INTO varchar_test13_4(col1) VALUES('1');
SELECT * from varchar_test13_4;
--ok
INSERT INTO varchar_test13_4(col1) VALUES('2');
SELECT * from varchar_test13_4;

--varchar_test13_5
SELECT * from varchar_test13_5;
--ok
INSERT INTO varchar_test13_5 VALUES('1', '1', '1');
SELECT * from varchar_test13_5;
--PKEY col1 null error 
INSERT INTO varchar_test13_5(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_5;
--PKEY col1 not unique error
INSERT INTO varchar_test13_5(col0,col1) VALUES('3','1');
SELECT * from varchar_test13_5;
--not null constrabigint col0 error
INSERT INTO varchar_test13_5(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_5;
--ok
INSERT INTO varchar_test13_5(col0,col1) VALUES('6','2');
SELECT * from varchar_test13_5;

--varchar_test13_6
SELECT * from varchar_test13_6;
--ok
INSERT INTO varchar_test13_6 VALUES('1', '1', '1');
SELECT * from varchar_test13_6;
--PKEY col1 null error 
INSERT INTO varchar_test13_6(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_6;
--PKEY col1 not unique error
INSERT INTO varchar_test13_6(col1,col2) VALUES('1','3');
SELECT * from varchar_test13_6;
--not null constrabigint col2 error
INSERT INTO varchar_test13_6(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_6;
--ok
INSERT INTO varchar_test13_6(col1,col2) VALUES('2','6');
SELECT * from varchar_test13_6;

--varchar_test13_7
SELECT * from varchar_test13_7;
--ok
INSERT INTO varchar_test13_7 VALUES('1', '1', '1');
SELECT * from varchar_test13_7;
--PKEY col1 null error 
INSERT INTO varchar_test13_7(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_7;
--PKEY col1 not unique error
INSERT INTO varchar_test13_7(col0,col1,col2) VALUES('3','1','3');
SELECT * from varchar_test13_7;
--not null constrabigint col0 error
INSERT INTO varchar_test13_7(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_7;
--not null constrabigint col2 error
INSERT INTO varchar_test13_7(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_7;
--ok
INSERT INTO varchar_test13_7(col0,col1,col2) VALUES('6','2','6');
SELECT * from varchar_test13_7;

--varchar_test13_8
SELECT * from varchar_test13_8;
--ok
INSERT INTO varchar_test13_8 VALUES('1', '1', '1');
SELECT * from varchar_test13_8;
--PKEY col2 null error 
INSERT INTO varchar_test13_8(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_8;
--PKEY col2 not unique error
INSERT INTO varchar_test13_8(col2) VALUES('1');
SELECT * from varchar_test13_8;
--ok
INSERT INTO varchar_test13_8(col2) VALUES('2');
SELECT * from varchar_test13_8;

--varchar_test13_9
SELECT * from varchar_test13_9;
--ok
INSERT INTO varchar_test13_9 VALUES('1', '1', '1');
SELECT * from varchar_test13_9;
--PKEY col2 null error 
INSERT INTO varchar_test13_9(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_9;
--PKEY col2 not unique error
INSERT INTO varchar_test13_9(col1,col2) VALUES('3','1');
SELECT * from varchar_test13_9;
--not null constrabigint col1 error
INSERT INTO varchar_test13_9(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_9;
--ok
INSERT INTO varchar_test13_9(col1,col2) VALUES('6','2');
SELECT * from varchar_test13_9;

--varchar_test13_10
SELECT * from varchar_test13_10;
--ok
INSERT INTO varchar_test13_10 VALUES('1', '1', '1');
SELECT * from varchar_test13_10;
--PKEY col2 null error 
INSERT INTO varchar_test13_10(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_10;
--PKEY col2 not unique error
INSERT INTO varchar_test13_10(col0,col2) VALUES('3','1');
SELECT * from varchar_test13_10;
--not null constrabigint col0 error
INSERT INTO varchar_test13_10(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_10;
--ok
INSERT INTO varchar_test13_10(col0,col2) VALUES('6','2');
SELECT * from varchar_test13_10;

--varchar_test13_11
SELECT * from varchar_test13_11;
--ok
INSERT INTO varchar_test13_11 VALUES('1', '1', '1');
SELECT * from varchar_test13_11;
--PKEY col2 null error 
INSERT INTO varchar_test13_11(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_11;
--PKEY col2 not unique error
INSERT INTO varchar_test13_11(col0,col1,col2) VALUES('3','3','1');
SELECT * from varchar_test13_11;
--not null constrabigint col0 error
INSERT INTO varchar_test13_11(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_11;
--not null constrabigint col1 error
INSERT INTO varchar_test13_11(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_11;
--ok
INSERT INTO varchar_test13_11(col0,col1,col2) VALUES('6','6','2');
SELECT * from varchar_test13_11;

--varchar_test13_12
SELECT * from varchar_test13_12;
--ok
INSERT INTO varchar_test13_12 VALUES('1', '1', '1');
SELECT * from varchar_test13_12;
--PKEY col0 null error 
INSERT INTO varchar_test13_12(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_12;
--PKEY col0 not unique error
INSERT INTO varchar_test13_12(col0) VALUES('1');
SELECT * from varchar_test13_12;
--ok
INSERT INTO varchar_test13_12(col0) VALUES('2');
SELECT * from varchar_test13_12;

--varchar_test13_13
SELECT * from varchar_test13_13;
--ok
INSERT INTO varchar_test13_13 VALUES('1', '1', '1');
SELECT * from varchar_test13_13;
--PKEY col0 null error 
INSERT INTO varchar_test13_13(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_13;
--PKEY col0 not unique error
INSERT INTO varchar_test13_13(col0,col2) VALUES('1','3');
SELECT * from varchar_test13_13;
--not null constrabigint col2 error
INSERT INTO varchar_test13_13(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_13;
--ok
INSERT INTO varchar_test13_13(col0,col2) VALUES('2','6');
SELECT * from varchar_test13_13;

--varchar_test13_14
SELECT * from varchar_test13_14;
--ok
INSERT INTO varchar_test13_14 VALUES('1', '1', '1');
SELECT * from varchar_test13_14;
--PKEY col0 null error 
INSERT INTO varchar_test13_14(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_14;
--PKEY col0 not unique error
INSERT INTO varchar_test13_14(col0,col1) VALUES('1','3');
SELECT * from varchar_test13_14;
--not null constrabigint col1 error
INSERT INTO varchar_test13_14(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_14;
--ok
INSERT INTO varchar_test13_14(col0,col1) VALUES('2','6');
SELECT * from varchar_test13_14;

--varchar_test13_15
SELECT * from varchar_test13_15;
--ok
INSERT INTO varchar_test13_15 VALUES('1', '1', '1');
SELECT * from varchar_test13_15;
--PKEY col0 null error 
INSERT INTO varchar_test13_15(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_15;
--PKEY col0 not unique error
INSERT INTO varchar_test13_15(col0,col1,col2) VALUES('1','3','3');
SELECT * from varchar_test13_15;
--not null constrabigint col1 error
INSERT INTO varchar_test13_15(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_15;
--not null constrabigint col2 error
INSERT INTO varchar_test13_15(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_15;
--ok
INSERT INTO varchar_test13_15(col0,col1,col2) VALUES('2','6','6');
SELECT * from varchar_test13_15;

--varchar_test13_16
SELECT * from varchar_test13_16;
--ok
INSERT INTO varchar_test13_16 VALUES('1', '1', '1');
SELECT * from varchar_test13_16;
--PKEY col1 null error 
INSERT INTO varchar_test13_16(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_16;
--PKEY col1 not unique error
INSERT INTO varchar_test13_16(col1) VALUES('1');
SELECT * from varchar_test13_16;
--ok
INSERT INTO varchar_test13_16(col1) VALUES('2');
SELECT * from varchar_test13_16;

--varchar_test13_17
SELECT * from varchar_test13_17;
--ok
INSERT INTO varchar_test13_17 VALUES('1', '1', '1');
SELECT * from varchar_test13_17;
--PKEY col1 null error 
INSERT INTO varchar_test13_17(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_17;
--PKEY col1 not unique error
INSERT INTO varchar_test13_17(col0,col1) VALUES('3','1');
SELECT * from varchar_test13_17;
--not null constrabigint col0 error
INSERT INTO varchar_test13_17(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_17;
--ok
INSERT INTO varchar_test13_17(col0,col1) VALUES('6','2');
SELECT * from varchar_test13_17;

--varchar_test13_18
SELECT * from varchar_test13_18;
--ok
INSERT INTO varchar_test13_18 VALUES('1', '1', '1');
SELECT * from varchar_test13_18;
--PKEY col1 null error 
INSERT INTO varchar_test13_18(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_18;
--PKEY col1 not unique error
INSERT INTO varchar_test13_18(col1,col2) VALUES('1','3');
SELECT * from varchar_test13_18;
--not null constrabigint col2 error
INSERT INTO varchar_test13_18(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_18;
--ok
INSERT INTO varchar_test13_18(col1,col2) VALUES('2','6');
SELECT * from varchar_test13_18;

--varchar_test13_19
SELECT * from varchar_test13_19;
--ok
INSERT INTO varchar_test13_19 VALUES('1', '1', '1');
SELECT * from varchar_test13_19;
--PKEY col1 null error 
INSERT INTO varchar_test13_19(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_19;
--PKEY col1 not unique error
INSERT INTO varchar_test13_19(col0,col1,col2) VALUES('3','1','3');
SELECT * from varchar_test13_19;
--not null constrabigint col0 error
INSERT INTO varchar_test13_19(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_19;
--not null constrabigint col2 error
INSERT INTO varchar_test13_19(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_19;
--ok
INSERT INTO varchar_test13_19(col0,col1,col2) VALUES('6','2','6');
SELECT * from varchar_test13_19;

--varchar_test13_20
SELECT * from varchar_test13_20;
--ok
INSERT INTO varchar_test13_20 VALUES('1', '1', '1');
SELECT * from varchar_test13_20;
--PKEY col2 null error 
INSERT INTO varchar_test13_20(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_20;
--PKEY col2 not unique error
INSERT INTO varchar_test13_20(col2) VALUES('1');
SELECT * from varchar_test13_20;
--ok
INSERT INTO varchar_test13_20(col2) VALUES('2');
SELECT * from varchar_test13_20;

--varchar_test13_21
SELECT * from varchar_test13_21;
--ok
INSERT INTO varchar_test13_21 VALUES('1', '1', '1');
SELECT * from varchar_test13_21;
--PKEY col2 null error 
INSERT INTO varchar_test13_21(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_21;
--PKEY col2 not unique error
INSERT INTO varchar_test13_21(col1,col2) VALUES('3','1');
SELECT * from varchar_test13_21;
--not null constrabigint col1 error
INSERT INTO varchar_test13_21(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_21;
--ok
INSERT INTO varchar_test13_21(col1,col2) VALUES('6','2');
SELECT * from varchar_test13_21;

--varchar_test13_22
SELECT * from varchar_test13_22;
--ok
INSERT INTO varchar_test13_22 VALUES('1', '1', '1');
SELECT * from varchar_test13_22;
--PKEY col2 null error 
INSERT INTO varchar_test13_22(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_22;
--PKEY col2 not unique error
INSERT INTO varchar_test13_22(col0,col2) VALUES('3','1');
SELECT * from varchar_test13_22;
--not null constrabigint col0 error
INSERT INTO varchar_test13_22(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_22;
--ok
INSERT INTO varchar_test13_22(col0,col2) VALUES('6','2');
SELECT * from varchar_test13_22;

--varchar_test13_23
SELECT * from varchar_test13_23;
--ok
INSERT INTO varchar_test13_23 VALUES('1', '1', '1');
SELECT * from varchar_test13_23;
--PKEY col2 null error 
INSERT INTO varchar_test13_23(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_23;
--PKEY col2 not unique error
INSERT INTO varchar_test13_23(col0,col1,col2) VALUES('3','3','1');
SELECT * from varchar_test13_23;
--not null constrabigint col0 error
INSERT INTO varchar_test13_23(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_23;
--not null constrabigint col1 error
INSERT INTO varchar_test13_23(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_23;
--ok
INSERT INTO varchar_test13_23(col0,col1,col2) VALUES('6','6','2');
SELECT * from varchar_test13_23;

--varchar_test13_24
SELECT * from varchar_test13_24;
--ok
INSERT INTO varchar_test13_24 VALUES('1', '1', '1');
SELECT * from varchar_test13_24;
--PKEY col0 null error 
INSERT INTO varchar_test13_24(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_24;
--PKEY col0 not unique error
INSERT INTO varchar_test13_24(col0) VALUES('1');
SELECT * from varchar_test13_24;
--ok
INSERT INTO varchar_test13_24(col0) VALUES('2');
SELECT * from varchar_test13_24;

--varchar_test13_25
SELECT * from varchar_test13_25;
--ok
INSERT INTO varchar_test13_25 VALUES('1', '1', '1');
SELECT * from varchar_test13_25;
--PKEY col0 null error 
INSERT INTO varchar_test13_25(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_25;
--PKEY col0 not unique error
INSERT INTO varchar_test13_25(col0,col2) VALUES('1','3');
SELECT * from varchar_test13_25;
--not null constrabigint col2 error
INSERT INTO varchar_test13_25(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_25;
--ok
INSERT INTO varchar_test13_25(col0,col2) VALUES('2','6');
SELECT * from varchar_test13_25;

--varchar_test13_26
SELECT * from varchar_test13_26;
--ok
INSERT INTO varchar_test13_26 VALUES('1', '1', '1');
SELECT * from varchar_test13_26;
--PKEY col0 null error 
INSERT INTO varchar_test13_26(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_26;
--PKEY col0 not unique error
INSERT INTO varchar_test13_26(col0,col1) VALUES('1','3');
SELECT * from varchar_test13_26;
--not null constrabigint col1 error
INSERT INTO varchar_test13_26(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_26;
--ok
INSERT INTO varchar_test13_26(col0,col1) VALUES('2','6');
SELECT * from varchar_test13_26;

--varchar_test13_27
SELECT * from varchar_test13_27;
--ok
INSERT INTO varchar_test13_27 VALUES('1', '1', '1');
SELECT * from varchar_test13_27;
--PKEY col0 null error 
INSERT INTO varchar_test13_27(col1, col2) VALUES('3', '3');
SELECT * from varchar_test13_27;
--PKEY col0 not unique error
INSERT INTO varchar_test13_27(col0,col1,col2) VALUES('1','3','3');
SELECT * from varchar_test13_27;
--not null constrabigint col1 error
INSERT INTO varchar_test13_27(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_27;
--not null constrabigint col2 error
INSERT INTO varchar_test13_27(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_27;
--ok
INSERT INTO varchar_test13_27(col0,col1,col2) VALUES('2','6','6');
SELECT * from varchar_test13_27;

--varchar_test13_28
SELECT * from varchar_test13_28;
--ok
INSERT INTO varchar_test13_28 VALUES('1', '1', '1');
SELECT * from varchar_test13_28;
--PKEY col1 null error 
INSERT INTO varchar_test13_28(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_28;
--PKEY col1 not unique error
INSERT INTO varchar_test13_28(col1) VALUES('1');
SELECT * from varchar_test13_28;
--ok
INSERT INTO varchar_test13_28(col1) VALUES('2');
SELECT * from varchar_test13_28;

--varchar_test13_29
SELECT * from varchar_test13_29;
--ok
INSERT INTO varchar_test13_29 VALUES('1', '1', '1');
SELECT * from varchar_test13_29;
--PKEY col1 null error 
INSERT INTO varchar_test13_29(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_29;
--PKEY col1 not unique error
INSERT INTO varchar_test13_29(col0,col1) VALUES('3','1');
SELECT * from varchar_test13_29;
--not null constrabigint col0 error
INSERT INTO varchar_test13_29(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_29;
--ok
INSERT INTO varchar_test13_29(col0,col1) VALUES('6','2');
SELECT * from varchar_test13_29;

--varchar_test13_30
SELECT * from varchar_test13_30;
--ok
INSERT INTO varchar_test13_30 VALUES('1', '1', '1');
SELECT * from varchar_test13_30;
--PKEY col1 null error 
INSERT INTO varchar_test13_30(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_30;
--PKEY col1 not unique error
INSERT INTO varchar_test13_30(col1,col2) VALUES('1','3');
SELECT * from varchar_test13_30;
--not null constrabigint col2 error
INSERT INTO varchar_test13_30(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_30;
--ok
INSERT INTO varchar_test13_30(col1,col2) VALUES('2','6');
SELECT * from varchar_test13_30;

--varchar_test13_31
SELECT * from varchar_test13_31;
--ok
INSERT INTO varchar_test13_31 VALUES('1', '1', '1');
SELECT * from varchar_test13_31;
--PKEY col1 null error 
INSERT INTO varchar_test13_31(col2, col0) VALUES('3', '3');
SELECT * from varchar_test13_31;
--PKEY col1 not unique error
INSERT INTO varchar_test13_31(col0,col1,col2) VALUES('3','1','3');
SELECT * from varchar_test13_31;
--not null constrabigint col0 error
INSERT INTO varchar_test13_31(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_31;
--not null constrabigint col2 error
INSERT INTO varchar_test13_31(col0,col1) VALUES('5','5');
SELECT * from varchar_test13_31;
--ok
INSERT INTO varchar_test13_31(col0,col1,col2) VALUES('6','2','6');
SELECT * from varchar_test13_31;

--varchar_test13_32
SELECT * from varchar_test13_32;
--ok
INSERT INTO varchar_test13_32 VALUES('1', '1', '1');
SELECT * from varchar_test13_32;
--PKEY col2 null error 
INSERT INTO varchar_test13_32(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_32;
--PKEY col2 not unique error
INSERT INTO varchar_test13_32(col2) VALUES('1');
SELECT * from varchar_test13_32;
--ok
INSERT INTO varchar_test13_32(col2) VALUES('2');
SELECT * from varchar_test13_32;

--varchar_test13_33
SELECT * from varchar_test13_33;
--ok
INSERT INTO varchar_test13_33 VALUES('1', '1', '1');
SELECT * from varchar_test13_33;
--PKEY col2 null error 
INSERT INTO varchar_test13_33(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_33;
--PKEY col2 not unique error
INSERT INTO varchar_test13_33(col1,col2) VALUES('3','1');
SELECT * from varchar_test13_33;
--not null constrabigint col1 error
INSERT INTO varchar_test13_33(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_33;
--ok
INSERT INTO varchar_test13_33(col1,col2) VALUES('6','2');
SELECT * from varchar_test13_33;

--varchar_test13_34
SELECT * from varchar_test13_34;
--ok
INSERT INTO varchar_test13_34 VALUES('1', '1', '1');
SELECT * from varchar_test13_34;
--PKEY col2 null error 
INSERT INTO varchar_test13_34(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_34;
--PKEY col2 not unique error
INSERT INTO varchar_test13_34(col0,col2) VALUES('3','1');
SELECT * from varchar_test13_34;
--not null constrabigint col0 error
INSERT INTO varchar_test13_34(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_34;
--ok
INSERT INTO varchar_test13_34(col0,col2) VALUES('6','2');
SELECT * from varchar_test13_34;

--varchar_test13_35
SELECT * from varchar_test13_35;
--ok
INSERT INTO varchar_test13_35 VALUES('1', '1', '1');
SELECT * from varchar_test13_35;
--PKEY col2 null error 
INSERT INTO varchar_test13_35(col0, col1) VALUES('3', '3');
SELECT * from varchar_test13_35;
--PKEY col2 not unique error
INSERT INTO varchar_test13_35(col0,col1,col2) VALUES('3','3','1');
SELECT * from varchar_test13_35;
--not null constrabigint col0 error
INSERT INTO varchar_test13_35(col1,col2) VALUES('5','5');
SELECT * from varchar_test13_35;
--not null constrabigint col1 error
INSERT INTO varchar_test13_35(col0,col2) VALUES('5','5');
SELECT * from varchar_test13_35;
--ok
INSERT INTO varchar_test13_35(col0,col1,col2) VALUES('6','6','2');
SELECT * from varchar_test13_35;

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

CREATE TABLE bigint_test14_0 (
col0 bigint ,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_1 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_2 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_3 (
col0 bigint ,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_4 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_5 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_6 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_7 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE bigint_test14_8 (
col0 bigint ,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_9 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_10 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_11 (
col0 bigint ,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_12 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_13 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_14 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_15 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_16 (
col0 bigint ,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_17 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_18 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_19 (
col0 bigint ,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_20 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_21 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_22 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_23 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_24 (
col0 bigint ,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_25 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_26 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_27 (
col0 bigint ,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_28 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_29 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_30 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_31 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE bigint_test14_32 (
col0 bigint ,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_33 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_34 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_35 (
col0 bigint ,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_36 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_37 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_38 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_39 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_40 (
col0 bigint ,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_41 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_42 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_43 (
col0 bigint ,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_44 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_45 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_46 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_47 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_48 (
col0 bigint ,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_49 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_50 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_51 (
col0 bigint ,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_52 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_53 (
col0 bigint ,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_54 (
col0 bigint NOT NULL,
col1 bigint ,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE bigint_test14_55 (
col0 bigint NOT NULL,
col1 bigint NOT NULL,
col2 bigint NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE FOREIGN TABLE bigint_test14_0 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_1 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_2 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_3 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_4 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_5 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_6 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_7 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_8 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_9 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_10 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_11 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_12 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_13 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_14 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_15 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_16 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_17 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_18 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_19 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_20 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_21 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_22 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_23 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_24 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_25 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_26 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_27 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_28 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_29 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_30 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_31 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_32 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_33 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_34 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_35 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_36 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_37 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_38 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_39 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_40 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_41 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_42 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_43 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_44 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_45 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_46 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_47 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_48 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_49 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_50 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_51 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_52 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_53 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_54 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
CREATE FOREIGN TABLE bigint_test14_55 (
col0 bigint ,col1 bigint ,col2 bigint 
) SERVER ogawayama;
--bigint_test14_0
SELECT * from bigint_test14_0;
--ok
INSERT INTO bigint_test14_0 VALUES(1, 1, 1);
SELECT * from bigint_test14_0;
--PKEY col0 null error 
INSERT INTO bigint_test14_0(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_0;
--PKEY col0 null error 
INSERT INTO bigint_test14_0(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_0;
--PKEY col0 not unique error
INSERT INTO bigint_test14_0(col0) VALUES(1);
SELECT * from bigint_test14_0;
--ok
INSERT INTO bigint_test14_0(col0) VALUES(2);
SELECT * from bigint_test14_0;

--bigint_test14_1
SELECT * from bigint_test14_1;
--ok
INSERT INTO bigint_test14_1 VALUES(1, 1, 1);
SELECT * from bigint_test14_1;
--PKEY col0 null error 
INSERT INTO bigint_test14_1(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_1;
--PKEY col0 null error 
INSERT INTO bigint_test14_1(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_1;
--PKEY col0 not unique error
INSERT INTO bigint_test14_1(col0) VALUES(1);
SELECT * from bigint_test14_1;
--not null constrabigint col0 error
INSERT INTO bigint_test14_1(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_1;
--ok
INSERT INTO bigint_test14_1(col0) VALUES(2);
SELECT * from bigint_test14_1;

--bigint_test14_2
SELECT * from bigint_test14_2;
--ok
INSERT INTO bigint_test14_2 VALUES(1, 1, 1);
SELECT * from bigint_test14_2;
--PKEY col0 null error 
INSERT INTO bigint_test14_2(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_2;
--PKEY col0 null error 
INSERT INTO bigint_test14_2(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_2;
--PKEY col0 not unique error
INSERT INTO bigint_test14_2(col0,col1) VALUES(1,3);
SELECT * from bigint_test14_2;
--not null constrabigint col1 error
INSERT INTO bigint_test14_2(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_2;
--ok
INSERT INTO bigint_test14_2(col0,col1) VALUES(2,6);
SELECT * from bigint_test14_2;

--bigint_test14_3
SELECT * from bigint_test14_3;
--ok
INSERT INTO bigint_test14_3 VALUES(1, 1, 1);
SELECT * from bigint_test14_3;
--PKEY col0 null error 
INSERT INTO bigint_test14_3(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_3;
--PKEY col0 null error 
INSERT INTO bigint_test14_3(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_3;
--PKEY col0 not unique error
INSERT INTO bigint_test14_3(col0,col2) VALUES(1,3);
SELECT * from bigint_test14_3;
--not null constrabigint col2 error
INSERT INTO bigint_test14_3(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_3;
--ok
INSERT INTO bigint_test14_3(col0,col2) VALUES(2,6);
SELECT * from bigint_test14_3;

--bigint_test14_4
SELECT * from bigint_test14_4;
--ok
INSERT INTO bigint_test14_4 VALUES(1, 1, 1);
SELECT * from bigint_test14_4;
--PKEY col0 null error 
INSERT INTO bigint_test14_4(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_4;
--PKEY col0 null error 
INSERT INTO bigint_test14_4(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_4;
--PKEY col0 not unique error
INSERT INTO bigint_test14_4(col0,col1) VALUES(1,3);
SELECT * from bigint_test14_4;
--not null constrabigint col0 error
INSERT INTO bigint_test14_4(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_4;
--not null constrabigint col1 error
INSERT INTO bigint_test14_4(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_4;
--ok
INSERT INTO bigint_test14_4(col0,col1) VALUES(2,6);
SELECT * from bigint_test14_4;

--bigint_test14_5
SELECT * from bigint_test14_5;
--ok
INSERT INTO bigint_test14_5 VALUES(1, 1, 1);
SELECT * from bigint_test14_5;
--PKEY col0 null error 
INSERT INTO bigint_test14_5(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_5;
--PKEY col0 null error 
INSERT INTO bigint_test14_5(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_5;
--PKEY col0 not unique error
INSERT INTO bigint_test14_5(col0,col1,col2) VALUES(1,3,3);
SELECT * from bigint_test14_5;
--not null constrabigint col1 error
INSERT INTO bigint_test14_5(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_5;
--not null constrabigint col2 error
INSERT INTO bigint_test14_5(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_5;
--ok
INSERT INTO bigint_test14_5(col0,col1,col2) VALUES(2,6,6);
SELECT * from bigint_test14_5;

--bigint_test14_6
SELECT * from bigint_test14_6;
--ok
INSERT INTO bigint_test14_6 VALUES(1, 1, 1);
SELECT * from bigint_test14_6;
--PKEY col0 null error 
INSERT INTO bigint_test14_6(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_6;
--PKEY col0 null error 
INSERT INTO bigint_test14_6(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_6;
--PKEY col0 not unique error
INSERT INTO bigint_test14_6(col0,col2) VALUES(1,3);
SELECT * from bigint_test14_6;
--not null constrabigint col0 error
INSERT INTO bigint_test14_6(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_6;
--not null constrabigint col2 error
INSERT INTO bigint_test14_6(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_6;
--ok
INSERT INTO bigint_test14_6(col0,col2) VALUES(2,6);
SELECT * from bigint_test14_6;

--bigint_test14_7
SELECT * from bigint_test14_7;
--ok
INSERT INTO bigint_test14_7 VALUES(1, 1, 1);
SELECT * from bigint_test14_7;
--PKEY col0 null error 
INSERT INTO bigint_test14_7(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_7;
--PKEY col0 null error 
INSERT INTO bigint_test14_7(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_7;
--PKEY col0 not unique error
INSERT INTO bigint_test14_7(col0,col1,col2) VALUES(1,3,3);
SELECT * from bigint_test14_7;
--not null constrabigint col0 error
INSERT INTO bigint_test14_7(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_7;
--not null constrabigint col1 error
INSERT INTO bigint_test14_7(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_7;
--not null constrabigint col2 error
INSERT INTO bigint_test14_7(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_7;
--ok
INSERT INTO bigint_test14_7(col0,col1,col2) VALUES(2,6,6);
SELECT * from bigint_test14_7;

--bigint_test14_8
SELECT * from bigint_test14_8;
--ok
INSERT INTO bigint_test14_8 VALUES(1, 1, 1);
SELECT * from bigint_test14_8;
--PKEY col1 null error 
INSERT INTO bigint_test14_8(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_8;
--PKEY col1 null error 
INSERT INTO bigint_test14_8(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_8;
--PKEY col1 not unique error
INSERT INTO bigint_test14_8(col1) VALUES(1);
SELECT * from bigint_test14_8;
--ok
INSERT INTO bigint_test14_8(col1) VALUES(2);
SELECT * from bigint_test14_8;

--bigint_test14_9
SELECT * from bigint_test14_9;
--ok
INSERT INTO bigint_test14_9 VALUES(1, 1, 1);
SELECT * from bigint_test14_9;
--PKEY col1 null error 
INSERT INTO bigint_test14_9(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_9;
--PKEY col1 null error 
INSERT INTO bigint_test14_9(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_9;
--PKEY col1 not unique error
INSERT INTO bigint_test14_9(col0,col1) VALUES(3,1);
SELECT * from bigint_test14_9;
--not null constrabigint col0 error
INSERT INTO bigint_test14_9(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_9;
--ok
INSERT INTO bigint_test14_9(col0,col1) VALUES(6,2);
SELECT * from bigint_test14_9;

--bigint_test14_10
SELECT * from bigint_test14_10;
--ok
INSERT INTO bigint_test14_10 VALUES(1, 1, 1);
SELECT * from bigint_test14_10;
--PKEY col1 null error 
INSERT INTO bigint_test14_10(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_10;
--PKEY col1 null error 
INSERT INTO bigint_test14_10(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_10;
--PKEY col1 not unique error
INSERT INTO bigint_test14_10(col1) VALUES(1);
SELECT * from bigint_test14_10;
--not null constrabigint col1 error
INSERT INTO bigint_test14_10(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_10;
--ok
INSERT INTO bigint_test14_10(col1) VALUES(2);
SELECT * from bigint_test14_10;

--bigint_test14_11
SELECT * from bigint_test14_11;
--ok
INSERT INTO bigint_test14_11 VALUES(1, 1, 1);
SELECT * from bigint_test14_11;
--PKEY col1 null error 
INSERT INTO bigint_test14_11(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_11;
--PKEY col1 null error 
INSERT INTO bigint_test14_11(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_11;
--PKEY col1 not unique error
INSERT INTO bigint_test14_11(col1,col2) VALUES(1,3);
SELECT * from bigint_test14_11;
--not null constrabigint col2 error
INSERT INTO bigint_test14_11(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_11;
--ok
INSERT INTO bigint_test14_11(col1,col2) VALUES(2,6);
SELECT * from bigint_test14_11;

--bigint_test14_12
SELECT * from bigint_test14_12;
--ok
INSERT INTO bigint_test14_12 VALUES(1, 1, 1);
SELECT * from bigint_test14_12;
--PKEY col1 null error 
INSERT INTO bigint_test14_12(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_12;
--PKEY col1 null error 
INSERT INTO bigint_test14_12(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_12;
--PKEY col1 not unique error
INSERT INTO bigint_test14_12(col0,col1) VALUES(3,1);
SELECT * from bigint_test14_12;
--not null constrabigint col0 error
INSERT INTO bigint_test14_12(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_12;
--not null constrabigint col1 error
INSERT INTO bigint_test14_12(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_12;
--ok
INSERT INTO bigint_test14_12(col0,col1) VALUES(6,2);
SELECT * from bigint_test14_12;

--bigint_test14_13
SELECT * from bigint_test14_13;
--ok
INSERT INTO bigint_test14_13 VALUES(1, 1, 1);
SELECT * from bigint_test14_13;
--PKEY col1 null error 
INSERT INTO bigint_test14_13(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_13;
--PKEY col1 null error 
INSERT INTO bigint_test14_13(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_13;
--PKEY col1 not unique error
INSERT INTO bigint_test14_13(col1,col2) VALUES(1,3);
SELECT * from bigint_test14_13;
--not null constrabigint col1 error
INSERT INTO bigint_test14_13(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_13;
--not null constrabigint col2 error
INSERT INTO bigint_test14_13(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_13;
--ok
INSERT INTO bigint_test14_13(col1,col2) VALUES(2,6);
SELECT * from bigint_test14_13;

--bigint_test14_14
SELECT * from bigint_test14_14;
--ok
INSERT INTO bigint_test14_14 VALUES(1, 1, 1);
SELECT * from bigint_test14_14;
--PKEY col1 null error 
INSERT INTO bigint_test14_14(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_14;
--PKEY col1 null error 
INSERT INTO bigint_test14_14(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_14;
--PKEY col1 not unique error
INSERT INTO bigint_test14_14(col0,col1,col2) VALUES(3,1,3);
SELECT * from bigint_test14_14;
--not null constrabigint col0 error
INSERT INTO bigint_test14_14(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_14;
--not null constrabigint col2 error
INSERT INTO bigint_test14_14(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_14;
--ok
INSERT INTO bigint_test14_14(col0,col1,col2) VALUES(6,2,6);
SELECT * from bigint_test14_14;

--bigint_test14_15
SELECT * from bigint_test14_15;
--ok
INSERT INTO bigint_test14_15 VALUES(1, 1, 1);
SELECT * from bigint_test14_15;
--PKEY col1 null error 
INSERT INTO bigint_test14_15(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_15;
--PKEY col1 null error 
INSERT INTO bigint_test14_15(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_15;
--PKEY col1 not unique error
INSERT INTO bigint_test14_15(col0,col1,col2) VALUES(3,1,3);
SELECT * from bigint_test14_15;
--not null constrabigint col0 error
INSERT INTO bigint_test14_15(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_15;
--not null constrabigint col1 error
INSERT INTO bigint_test14_15(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_15;
--not null constrabigint col2 error
INSERT INTO bigint_test14_15(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_15;
--ok
INSERT INTO bigint_test14_15(col0,col1,col2) VALUES(6,2,6);
SELECT * from bigint_test14_15;

--bigint_test14_16
SELECT * from bigint_test14_16;
--ok
INSERT INTO bigint_test14_16 VALUES(1, 1, 1);
SELECT * from bigint_test14_16;
--PKEY col2 null error 
INSERT INTO bigint_test14_16(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_16;
--PKEY col2 null error 
INSERT INTO bigint_test14_16(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_16;
--PKEY col2 not unique error
INSERT INTO bigint_test14_16(col2) VALUES(1);
SELECT * from bigint_test14_16;
--ok
INSERT INTO bigint_test14_16(col2) VALUES(2);
SELECT * from bigint_test14_16;

--bigint_test14_17
SELECT * from bigint_test14_17;
--ok
INSERT INTO bigint_test14_17 VALUES(1, 1, 1);
SELECT * from bigint_test14_17;
--PKEY col2 null error 
INSERT INTO bigint_test14_17(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_17;
--PKEY col2 null error 
INSERT INTO bigint_test14_17(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_17;
--PKEY col2 not unique error
INSERT INTO bigint_test14_17(col0,col2) VALUES(3,1);
SELECT * from bigint_test14_17;
--not null constrabigint col0 error
INSERT INTO bigint_test14_17(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_17;
--ok
INSERT INTO bigint_test14_17(col0,col2) VALUES(6,2);
SELECT * from bigint_test14_17;

--bigint_test14_18
SELECT * from bigint_test14_18;
--ok
INSERT INTO bigint_test14_18 VALUES(1, 1, 1);
SELECT * from bigint_test14_18;
--PKEY col2 null error 
INSERT INTO bigint_test14_18(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_18;
--PKEY col2 null error 
INSERT INTO bigint_test14_18(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_18;
--PKEY col2 not unique error
INSERT INTO bigint_test14_18(col1,col2) VALUES(3,1);
SELECT * from bigint_test14_18;
--not null constrabigint col1 error
INSERT INTO bigint_test14_18(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_18;
--ok
INSERT INTO bigint_test14_18(col1,col2) VALUES(6,2);
SELECT * from bigint_test14_18;

--bigint_test14_19
SELECT * from bigint_test14_19;
--ok
INSERT INTO bigint_test14_19 VALUES(1, 1, 1);
SELECT * from bigint_test14_19;
--PKEY col2 null error 
INSERT INTO bigint_test14_19(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_19;
--PKEY col2 null error 
INSERT INTO bigint_test14_19(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_19;
--PKEY col2 not unique error
INSERT INTO bigint_test14_19(col2) VALUES(1);
SELECT * from bigint_test14_19;
--not null constrabigint col2 error
INSERT INTO bigint_test14_19(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_19;
--ok
INSERT INTO bigint_test14_19(col2) VALUES(2);
SELECT * from bigint_test14_19;

--bigint_test14_20
SELECT * from bigint_test14_20;
--ok
INSERT INTO bigint_test14_20 VALUES(1, 1, 1);
SELECT * from bigint_test14_20;
--PKEY col2 null error 
INSERT INTO bigint_test14_20(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_20;
--PKEY col2 null error 
INSERT INTO bigint_test14_20(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_20;
--PKEY col2 not unique error
INSERT INTO bigint_test14_20(col0,col1,col2) VALUES(3,3,1);
SELECT * from bigint_test14_20;
--not null constrabigint col0 error
INSERT INTO bigint_test14_20(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_20;
--not null constrabigint col1 error
INSERT INTO bigint_test14_20(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_20;
--ok
INSERT INTO bigint_test14_20(col0,col1,col2) VALUES(6,6,2);
SELECT * from bigint_test14_20;

--bigint_test14_21
SELECT * from bigint_test14_21;
--ok
INSERT INTO bigint_test14_21 VALUES(1, 1, 1);
SELECT * from bigint_test14_21;
--PKEY col2 null error 
INSERT INTO bigint_test14_21(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_21;
--PKEY col2 null error 
INSERT INTO bigint_test14_21(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_21;
--PKEY col2 not unique error
INSERT INTO bigint_test14_21(col1,col2) VALUES(3,1);
SELECT * from bigint_test14_21;
--not null constrabigint col1 error
INSERT INTO bigint_test14_21(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_21;
--not null constrabigint col2 error
INSERT INTO bigint_test14_21(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_21;
--ok
INSERT INTO bigint_test14_21(col1,col2) VALUES(6,2);
SELECT * from bigint_test14_21;

--bigint_test14_22
SELECT * from bigint_test14_22;
--ok
INSERT INTO bigint_test14_22 VALUES(1, 1, 1);
SELECT * from bigint_test14_22;
--PKEY col2 null error 
INSERT INTO bigint_test14_22(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_22;
--PKEY col2 null error 
INSERT INTO bigint_test14_22(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_22;
--PKEY col2 not unique error
INSERT INTO bigint_test14_22(col0,col2) VALUES(3,1);
SELECT * from bigint_test14_22;
--not null constrabigint col0 error
INSERT INTO bigint_test14_22(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_22;
--not null constrabigint col2 error
INSERT INTO bigint_test14_22(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_22;
--ok
INSERT INTO bigint_test14_22(col0,col2) VALUES(6,2);
SELECT * from bigint_test14_22;

--bigint_test14_23
SELECT * from bigint_test14_23;
--ok
INSERT INTO bigint_test14_23 VALUES(1, 1, 1);
SELECT * from bigint_test14_23;
--PKEY col2 null error 
INSERT INTO bigint_test14_23(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_23;
--PKEY col2 null error 
INSERT INTO bigint_test14_23(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_23;
--PKEY col2 not unique error
INSERT INTO bigint_test14_23(col0,col1,col2) VALUES(3,3,1);
SELECT * from bigint_test14_23;
--not null constrabigint col0 error
INSERT INTO bigint_test14_23(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_23;
--not null constrabigint col1 error
INSERT INTO bigint_test14_23(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_23;
--not null constrabigint col2 error
INSERT INTO bigint_test14_23(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_23;
--ok
INSERT INTO bigint_test14_23(col0,col1,col2) VALUES(6,6,2);
SELECT * from bigint_test14_23;

--bigint_test14_24
SELECT * from bigint_test14_24;
--ok
INSERT INTO bigint_test14_24 VALUES(1, 1, 1);
SELECT * from bigint_test14_24;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_24(col2) VALUES(3);
SELECT * from bigint_test14_24;
--PKEY col0 null error 
INSERT INTO bigint_test14_24(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_24;
--PKEY col1 null error 
INSERT INTO bigint_test14_24(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_24;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_24(col0,col1) VALUES(1,1);
SELECT * from bigint_test14_24;
--ok
INSERT INTO bigint_test14_24(col0,col1) VALUES(2,2);
SELECT * from bigint_test14_24;

--bigint_test14_25
SELECT * from bigint_test14_25;
--ok
INSERT INTO bigint_test14_25 VALUES(1, 1, 1);
SELECT * from bigint_test14_25;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_25(col2) VALUES(3);
SELECT * from bigint_test14_25;
--PKEY col0 null error 
INSERT INTO bigint_test14_25(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_25;
--PKEY col1 null error 
INSERT INTO bigint_test14_25(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_25;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_25(col0,col1) VALUES(1,1);
SELECT * from bigint_test14_25;
--not null constrabigint col0 error
INSERT INTO bigint_test14_25(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_25;
--ok
INSERT INTO bigint_test14_25(col0,col1) VALUES(2,2);
SELECT * from bigint_test14_25;

--bigint_test14_26
SELECT * from bigint_test14_26;
--ok
INSERT INTO bigint_test14_26 VALUES(1, 1, 1);
SELECT * from bigint_test14_26;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_26(col2) VALUES(3);
SELECT * from bigint_test14_26;
--PKEY col0 null error 
INSERT INTO bigint_test14_26(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_26;
--PKEY col1 null error 
INSERT INTO bigint_test14_26(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_26;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_26(col0,col1) VALUES(1,1);
SELECT * from bigint_test14_26;
--not null constrabigint col1 error
INSERT INTO bigint_test14_26(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_26;
--ok
INSERT INTO bigint_test14_26(col0,col1) VALUES(2,2);
SELECT * from bigint_test14_26;

--bigint_test14_27
SELECT * from bigint_test14_27;
--ok
INSERT INTO bigint_test14_27 VALUES(1, 1, 1);
SELECT * from bigint_test14_27;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_27(col2) VALUES(3);
SELECT * from bigint_test14_27;
--PKEY col0 null error 
INSERT INTO bigint_test14_27(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_27;
--PKEY col1 null error 
INSERT INTO bigint_test14_27(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_27;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_27(col0,col1,col2) VALUES(1,1,3);
SELECT * from bigint_test14_27;
--not null constrabigint col2 error
INSERT INTO bigint_test14_27(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_27;
--ok
INSERT INTO bigint_test14_27(col0,col1,col2) VALUES(2,2,6);
SELECT * from bigint_test14_27;

--bigint_test14_28
SELECT * from bigint_test14_28;
--ok
INSERT INTO bigint_test14_28 VALUES(1, 1, 1);
SELECT * from bigint_test14_28;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_28(col2) VALUES(3);
SELECT * from bigint_test14_28;
--PKEY col0 null error 
INSERT INTO bigint_test14_28(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_28;
--PKEY col1 null error 
INSERT INTO bigint_test14_28(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_28;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_28(col0,col1) VALUES(1,1);
SELECT * from bigint_test14_28;
--not null constrabigint col0 error
INSERT INTO bigint_test14_28(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_28;
--not null constrabigint col1 error
INSERT INTO bigint_test14_28(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_28;
--ok
INSERT INTO bigint_test14_28(col0,col1) VALUES(2,2);
SELECT * from bigint_test14_28;

--bigint_test14_29
SELECT * from bigint_test14_29;
--ok
INSERT INTO bigint_test14_29 VALUES(1, 1, 1);
SELECT * from bigint_test14_29;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_29(col2) VALUES(3);
SELECT * from bigint_test14_29;
--PKEY col0 null error 
INSERT INTO bigint_test14_29(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_29;
--PKEY col1 null error 
INSERT INTO bigint_test14_29(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_29;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_29(col0,col1,col2) VALUES(1,1,3);
SELECT * from bigint_test14_29;
--not null constrabigint col1 error
INSERT INTO bigint_test14_29(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_29;
--not null constrabigint col2 error
INSERT INTO bigint_test14_29(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_29;
--ok
INSERT INTO bigint_test14_29(col0,col1,col2) VALUES(2,2,6);
SELECT * from bigint_test14_29;

--bigint_test14_30
SELECT * from bigint_test14_30;
--ok
INSERT INTO bigint_test14_30 VALUES(1, 1, 1);
SELECT * from bigint_test14_30;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_30(col2) VALUES(3);
SELECT * from bigint_test14_30;
--PKEY col0 null error 
INSERT INTO bigint_test14_30(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_30;
--PKEY col1 null error 
INSERT INTO bigint_test14_30(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_30;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_30(col0,col1,col2) VALUES(1,1,3);
SELECT * from bigint_test14_30;
--not null constrabigint col0 error
INSERT INTO bigint_test14_30(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_30;
--not null constrabigint col2 error
INSERT INTO bigint_test14_30(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_30;
--ok
INSERT INTO bigint_test14_30(col0,col1,col2) VALUES(2,2,6);
SELECT * from bigint_test14_30;

--bigint_test14_31
SELECT * from bigint_test14_31;
--ok
INSERT INTO bigint_test14_31 VALUES(1, 1, 1);
SELECT * from bigint_test14_31;
--PKEY col0 col1 null error 
INSERT INTO bigint_test14_31(col2) VALUES(3);
SELECT * from bigint_test14_31;
--PKEY col0 null error 
INSERT INTO bigint_test14_31(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_31;
--PKEY col1 null error 
INSERT INTO bigint_test14_31(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_31;
--PKEY col0 col1 not unique error
INSERT INTO bigint_test14_31(col0,col1,col2) VALUES(1,1,3);
SELECT * from bigint_test14_31;
--not null constrabigint col0 error
INSERT INTO bigint_test14_31(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_31;
--not null constrabigint col1 error
INSERT INTO bigint_test14_31(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_31;
--not null constrabigint col2 error
INSERT INTO bigint_test14_31(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_31;
--ok
INSERT INTO bigint_test14_31(col0,col1,col2) VALUES(2,2,6);
SELECT * from bigint_test14_31;

--bigint_test14_32
SELECT * from bigint_test14_32;
--ok
INSERT INTO bigint_test14_32 VALUES(1, 1, 1);
SELECT * from bigint_test14_32;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_32(col0) VALUES(3);
SELECT * from bigint_test14_32;
--PKEY col1 null error 
INSERT INTO bigint_test14_32(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_32;
--PKEY col2 null error 
INSERT INTO bigint_test14_32(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_32;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_32(col1,col2) VALUES(1,1);
SELECT * from bigint_test14_32;
--ok
INSERT INTO bigint_test14_32(col1,col2) VALUES(2,2);
SELECT * from bigint_test14_32;

--bigint_test14_33
SELECT * from bigint_test14_33;
--ok
INSERT INTO bigint_test14_33 VALUES(1, 1, 1);
SELECT * from bigint_test14_33;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_33(col0) VALUES(3);
SELECT * from bigint_test14_33;
--PKEY col1 null error 
INSERT INTO bigint_test14_33(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_33;
--PKEY col2 null error 
INSERT INTO bigint_test14_33(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_33;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_33(col0,col1,col2) VALUES(3,1,1);
SELECT * from bigint_test14_33;
--not null constrabigint col0 error
INSERT INTO bigint_test14_33(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_33;
--ok
INSERT INTO bigint_test14_33(col0,col1,col2) VALUES(6,2,2);
SELECT * from bigint_test14_33;

--bigint_test14_34
SELECT * from bigint_test14_34;
--ok
INSERT INTO bigint_test14_34 VALUES(1, 1, 1);
SELECT * from bigint_test14_34;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_34(col0) VALUES(3);
SELECT * from bigint_test14_34;
--PKEY col1 null error 
INSERT INTO bigint_test14_34(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_34;
--PKEY col2 null error 
INSERT INTO bigint_test14_34(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_34;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_34(col1,col2) VALUES(1,1);
SELECT * from bigint_test14_34;
--not null constrabigint col1 error
INSERT INTO bigint_test14_34(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_34;
--ok
INSERT INTO bigint_test14_34(col1,col2) VALUES(2,2);
SELECT * from bigint_test14_34;

--bigint_test14_35
SELECT * from bigint_test14_35;
--ok
INSERT INTO bigint_test14_35 VALUES(1, 1, 1);
SELECT * from bigint_test14_35;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_35(col0) VALUES(3);
SELECT * from bigint_test14_35;
--PKEY col1 null error 
INSERT INTO bigint_test14_35(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_35;
--PKEY col2 null error 
INSERT INTO bigint_test14_35(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_35;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_35(col1,col2) VALUES(1,1);
SELECT * from bigint_test14_35;
--not null constrabigint col2 error
INSERT INTO bigint_test14_35(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_35;
--ok
INSERT INTO bigint_test14_35(col1,col2) VALUES(2,2);
SELECT * from bigint_test14_35;

--bigint_test14_36
SELECT * from bigint_test14_36;
--ok
INSERT INTO bigint_test14_36 VALUES(1, 1, 1);
SELECT * from bigint_test14_36;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_36(col0) VALUES(3);
SELECT * from bigint_test14_36;
--PKEY col1 null error 
INSERT INTO bigint_test14_36(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_36;
--PKEY col2 null error 
INSERT INTO bigint_test14_36(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_36;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_36(col0,col1,col2) VALUES(3,1,1);
SELECT * from bigint_test14_36;
--not null constrabigint col0 error
INSERT INTO bigint_test14_36(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_36;
--not null constrabigint col1 error
INSERT INTO bigint_test14_36(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_36;
--ok
INSERT INTO bigint_test14_36(col0,col1,col2) VALUES(6,2,2);
SELECT * from bigint_test14_36;

--bigint_test14_37
SELECT * from bigint_test14_37;
--ok
INSERT INTO bigint_test14_37 VALUES(1, 1, 1);
SELECT * from bigint_test14_37;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_37(col0) VALUES(3);
SELECT * from bigint_test14_37;
--PKEY col1 null error 
INSERT INTO bigint_test14_37(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_37;
--PKEY col2 null error 
INSERT INTO bigint_test14_37(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_37;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_37(col1,col2) VALUES(1,1);
SELECT * from bigint_test14_37;
--not null constrabigint col1 error
INSERT INTO bigint_test14_37(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_37;
--not null constrabigint col2 error
INSERT INTO bigint_test14_37(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_37;
--ok
INSERT INTO bigint_test14_37(col1,col2) VALUES(2,2);
SELECT * from bigint_test14_37;

--bigint_test14_38
SELECT * from bigint_test14_38;
--ok
INSERT INTO bigint_test14_38 VALUES(1, 1, 1);
SELECT * from bigint_test14_38;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_38(col0) VALUES(3);
SELECT * from bigint_test14_38;
--PKEY col1 null error 
INSERT INTO bigint_test14_38(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_38;
--PKEY col2 null error 
INSERT INTO bigint_test14_38(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_38;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_38(col0,col1,col2) VALUES(3,1,1);
SELECT * from bigint_test14_38;
--not null constrabigint col0 error
INSERT INTO bigint_test14_38(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_38;
--not null constrabigint col2 error
INSERT INTO bigint_test14_38(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_38;
--ok
INSERT INTO bigint_test14_38(col0,col1,col2) VALUES(6,2,2);
SELECT * from bigint_test14_38;

--bigint_test14_39
SELECT * from bigint_test14_39;
--ok
INSERT INTO bigint_test14_39 VALUES(1, 1, 1);
SELECT * from bigint_test14_39;
--PKEY col1 col2 null error 
INSERT INTO bigint_test14_39(col0) VALUES(3);
SELECT * from bigint_test14_39;
--PKEY col1 null error 
INSERT INTO bigint_test14_39(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_39;
--PKEY col2 null error 
INSERT INTO bigint_test14_39(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_39;
--PKEY col1 col2 not unique error
INSERT INTO bigint_test14_39(col0,col1,col2) VALUES(3,1,1);
SELECT * from bigint_test14_39;
--not null constrabigint col0 error
INSERT INTO bigint_test14_39(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_39;
--not null constrabigint col1 error
INSERT INTO bigint_test14_39(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_39;
--not null constrabigint col2 error
INSERT INTO bigint_test14_39(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_39;
--ok
INSERT INTO bigint_test14_39(col0,col1,col2) VALUES(6,2,2);
SELECT * from bigint_test14_39;

--bigint_test14_40
SELECT * from bigint_test14_40;
--ok
INSERT INTO bigint_test14_40 VALUES(1, 1, 1);
SELECT * from bigint_test14_40;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_40(col1) VALUES(3);
SELECT * from bigint_test14_40;
--PKEY col0 null error 
INSERT INTO bigint_test14_40(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_40;
--PKEY col2 null error 
INSERT INTO bigint_test14_40(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_40;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_40(col0,col2) VALUES(1,1);
SELECT * from bigint_test14_40;
--ok
INSERT INTO bigint_test14_40(col0,col2) VALUES(2,2);
SELECT * from bigint_test14_40;

--bigint_test14_41
SELECT * from bigint_test14_41;
--ok
INSERT INTO bigint_test14_41 VALUES(1, 1, 1);
SELECT * from bigint_test14_41;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_41(col1) VALUES(3);
SELECT * from bigint_test14_41;
--PKEY col0 null error 
INSERT INTO bigint_test14_41(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_41;
--PKEY col2 null error 
INSERT INTO bigint_test14_41(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_41;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_41(col0,col2) VALUES(1,1);
SELECT * from bigint_test14_41;
--not null constrabigint col0 error
INSERT INTO bigint_test14_41(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_41;
--ok
INSERT INTO bigint_test14_41(col0,col2) VALUES(2,2);
SELECT * from bigint_test14_41;

--bigint_test14_42
SELECT * from bigint_test14_42;
--ok
INSERT INTO bigint_test14_42 VALUES(1, 1, 1);
SELECT * from bigint_test14_42;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_42(col1) VALUES(3);
SELECT * from bigint_test14_42;
--PKEY col0 null error 
INSERT INTO bigint_test14_42(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_42;
--PKEY col2 null error 
INSERT INTO bigint_test14_42(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_42;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_42(col0,col1,col2) VALUES(1,3,1);
SELECT * from bigint_test14_42;
--not null constrabigint col1 error
INSERT INTO bigint_test14_42(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_42;
--ok
INSERT INTO bigint_test14_42(col0,col1,col2) VALUES(2,6,2);
SELECT * from bigint_test14_42;

--bigint_test14_43
SELECT * from bigint_test14_43;
--ok
INSERT INTO bigint_test14_43 VALUES(1, 1, 1);
SELECT * from bigint_test14_43;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_43(col1) VALUES(3);
SELECT * from bigint_test14_43;
--PKEY col0 null error 
INSERT INTO bigint_test14_43(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_43;
--PKEY col2 null error 
INSERT INTO bigint_test14_43(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_43;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_43(col0,col2) VALUES(1,1);
SELECT * from bigint_test14_43;
--not null constrabigint col2 error
INSERT INTO bigint_test14_43(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_43;
--ok
INSERT INTO bigint_test14_43(col0,col2) VALUES(2,2);
SELECT * from bigint_test14_43;

--bigint_test14_44
SELECT * from bigint_test14_44;
--ok
INSERT INTO bigint_test14_44 VALUES(1, 1, 1);
SELECT * from bigint_test14_44;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_44(col1) VALUES(3);
SELECT * from bigint_test14_44;
--PKEY col0 null error 
INSERT INTO bigint_test14_44(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_44;
--PKEY col2 null error 
INSERT INTO bigint_test14_44(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_44;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_44(col0,col1,col2) VALUES(1,3,1);
SELECT * from bigint_test14_44;
--not null constrabigint col0 error
INSERT INTO bigint_test14_44(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_44;
--not null constrabigint col1 error
INSERT INTO bigint_test14_44(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_44;
--ok
INSERT INTO bigint_test14_44(col0,col1,col2) VALUES(2,6,2);
SELECT * from bigint_test14_44;

--bigint_test14_45
SELECT * from bigint_test14_45;
--ok
INSERT INTO bigint_test14_45 VALUES(1, 1, 1);
SELECT * from bigint_test14_45;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_45(col1) VALUES(3);
SELECT * from bigint_test14_45;
--PKEY col0 null error 
INSERT INTO bigint_test14_45(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_45;
--PKEY col2 null error 
INSERT INTO bigint_test14_45(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_45;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_45(col0,col1,col2) VALUES(1,3,1);
SELECT * from bigint_test14_45;
--not null constrabigint col1 error
INSERT INTO bigint_test14_45(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_45;
--not null constrabigint col2 error
INSERT INTO bigint_test14_45(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_45;
--ok
INSERT INTO bigint_test14_45(col0,col1,col2) VALUES(2,6,2);
SELECT * from bigint_test14_45;

--bigint_test14_46
SELECT * from bigint_test14_46;
--ok
INSERT INTO bigint_test14_46 VALUES(1, 1, 1);
SELECT * from bigint_test14_46;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_46(col1) VALUES(3);
SELECT * from bigint_test14_46;
--PKEY col0 null error 
INSERT INTO bigint_test14_46(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_46;
--PKEY col2 null error 
INSERT INTO bigint_test14_46(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_46;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_46(col0,col2) VALUES(1,1);
SELECT * from bigint_test14_46;
--not null constrabigint col0 error
INSERT INTO bigint_test14_46(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_46;
--not null constrabigint col2 error
INSERT INTO bigint_test14_46(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_46;
--ok
INSERT INTO bigint_test14_46(col0,col2) VALUES(2,2);
SELECT * from bigint_test14_46;

--bigint_test14_47
SELECT * from bigint_test14_47;
--ok
INSERT INTO bigint_test14_47 VALUES(1, 1, 1);
SELECT * from bigint_test14_47;
--PKEY col0 col2 null error 
INSERT INTO bigint_test14_47(col1) VALUES(3);
SELECT * from bigint_test14_47;
--PKEY col0 null error 
INSERT INTO bigint_test14_47(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_47;
--PKEY col2 null error 
INSERT INTO bigint_test14_47(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_47;
--PKEY col0 col2 not unique error
INSERT INTO bigint_test14_47(col0,col1,col2) VALUES(1,3,1);
SELECT * from bigint_test14_47;
--not null constrabigint col0 error
INSERT INTO bigint_test14_47(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_47;
--not null constrabigint col1 error
INSERT INTO bigint_test14_47(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_47;
--not null constrabigint col2 error
INSERT INTO bigint_test14_47(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_47;
--ok
INSERT INTO bigint_test14_47(col0,col1,col2) VALUES(2,6,2);
SELECT * from bigint_test14_47;

--bigint_test14_48
SELECT * from bigint_test14_48;
--ok
INSERT INTO bigint_test14_48 VALUES(1, 1, 1);
SELECT * from bigint_test14_48;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_48() VALUES();
SELECT * from bigint_test14_48;
--PKEY col0 null error 
INSERT INTO bigint_test14_48(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_48;
--PKEY col1 null error 
INSERT INTO bigint_test14_48(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_48;
--PKEY col2 null error 
INSERT INTO bigint_test14_48(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_48;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_48(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_48;
--ok
INSERT INTO bigint_test14_48(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_48;

--bigint_test14_49
SELECT * from bigint_test14_49;
--ok
INSERT INTO bigint_test14_49 VALUES(1, 1, 1);
SELECT * from bigint_test14_49;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_49() VALUES();
SELECT * from bigint_test14_49;
--PKEY col0 null error 
INSERT INTO bigint_test14_49(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_49;
--PKEY col1 null error 
INSERT INTO bigint_test14_49(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_49;
--PKEY col2 null error 
INSERT INTO bigint_test14_49(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_49;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_49(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_49;
--not null constrabigint col0 error
INSERT INTO bigint_test14_49(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_49;
--ok
INSERT INTO bigint_test14_49(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_49;

--bigint_test14_50
SELECT * from bigint_test14_50;
--ok
INSERT INTO bigint_test14_50 VALUES(1, 1, 1);
SELECT * from bigint_test14_50;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_50() VALUES();
SELECT * from bigint_test14_50;
--PKEY col0 null error 
INSERT INTO bigint_test14_50(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_50;
--PKEY col1 null error 
INSERT INTO bigint_test14_50(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_50;
--PKEY col2 null error 
INSERT INTO bigint_test14_50(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_50;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_50(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_50;
--not null constrabigint col1 error
INSERT INTO bigint_test14_50(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_50;
--ok
INSERT INTO bigint_test14_50(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_50;

--bigint_test14_51
SELECT * from bigint_test14_51;
--ok
INSERT INTO bigint_test14_51 VALUES(1, 1, 1);
SELECT * from bigint_test14_51;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_51() VALUES();
SELECT * from bigint_test14_51;
--PKEY col0 null error 
INSERT INTO bigint_test14_51(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_51;
--PKEY col1 null error 
INSERT INTO bigint_test14_51(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_51;
--PKEY col2 null error 
INSERT INTO bigint_test14_51(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_51;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_51(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_51;
--not null constrabigint col2 error
INSERT INTO bigint_test14_51(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_51;
--ok
INSERT INTO bigint_test14_51(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_51;

--bigint_test14_52
SELECT * from bigint_test14_52;
--ok
INSERT INTO bigint_test14_52 VALUES(1, 1, 1);
SELECT * from bigint_test14_52;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_52() VALUES();
SELECT * from bigint_test14_52;
--PKEY col0 null error 
INSERT INTO bigint_test14_52(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_52;
--PKEY col1 null error 
INSERT INTO bigint_test14_52(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_52;
--PKEY col2 null error 
INSERT INTO bigint_test14_52(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_52;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_52(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_52;
--not null constrabigint col0 error
INSERT INTO bigint_test14_52(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_52;
--not null constrabigint col1 error
INSERT INTO bigint_test14_52(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_52;
--ok
INSERT INTO bigint_test14_52(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_52;

--bigint_test14_53
SELECT * from bigint_test14_53;
--ok
INSERT INTO bigint_test14_53 VALUES(1, 1, 1);
SELECT * from bigint_test14_53;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_53() VALUES();
SELECT * from bigint_test14_53;
--PKEY col0 null error 
INSERT INTO bigint_test14_53(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_53;
--PKEY col1 null error 
INSERT INTO bigint_test14_53(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_53;
--PKEY col2 null error 
INSERT INTO bigint_test14_53(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_53;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_53(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_53;
--not null constrabigint col1 error
INSERT INTO bigint_test14_53(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_53;
--not null constrabigint col2 error
INSERT INTO bigint_test14_53(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_53;
--ok
INSERT INTO bigint_test14_53(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_53;

--bigint_test14_54
SELECT * from bigint_test14_54;
--ok
INSERT INTO bigint_test14_54 VALUES(1, 1, 1);
SELECT * from bigint_test14_54;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_54() VALUES();
SELECT * from bigint_test14_54;
--PKEY col0 null error 
INSERT INTO bigint_test14_54(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_54;
--PKEY col1 null error 
INSERT INTO bigint_test14_54(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_54;
--PKEY col2 null error 
INSERT INTO bigint_test14_54(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_54;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_54(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_54;
--not null constrabigint col0 error
INSERT INTO bigint_test14_54(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_54;
--not null constrabigint col2 error
INSERT INTO bigint_test14_54(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_54;
--ok
INSERT INTO bigint_test14_54(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_54;

--bigint_test14_55
SELECT * from bigint_test14_55;
--ok
INSERT INTO bigint_test14_55 VALUES(1, 1, 1);
SELECT * from bigint_test14_55;
--PKEY col0 col1 col2 null error 
INSERT INTO bigint_test14_55() VALUES();
SELECT * from bigint_test14_55;
--PKEY col0 null error 
INSERT INTO bigint_test14_55(col1,col2) VALUES(3,3);
SELECT * from bigint_test14_55;
--PKEY col1 null error 
INSERT INTO bigint_test14_55(col0,col2) VALUES(3,3);
SELECT * from bigint_test14_55;
--PKEY col2 null error 
INSERT INTO bigint_test14_55(col0,col1) VALUES(3,3);
SELECT * from bigint_test14_55;
--PKEY col0 col1 col2 not unique error
INSERT INTO bigint_test14_55(col0,col1,col2) VALUES(1,1,1);
SELECT * from bigint_test14_55;
--not null constrabigint col0 error
INSERT INTO bigint_test14_55(col1,col2) VALUES(5,5);
SELECT * from bigint_test14_55;
--not null constrabigint col1 error
INSERT INTO bigint_test14_55(col0,col2) VALUES(5,5);
SELECT * from bigint_test14_55;
--not null constrabigint col2 error
INSERT INTO bigint_test14_55(col0,col1) VALUES(5,5);
SELECT * from bigint_test14_55;
--ok
INSERT INTO bigint_test14_55(col0,col1,col2) VALUES(2,2,2);
SELECT * from bigint_test14_55;

CREATE TABLE real_test14_0 (
col0 real ,
col1 real ,
col2 real ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_1 (
col0 real NOT NULL,
col1 real ,
col2 real ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_2 (
col0 real ,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_3 (
col0 real ,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_4 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_5 (
col0 real ,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_6 (
col0 real NOT NULL,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_7 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE real_test14_8 (
col0 real ,
col1 real ,
col2 real ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_9 (
col0 real NOT NULL,
col1 real ,
col2 real ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_10 (
col0 real ,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_11 (
col0 real ,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_12 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_13 (
col0 real ,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_14 (
col0 real NOT NULL,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_15 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE real_test14_16 (
col0 real ,
col1 real ,
col2 real ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_17 (
col0 real NOT NULL,
col1 real ,
col2 real ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_18 (
col0 real ,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_19 (
col0 real ,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_20 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_21 (
col0 real ,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_22 (
col0 real NOT NULL,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_23 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE real_test14_24 (
col0 real ,
col1 real ,
col2 real ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_25 (
col0 real NOT NULL,
col1 real ,
col2 real ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_26 (
col0 real ,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_27 (
col0 real ,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_28 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_29 (
col0 real ,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_30 (
col0 real NOT NULL,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_31 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE real_test14_32 (
col0 real ,
col1 real ,
col2 real ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_33 (
col0 real NOT NULL,
col1 real ,
col2 real ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_34 (
col0 real ,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_35 (
col0 real ,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_36 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_37 (
col0 real ,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_38 (
col0 real NOT NULL,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_39 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_40 (
col0 real ,
col1 real ,
col2 real ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_41 (
col0 real NOT NULL,
col1 real ,
col2 real ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_42 (
col0 real ,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_43 (
col0 real ,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_44 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_45 (
col0 real ,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_46 (
col0 real NOT NULL,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_47 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_48 (
col0 real ,
col1 real ,
col2 real ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_49 (
col0 real NOT NULL,
col1 real ,
col2 real ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_50 (
col0 real ,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_51 (
col0 real ,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_52 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_53 (
col0 real ,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_54 (
col0 real NOT NULL,
col1 real ,
col2 real NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE real_test14_55 (
col0 real NOT NULL,
col1 real NOT NULL,
col2 real NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE FOREIGN TABLE real_test14_0 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_1 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_2 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_3 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_4 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_5 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_6 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_7 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_8 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_9 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_10 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_11 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_12 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_13 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_14 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_15 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_16 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_17 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_18 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_19 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_20 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_21 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_22 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_23 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_24 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_25 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_26 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_27 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_28 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_29 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_30 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_31 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_32 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_33 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_34 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_35 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_36 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_37 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_38 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_39 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_40 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_41 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_42 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_43 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_44 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_45 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_46 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_47 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_48 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_49 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_50 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_51 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_52 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_53 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_54 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
CREATE FOREIGN TABLE real_test14_55 (
col0 real ,col1 real ,col2 real 
) SERVER ogawayama;
--real_test14_0
SELECT * from real_test14_0;
--ok
INSERT INTO real_test14_0 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_0;
--PKEY col0 null error 
INSERT INTO real_test14_0(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_0;
--PKEY col0 null error 
INSERT INTO real_test14_0(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_0;
--PKEY col0 not unique error
INSERT INTO real_test14_0(col0) VALUES(1.1);
SELECT * from real_test14_0;
--ok
INSERT INTO real_test14_0(col0) VALUES(2.2);
SELECT * from real_test14_0;

--real_test14_1
SELECT * from real_test14_1;
--ok
INSERT INTO real_test14_1 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_1;
--PKEY col0 null error 
INSERT INTO real_test14_1(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_1;
--PKEY col0 null error 
INSERT INTO real_test14_1(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_1;
--PKEY col0 not unique error
INSERT INTO real_test14_1(col0) VALUES(1.1);
SELECT * from real_test14_1;
--not null constraint col0 error
INSERT INTO real_test14_1(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_1;
--ok
INSERT INTO real_test14_1(col0) VALUES(2.2);
SELECT * from real_test14_1;

--real_test14_2
SELECT * from real_test14_2;
--ok
INSERT INTO real_test14_2 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_2;
--PKEY col0 null error 
INSERT INTO real_test14_2(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_2;
--PKEY col0 null error 
INSERT INTO real_test14_2(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_2;
--PKEY col0 not unique error
INSERT INTO real_test14_2(col0,col1) VALUES(1.1,3.3);
SELECT * from real_test14_2;
--not null constraint col1 error
INSERT INTO real_test14_2(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_2;
--ok
INSERT INTO real_test14_2(col0,col1) VALUES(2.2,6.6);
SELECT * from real_test14_2;

--real_test14_3
SELECT * from real_test14_3;
--ok
INSERT INTO real_test14_3 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_3;
--PKEY col0 null error 
INSERT INTO real_test14_3(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_3;
--PKEY col0 null error 
INSERT INTO real_test14_3(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_3;
--PKEY col0 not unique error
INSERT INTO real_test14_3(col0,col2) VALUES(1.1,3.3);
SELECT * from real_test14_3;
--not null constraint col2 error
INSERT INTO real_test14_3(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_3;
--ok
INSERT INTO real_test14_3(col0,col2) VALUES(2.2,6.6);
SELECT * from real_test14_3;

--real_test14_4
SELECT * from real_test14_4;
--ok
INSERT INTO real_test14_4 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_4;
--PKEY col0 null error 
INSERT INTO real_test14_4(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_4;
--PKEY col0 null error 
INSERT INTO real_test14_4(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_4;
--PKEY col0 not unique error
INSERT INTO real_test14_4(col0,col1) VALUES(1.1,3.3);
SELECT * from real_test14_4;
--not null constraint col0 error
INSERT INTO real_test14_4(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_4;
--not null constraint col1 error
INSERT INTO real_test14_4(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_4;
--ok
INSERT INTO real_test14_4(col0,col1) VALUES(2.2,6.6);
SELECT * from real_test14_4;

--real_test14_5
SELECT * from real_test14_5;
--ok
INSERT INTO real_test14_5 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_5;
--PKEY col0 null error 
INSERT INTO real_test14_5(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_5;
--PKEY col0 null error 
INSERT INTO real_test14_5(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_5;
--PKEY col0 not unique error
INSERT INTO real_test14_5(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from real_test14_5;
--not null constraint col1 error
INSERT INTO real_test14_5(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_5;
--not null constraint col2 error
INSERT INTO real_test14_5(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_5;
--ok
INSERT INTO real_test14_5(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from real_test14_5;

--real_test14_6
SELECT * from real_test14_6;
--ok
INSERT INTO real_test14_6 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_6;
--PKEY col0 null error 
INSERT INTO real_test14_6(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_6;
--PKEY col0 null error 
INSERT INTO real_test14_6(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_6;
--PKEY col0 not unique error
INSERT INTO real_test14_6(col0,col2) VALUES(1.1,3.3);
SELECT * from real_test14_6;
--not null constraint col0 error
INSERT INTO real_test14_6(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_6;
--not null constraint col2 error
INSERT INTO real_test14_6(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_6;
--ok
INSERT INTO real_test14_6(col0,col2) VALUES(2.2,6.6);
SELECT * from real_test14_6;

--real_test14_7
SELECT * from real_test14_7;
--ok
INSERT INTO real_test14_7 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_7;
--PKEY col0 null error 
INSERT INTO real_test14_7(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_7;
--PKEY col0 null error 
INSERT INTO real_test14_7(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_7;
--PKEY col0 not unique error
INSERT INTO real_test14_7(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from real_test14_7;
--not null constraint col0 error
INSERT INTO real_test14_7(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_7;
--not null constraint col1 error
INSERT INTO real_test14_7(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_7;
--not null constraint col2 error
INSERT INTO real_test14_7(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_7;
--ok
INSERT INTO real_test14_7(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from real_test14_7;

--real_test14_8
SELECT * from real_test14_8;
--ok
INSERT INTO real_test14_8 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_8;
--PKEY col1 null error 
INSERT INTO real_test14_8(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_8;
--PKEY col1 null error 
INSERT INTO real_test14_8(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_8;
--PKEY col1 not unique error
INSERT INTO real_test14_8(col1) VALUES(1.1);
SELECT * from real_test14_8;
--ok
INSERT INTO real_test14_8(col1) VALUES(2.2);
SELECT * from real_test14_8;

--real_test14_9
SELECT * from real_test14_9;
--ok
INSERT INTO real_test14_9 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_9;
--PKEY col1 null error 
INSERT INTO real_test14_9(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_9;
--PKEY col1 null error 
INSERT INTO real_test14_9(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_9;
--PKEY col1 not unique error
INSERT INTO real_test14_9(col0,col1) VALUES(3.3,1.1);
SELECT * from real_test14_9;
--not null constraint col0 error
INSERT INTO real_test14_9(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_9;
--ok
INSERT INTO real_test14_9(col0,col1) VALUES(6.6,2.2);
SELECT * from real_test14_9;

--real_test14_10
SELECT * from real_test14_10;
--ok
INSERT INTO real_test14_10 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_10;
--PKEY col1 null error 
INSERT INTO real_test14_10(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_10;
--PKEY col1 null error 
INSERT INTO real_test14_10(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_10;
--PKEY col1 not unique error
INSERT INTO real_test14_10(col1) VALUES(1.1);
SELECT * from real_test14_10;
--not null constraint col1 error
INSERT INTO real_test14_10(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_10;
--ok
INSERT INTO real_test14_10(col1) VALUES(2.2);
SELECT * from real_test14_10;

--real_test14_11
SELECT * from real_test14_11;
--ok
INSERT INTO real_test14_11 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_11;
--PKEY col1 null error 
INSERT INTO real_test14_11(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_11;
--PKEY col1 null error 
INSERT INTO real_test14_11(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_11;
--PKEY col1 not unique error
INSERT INTO real_test14_11(col1,col2) VALUES(1.1,3.3);
SELECT * from real_test14_11;
--not null constraint col2 error
INSERT INTO real_test14_11(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_11;
--ok
INSERT INTO real_test14_11(col1,col2) VALUES(2.2,6.6);
SELECT * from real_test14_11;

--real_test14_12
SELECT * from real_test14_12;
--ok
INSERT INTO real_test14_12 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_12;
--PKEY col1 null error 
INSERT INTO real_test14_12(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_12;
--PKEY col1 null error 
INSERT INTO real_test14_12(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_12;
--PKEY col1 not unique error
INSERT INTO real_test14_12(col0,col1) VALUES(3.3,1.1);
SELECT * from real_test14_12;
--not null constraint col0 error
INSERT INTO real_test14_12(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_12;
--not null constraint col1 error
INSERT INTO real_test14_12(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_12;
--ok
INSERT INTO real_test14_12(col0,col1) VALUES(6.6,2.2);
SELECT * from real_test14_12;

--real_test14_13
SELECT * from real_test14_13;
--ok
INSERT INTO real_test14_13 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_13;
--PKEY col1 null error 
INSERT INTO real_test14_13(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_13;
--PKEY col1 null error 
INSERT INTO real_test14_13(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_13;
--PKEY col1 not unique error
INSERT INTO real_test14_13(col1,col2) VALUES(1.1,3.3);
SELECT * from real_test14_13;
--not null constraint col1 error
INSERT INTO real_test14_13(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_13;
--not null constraint col2 error
INSERT INTO real_test14_13(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_13;
--ok
INSERT INTO real_test14_13(col1,col2) VALUES(2.2,6.6);
SELECT * from real_test14_13;

--real_test14_14
SELECT * from real_test14_14;
--ok
INSERT INTO real_test14_14 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_14;
--PKEY col1 null error 
INSERT INTO real_test14_14(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_14;
--PKEY col1 null error 
INSERT INTO real_test14_14(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_14;
--PKEY col1 not unique error
INSERT INTO real_test14_14(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from real_test14_14;
--not null constraint col0 error
INSERT INTO real_test14_14(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_14;
--not null constraint col2 error
INSERT INTO real_test14_14(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_14;
--ok
INSERT INTO real_test14_14(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from real_test14_14;

--real_test14_15
SELECT * from real_test14_15;
--ok
INSERT INTO real_test14_15 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_15;
--PKEY col1 null error 
INSERT INTO real_test14_15(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_15;
--PKEY col1 null error 
INSERT INTO real_test14_15(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_15;
--PKEY col1 not unique error
INSERT INTO real_test14_15(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from real_test14_15;
--not null constraint col0 error
INSERT INTO real_test14_15(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_15;
--not null constraint col1 error
INSERT INTO real_test14_15(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_15;
--not null constraint col2 error
INSERT INTO real_test14_15(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_15;
--ok
INSERT INTO real_test14_15(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from real_test14_15;

--real_test14_16
SELECT * from real_test14_16;
--ok
INSERT INTO real_test14_16 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_16;
--PKEY col2 null error 
INSERT INTO real_test14_16(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_16;
--PKEY col2 null error 
INSERT INTO real_test14_16(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_16;
--PKEY col2 not unique error
INSERT INTO real_test14_16(col2) VALUES(1.1);
SELECT * from real_test14_16;
--ok
INSERT INTO real_test14_16(col2) VALUES(2.2);
SELECT * from real_test14_16;

--real_test14_17
SELECT * from real_test14_17;
--ok
INSERT INTO real_test14_17 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_17;
--PKEY col2 null error 
INSERT INTO real_test14_17(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_17;
--PKEY col2 null error 
INSERT INTO real_test14_17(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_17;
--PKEY col2 not unique error
INSERT INTO real_test14_17(col0,col2) VALUES(3.3,1.1);
SELECT * from real_test14_17;
--not null constraint col0 error
INSERT INTO real_test14_17(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_17;
--ok
INSERT INTO real_test14_17(col0,col2) VALUES(6.6,2.2);
SELECT * from real_test14_17;

--real_test14_18
SELECT * from real_test14_18;
--ok
INSERT INTO real_test14_18 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_18;
--PKEY col2 null error 
INSERT INTO real_test14_18(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_18;
--PKEY col2 null error 
INSERT INTO real_test14_18(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_18;
--PKEY col2 not unique error
INSERT INTO real_test14_18(col1,col2) VALUES(3.3,1.1);
SELECT * from real_test14_18;
--not null constraint col1 error
INSERT INTO real_test14_18(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_18;
--ok
INSERT INTO real_test14_18(col1,col2) VALUES(6.6,2.2);
SELECT * from real_test14_18;

--real_test14_19
SELECT * from real_test14_19;
--ok
INSERT INTO real_test14_19 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_19;
--PKEY col2 null error 
INSERT INTO real_test14_19(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_19;
--PKEY col2 null error 
INSERT INTO real_test14_19(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_19;
--PKEY col2 not unique error
INSERT INTO real_test14_19(col2) VALUES(1.1);
SELECT * from real_test14_19;
--not null constraint col2 error
INSERT INTO real_test14_19(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_19;
--ok
INSERT INTO real_test14_19(col2) VALUES(2.2);
SELECT * from real_test14_19;

--real_test14_20
SELECT * from real_test14_20;
--ok
INSERT INTO real_test14_20 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_20;
--PKEY col2 null error 
INSERT INTO real_test14_20(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_20;
--PKEY col2 null error 
INSERT INTO real_test14_20(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_20;
--PKEY col2 not unique error
INSERT INTO real_test14_20(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from real_test14_20;
--not null constraint col0 error
INSERT INTO real_test14_20(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_20;
--not null constraint col1 error
INSERT INTO real_test14_20(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_20;
--ok
INSERT INTO real_test14_20(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from real_test14_20;

--real_test14_21
SELECT * from real_test14_21;
--ok
INSERT INTO real_test14_21 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_21;
--PKEY col2 null error 
INSERT INTO real_test14_21(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_21;
--PKEY col2 null error 
INSERT INTO real_test14_21(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_21;
--PKEY col2 not unique error
INSERT INTO real_test14_21(col1,col2) VALUES(3.3,1.1);
SELECT * from real_test14_21;
--not null constraint col1 error
INSERT INTO real_test14_21(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_21;
--not null constraint col2 error
INSERT INTO real_test14_21(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_21;
--ok
INSERT INTO real_test14_21(col1,col2) VALUES(6.6,2.2);
SELECT * from real_test14_21;

--real_test14_22
SELECT * from real_test14_22;
--ok
INSERT INTO real_test14_22 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_22;
--PKEY col2 null error 
INSERT INTO real_test14_22(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_22;
--PKEY col2 null error 
INSERT INTO real_test14_22(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_22;
--PKEY col2 not unique error
INSERT INTO real_test14_22(col0,col2) VALUES(3.3,1.1);
SELECT * from real_test14_22;
--not null constraint col0 error
INSERT INTO real_test14_22(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_22;
--not null constraint col2 error
INSERT INTO real_test14_22(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_22;
--ok
INSERT INTO real_test14_22(col0,col2) VALUES(6.6,2.2);
SELECT * from real_test14_22;

--real_test14_23
SELECT * from real_test14_23;
--ok
INSERT INTO real_test14_23 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_23;
--PKEY col2 null error 
INSERT INTO real_test14_23(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_23;
--PKEY col2 null error 
INSERT INTO real_test14_23(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_23;
--PKEY col2 not unique error
INSERT INTO real_test14_23(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from real_test14_23;
--not null constraint col0 error
INSERT INTO real_test14_23(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_23;
--not null constraint col1 error
INSERT INTO real_test14_23(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_23;
--not null constraint col2 error
INSERT INTO real_test14_23(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_23;
--ok
INSERT INTO real_test14_23(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from real_test14_23;

--real_test14_24
SELECT * from real_test14_24;
--ok
INSERT INTO real_test14_24 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_24;
--PKEY col0 col1 null error 
INSERT INTO real_test14_24(col2) VALUES(3.3);
SELECT * from real_test14_24;
--PKEY col0 null error 
INSERT INTO real_test14_24(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_24;
--PKEY col1 null error 
INSERT INTO real_test14_24(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_24;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_24(col0,col1) VALUES(1.1,1.1);
SELECT * from real_test14_24;
--ok
INSERT INTO real_test14_24(col0,col1) VALUES(2.2,2.2);
SELECT * from real_test14_24;

--real_test14_25
SELECT * from real_test14_25;
--ok
INSERT INTO real_test14_25 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_25;
--PKEY col0 col1 null error 
INSERT INTO real_test14_25(col2) VALUES(3.3);
SELECT * from real_test14_25;
--PKEY col0 null error 
INSERT INTO real_test14_25(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_25;
--PKEY col1 null error 
INSERT INTO real_test14_25(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_25;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_25(col0,col1) VALUES(1.1,1.1);
SELECT * from real_test14_25;
--not null constraint col0 error
INSERT INTO real_test14_25(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_25;
--ok
INSERT INTO real_test14_25(col0,col1) VALUES(2.2,2.2);
SELECT * from real_test14_25;

--real_test14_26
SELECT * from real_test14_26;
--ok
INSERT INTO real_test14_26 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_26;
--PKEY col0 col1 null error 
INSERT INTO real_test14_26(col2) VALUES(3.3);
SELECT * from real_test14_26;
--PKEY col0 null error 
INSERT INTO real_test14_26(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_26;
--PKEY col1 null error 
INSERT INTO real_test14_26(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_26;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_26(col0,col1) VALUES(1.1,1.1);
SELECT * from real_test14_26;
--not null constraint col1 error
INSERT INTO real_test14_26(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_26;
--ok
INSERT INTO real_test14_26(col0,col1) VALUES(2.2,2.2);
SELECT * from real_test14_26;

--real_test14_27
SELECT * from real_test14_27;
--ok
INSERT INTO real_test14_27 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_27;
--PKEY col0 col1 null error 
INSERT INTO real_test14_27(col2) VALUES(3.3);
SELECT * from real_test14_27;
--PKEY col0 null error 
INSERT INTO real_test14_27(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_27;
--PKEY col1 null error 
INSERT INTO real_test14_27(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_27;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_27(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from real_test14_27;
--not null constraint col2 error
INSERT INTO real_test14_27(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_27;
--ok
INSERT INTO real_test14_27(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from real_test14_27;

--real_test14_28
SELECT * from real_test14_28;
--ok
INSERT INTO real_test14_28 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_28;
--PKEY col0 col1 null error 
INSERT INTO real_test14_28(col2) VALUES(3.3);
SELECT * from real_test14_28;
--PKEY col0 null error 
INSERT INTO real_test14_28(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_28;
--PKEY col1 null error 
INSERT INTO real_test14_28(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_28;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_28(col0,col1) VALUES(1.1,1.1);
SELECT * from real_test14_28;
--not null constraint col0 error
INSERT INTO real_test14_28(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_28;
--not null constraint col1 error
INSERT INTO real_test14_28(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_28;
--ok
INSERT INTO real_test14_28(col0,col1) VALUES(2.2,2.2);
SELECT * from real_test14_28;

--real_test14_29
SELECT * from real_test14_29;
--ok
INSERT INTO real_test14_29 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_29;
--PKEY col0 col1 null error 
INSERT INTO real_test14_29(col2) VALUES(3.3);
SELECT * from real_test14_29;
--PKEY col0 null error 
INSERT INTO real_test14_29(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_29;
--PKEY col1 null error 
INSERT INTO real_test14_29(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_29;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_29(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from real_test14_29;
--not null constraint col1 error
INSERT INTO real_test14_29(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_29;
--not null constraint col2 error
INSERT INTO real_test14_29(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_29;
--ok
INSERT INTO real_test14_29(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from real_test14_29;

--real_test14_30
SELECT * from real_test14_30;
--ok
INSERT INTO real_test14_30 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_30;
--PKEY col0 col1 null error 
INSERT INTO real_test14_30(col2) VALUES(3.3);
SELECT * from real_test14_30;
--PKEY col0 null error 
INSERT INTO real_test14_30(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_30;
--PKEY col1 null error 
INSERT INTO real_test14_30(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_30;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_30(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from real_test14_30;
--not null constraint col0 error
INSERT INTO real_test14_30(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_30;
--not null constraint col2 error
INSERT INTO real_test14_30(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_30;
--ok
INSERT INTO real_test14_30(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from real_test14_30;

--real_test14_31
SELECT * from real_test14_31;
--ok
INSERT INTO real_test14_31 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_31;
--PKEY col0 col1 null error 
INSERT INTO real_test14_31(col2) VALUES(3.3);
SELECT * from real_test14_31;
--PKEY col0 null error 
INSERT INTO real_test14_31(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_31;
--PKEY col1 null error 
INSERT INTO real_test14_31(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_31;
--PKEY col0 col1 not unique error
INSERT INTO real_test14_31(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from real_test14_31;
--not null constraint col0 error
INSERT INTO real_test14_31(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_31;
--not null constraint col1 error
INSERT INTO real_test14_31(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_31;
--not null constraint col2 error
INSERT INTO real_test14_31(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_31;
--ok
INSERT INTO real_test14_31(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from real_test14_31;

--real_test14_32
SELECT * from real_test14_32;
--ok
INSERT INTO real_test14_32 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_32;
--PKEY col1 col2 null error 
INSERT INTO real_test14_32(col0) VALUES(3.3);
SELECT * from real_test14_32;
--PKEY col1 null error 
INSERT INTO real_test14_32(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_32;
--PKEY col2 null error 
INSERT INTO real_test14_32(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_32;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_32(col1,col2) VALUES(1.1,1.1);
SELECT * from real_test14_32;
--ok
INSERT INTO real_test14_32(col1,col2) VALUES(2.2,2.2);
SELECT * from real_test14_32;

--real_test14_33
SELECT * from real_test14_33;
--ok
INSERT INTO real_test14_33 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_33;
--PKEY col1 col2 null error 
INSERT INTO real_test14_33(col0) VALUES(3.3);
SELECT * from real_test14_33;
--PKEY col1 null error 
INSERT INTO real_test14_33(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_33;
--PKEY col2 null error 
INSERT INTO real_test14_33(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_33;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_33(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from real_test14_33;
--not null constraint col0 error
INSERT INTO real_test14_33(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_33;
--ok
INSERT INTO real_test14_33(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from real_test14_33;

--real_test14_34
SELECT * from real_test14_34;
--ok
INSERT INTO real_test14_34 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_34;
--PKEY col1 col2 null error 
INSERT INTO real_test14_34(col0) VALUES(3.3);
SELECT * from real_test14_34;
--PKEY col1 null error 
INSERT INTO real_test14_34(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_34;
--PKEY col2 null error 
INSERT INTO real_test14_34(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_34;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_34(col1,col2) VALUES(1.1,1.1);
SELECT * from real_test14_34;
--not null constraint col1 error
INSERT INTO real_test14_34(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_34;
--ok
INSERT INTO real_test14_34(col1,col2) VALUES(2.2,2.2);
SELECT * from real_test14_34;

--real_test14_35
SELECT * from real_test14_35;
--ok
INSERT INTO real_test14_35 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_35;
--PKEY col1 col2 null error 
INSERT INTO real_test14_35(col0) VALUES(3.3);
SELECT * from real_test14_35;
--PKEY col1 null error 
INSERT INTO real_test14_35(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_35;
--PKEY col2 null error 
INSERT INTO real_test14_35(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_35;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_35(col1,col2) VALUES(1.1,1.1);
SELECT * from real_test14_35;
--not null constraint col2 error
INSERT INTO real_test14_35(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_35;
--ok
INSERT INTO real_test14_35(col1,col2) VALUES(2.2,2.2);
SELECT * from real_test14_35;

--real_test14_36
SELECT * from real_test14_36;
--ok
INSERT INTO real_test14_36 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_36;
--PKEY col1 col2 null error 
INSERT INTO real_test14_36(col0) VALUES(3.3);
SELECT * from real_test14_36;
--PKEY col1 null error 
INSERT INTO real_test14_36(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_36;
--PKEY col2 null error 
INSERT INTO real_test14_36(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_36;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_36(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from real_test14_36;
--not null constraint col0 error
INSERT INTO real_test14_36(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_36;
--not null constraint col1 error
INSERT INTO real_test14_36(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_36;
--ok
INSERT INTO real_test14_36(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from real_test14_36;

--real_test14_37
SELECT * from real_test14_37;
--ok
INSERT INTO real_test14_37 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_37;
--PKEY col1 col2 null error 
INSERT INTO real_test14_37(col0) VALUES(3.3);
SELECT * from real_test14_37;
--PKEY col1 null error 
INSERT INTO real_test14_37(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_37;
--PKEY col2 null error 
INSERT INTO real_test14_37(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_37;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_37(col1,col2) VALUES(1.1,1.1);
SELECT * from real_test14_37;
--not null constraint col1 error
INSERT INTO real_test14_37(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_37;
--not null constraint col2 error
INSERT INTO real_test14_37(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_37;
--ok
INSERT INTO real_test14_37(col1,col2) VALUES(2.2,2.2);
SELECT * from real_test14_37;

--real_test14_38
SELECT * from real_test14_38;
--ok
INSERT INTO real_test14_38 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_38;
--PKEY col1 col2 null error 
INSERT INTO real_test14_38(col0) VALUES(3.3);
SELECT * from real_test14_38;
--PKEY col1 null error 
INSERT INTO real_test14_38(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_38;
--PKEY col2 null error 
INSERT INTO real_test14_38(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_38;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_38(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from real_test14_38;
--not null constraint col0 error
INSERT INTO real_test14_38(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_38;
--not null constraint col2 error
INSERT INTO real_test14_38(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_38;
--ok
INSERT INTO real_test14_38(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from real_test14_38;

--real_test14_39
SELECT * from real_test14_39;
--ok
INSERT INTO real_test14_39 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_39;
--PKEY col1 col2 null error 
INSERT INTO real_test14_39(col0) VALUES(3.3);
SELECT * from real_test14_39;
--PKEY col1 null error 
INSERT INTO real_test14_39(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_39;
--PKEY col2 null error 
INSERT INTO real_test14_39(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_39;
--PKEY col1 col2 not unique error
INSERT INTO real_test14_39(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from real_test14_39;
--not null constraint col0 error
INSERT INTO real_test14_39(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_39;
--not null constraint col1 error
INSERT INTO real_test14_39(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_39;
--not null constraint col2 error
INSERT INTO real_test14_39(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_39;
--ok
INSERT INTO real_test14_39(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from real_test14_39;

--real_test14_40
SELECT * from real_test14_40;
--ok
INSERT INTO real_test14_40 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_40;
--PKEY col0 col2 null error 
INSERT INTO real_test14_40(col1) VALUES(3.3);
SELECT * from real_test14_40;
--PKEY col0 null error 
INSERT INTO real_test14_40(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_40;
--PKEY col2 null error 
INSERT INTO real_test14_40(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_40;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_40(col0,col2) VALUES(1.1,1.1);
SELECT * from real_test14_40;
--ok
INSERT INTO real_test14_40(col0,col2) VALUES(2.2,2.2);
SELECT * from real_test14_40;

--real_test14_41
SELECT * from real_test14_41;
--ok
INSERT INTO real_test14_41 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_41;
--PKEY col0 col2 null error 
INSERT INTO real_test14_41(col1) VALUES(3.3);
SELECT * from real_test14_41;
--PKEY col0 null error 
INSERT INTO real_test14_41(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_41;
--PKEY col2 null error 
INSERT INTO real_test14_41(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_41;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_41(col0,col2) VALUES(1.1,1.1);
SELECT * from real_test14_41;
--not null constraint col0 error
INSERT INTO real_test14_41(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_41;
--ok
INSERT INTO real_test14_41(col0,col2) VALUES(2.2,2.2);
SELECT * from real_test14_41;

--real_test14_42
SELECT * from real_test14_42;
--ok
INSERT INTO real_test14_42 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_42;
--PKEY col0 col2 null error 
INSERT INTO real_test14_42(col1) VALUES(3.3);
SELECT * from real_test14_42;
--PKEY col0 null error 
INSERT INTO real_test14_42(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_42;
--PKEY col2 null error 
INSERT INTO real_test14_42(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_42;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_42(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from real_test14_42;
--not null constraint col1 error
INSERT INTO real_test14_42(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_42;
--ok
INSERT INTO real_test14_42(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from real_test14_42;

--real_test14_43
SELECT * from real_test14_43;
--ok
INSERT INTO real_test14_43 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_43;
--PKEY col0 col2 null error 
INSERT INTO real_test14_43(col1) VALUES(3.3);
SELECT * from real_test14_43;
--PKEY col0 null error 
INSERT INTO real_test14_43(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_43;
--PKEY col2 null error 
INSERT INTO real_test14_43(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_43;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_43(col0,col2) VALUES(1.1,1.1);
SELECT * from real_test14_43;
--not null constraint col2 error
INSERT INTO real_test14_43(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_43;
--ok
INSERT INTO real_test14_43(col0,col2) VALUES(2.2,2.2);
SELECT * from real_test14_43;

--real_test14_44
SELECT * from real_test14_44;
--ok
INSERT INTO real_test14_44 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_44;
--PKEY col0 col2 null error 
INSERT INTO real_test14_44(col1) VALUES(3.3);
SELECT * from real_test14_44;
--PKEY col0 null error 
INSERT INTO real_test14_44(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_44;
--PKEY col2 null error 
INSERT INTO real_test14_44(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_44;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_44(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from real_test14_44;
--not null constraint col0 error
INSERT INTO real_test14_44(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_44;
--not null constraint col1 error
INSERT INTO real_test14_44(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_44;
--ok
INSERT INTO real_test14_44(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from real_test14_44;

--real_test14_45
SELECT * from real_test14_45;
--ok
INSERT INTO real_test14_45 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_45;
--PKEY col0 col2 null error 
INSERT INTO real_test14_45(col1) VALUES(3.3);
SELECT * from real_test14_45;
--PKEY col0 null error 
INSERT INTO real_test14_45(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_45;
--PKEY col2 null error 
INSERT INTO real_test14_45(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_45;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_45(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from real_test14_45;
--not null constraint col1 error
INSERT INTO real_test14_45(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_45;
--not null constraint col2 error
INSERT INTO real_test14_45(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_45;
--ok
INSERT INTO real_test14_45(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from real_test14_45;

--real_test14_46
SELECT * from real_test14_46;
--ok
INSERT INTO real_test14_46 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_46;
--PKEY col0 col2 null error 
INSERT INTO real_test14_46(col1) VALUES(3.3);
SELECT * from real_test14_46;
--PKEY col0 null error 
INSERT INTO real_test14_46(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_46;
--PKEY col2 null error 
INSERT INTO real_test14_46(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_46;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_46(col0,col2) VALUES(1.1,1.1);
SELECT * from real_test14_46;
--not null constraint col0 error
INSERT INTO real_test14_46(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_46;
--not null constraint col2 error
INSERT INTO real_test14_46(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_46;
--ok
INSERT INTO real_test14_46(col0,col2) VALUES(2.2,2.2);
SELECT * from real_test14_46;

--real_test14_47
SELECT * from real_test14_47;
--ok
INSERT INTO real_test14_47 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_47;
--PKEY col0 col2 null error 
INSERT INTO real_test14_47(col1) VALUES(3.3);
SELECT * from real_test14_47;
--PKEY col0 null error 
INSERT INTO real_test14_47(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_47;
--PKEY col2 null error 
INSERT INTO real_test14_47(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_47;
--PKEY col0 col2 not unique error
INSERT INTO real_test14_47(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from real_test14_47;
--not null constraint col0 error
INSERT INTO real_test14_47(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_47;
--not null constraint col1 error
INSERT INTO real_test14_47(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_47;
--not null constraint col2 error
INSERT INTO real_test14_47(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_47;
--ok
INSERT INTO real_test14_47(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from real_test14_47;

--real_test14_48
SELECT * from real_test14_48;
--ok
INSERT INTO real_test14_48 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_48;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_48() VALUES();
SELECT * from real_test14_48;
--PKEY col0 null error 
INSERT INTO real_test14_48(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_48;
--PKEY col1 null error 
INSERT INTO real_test14_48(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_48;
--PKEY col2 null error 
INSERT INTO real_test14_48(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_48;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_48(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_48;
--ok
INSERT INTO real_test14_48(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_48;

--real_test14_49
SELECT * from real_test14_49;
--ok
INSERT INTO real_test14_49 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_49;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_49() VALUES();
SELECT * from real_test14_49;
--PKEY col0 null error 
INSERT INTO real_test14_49(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_49;
--PKEY col1 null error 
INSERT INTO real_test14_49(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_49;
--PKEY col2 null error 
INSERT INTO real_test14_49(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_49;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_49(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_49;
--not null constraint col0 error
INSERT INTO real_test14_49(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_49;
--ok
INSERT INTO real_test14_49(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_49;

--real_test14_50
SELECT * from real_test14_50;
--ok
INSERT INTO real_test14_50 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_50;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_50() VALUES();
SELECT * from real_test14_50;
--PKEY col0 null error 
INSERT INTO real_test14_50(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_50;
--PKEY col1 null error 
INSERT INTO real_test14_50(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_50;
--PKEY col2 null error 
INSERT INTO real_test14_50(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_50;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_50(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_50;
--not null constraint col1 error
INSERT INTO real_test14_50(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_50;
--ok
INSERT INTO real_test14_50(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_50;

--real_test14_51
SELECT * from real_test14_51;
--ok
INSERT INTO real_test14_51 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_51;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_51() VALUES();
SELECT * from real_test14_51;
--PKEY col0 null error 
INSERT INTO real_test14_51(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_51;
--PKEY col1 null error 
INSERT INTO real_test14_51(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_51;
--PKEY col2 null error 
INSERT INTO real_test14_51(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_51;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_51(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_51;
--not null constraint col2 error
INSERT INTO real_test14_51(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_51;
--ok
INSERT INTO real_test14_51(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_51;

--real_test14_52
SELECT * from real_test14_52;
--ok
INSERT INTO real_test14_52 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_52;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_52() VALUES();
SELECT * from real_test14_52;
--PKEY col0 null error 
INSERT INTO real_test14_52(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_52;
--PKEY col1 null error 
INSERT INTO real_test14_52(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_52;
--PKEY col2 null error 
INSERT INTO real_test14_52(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_52;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_52(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_52;
--not null constraint col0 error
INSERT INTO real_test14_52(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_52;
--not null constraint col1 error
INSERT INTO real_test14_52(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_52;
--ok
INSERT INTO real_test14_52(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_52;

--real_test14_53
SELECT * from real_test14_53;
--ok
INSERT INTO real_test14_53 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_53;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_53() VALUES();
SELECT * from real_test14_53;
--PKEY col0 null error 
INSERT INTO real_test14_53(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_53;
--PKEY col1 null error 
INSERT INTO real_test14_53(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_53;
--PKEY col2 null error 
INSERT INTO real_test14_53(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_53;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_53(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_53;
--not null constraint col1 error
INSERT INTO real_test14_53(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_53;
--not null constraint col2 error
INSERT INTO real_test14_53(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_53;
--ok
INSERT INTO real_test14_53(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_53;

--real_test14_54
SELECT * from real_test14_54;
--ok
INSERT INTO real_test14_54 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_54;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_54() VALUES();
SELECT * from real_test14_54;
--PKEY col0 null error 
INSERT INTO real_test14_54(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_54;
--PKEY col1 null error 
INSERT INTO real_test14_54(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_54;
--PKEY col2 null error 
INSERT INTO real_test14_54(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_54;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_54(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_54;
--not null constraint col0 error
INSERT INTO real_test14_54(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_54;
--not null constraint col2 error
INSERT INTO real_test14_54(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_54;
--ok
INSERT INTO real_test14_54(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_54;

--real_test14_55
SELECT * from real_test14_55;
--ok
INSERT INTO real_test14_55 VALUES(1.1, 1.1, 1.1);
SELECT * from real_test14_55;
--PKEY col0 col1 col2 null error 
INSERT INTO real_test14_55() VALUES();
SELECT * from real_test14_55;
--PKEY col0 null error 
INSERT INTO real_test14_55(col1,col2) VALUES(3.3,3.3);
SELECT * from real_test14_55;
--PKEY col1 null error 
INSERT INTO real_test14_55(col0,col2) VALUES(3.3,3.3);
SELECT * from real_test14_55;
--PKEY col2 null error 
INSERT INTO real_test14_55(col0,col1) VALUES(3.3,3.3);
SELECT * from real_test14_55;
--PKEY col0 col1 col2 not unique error
INSERT INTO real_test14_55(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from real_test14_55;
--not null constraint col0 error
INSERT INTO real_test14_55(col1,col2) VALUES(5.5,5.5);
SELECT * from real_test14_55;
--not null constraint col1 error
INSERT INTO real_test14_55(col0,col2) VALUES(5.5,5.5);
SELECT * from real_test14_55;
--not null constraint col2 error
INSERT INTO real_test14_55(col0,col1) VALUES(5.5,5.5);
SELECT * from real_test14_55;
--ok
INSERT INTO real_test14_55(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from real_test14_55;

CREATE TABLE double_test14_0 (
col0 double precision ,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_1 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_2 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_3 (
col0 double precision ,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_4 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_5 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_6 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_7 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE double_test14_8 (
col0 double precision ,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_9 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_10 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_11 (
col0 double precision ,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_12 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_13 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_14 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_15 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE double_test14_16 (
col0 double precision ,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_17 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_18 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_19 (
col0 double precision ,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_20 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_21 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_22 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_23 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE double_test14_24 (
col0 double precision ,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_25 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_26 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_27 (
col0 double precision ,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_28 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_29 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_30 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_31 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE double_test14_32 (
col0 double precision ,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_33 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_34 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_35 (
col0 double precision ,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_36 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_37 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_38 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_39 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_40 (
col0 double precision ,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_41 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_42 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_43 (
col0 double precision ,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_44 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_45 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_46 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_47 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_48 (
col0 double precision ,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_49 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_50 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_51 (
col0 double precision ,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_52 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_53 (
col0 double precision ,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_54 (
col0 double precision NOT NULL,
col1 double precision ,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE double_test14_55 (
col0 double precision NOT NULL,
col1 double precision NOT NULL,
col2 double precision NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE FOREIGN TABLE double_test14_0 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_1 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_2 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_3 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_4 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_5 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_6 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_7 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_8 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_9 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_10 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_11 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_12 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_13 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_14 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_15 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_16 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_17 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_18 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_19 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_20 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_21 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_22 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_23 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_24 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_25 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_26 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_27 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_28 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_29 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_30 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_31 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_32 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_33 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_34 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_35 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_36 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_37 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_38 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_39 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_40 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_41 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_42 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_43 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_44 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_45 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_46 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_47 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_48 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_49 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_50 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_51 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_52 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_53 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_54 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
CREATE FOREIGN TABLE double_test14_55 (
col0 double precision ,col1 double precision ,col2 double precision 
) SERVER ogawayama;
--double_test14_0
SELECT * from double_test14_0;
--ok
INSERT INTO double_test14_0 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_0;
--PKEY col0 null error 
INSERT INTO double_test14_0(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_0;
--PKEY col0 null error 
INSERT INTO double_test14_0(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_0;
--PKEY col0 not unique error
INSERT INTO double_test14_0(col0) VALUES(1.1);
SELECT * from double_test14_0;
--ok
INSERT INTO double_test14_0(col0) VALUES(2.2);
SELECT * from double_test14_0;

--double_test14_1
SELECT * from double_test14_1;
--ok
INSERT INTO double_test14_1 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_1;
--PKEY col0 null error 
INSERT INTO double_test14_1(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_1;
--PKEY col0 null error 
INSERT INTO double_test14_1(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_1;
--PKEY col0 not unique error
INSERT INTO double_test14_1(col0) VALUES(1.1);
SELECT * from double_test14_1;
--not null constraint col0 error
INSERT INTO double_test14_1(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_1;
--ok
INSERT INTO double_test14_1(col0) VALUES(2.2);
SELECT * from double_test14_1;

--double_test14_2
SELECT * from double_test14_2;
--ok
INSERT INTO double_test14_2 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_2;
--PKEY col0 null error 
INSERT INTO double_test14_2(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_2;
--PKEY col0 null error 
INSERT INTO double_test14_2(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_2;
--PKEY col0 not unique error
INSERT INTO double_test14_2(col0,col1) VALUES(1.1,3.3);
SELECT * from double_test14_2;
--not null constraint col1 error
INSERT INTO double_test14_2(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_2;
--ok
INSERT INTO double_test14_2(col0,col1) VALUES(2.2,6.6);
SELECT * from double_test14_2;

--double_test14_3
SELECT * from double_test14_3;
--ok
INSERT INTO double_test14_3 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_3;
--PKEY col0 null error 
INSERT INTO double_test14_3(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_3;
--PKEY col0 null error 
INSERT INTO double_test14_3(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_3;
--PKEY col0 not unique error
INSERT INTO double_test14_3(col0,col2) VALUES(1.1,3.3);
SELECT * from double_test14_3;
--not null constraint col2 error
INSERT INTO double_test14_3(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_3;
--ok
INSERT INTO double_test14_3(col0,col2) VALUES(2.2,6.6);
SELECT * from double_test14_3;

--double_test14_4
SELECT * from double_test14_4;
--ok
INSERT INTO double_test14_4 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_4;
--PKEY col0 null error 
INSERT INTO double_test14_4(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_4;
--PKEY col0 null error 
INSERT INTO double_test14_4(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_4;
--PKEY col0 not unique error
INSERT INTO double_test14_4(col0,col1) VALUES(1.1,3.3);
SELECT * from double_test14_4;
--not null constraint col0 error
INSERT INTO double_test14_4(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_4;
--not null constraint col1 error
INSERT INTO double_test14_4(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_4;
--ok
INSERT INTO double_test14_4(col0,col1) VALUES(2.2,6.6);
SELECT * from double_test14_4;

--double_test14_5
SELECT * from double_test14_5;
--ok
INSERT INTO double_test14_5 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_5;
--PKEY col0 null error 
INSERT INTO double_test14_5(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_5;
--PKEY col0 null error 
INSERT INTO double_test14_5(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_5;
--PKEY col0 not unique error
INSERT INTO double_test14_5(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from double_test14_5;
--not null constraint col1 error
INSERT INTO double_test14_5(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_5;
--not null constraint col2 error
INSERT INTO double_test14_5(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_5;
--ok
INSERT INTO double_test14_5(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from double_test14_5;

--double_test14_6
SELECT * from double_test14_6;
--ok
INSERT INTO double_test14_6 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_6;
--PKEY col0 null error 
INSERT INTO double_test14_6(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_6;
--PKEY col0 null error 
INSERT INTO double_test14_6(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_6;
--PKEY col0 not unique error
INSERT INTO double_test14_6(col0,col2) VALUES(1.1,3.3);
SELECT * from double_test14_6;
--not null constraint col0 error
INSERT INTO double_test14_6(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_6;
--not null constraint col2 error
INSERT INTO double_test14_6(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_6;
--ok
INSERT INTO double_test14_6(col0,col2) VALUES(2.2,6.6);
SELECT * from double_test14_6;

--double_test14_7
SELECT * from double_test14_7;
--ok
INSERT INTO double_test14_7 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_7;
--PKEY col0 null error 
INSERT INTO double_test14_7(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_7;
--PKEY col0 null error 
INSERT INTO double_test14_7(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_7;
--PKEY col0 not unique error
INSERT INTO double_test14_7(col0,col1,col2) VALUES(1.1,3.3,3.3);
SELECT * from double_test14_7;
--not null constraint col0 error
INSERT INTO double_test14_7(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_7;
--not null constraint col1 error
INSERT INTO double_test14_7(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_7;
--not null constraint col2 error
INSERT INTO double_test14_7(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_7;
--ok
INSERT INTO double_test14_7(col0,col1,col2) VALUES(2.2,6.6,6.6);
SELECT * from double_test14_7;

--double_test14_8
SELECT * from double_test14_8;
--ok
INSERT INTO double_test14_8 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_8;
--PKEY col1 null error 
INSERT INTO double_test14_8(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_8;
--PKEY col1 null error 
INSERT INTO double_test14_8(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_8;
--PKEY col1 not unique error
INSERT INTO double_test14_8(col1) VALUES(1.1);
SELECT * from double_test14_8;
--ok
INSERT INTO double_test14_8(col1) VALUES(2.2);
SELECT * from double_test14_8;

--double_test14_9
SELECT * from double_test14_9;
--ok
INSERT INTO double_test14_9 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_9;
--PKEY col1 null error 
INSERT INTO double_test14_9(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_9;
--PKEY col1 null error 
INSERT INTO double_test14_9(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_9;
--PKEY col1 not unique error
INSERT INTO double_test14_9(col0,col1) VALUES(3.3,1.1);
SELECT * from double_test14_9;
--not null constraint col0 error
INSERT INTO double_test14_9(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_9;
--ok
INSERT INTO double_test14_9(col0,col1) VALUES(6.6,2.2);
SELECT * from double_test14_9;

--double_test14_10
SELECT * from double_test14_10;
--ok
INSERT INTO double_test14_10 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_10;
--PKEY col1 null error 
INSERT INTO double_test14_10(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_10;
--PKEY col1 null error 
INSERT INTO double_test14_10(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_10;
--PKEY col1 not unique error
INSERT INTO double_test14_10(col1) VALUES(1.1);
SELECT * from double_test14_10;
--not null constraint col1 error
INSERT INTO double_test14_10(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_10;
--ok
INSERT INTO double_test14_10(col1) VALUES(2.2);
SELECT * from double_test14_10;

--double_test14_11
SELECT * from double_test14_11;
--ok
INSERT INTO double_test14_11 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_11;
--PKEY col1 null error 
INSERT INTO double_test14_11(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_11;
--PKEY col1 null error 
INSERT INTO double_test14_11(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_11;
--PKEY col1 not unique error
INSERT INTO double_test14_11(col1,col2) VALUES(1.1,3.3);
SELECT * from double_test14_11;
--not null constraint col2 error
INSERT INTO double_test14_11(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_11;
--ok
INSERT INTO double_test14_11(col1,col2) VALUES(2.2,6.6);
SELECT * from double_test14_11;

--double_test14_12
SELECT * from double_test14_12;
--ok
INSERT INTO double_test14_12 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_12;
--PKEY col1 null error 
INSERT INTO double_test14_12(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_12;
--PKEY col1 null error 
INSERT INTO double_test14_12(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_12;
--PKEY col1 not unique error
INSERT INTO double_test14_12(col0,col1) VALUES(3.3,1.1);
SELECT * from double_test14_12;
--not null constraint col0 error
INSERT INTO double_test14_12(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_12;
--not null constraint col1 error
INSERT INTO double_test14_12(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_12;
--ok
INSERT INTO double_test14_12(col0,col1) VALUES(6.6,2.2);
SELECT * from double_test14_12;

--double_test14_13
SELECT * from double_test14_13;
--ok
INSERT INTO double_test14_13 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_13;
--PKEY col1 null error 
INSERT INTO double_test14_13(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_13;
--PKEY col1 null error 
INSERT INTO double_test14_13(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_13;
--PKEY col1 not unique error
INSERT INTO double_test14_13(col1,col2) VALUES(1.1,3.3);
SELECT * from double_test14_13;
--not null constraint col1 error
INSERT INTO double_test14_13(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_13;
--not null constraint col2 error
INSERT INTO double_test14_13(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_13;
--ok
INSERT INTO double_test14_13(col1,col2) VALUES(2.2,6.6);
SELECT * from double_test14_13;

--double_test14_14
SELECT * from double_test14_14;
--ok
INSERT INTO double_test14_14 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_14;
--PKEY col1 null error 
INSERT INTO double_test14_14(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_14;
--PKEY col1 null error 
INSERT INTO double_test14_14(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_14;
--PKEY col1 not unique error
INSERT INTO double_test14_14(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from double_test14_14;
--not null constraint col0 error
INSERT INTO double_test14_14(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_14;
--not null constraint col2 error
INSERT INTO double_test14_14(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_14;
--ok
INSERT INTO double_test14_14(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from double_test14_14;

--double_test14_15
SELECT * from double_test14_15;
--ok
INSERT INTO double_test14_15 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_15;
--PKEY col1 null error 
INSERT INTO double_test14_15(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_15;
--PKEY col1 null error 
INSERT INTO double_test14_15(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_15;
--PKEY col1 not unique error
INSERT INTO double_test14_15(col0,col1,col2) VALUES(3.3,1.1,3.3);
SELECT * from double_test14_15;
--not null constraint col0 error
INSERT INTO double_test14_15(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_15;
--not null constraint col1 error
INSERT INTO double_test14_15(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_15;
--not null constraint col2 error
INSERT INTO double_test14_15(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_15;
--ok
INSERT INTO double_test14_15(col0,col1,col2) VALUES(6.6,2.2,6.6);
SELECT * from double_test14_15;

--double_test14_16
SELECT * from double_test14_16;
--ok
INSERT INTO double_test14_16 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_16;
--PKEY col2 null error 
INSERT INTO double_test14_16(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_16;
--PKEY col2 null error 
INSERT INTO double_test14_16(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_16;
--PKEY col2 not unique error
INSERT INTO double_test14_16(col2) VALUES(1.1);
SELECT * from double_test14_16;
--ok
INSERT INTO double_test14_16(col2) VALUES(2.2);
SELECT * from double_test14_16;

--double_test14_17
SELECT * from double_test14_17;
--ok
INSERT INTO double_test14_17 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_17;
--PKEY col2 null error 
INSERT INTO double_test14_17(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_17;
--PKEY col2 null error 
INSERT INTO double_test14_17(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_17;
--PKEY col2 not unique error
INSERT INTO double_test14_17(col0,col2) VALUES(3.3,1.1);
SELECT * from double_test14_17;
--not null constraint col0 error
INSERT INTO double_test14_17(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_17;
--ok
INSERT INTO double_test14_17(col0,col2) VALUES(6.6,2.2);
SELECT * from double_test14_17;

--double_test14_18
SELECT * from double_test14_18;
--ok
INSERT INTO double_test14_18 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_18;
--PKEY col2 null error 
INSERT INTO double_test14_18(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_18;
--PKEY col2 null error 
INSERT INTO double_test14_18(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_18;
--PKEY col2 not unique error
INSERT INTO double_test14_18(col1,col2) VALUES(3.3,1.1);
SELECT * from double_test14_18;
--not null constraint col1 error
INSERT INTO double_test14_18(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_18;
--ok
INSERT INTO double_test14_18(col1,col2) VALUES(6.6,2.2);
SELECT * from double_test14_18;

--double_test14_19
SELECT * from double_test14_19;
--ok
INSERT INTO double_test14_19 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_19;
--PKEY col2 null error 
INSERT INTO double_test14_19(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_19;
--PKEY col2 null error 
INSERT INTO double_test14_19(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_19;
--PKEY col2 not unique error
INSERT INTO double_test14_19(col2) VALUES(1.1);
SELECT * from double_test14_19;
--not null constraint col2 error
INSERT INTO double_test14_19(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_19;
--ok
INSERT INTO double_test14_19(col2) VALUES(2.2);
SELECT * from double_test14_19;

--double_test14_20
SELECT * from double_test14_20;
--ok
INSERT INTO double_test14_20 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_20;
--PKEY col2 null error 
INSERT INTO double_test14_20(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_20;
--PKEY col2 null error 
INSERT INTO double_test14_20(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_20;
--PKEY col2 not unique error
INSERT INTO double_test14_20(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from double_test14_20;
--not null constraint col0 error
INSERT INTO double_test14_20(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_20;
--not null constraint col1 error
INSERT INTO double_test14_20(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_20;
--ok
INSERT INTO double_test14_20(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from double_test14_20;

--double_test14_21
SELECT * from double_test14_21;
--ok
INSERT INTO double_test14_21 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_21;
--PKEY col2 null error 
INSERT INTO double_test14_21(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_21;
--PKEY col2 null error 
INSERT INTO double_test14_21(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_21;
--PKEY col2 not unique error
INSERT INTO double_test14_21(col1,col2) VALUES(3.3,1.1);
SELECT * from double_test14_21;
--not null constraint col1 error
INSERT INTO double_test14_21(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_21;
--not null constraint col2 error
INSERT INTO double_test14_21(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_21;
--ok
INSERT INTO double_test14_21(col1,col2) VALUES(6.6,2.2);
SELECT * from double_test14_21;

--double_test14_22
SELECT * from double_test14_22;
--ok
INSERT INTO double_test14_22 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_22;
--PKEY col2 null error 
INSERT INTO double_test14_22(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_22;
--PKEY col2 null error 
INSERT INTO double_test14_22(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_22;
--PKEY col2 not unique error
INSERT INTO double_test14_22(col0,col2) VALUES(3.3,1.1);
SELECT * from double_test14_22;
--not null constraint col0 error
INSERT INTO double_test14_22(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_22;
--not null constraint col2 error
INSERT INTO double_test14_22(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_22;
--ok
INSERT INTO double_test14_22(col0,col2) VALUES(6.6,2.2);
SELECT * from double_test14_22;

--double_test14_23
SELECT * from double_test14_23;
--ok
INSERT INTO double_test14_23 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_23;
--PKEY col2 null error 
INSERT INTO double_test14_23(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_23;
--PKEY col2 null error 
INSERT INTO double_test14_23(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_23;
--PKEY col2 not unique error
INSERT INTO double_test14_23(col0,col1,col2) VALUES(3.3,3.3,1.1);
SELECT * from double_test14_23;
--not null constraint col0 error
INSERT INTO double_test14_23(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_23;
--not null constraint col1 error
INSERT INTO double_test14_23(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_23;
--not null constraint col2 error
INSERT INTO double_test14_23(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_23;
--ok
INSERT INTO double_test14_23(col0,col1,col2) VALUES(6.6,6.6,2.2);
SELECT * from double_test14_23;

--double_test14_24
SELECT * from double_test14_24;
--ok
INSERT INTO double_test14_24 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_24;
--PKEY col0 col1 null error 
INSERT INTO double_test14_24(col2) VALUES(3.3);
SELECT * from double_test14_24;
--PKEY col0 null error 
INSERT INTO double_test14_24(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_24;
--PKEY col1 null error 
INSERT INTO double_test14_24(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_24;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_24(col0,col1) VALUES(1.1,1.1);
SELECT * from double_test14_24;
--ok
INSERT INTO double_test14_24(col0,col1) VALUES(2.2,2.2);
SELECT * from double_test14_24;

--double_test14_25
SELECT * from double_test14_25;
--ok
INSERT INTO double_test14_25 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_25;
--PKEY col0 col1 null error 
INSERT INTO double_test14_25(col2) VALUES(3.3);
SELECT * from double_test14_25;
--PKEY col0 null error 
INSERT INTO double_test14_25(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_25;
--PKEY col1 null error 
INSERT INTO double_test14_25(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_25;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_25(col0,col1) VALUES(1.1,1.1);
SELECT * from double_test14_25;
--not null constraint col0 error
INSERT INTO double_test14_25(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_25;
--ok
INSERT INTO double_test14_25(col0,col1) VALUES(2.2,2.2);
SELECT * from double_test14_25;

--double_test14_26
SELECT * from double_test14_26;
--ok
INSERT INTO double_test14_26 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_26;
--PKEY col0 col1 null error 
INSERT INTO double_test14_26(col2) VALUES(3.3);
SELECT * from double_test14_26;
--PKEY col0 null error 
INSERT INTO double_test14_26(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_26;
--PKEY col1 null error 
INSERT INTO double_test14_26(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_26;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_26(col0,col1) VALUES(1.1,1.1);
SELECT * from double_test14_26;
--not null constraint col1 error
INSERT INTO double_test14_26(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_26;
--ok
INSERT INTO double_test14_26(col0,col1) VALUES(2.2,2.2);
SELECT * from double_test14_26;

--double_test14_27
SELECT * from double_test14_27;
--ok
INSERT INTO double_test14_27 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_27;
--PKEY col0 col1 null error 
INSERT INTO double_test14_27(col2) VALUES(3.3);
SELECT * from double_test14_27;
--PKEY col0 null error 
INSERT INTO double_test14_27(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_27;
--PKEY col1 null error 
INSERT INTO double_test14_27(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_27;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_27(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from double_test14_27;
--not null constraint col2 error
INSERT INTO double_test14_27(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_27;
--ok
INSERT INTO double_test14_27(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from double_test14_27;

--double_test14_28
SELECT * from double_test14_28;
--ok
INSERT INTO double_test14_28 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_28;
--PKEY col0 col1 null error 
INSERT INTO double_test14_28(col2) VALUES(3.3);
SELECT * from double_test14_28;
--PKEY col0 null error 
INSERT INTO double_test14_28(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_28;
--PKEY col1 null error 
INSERT INTO double_test14_28(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_28;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_28(col0,col1) VALUES(1.1,1.1);
SELECT * from double_test14_28;
--not null constraint col0 error
INSERT INTO double_test14_28(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_28;
--not null constraint col1 error
INSERT INTO double_test14_28(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_28;
--ok
INSERT INTO double_test14_28(col0,col1) VALUES(2.2,2.2);
SELECT * from double_test14_28;

--double_test14_29
SELECT * from double_test14_29;
--ok
INSERT INTO double_test14_29 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_29;
--PKEY col0 col1 null error 
INSERT INTO double_test14_29(col2) VALUES(3.3);
SELECT * from double_test14_29;
--PKEY col0 null error 
INSERT INTO double_test14_29(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_29;
--PKEY col1 null error 
INSERT INTO double_test14_29(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_29;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_29(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from double_test14_29;
--not null constraint col1 error
INSERT INTO double_test14_29(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_29;
--not null constraint col2 error
INSERT INTO double_test14_29(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_29;
--ok
INSERT INTO double_test14_29(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from double_test14_29;

--double_test14_30
SELECT * from double_test14_30;
--ok
INSERT INTO double_test14_30 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_30;
--PKEY col0 col1 null error 
INSERT INTO double_test14_30(col2) VALUES(3.3);
SELECT * from double_test14_30;
--PKEY col0 null error 
INSERT INTO double_test14_30(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_30;
--PKEY col1 null error 
INSERT INTO double_test14_30(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_30;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_30(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from double_test14_30;
--not null constraint col0 error
INSERT INTO double_test14_30(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_30;
--not null constraint col2 error
INSERT INTO double_test14_30(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_30;
--ok
INSERT INTO double_test14_30(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from double_test14_30;

--double_test14_31
SELECT * from double_test14_31;
--ok
INSERT INTO double_test14_31 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_31;
--PKEY col0 col1 null error 
INSERT INTO double_test14_31(col2) VALUES(3.3);
SELECT * from double_test14_31;
--PKEY col0 null error 
INSERT INTO double_test14_31(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_31;
--PKEY col1 null error 
INSERT INTO double_test14_31(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_31;
--PKEY col0 col1 not unique error
INSERT INTO double_test14_31(col0,col1,col2) VALUES(1.1,1.1,3.3);
SELECT * from double_test14_31;
--not null constraint col0 error
INSERT INTO double_test14_31(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_31;
--not null constraint col1 error
INSERT INTO double_test14_31(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_31;
--not null constraint col2 error
INSERT INTO double_test14_31(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_31;
--ok
INSERT INTO double_test14_31(col0,col1,col2) VALUES(2.2,2.2,6.6);
SELECT * from double_test14_31;

--double_test14_32
SELECT * from double_test14_32;
--ok
INSERT INTO double_test14_32 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_32;
--PKEY col1 col2 null error 
INSERT INTO double_test14_32(col0) VALUES(3.3);
SELECT * from double_test14_32;
--PKEY col1 null error 
INSERT INTO double_test14_32(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_32;
--PKEY col2 null error 
INSERT INTO double_test14_32(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_32;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_32(col1,col2) VALUES(1.1,1.1);
SELECT * from double_test14_32;
--ok
INSERT INTO double_test14_32(col1,col2) VALUES(2.2,2.2);
SELECT * from double_test14_32;

--double_test14_33
SELECT * from double_test14_33;
--ok
INSERT INTO double_test14_33 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_33;
--PKEY col1 col2 null error 
INSERT INTO double_test14_33(col0) VALUES(3.3);
SELECT * from double_test14_33;
--PKEY col1 null error 
INSERT INTO double_test14_33(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_33;
--PKEY col2 null error 
INSERT INTO double_test14_33(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_33;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_33(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from double_test14_33;
--not null constraint col0 error
INSERT INTO double_test14_33(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_33;
--ok
INSERT INTO double_test14_33(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from double_test14_33;

--double_test14_34
SELECT * from double_test14_34;
--ok
INSERT INTO double_test14_34 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_34;
--PKEY col1 col2 null error 
INSERT INTO double_test14_34(col0) VALUES(3.3);
SELECT * from double_test14_34;
--PKEY col1 null error 
INSERT INTO double_test14_34(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_34;
--PKEY col2 null error 
INSERT INTO double_test14_34(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_34;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_34(col1,col2) VALUES(1.1,1.1);
SELECT * from double_test14_34;
--not null constraint col1 error
INSERT INTO double_test14_34(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_34;
--ok
INSERT INTO double_test14_34(col1,col2) VALUES(2.2,2.2);
SELECT * from double_test14_34;

--double_test14_35
SELECT * from double_test14_35;
--ok
INSERT INTO double_test14_35 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_35;
--PKEY col1 col2 null error 
INSERT INTO double_test14_35(col0) VALUES(3.3);
SELECT * from double_test14_35;
--PKEY col1 null error 
INSERT INTO double_test14_35(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_35;
--PKEY col2 null error 
INSERT INTO double_test14_35(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_35;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_35(col1,col2) VALUES(1.1,1.1);
SELECT * from double_test14_35;
--not null constraint col2 error
INSERT INTO double_test14_35(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_35;
--ok
INSERT INTO double_test14_35(col1,col2) VALUES(2.2,2.2);
SELECT * from double_test14_35;

--double_test14_36
SELECT * from double_test14_36;
--ok
INSERT INTO double_test14_36 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_36;
--PKEY col1 col2 null error 
INSERT INTO double_test14_36(col0) VALUES(3.3);
SELECT * from double_test14_36;
--PKEY col1 null error 
INSERT INTO double_test14_36(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_36;
--PKEY col2 null error 
INSERT INTO double_test14_36(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_36;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_36(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from double_test14_36;
--not null constraint col0 error
INSERT INTO double_test14_36(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_36;
--not null constraint col1 error
INSERT INTO double_test14_36(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_36;
--ok
INSERT INTO double_test14_36(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from double_test14_36;

--double_test14_37
SELECT * from double_test14_37;
--ok
INSERT INTO double_test14_37 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_37;
--PKEY col1 col2 null error 
INSERT INTO double_test14_37(col0) VALUES(3.3);
SELECT * from double_test14_37;
--PKEY col1 null error 
INSERT INTO double_test14_37(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_37;
--PKEY col2 null error 
INSERT INTO double_test14_37(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_37;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_37(col1,col2) VALUES(1.1,1.1);
SELECT * from double_test14_37;
--not null constraint col1 error
INSERT INTO double_test14_37(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_37;
--not null constraint col2 error
INSERT INTO double_test14_37(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_37;
--ok
INSERT INTO double_test14_37(col1,col2) VALUES(2.2,2.2);
SELECT * from double_test14_37;

--double_test14_38
SELECT * from double_test14_38;
--ok
INSERT INTO double_test14_38 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_38;
--PKEY col1 col2 null error 
INSERT INTO double_test14_38(col0) VALUES(3.3);
SELECT * from double_test14_38;
--PKEY col1 null error 
INSERT INTO double_test14_38(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_38;
--PKEY col2 null error 
INSERT INTO double_test14_38(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_38;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_38(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from double_test14_38;
--not null constraint col0 error
INSERT INTO double_test14_38(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_38;
--not null constraint col2 error
INSERT INTO double_test14_38(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_38;
--ok
INSERT INTO double_test14_38(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from double_test14_38;

--double_test14_39
SELECT * from double_test14_39;
--ok
INSERT INTO double_test14_39 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_39;
--PKEY col1 col2 null error 
INSERT INTO double_test14_39(col0) VALUES(3.3);
SELECT * from double_test14_39;
--PKEY col1 null error 
INSERT INTO double_test14_39(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_39;
--PKEY col2 null error 
INSERT INTO double_test14_39(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_39;
--PKEY col1 col2 not unique error
INSERT INTO double_test14_39(col0,col1,col2) VALUES(3.3,1.1,1.1);
SELECT * from double_test14_39;
--not null constraint col0 error
INSERT INTO double_test14_39(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_39;
--not null constraint col1 error
INSERT INTO double_test14_39(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_39;
--not null constraint col2 error
INSERT INTO double_test14_39(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_39;
--ok
INSERT INTO double_test14_39(col0,col1,col2) VALUES(6.6,2.2,2.2);
SELECT * from double_test14_39;

--double_test14_40
SELECT * from double_test14_40;
--ok
INSERT INTO double_test14_40 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_40;
--PKEY col0 col2 null error 
INSERT INTO double_test14_40(col1) VALUES(3.3);
SELECT * from double_test14_40;
--PKEY col0 null error 
INSERT INTO double_test14_40(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_40;
--PKEY col2 null error 
INSERT INTO double_test14_40(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_40;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_40(col0,col2) VALUES(1.1,1.1);
SELECT * from double_test14_40;
--ok
INSERT INTO double_test14_40(col0,col2) VALUES(2.2,2.2);
SELECT * from double_test14_40;

--double_test14_41
SELECT * from double_test14_41;
--ok
INSERT INTO double_test14_41 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_41;
--PKEY col0 col2 null error 
INSERT INTO double_test14_41(col1) VALUES(3.3);
SELECT * from double_test14_41;
--PKEY col0 null error 
INSERT INTO double_test14_41(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_41;
--PKEY col2 null error 
INSERT INTO double_test14_41(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_41;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_41(col0,col2) VALUES(1.1,1.1);
SELECT * from double_test14_41;
--not null constraint col0 error
INSERT INTO double_test14_41(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_41;
--ok
INSERT INTO double_test14_41(col0,col2) VALUES(2.2,2.2);
SELECT * from double_test14_41;

--double_test14_42
SELECT * from double_test14_42;
--ok
INSERT INTO double_test14_42 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_42;
--PKEY col0 col2 null error 
INSERT INTO double_test14_42(col1) VALUES(3.3);
SELECT * from double_test14_42;
--PKEY col0 null error 
INSERT INTO double_test14_42(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_42;
--PKEY col2 null error 
INSERT INTO double_test14_42(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_42;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_42(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from double_test14_42;
--not null constraint col1 error
INSERT INTO double_test14_42(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_42;
--ok
INSERT INTO double_test14_42(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from double_test14_42;

--double_test14_43
SELECT * from double_test14_43;
--ok
INSERT INTO double_test14_43 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_43;
--PKEY col0 col2 null error 
INSERT INTO double_test14_43(col1) VALUES(3.3);
SELECT * from double_test14_43;
--PKEY col0 null error 
INSERT INTO double_test14_43(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_43;
--PKEY col2 null error 
INSERT INTO double_test14_43(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_43;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_43(col0,col2) VALUES(1.1,1.1);
SELECT * from double_test14_43;
--not null constraint col2 error
INSERT INTO double_test14_43(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_43;
--ok
INSERT INTO double_test14_43(col0,col2) VALUES(2.2,2.2);
SELECT * from double_test14_43;

--double_test14_44
SELECT * from double_test14_44;
--ok
INSERT INTO double_test14_44 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_44;
--PKEY col0 col2 null error 
INSERT INTO double_test14_44(col1) VALUES(3.3);
SELECT * from double_test14_44;
--PKEY col0 null error 
INSERT INTO double_test14_44(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_44;
--PKEY col2 null error 
INSERT INTO double_test14_44(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_44;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_44(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from double_test14_44;
--not null constraint col0 error
INSERT INTO double_test14_44(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_44;
--not null constraint col1 error
INSERT INTO double_test14_44(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_44;
--ok
INSERT INTO double_test14_44(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from double_test14_44;

--double_test14_45
SELECT * from double_test14_45;
--ok
INSERT INTO double_test14_45 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_45;
--PKEY col0 col2 null error 
INSERT INTO double_test14_45(col1) VALUES(3.3);
SELECT * from double_test14_45;
--PKEY col0 null error 
INSERT INTO double_test14_45(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_45;
--PKEY col2 null error 
INSERT INTO double_test14_45(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_45;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_45(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from double_test14_45;
--not null constraint col1 error
INSERT INTO double_test14_45(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_45;
--not null constraint col2 error
INSERT INTO double_test14_45(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_45;
--ok
INSERT INTO double_test14_45(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from double_test14_45;

--double_test14_46
SELECT * from double_test14_46;
--ok
INSERT INTO double_test14_46 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_46;
--PKEY col0 col2 null error 
INSERT INTO double_test14_46(col1) VALUES(3.3);
SELECT * from double_test14_46;
--PKEY col0 null error 
INSERT INTO double_test14_46(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_46;
--PKEY col2 null error 
INSERT INTO double_test14_46(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_46;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_46(col0,col2) VALUES(1.1,1.1);
SELECT * from double_test14_46;
--not null constraint col0 error
INSERT INTO double_test14_46(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_46;
--not null constraint col2 error
INSERT INTO double_test14_46(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_46;
--ok
INSERT INTO double_test14_46(col0,col2) VALUES(2.2,2.2);
SELECT * from double_test14_46;

--double_test14_47
SELECT * from double_test14_47;
--ok
INSERT INTO double_test14_47 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_47;
--PKEY col0 col2 null error 
INSERT INTO double_test14_47(col1) VALUES(3.3);
SELECT * from double_test14_47;
--PKEY col0 null error 
INSERT INTO double_test14_47(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_47;
--PKEY col2 null error 
INSERT INTO double_test14_47(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_47;
--PKEY col0 col2 not unique error
INSERT INTO double_test14_47(col0,col1,col2) VALUES(1.1,3.3,1.1);
SELECT * from double_test14_47;
--not null constraint col0 error
INSERT INTO double_test14_47(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_47;
--not null constraint col1 error
INSERT INTO double_test14_47(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_47;
--not null constraint col2 error
INSERT INTO double_test14_47(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_47;
--ok
INSERT INTO double_test14_47(col0,col1,col2) VALUES(2.2,6.6,2.2);
SELECT * from double_test14_47;

--double_test14_48
SELECT * from double_test14_48;
--ok
INSERT INTO double_test14_48 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_48;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_48() VALUES();
SELECT * from double_test14_48;
--PKEY col0 null error 
INSERT INTO double_test14_48(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_48;
--PKEY col1 null error 
INSERT INTO double_test14_48(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_48;
--PKEY col2 null error 
INSERT INTO double_test14_48(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_48;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_48(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_48;
--ok
INSERT INTO double_test14_48(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_48;

--double_test14_49
SELECT * from double_test14_49;
--ok
INSERT INTO double_test14_49 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_49;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_49() VALUES();
SELECT * from double_test14_49;
--PKEY col0 null error 
INSERT INTO double_test14_49(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_49;
--PKEY col1 null error 
INSERT INTO double_test14_49(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_49;
--PKEY col2 null error 
INSERT INTO double_test14_49(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_49;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_49(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_49;
--not null constraint col0 error
INSERT INTO double_test14_49(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_49;
--ok
INSERT INTO double_test14_49(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_49;

--double_test14_50
SELECT * from double_test14_50;
--ok
INSERT INTO double_test14_50 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_50;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_50() VALUES();
SELECT * from double_test14_50;
--PKEY col0 null error 
INSERT INTO double_test14_50(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_50;
--PKEY col1 null error 
INSERT INTO double_test14_50(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_50;
--PKEY col2 null error 
INSERT INTO double_test14_50(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_50;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_50(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_50;
--not null constraint col1 error
INSERT INTO double_test14_50(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_50;
--ok
INSERT INTO double_test14_50(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_50;

--double_test14_51
SELECT * from double_test14_51;
--ok
INSERT INTO double_test14_51 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_51;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_51() VALUES();
SELECT * from double_test14_51;
--PKEY col0 null error 
INSERT INTO double_test14_51(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_51;
--PKEY col1 null error 
INSERT INTO double_test14_51(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_51;
--PKEY col2 null error 
INSERT INTO double_test14_51(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_51;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_51(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_51;
--not null constraint col2 error
INSERT INTO double_test14_51(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_51;
--ok
INSERT INTO double_test14_51(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_51;

--double_test14_52
SELECT * from double_test14_52;
--ok
INSERT INTO double_test14_52 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_52;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_52() VALUES();
SELECT * from double_test14_52;
--PKEY col0 null error 
INSERT INTO double_test14_52(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_52;
--PKEY col1 null error 
INSERT INTO double_test14_52(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_52;
--PKEY col2 null error 
INSERT INTO double_test14_52(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_52;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_52(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_52;
--not null constraint col0 error
INSERT INTO double_test14_52(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_52;
--not null constraint col1 error
INSERT INTO double_test14_52(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_52;
--ok
INSERT INTO double_test14_52(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_52;

--double_test14_53
SELECT * from double_test14_53;
--ok
INSERT INTO double_test14_53 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_53;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_53() VALUES();
SELECT * from double_test14_53;
--PKEY col0 null error 
INSERT INTO double_test14_53(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_53;
--PKEY col1 null error 
INSERT INTO double_test14_53(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_53;
--PKEY col2 null error 
INSERT INTO double_test14_53(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_53;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_53(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_53;
--not null constraint col1 error
INSERT INTO double_test14_53(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_53;
--not null constraint col2 error
INSERT INTO double_test14_53(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_53;
--ok
INSERT INTO double_test14_53(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_53;

--double_test14_54
SELECT * from double_test14_54;
--ok
INSERT INTO double_test14_54 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_54;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_54() VALUES();
SELECT * from double_test14_54;
--PKEY col0 null error 
INSERT INTO double_test14_54(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_54;
--PKEY col1 null error 
INSERT INTO double_test14_54(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_54;
--PKEY col2 null error 
INSERT INTO double_test14_54(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_54;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_54(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_54;
--not null constraint col0 error
INSERT INTO double_test14_54(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_54;
--not null constraint col2 error
INSERT INTO double_test14_54(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_54;
--ok
INSERT INTO double_test14_54(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_54;

--double_test14_55
SELECT * from double_test14_55;
--ok
INSERT INTO double_test14_55 VALUES(1.1, 1.1, 1.1);
SELECT * from double_test14_55;
--PKEY col0 col1 col2 null error 
INSERT INTO double_test14_55() VALUES();
SELECT * from double_test14_55;
--PKEY col0 null error 
INSERT INTO double_test14_55(col1,col2) VALUES(3.3,3.3);
SELECT * from double_test14_55;
--PKEY col1 null error 
INSERT INTO double_test14_55(col0,col2) VALUES(3.3,3.3);
SELECT * from double_test14_55;
--PKEY col2 null error 
INSERT INTO double_test14_55(col0,col1) VALUES(3.3,3.3);
SELECT * from double_test14_55;
--PKEY col0 col1 col2 not unique error
INSERT INTO double_test14_55(col0,col1,col2) VALUES(1.1,1.1,1.1);
SELECT * from double_test14_55;
--not null constraint col0 error
INSERT INTO double_test14_55(col1,col2) VALUES(5.5,5.5);
SELECT * from double_test14_55;
--not null constraint col1 error
INSERT INTO double_test14_55(col0,col2) VALUES(5.5,5.5);
SELECT * from double_test14_55;
--not null constraint col2 error
INSERT INTO double_test14_55(col0,col1) VALUES(5.5,5.5);
SELECT * from double_test14_55;
--ok
INSERT INTO double_test14_55(col0,col1,col2) VALUES(2.2,2.2,2.2);
SELECT * from double_test14_55;

CREATE TABLE char_test14_0 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_1 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_2 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_3 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_4 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_5 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_6 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_7 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE char_test14_8 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_9 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_10 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_11 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_12 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_13 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_14 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_15 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE char_test14_16 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_17 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_18 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_19 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_20 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_21 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_22 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_23 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE char_test14_24 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_25 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_26 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_27 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_28 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_29 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_30 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_31 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE char_test14_32 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_33 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_34 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_35 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_36 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_37 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_38 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_39 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_40 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_41 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_42 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_43 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_44 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_45 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_46 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_47 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_48 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_49 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_50 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_51 (
col0 char(10) ,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_52 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_53 (
col0 char(10) ,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_54 (
col0 char(10) NOT NULL,
col1 char(10) ,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE char_test14_55 (
col0 char(10) NOT NULL,
col1 char(10) NOT NULL,
col2 char(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE FOREIGN TABLE char_test14_0 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_1 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_2 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_3 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_4 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_5 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_6 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_7 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_8 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_9 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_10 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_11 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_12 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_13 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_14 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_15 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_16 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_17 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_18 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_19 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_20 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_21 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_22 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_23 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_24 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_25 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_26 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_27 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_28 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_29 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_30 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_31 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_32 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_33 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_34 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_35 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_36 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_37 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_38 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_39 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_40 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_41 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_42 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_43 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_44 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_45 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_46 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_47 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_48 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_49 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_50 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_51 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_52 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_53 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_54 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE char_test14_55 (
col0 char(10) ,col1 char(10) ,col2 char(10) 
) SERVER ogawayama;
--char_test14_0
SELECT * from char_test14_0;
--ok
INSERT INTO char_test14_0 VALUES('1', '1', '1');
SELECT * from char_test14_0;
--PKEY col0 null error 
INSERT INTO char_test14_0(col1,col2) VALUES('3','3');
SELECT * from char_test14_0;
--PKEY col0 null error 
INSERT INTO char_test14_0(col1,col2) VALUES('3','3');
SELECT * from char_test14_0;
--PKEY col0 not unique error
INSERT INTO char_test14_0(col0) VALUES('1');
SELECT * from char_test14_0;
--ok
INSERT INTO char_test14_0(col0) VALUES('2');
SELECT * from char_test14_0;

--char_test14_1
SELECT * from char_test14_1;
--ok
INSERT INTO char_test14_1 VALUES('1', '1', '1');
SELECT * from char_test14_1;
--PKEY col0 null error 
INSERT INTO char_test14_1(col1,col2) VALUES('3','3');
SELECT * from char_test14_1;
--PKEY col0 null error 
INSERT INTO char_test14_1(col1,col2) VALUES('3','3');
SELECT * from char_test14_1;
--PKEY col0 not unique error
INSERT INTO char_test14_1(col0) VALUES('1');
SELECT * from char_test14_1;
--not null constraint col0 error
INSERT INTO char_test14_1(col1,col2) VALUES('5','5');
SELECT * from char_test14_1;
--ok
INSERT INTO char_test14_1(col0) VALUES('2');
SELECT * from char_test14_1;

--char_test14_2
SELECT * from char_test14_2;
--ok
INSERT INTO char_test14_2 VALUES('1', '1', '1');
SELECT * from char_test14_2;
--PKEY col0 null error 
INSERT INTO char_test14_2(col1,col2) VALUES('3','3');
SELECT * from char_test14_2;
--PKEY col0 null error 
INSERT INTO char_test14_2(col1,col2) VALUES('3','3');
SELECT * from char_test14_2;
--PKEY col0 not unique error
INSERT INTO char_test14_2(col0,col1) VALUES('1','3');
SELECT * from char_test14_2;
--not null constraint col1 error
INSERT INTO char_test14_2(col0,col2) VALUES('5','5');
SELECT * from char_test14_2;
--ok
INSERT INTO char_test14_2(col0,col1) VALUES('2','6');
SELECT * from char_test14_2;

--char_test14_3
SELECT * from char_test14_3;
--ok
INSERT INTO char_test14_3 VALUES('1', '1', '1');
SELECT * from char_test14_3;
--PKEY col0 null error 
INSERT INTO char_test14_3(col1,col2) VALUES('3','3');
SELECT * from char_test14_3;
--PKEY col0 null error 
INSERT INTO char_test14_3(col1,col2) VALUES('3','3');
SELECT * from char_test14_3;
--PKEY col0 not unique error
INSERT INTO char_test14_3(col0,col2) VALUES('1','3');
SELECT * from char_test14_3;
--not null constraint col2 error
INSERT INTO char_test14_3(col0,col1) VALUES('5','5');
SELECT * from char_test14_3;
--ok
INSERT INTO char_test14_3(col0,col2) VALUES('2','6');
SELECT * from char_test14_3;

--char_test14_4
SELECT * from char_test14_4;
--ok
INSERT INTO char_test14_4 VALUES('1', '1', '1');
SELECT * from char_test14_4;
--PKEY col0 null error 
INSERT INTO char_test14_4(col1,col2) VALUES('3','3');
SELECT * from char_test14_4;
--PKEY col0 null error 
INSERT INTO char_test14_4(col1,col2) VALUES('3','3');
SELECT * from char_test14_4;
--PKEY col0 not unique error
INSERT INTO char_test14_4(col0,col1) VALUES('1','3');
SELECT * from char_test14_4;
--not null constraint col0 error
INSERT INTO char_test14_4(col1,col2) VALUES('5','5');
SELECT * from char_test14_4;
--not null constraint col1 error
INSERT INTO char_test14_4(col0,col2) VALUES('5','5');
SELECT * from char_test14_4;
--ok
INSERT INTO char_test14_4(col0,col1) VALUES('2','6');
SELECT * from char_test14_4;

--char_test14_5
SELECT * from char_test14_5;
--ok
INSERT INTO char_test14_5 VALUES('1', '1', '1');
SELECT * from char_test14_5;
--PKEY col0 null error 
INSERT INTO char_test14_5(col1,col2) VALUES('3','3');
SELECT * from char_test14_5;
--PKEY col0 null error 
INSERT INTO char_test14_5(col1,col2) VALUES('3','3');
SELECT * from char_test14_5;
--PKEY col0 not unique error
INSERT INTO char_test14_5(col0,col1,col2) VALUES('1','3','3');
SELECT * from char_test14_5;
--not null constraint col1 error
INSERT INTO char_test14_5(col0,col2) VALUES('5','5');
SELECT * from char_test14_5;
--not null constraint col2 error
INSERT INTO char_test14_5(col0,col1) VALUES('5','5');
SELECT * from char_test14_5;
--ok
INSERT INTO char_test14_5(col0,col1,col2) VALUES('2','6','6');
SELECT * from char_test14_5;

--char_test14_6
SELECT * from char_test14_6;
--ok
INSERT INTO char_test14_6 VALUES('1', '1', '1');
SELECT * from char_test14_6;
--PKEY col0 null error 
INSERT INTO char_test14_6(col1,col2) VALUES('3','3');
SELECT * from char_test14_6;
--PKEY col0 null error 
INSERT INTO char_test14_6(col1,col2) VALUES('3','3');
SELECT * from char_test14_6;
--PKEY col0 not unique error
INSERT INTO char_test14_6(col0,col2) VALUES('1','3');
SELECT * from char_test14_6;
--not null constraint col0 error
INSERT INTO char_test14_6(col1,col2) VALUES('5','5');
SELECT * from char_test14_6;
--not null constraint col2 error
INSERT INTO char_test14_6(col0,col1) VALUES('5','5');
SELECT * from char_test14_6;
--ok
INSERT INTO char_test14_6(col0,col2) VALUES('2','6');
SELECT * from char_test14_6;

--char_test14_7
SELECT * from char_test14_7;
--ok
INSERT INTO char_test14_7 VALUES('1', '1', '1');
SELECT * from char_test14_7;
--PKEY col0 null error 
INSERT INTO char_test14_7(col1,col2) VALUES('3','3');
SELECT * from char_test14_7;
--PKEY col0 null error 
INSERT INTO char_test14_7(col1,col2) VALUES('3','3');
SELECT * from char_test14_7;
--PKEY col0 not unique error
INSERT INTO char_test14_7(col0,col1,col2) VALUES('1','3','3');
SELECT * from char_test14_7;
--not null constraint col0 error
INSERT INTO char_test14_7(col1,col2) VALUES('5','5');
SELECT * from char_test14_7;
--not null constraint col1 error
INSERT INTO char_test14_7(col0,col2) VALUES('5','5');
SELECT * from char_test14_7;
--not null constraint col2 error
INSERT INTO char_test14_7(col0,col1) VALUES('5','5');
SELECT * from char_test14_7;
--ok
INSERT INTO char_test14_7(col0,col1,col2) VALUES('2','6','6');
SELECT * from char_test14_7;

--char_test14_8
SELECT * from char_test14_8;
--ok
INSERT INTO char_test14_8 VALUES('1', '1', '1');
SELECT * from char_test14_8;
--PKEY col1 null error 
INSERT INTO char_test14_8(col0,col2) VALUES('3','3');
SELECT * from char_test14_8;
--PKEY col1 null error 
INSERT INTO char_test14_8(col0,col2) VALUES('3','3');
SELECT * from char_test14_8;
--PKEY col1 not unique error
INSERT INTO char_test14_8(col1) VALUES('1');
SELECT * from char_test14_8;
--ok
INSERT INTO char_test14_8(col1) VALUES('2');
SELECT * from char_test14_8;

--char_test14_9
SELECT * from char_test14_9;
--ok
INSERT INTO char_test14_9 VALUES('1', '1', '1');
SELECT * from char_test14_9;
--PKEY col1 null error 
INSERT INTO char_test14_9(col0,col2) VALUES('3','3');
SELECT * from char_test14_9;
--PKEY col1 null error 
INSERT INTO char_test14_9(col0,col2) VALUES('3','3');
SELECT * from char_test14_9;
--PKEY col1 not unique error
INSERT INTO char_test14_9(col0,col1) VALUES('3','1');
SELECT * from char_test14_9;
--not null constraint col0 error
INSERT INTO char_test14_9(col1,col2) VALUES('5','5');
SELECT * from char_test14_9;
--ok
INSERT INTO char_test14_9(col0,col1) VALUES('6','2');
SELECT * from char_test14_9;

--char_test14_10
SELECT * from char_test14_10;
--ok
INSERT INTO char_test14_10 VALUES('1', '1', '1');
SELECT * from char_test14_10;
--PKEY col1 null error 
INSERT INTO char_test14_10(col0,col2) VALUES('3','3');
SELECT * from char_test14_10;
--PKEY col1 null error 
INSERT INTO char_test14_10(col0,col2) VALUES('3','3');
SELECT * from char_test14_10;
--PKEY col1 not unique error
INSERT INTO char_test14_10(col1) VALUES('1');
SELECT * from char_test14_10;
--not null constraint col1 error
INSERT INTO char_test14_10(col0,col2) VALUES('5','5');
SELECT * from char_test14_10;
--ok
INSERT INTO char_test14_10(col1) VALUES('2');
SELECT * from char_test14_10;

--char_test14_11
SELECT * from char_test14_11;
--ok
INSERT INTO char_test14_11 VALUES('1', '1', '1');
SELECT * from char_test14_11;
--PKEY col1 null error 
INSERT INTO char_test14_11(col0,col2) VALUES('3','3');
SELECT * from char_test14_11;
--PKEY col1 null error 
INSERT INTO char_test14_11(col0,col2) VALUES('3','3');
SELECT * from char_test14_11;
--PKEY col1 not unique error
INSERT INTO char_test14_11(col1,col2) VALUES('1','3');
SELECT * from char_test14_11;
--not null constraint col2 error
INSERT INTO char_test14_11(col0,col1) VALUES('5','5');
SELECT * from char_test14_11;
--ok
INSERT INTO char_test14_11(col1,col2) VALUES('2','6');
SELECT * from char_test14_11;

--char_test14_12
SELECT * from char_test14_12;
--ok
INSERT INTO char_test14_12 VALUES('1', '1', '1');
SELECT * from char_test14_12;
--PKEY col1 null error 
INSERT INTO char_test14_12(col0,col2) VALUES('3','3');
SELECT * from char_test14_12;
--PKEY col1 null error 
INSERT INTO char_test14_12(col0,col2) VALUES('3','3');
SELECT * from char_test14_12;
--PKEY col1 not unique error
INSERT INTO char_test14_12(col0,col1) VALUES('3','1');
SELECT * from char_test14_12;
--not null constraint col0 error
INSERT INTO char_test14_12(col1,col2) VALUES('5','5');
SELECT * from char_test14_12;
--not null constraint col1 error
INSERT INTO char_test14_12(col0,col2) VALUES('5','5');
SELECT * from char_test14_12;
--ok
INSERT INTO char_test14_12(col0,col1) VALUES('6','2');
SELECT * from char_test14_12;

--char_test14_13
SELECT * from char_test14_13;
--ok
INSERT INTO char_test14_13 VALUES('1', '1', '1');
SELECT * from char_test14_13;
--PKEY col1 null error 
INSERT INTO char_test14_13(col0,col2) VALUES('3','3');
SELECT * from char_test14_13;
--PKEY col1 null error 
INSERT INTO char_test14_13(col0,col2) VALUES('3','3');
SELECT * from char_test14_13;
--PKEY col1 not unique error
INSERT INTO char_test14_13(col1,col2) VALUES('1','3');
SELECT * from char_test14_13;
--not null constraint col1 error
INSERT INTO char_test14_13(col0,col2) VALUES('5','5');
SELECT * from char_test14_13;
--not null constraint col2 error
INSERT INTO char_test14_13(col0,col1) VALUES('5','5');
SELECT * from char_test14_13;
--ok
INSERT INTO char_test14_13(col1,col2) VALUES('2','6');
SELECT * from char_test14_13;

--char_test14_14
SELECT * from char_test14_14;
--ok
INSERT INTO char_test14_14 VALUES('1', '1', '1');
SELECT * from char_test14_14;
--PKEY col1 null error 
INSERT INTO char_test14_14(col0,col2) VALUES('3','3');
SELECT * from char_test14_14;
--PKEY col1 null error 
INSERT INTO char_test14_14(col0,col2) VALUES('3','3');
SELECT * from char_test14_14;
--PKEY col1 not unique error
INSERT INTO char_test14_14(col0,col1,col2) VALUES('3','1','3');
SELECT * from char_test14_14;
--not null constraint col0 error
INSERT INTO char_test14_14(col1,col2) VALUES('5','5');
SELECT * from char_test14_14;
--not null constraint col2 error
INSERT INTO char_test14_14(col0,col1) VALUES('5','5');
SELECT * from char_test14_14;
--ok
INSERT INTO char_test14_14(col0,col1,col2) VALUES('6','2','6');
SELECT * from char_test14_14;

--char_test14_15
SELECT * from char_test14_15;
--ok
INSERT INTO char_test14_15 VALUES('1', '1', '1');
SELECT * from char_test14_15;
--PKEY col1 null error 
INSERT INTO char_test14_15(col0,col2) VALUES('3','3');
SELECT * from char_test14_15;
--PKEY col1 null error 
INSERT INTO char_test14_15(col0,col2) VALUES('3','3');
SELECT * from char_test14_15;
--PKEY col1 not unique error
INSERT INTO char_test14_15(col0,col1,col2) VALUES('3','1','3');
SELECT * from char_test14_15;
--not null constraint col0 error
INSERT INTO char_test14_15(col1,col2) VALUES('5','5');
SELECT * from char_test14_15;
--not null constraint col1 error
INSERT INTO char_test14_15(col0,col2) VALUES('5','5');
SELECT * from char_test14_15;
--not null constraint col2 error
INSERT INTO char_test14_15(col0,col1) VALUES('5','5');
SELECT * from char_test14_15;
--ok
INSERT INTO char_test14_15(col0,col1,col2) VALUES('6','2','6');
SELECT * from char_test14_15;

--char_test14_16
SELECT * from char_test14_16;
--ok
INSERT INTO char_test14_16 VALUES('1', '1', '1');
SELECT * from char_test14_16;
--PKEY col2 null error 
INSERT INTO char_test14_16(col0,col1) VALUES('3','3');
SELECT * from char_test14_16;
--PKEY col2 null error 
INSERT INTO char_test14_16(col0,col1) VALUES('3','3');
SELECT * from char_test14_16;
--PKEY col2 not unique error
INSERT INTO char_test14_16(col2) VALUES('1');
SELECT * from char_test14_16;
--ok
INSERT INTO char_test14_16(col2) VALUES('2');
SELECT * from char_test14_16;

--char_test14_17
SELECT * from char_test14_17;
--ok
INSERT INTO char_test14_17 VALUES('1', '1', '1');
SELECT * from char_test14_17;
--PKEY col2 null error 
INSERT INTO char_test14_17(col0,col1) VALUES('3','3');
SELECT * from char_test14_17;
--PKEY col2 null error 
INSERT INTO char_test14_17(col0,col1) VALUES('3','3');
SELECT * from char_test14_17;
--PKEY col2 not unique error
INSERT INTO char_test14_17(col0,col2) VALUES('3','1');
SELECT * from char_test14_17;
--not null constraint col0 error
INSERT INTO char_test14_17(col1,col2) VALUES('5','5');
SELECT * from char_test14_17;
--ok
INSERT INTO char_test14_17(col0,col2) VALUES('6','2');
SELECT * from char_test14_17;

--char_test14_18
SELECT * from char_test14_18;
--ok
INSERT INTO char_test14_18 VALUES('1', '1', '1');
SELECT * from char_test14_18;
--PKEY col2 null error 
INSERT INTO char_test14_18(col0,col1) VALUES('3','3');
SELECT * from char_test14_18;
--PKEY col2 null error 
INSERT INTO char_test14_18(col0,col1) VALUES('3','3');
SELECT * from char_test14_18;
--PKEY col2 not unique error
INSERT INTO char_test14_18(col1,col2) VALUES('3','1');
SELECT * from char_test14_18;
--not null constraint col1 error
INSERT INTO char_test14_18(col0,col2) VALUES('5','5');
SELECT * from char_test14_18;
--ok
INSERT INTO char_test14_18(col1,col2) VALUES('6','2');
SELECT * from char_test14_18;

--char_test14_19
SELECT * from char_test14_19;
--ok
INSERT INTO char_test14_19 VALUES('1', '1', '1');
SELECT * from char_test14_19;
--PKEY col2 null error 
INSERT INTO char_test14_19(col0,col1) VALUES('3','3');
SELECT * from char_test14_19;
--PKEY col2 null error 
INSERT INTO char_test14_19(col0,col1) VALUES('3','3');
SELECT * from char_test14_19;
--PKEY col2 not unique error
INSERT INTO char_test14_19(col2) VALUES('1');
SELECT * from char_test14_19;
--not null constraint col2 error
INSERT INTO char_test14_19(col0,col1) VALUES('5','5');
SELECT * from char_test14_19;
--ok
INSERT INTO char_test14_19(col2) VALUES('2');
SELECT * from char_test14_19;

--char_test14_20
SELECT * from char_test14_20;
--ok
INSERT INTO char_test14_20 VALUES('1', '1', '1');
SELECT * from char_test14_20;
--PKEY col2 null error 
INSERT INTO char_test14_20(col0,col1) VALUES('3','3');
SELECT * from char_test14_20;
--PKEY col2 null error 
INSERT INTO char_test14_20(col0,col1) VALUES('3','3');
SELECT * from char_test14_20;
--PKEY col2 not unique error
INSERT INTO char_test14_20(col0,col1,col2) VALUES('3','3','1');
SELECT * from char_test14_20;
--not null constraint col0 error
INSERT INTO char_test14_20(col1,col2) VALUES('5','5');
SELECT * from char_test14_20;
--not null constraint col1 error
INSERT INTO char_test14_20(col0,col2) VALUES('5','5');
SELECT * from char_test14_20;
--ok
INSERT INTO char_test14_20(col0,col1,col2) VALUES('6','6','2');
SELECT * from char_test14_20;

--char_test14_21
SELECT * from char_test14_21;
--ok
INSERT INTO char_test14_21 VALUES('1', '1', '1');
SELECT * from char_test14_21;
--PKEY col2 null error 
INSERT INTO char_test14_21(col0,col1) VALUES('3','3');
SELECT * from char_test14_21;
--PKEY col2 null error 
INSERT INTO char_test14_21(col0,col1) VALUES('3','3');
SELECT * from char_test14_21;
--PKEY col2 not unique error
INSERT INTO char_test14_21(col1,col2) VALUES('3','1');
SELECT * from char_test14_21;
--not null constraint col1 error
INSERT INTO char_test14_21(col0,col2) VALUES('5','5');
SELECT * from char_test14_21;
--not null constraint col2 error
INSERT INTO char_test14_21(col0,col1) VALUES('5','5');
SELECT * from char_test14_21;
--ok
INSERT INTO char_test14_21(col1,col2) VALUES('6','2');
SELECT * from char_test14_21;

--char_test14_22
SELECT * from char_test14_22;
--ok
INSERT INTO char_test14_22 VALUES('1', '1', '1');
SELECT * from char_test14_22;
--PKEY col2 null error 
INSERT INTO char_test14_22(col0,col1) VALUES('3','3');
SELECT * from char_test14_22;
--PKEY col2 null error 
INSERT INTO char_test14_22(col0,col1) VALUES('3','3');
SELECT * from char_test14_22;
--PKEY col2 not unique error
INSERT INTO char_test14_22(col0,col2) VALUES('3','1');
SELECT * from char_test14_22;
--not null constraint col0 error
INSERT INTO char_test14_22(col1,col2) VALUES('5','5');
SELECT * from char_test14_22;
--not null constraint col2 error
INSERT INTO char_test14_22(col0,col1) VALUES('5','5');
SELECT * from char_test14_22;
--ok
INSERT INTO char_test14_22(col0,col2) VALUES('6','2');
SELECT * from char_test14_22;

--char_test14_23
SELECT * from char_test14_23;
--ok
INSERT INTO char_test14_23 VALUES('1', '1', '1');
SELECT * from char_test14_23;
--PKEY col2 null error 
INSERT INTO char_test14_23(col0,col1) VALUES('3','3');
SELECT * from char_test14_23;
--PKEY col2 null error 
INSERT INTO char_test14_23(col0,col1) VALUES('3','3');
SELECT * from char_test14_23;
--PKEY col2 not unique error
INSERT INTO char_test14_23(col0,col1,col2) VALUES('3','3','1');
SELECT * from char_test14_23;
--not null constraint col0 error
INSERT INTO char_test14_23(col1,col2) VALUES('5','5');
SELECT * from char_test14_23;
--not null constraint col1 error
INSERT INTO char_test14_23(col0,col2) VALUES('5','5');
SELECT * from char_test14_23;
--not null constraint col2 error
INSERT INTO char_test14_23(col0,col1) VALUES('5','5');
SELECT * from char_test14_23;
--ok
INSERT INTO char_test14_23(col0,col1,col2) VALUES('6','6','2');
SELECT * from char_test14_23;

--char_test14_24
SELECT * from char_test14_24;
--ok
INSERT INTO char_test14_24 VALUES('1', '1', '1');
SELECT * from char_test14_24;
--PKEY col0 col1 null error 
INSERT INTO char_test14_24(col2) VALUES('3');
SELECT * from char_test14_24;
--PKEY col0 null error 
INSERT INTO char_test14_24(col1,col2) VALUES('3','3');
SELECT * from char_test14_24;
--PKEY col1 null error 
INSERT INTO char_test14_24(col0,col2) VALUES('3','3');
SELECT * from char_test14_24;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_24(col0,col1) VALUES('1','1');
SELECT * from char_test14_24;
--ok
INSERT INTO char_test14_24(col0,col1) VALUES('2','2');
SELECT * from char_test14_24;

--char_test14_25
SELECT * from char_test14_25;
--ok
INSERT INTO char_test14_25 VALUES('1', '1', '1');
SELECT * from char_test14_25;
--PKEY col0 col1 null error 
INSERT INTO char_test14_25(col2) VALUES('3');
SELECT * from char_test14_25;
--PKEY col0 null error 
INSERT INTO char_test14_25(col1,col2) VALUES('3','3');
SELECT * from char_test14_25;
--PKEY col1 null error 
INSERT INTO char_test14_25(col0,col2) VALUES('3','3');
SELECT * from char_test14_25;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_25(col0,col1) VALUES('1','1');
SELECT * from char_test14_25;
--not null constraint col0 error
INSERT INTO char_test14_25(col1,col2) VALUES('5','5');
SELECT * from char_test14_25;
--ok
INSERT INTO char_test14_25(col0,col1) VALUES('2','2');
SELECT * from char_test14_25;

--char_test14_26
SELECT * from char_test14_26;
--ok
INSERT INTO char_test14_26 VALUES('1', '1', '1');
SELECT * from char_test14_26;
--PKEY col0 col1 null error 
INSERT INTO char_test14_26(col2) VALUES('3');
SELECT * from char_test14_26;
--PKEY col0 null error 
INSERT INTO char_test14_26(col1,col2) VALUES('3','3');
SELECT * from char_test14_26;
--PKEY col1 null error 
INSERT INTO char_test14_26(col0,col2) VALUES('3','3');
SELECT * from char_test14_26;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_26(col0,col1) VALUES('1','1');
SELECT * from char_test14_26;
--not null constraint col1 error
INSERT INTO char_test14_26(col0,col2) VALUES('5','5');
SELECT * from char_test14_26;
--ok
INSERT INTO char_test14_26(col0,col1) VALUES('2','2');
SELECT * from char_test14_26;

--char_test14_27
SELECT * from char_test14_27;
--ok
INSERT INTO char_test14_27 VALUES('1', '1', '1');
SELECT * from char_test14_27;
--PKEY col0 col1 null error 
INSERT INTO char_test14_27(col2) VALUES('3');
SELECT * from char_test14_27;
--PKEY col0 null error 
INSERT INTO char_test14_27(col1,col2) VALUES('3','3');
SELECT * from char_test14_27;
--PKEY col1 null error 
INSERT INTO char_test14_27(col0,col2) VALUES('3','3');
SELECT * from char_test14_27;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_27(col0,col1,col2) VALUES('1','1','3');
SELECT * from char_test14_27;
--not null constraint col2 error
INSERT INTO char_test14_27(col0,col1) VALUES('5','5');
SELECT * from char_test14_27;
--ok
INSERT INTO char_test14_27(col0,col1,col2) VALUES('2','2','6');
SELECT * from char_test14_27;

--char_test14_28
SELECT * from char_test14_28;
--ok
INSERT INTO char_test14_28 VALUES('1', '1', '1');
SELECT * from char_test14_28;
--PKEY col0 col1 null error 
INSERT INTO char_test14_28(col2) VALUES('3');
SELECT * from char_test14_28;
--PKEY col0 null error 
INSERT INTO char_test14_28(col1,col2) VALUES('3','3');
SELECT * from char_test14_28;
--PKEY col1 null error 
INSERT INTO char_test14_28(col0,col2) VALUES('3','3');
SELECT * from char_test14_28;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_28(col0,col1) VALUES('1','1');
SELECT * from char_test14_28;
--not null constraint col0 error
INSERT INTO char_test14_28(col1,col2) VALUES('5','5');
SELECT * from char_test14_28;
--not null constraint col1 error
INSERT INTO char_test14_28(col0,col2) VALUES('5','5');
SELECT * from char_test14_28;
--ok
INSERT INTO char_test14_28(col0,col1) VALUES('2','2');
SELECT * from char_test14_28;

--char_test14_29
SELECT * from char_test14_29;
--ok
INSERT INTO char_test14_29 VALUES('1', '1', '1');
SELECT * from char_test14_29;
--PKEY col0 col1 null error 
INSERT INTO char_test14_29(col2) VALUES('3');
SELECT * from char_test14_29;
--PKEY col0 null error 
INSERT INTO char_test14_29(col1,col2) VALUES('3','3');
SELECT * from char_test14_29;
--PKEY col1 null error 
INSERT INTO char_test14_29(col0,col2) VALUES('3','3');
SELECT * from char_test14_29;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_29(col0,col1,col2) VALUES('1','1','3');
SELECT * from char_test14_29;
--not null constraint col1 error
INSERT INTO char_test14_29(col0,col2) VALUES('5','5');
SELECT * from char_test14_29;
--not null constraint col2 error
INSERT INTO char_test14_29(col0,col1) VALUES('5','5');
SELECT * from char_test14_29;
--ok
INSERT INTO char_test14_29(col0,col1,col2) VALUES('2','2','6');
SELECT * from char_test14_29;

--char_test14_30
SELECT * from char_test14_30;
--ok
INSERT INTO char_test14_30 VALUES('1', '1', '1');
SELECT * from char_test14_30;
--PKEY col0 col1 null error 
INSERT INTO char_test14_30(col2) VALUES('3');
SELECT * from char_test14_30;
--PKEY col0 null error 
INSERT INTO char_test14_30(col1,col2) VALUES('3','3');
SELECT * from char_test14_30;
--PKEY col1 null error 
INSERT INTO char_test14_30(col0,col2) VALUES('3','3');
SELECT * from char_test14_30;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_30(col0,col1,col2) VALUES('1','1','3');
SELECT * from char_test14_30;
--not null constraint col0 error
INSERT INTO char_test14_30(col1,col2) VALUES('5','5');
SELECT * from char_test14_30;
--not null constraint col2 error
INSERT INTO char_test14_30(col0,col1) VALUES('5','5');
SELECT * from char_test14_30;
--ok
INSERT INTO char_test14_30(col0,col1,col2) VALUES('2','2','6');
SELECT * from char_test14_30;

--char_test14_31
SELECT * from char_test14_31;
--ok
INSERT INTO char_test14_31 VALUES('1', '1', '1');
SELECT * from char_test14_31;
--PKEY col0 col1 null error 
INSERT INTO char_test14_31(col2) VALUES('3');
SELECT * from char_test14_31;
--PKEY col0 null error 
INSERT INTO char_test14_31(col1,col2) VALUES('3','3');
SELECT * from char_test14_31;
--PKEY col1 null error 
INSERT INTO char_test14_31(col0,col2) VALUES('3','3');
SELECT * from char_test14_31;
--PKEY col0 col1 not unique error
INSERT INTO char_test14_31(col0,col1,col2) VALUES('1','1','3');
SELECT * from char_test14_31;
--not null constraint col0 error
INSERT INTO char_test14_31(col1,col2) VALUES('5','5');
SELECT * from char_test14_31;
--not null constraint col1 error
INSERT INTO char_test14_31(col0,col2) VALUES('5','5');
SELECT * from char_test14_31;
--not null constraint col2 error
INSERT INTO char_test14_31(col0,col1) VALUES('5','5');
SELECT * from char_test14_31;
--ok
INSERT INTO char_test14_31(col0,col1,col2) VALUES('2','2','6');
SELECT * from char_test14_31;

--char_test14_32
SELECT * from char_test14_32;
--ok
INSERT INTO char_test14_32 VALUES('1', '1', '1');
SELECT * from char_test14_32;
--PKEY col1 col2 null error 
INSERT INTO char_test14_32(col0) VALUES('3');
SELECT * from char_test14_32;
--PKEY col1 null error 
INSERT INTO char_test14_32(col0,col2) VALUES('3','3');
SELECT * from char_test14_32;
--PKEY col2 null error 
INSERT INTO char_test14_32(col0,col1) VALUES('3','3');
SELECT * from char_test14_32;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_32(col1,col2) VALUES('1','1');
SELECT * from char_test14_32;
--ok
INSERT INTO char_test14_32(col1,col2) VALUES('2','2');
SELECT * from char_test14_32;

--char_test14_33
SELECT * from char_test14_33;
--ok
INSERT INTO char_test14_33 VALUES('1', '1', '1');
SELECT * from char_test14_33;
--PKEY col1 col2 null error 
INSERT INTO char_test14_33(col0) VALUES('3');
SELECT * from char_test14_33;
--PKEY col1 null error 
INSERT INTO char_test14_33(col0,col2) VALUES('3','3');
SELECT * from char_test14_33;
--PKEY col2 null error 
INSERT INTO char_test14_33(col0,col1) VALUES('3','3');
SELECT * from char_test14_33;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_33(col0,col1,col2) VALUES('3','1','1');
SELECT * from char_test14_33;
--not null constraint col0 error
INSERT INTO char_test14_33(col1,col2) VALUES('5','5');
SELECT * from char_test14_33;
--ok
INSERT INTO char_test14_33(col0,col1,col2) VALUES('6','2','2');
SELECT * from char_test14_33;

--char_test14_34
SELECT * from char_test14_34;
--ok
INSERT INTO char_test14_34 VALUES('1', '1', '1');
SELECT * from char_test14_34;
--PKEY col1 col2 null error 
INSERT INTO char_test14_34(col0) VALUES('3');
SELECT * from char_test14_34;
--PKEY col1 null error 
INSERT INTO char_test14_34(col0,col2) VALUES('3','3');
SELECT * from char_test14_34;
--PKEY col2 null error 
INSERT INTO char_test14_34(col0,col1) VALUES('3','3');
SELECT * from char_test14_34;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_34(col1,col2) VALUES('1','1');
SELECT * from char_test14_34;
--not null constraint col1 error
INSERT INTO char_test14_34(col0,col2) VALUES('5','5');
SELECT * from char_test14_34;
--ok
INSERT INTO char_test14_34(col1,col2) VALUES('2','2');
SELECT * from char_test14_34;

--char_test14_35
SELECT * from char_test14_35;
--ok
INSERT INTO char_test14_35 VALUES('1', '1', '1');
SELECT * from char_test14_35;
--PKEY col1 col2 null error 
INSERT INTO char_test14_35(col0) VALUES('3');
SELECT * from char_test14_35;
--PKEY col1 null error 
INSERT INTO char_test14_35(col0,col2) VALUES('3','3');
SELECT * from char_test14_35;
--PKEY col2 null error 
INSERT INTO char_test14_35(col0,col1) VALUES('3','3');
SELECT * from char_test14_35;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_35(col1,col2) VALUES('1','1');
SELECT * from char_test14_35;
--not null constraint col2 error
INSERT INTO char_test14_35(col0,col1) VALUES('5','5');
SELECT * from char_test14_35;
--ok
INSERT INTO char_test14_35(col1,col2) VALUES('2','2');
SELECT * from char_test14_35;

--char_test14_36
SELECT * from char_test14_36;
--ok
INSERT INTO char_test14_36 VALUES('1', '1', '1');
SELECT * from char_test14_36;
--PKEY col1 col2 null error 
INSERT INTO char_test14_36(col0) VALUES('3');
SELECT * from char_test14_36;
--PKEY col1 null error 
INSERT INTO char_test14_36(col0,col2) VALUES('3','3');
SELECT * from char_test14_36;
--PKEY col2 null error 
INSERT INTO char_test14_36(col0,col1) VALUES('3','3');
SELECT * from char_test14_36;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_36(col0,col1,col2) VALUES('3','1','1');
SELECT * from char_test14_36;
--not null constraint col0 error
INSERT INTO char_test14_36(col1,col2) VALUES('5','5');
SELECT * from char_test14_36;
--not null constraint col1 error
INSERT INTO char_test14_36(col0,col2) VALUES('5','5');
SELECT * from char_test14_36;
--ok
INSERT INTO char_test14_36(col0,col1,col2) VALUES('6','2','2');
SELECT * from char_test14_36;

--char_test14_37
SELECT * from char_test14_37;
--ok
INSERT INTO char_test14_37 VALUES('1', '1', '1');
SELECT * from char_test14_37;
--PKEY col1 col2 null error 
INSERT INTO char_test14_37(col0) VALUES('3');
SELECT * from char_test14_37;
--PKEY col1 null error 
INSERT INTO char_test14_37(col0,col2) VALUES('3','3');
SELECT * from char_test14_37;
--PKEY col2 null error 
INSERT INTO char_test14_37(col0,col1) VALUES('3','3');
SELECT * from char_test14_37;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_37(col1,col2) VALUES('1','1');
SELECT * from char_test14_37;
--not null constraint col1 error
INSERT INTO char_test14_37(col0,col2) VALUES('5','5');
SELECT * from char_test14_37;
--not null constraint col2 error
INSERT INTO char_test14_37(col0,col1) VALUES('5','5');
SELECT * from char_test14_37;
--ok
INSERT INTO char_test14_37(col1,col2) VALUES('2','2');
SELECT * from char_test14_37;

--char_test14_38
SELECT * from char_test14_38;
--ok
INSERT INTO char_test14_38 VALUES('1', '1', '1');
SELECT * from char_test14_38;
--PKEY col1 col2 null error 
INSERT INTO char_test14_38(col0) VALUES('3');
SELECT * from char_test14_38;
--PKEY col1 null error 
INSERT INTO char_test14_38(col0,col2) VALUES('3','3');
SELECT * from char_test14_38;
--PKEY col2 null error 
INSERT INTO char_test14_38(col0,col1) VALUES('3','3');
SELECT * from char_test14_38;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_38(col0,col1,col2) VALUES('3','1','1');
SELECT * from char_test14_38;
--not null constraint col0 error
INSERT INTO char_test14_38(col1,col2) VALUES('5','5');
SELECT * from char_test14_38;
--not null constraint col2 error
INSERT INTO char_test14_38(col0,col1) VALUES('5','5');
SELECT * from char_test14_38;
--ok
INSERT INTO char_test14_38(col0,col1,col2) VALUES('6','2','2');
SELECT * from char_test14_38;

--char_test14_39
SELECT * from char_test14_39;
--ok
INSERT INTO char_test14_39 VALUES('1', '1', '1');
SELECT * from char_test14_39;
--PKEY col1 col2 null error 
INSERT INTO char_test14_39(col0) VALUES('3');
SELECT * from char_test14_39;
--PKEY col1 null error 
INSERT INTO char_test14_39(col0,col2) VALUES('3','3');
SELECT * from char_test14_39;
--PKEY col2 null error 
INSERT INTO char_test14_39(col0,col1) VALUES('3','3');
SELECT * from char_test14_39;
--PKEY col1 col2 not unique error
INSERT INTO char_test14_39(col0,col1,col2) VALUES('3','1','1');
SELECT * from char_test14_39;
--not null constraint col0 error
INSERT INTO char_test14_39(col1,col2) VALUES('5','5');
SELECT * from char_test14_39;
--not null constraint col1 error
INSERT INTO char_test14_39(col0,col2) VALUES('5','5');
SELECT * from char_test14_39;
--not null constraint col2 error
INSERT INTO char_test14_39(col0,col1) VALUES('5','5');
SELECT * from char_test14_39;
--ok
INSERT INTO char_test14_39(col0,col1,col2) VALUES('6','2','2');
SELECT * from char_test14_39;

--char_test14_40
SELECT * from char_test14_40;
--ok
INSERT INTO char_test14_40 VALUES('1', '1', '1');
SELECT * from char_test14_40;
--PKEY col0 col2 null error 
INSERT INTO char_test14_40(col1) VALUES('3');
SELECT * from char_test14_40;
--PKEY col0 null error 
INSERT INTO char_test14_40(col1,col2) VALUES('3','3');
SELECT * from char_test14_40;
--PKEY col2 null error 
INSERT INTO char_test14_40(col0,col1) VALUES('3','3');
SELECT * from char_test14_40;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_40(col0,col2) VALUES('1','1');
SELECT * from char_test14_40;
--ok
INSERT INTO char_test14_40(col0,col2) VALUES('2','2');
SELECT * from char_test14_40;

--char_test14_41
SELECT * from char_test14_41;
--ok
INSERT INTO char_test14_41 VALUES('1', '1', '1');
SELECT * from char_test14_41;
--PKEY col0 col2 null error 
INSERT INTO char_test14_41(col1) VALUES('3');
SELECT * from char_test14_41;
--PKEY col0 null error 
INSERT INTO char_test14_41(col1,col2) VALUES('3','3');
SELECT * from char_test14_41;
--PKEY col2 null error 
INSERT INTO char_test14_41(col0,col1) VALUES('3','3');
SELECT * from char_test14_41;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_41(col0,col2) VALUES('1','1');
SELECT * from char_test14_41;
--not null constraint col0 error
INSERT INTO char_test14_41(col1,col2) VALUES('5','5');
SELECT * from char_test14_41;
--ok
INSERT INTO char_test14_41(col0,col2) VALUES('2','2');
SELECT * from char_test14_41;

--char_test14_42
SELECT * from char_test14_42;
--ok
INSERT INTO char_test14_42 VALUES('1', '1', '1');
SELECT * from char_test14_42;
--PKEY col0 col2 null error 
INSERT INTO char_test14_42(col1) VALUES('3');
SELECT * from char_test14_42;
--PKEY col0 null error 
INSERT INTO char_test14_42(col1,col2) VALUES('3','3');
SELECT * from char_test14_42;
--PKEY col2 null error 
INSERT INTO char_test14_42(col0,col1) VALUES('3','3');
SELECT * from char_test14_42;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_42(col0,col1,col2) VALUES('1','3','1');
SELECT * from char_test14_42;
--not null constraint col1 error
INSERT INTO char_test14_42(col0,col2) VALUES('5','5');
SELECT * from char_test14_42;
--ok
INSERT INTO char_test14_42(col0,col1,col2) VALUES('2','6','2');
SELECT * from char_test14_42;

--char_test14_43
SELECT * from char_test14_43;
--ok
INSERT INTO char_test14_43 VALUES('1', '1', '1');
SELECT * from char_test14_43;
--PKEY col0 col2 null error 
INSERT INTO char_test14_43(col1) VALUES('3');
SELECT * from char_test14_43;
--PKEY col0 null error 
INSERT INTO char_test14_43(col1,col2) VALUES('3','3');
SELECT * from char_test14_43;
--PKEY col2 null error 
INSERT INTO char_test14_43(col0,col1) VALUES('3','3');
SELECT * from char_test14_43;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_43(col0,col2) VALUES('1','1');
SELECT * from char_test14_43;
--not null constraint col2 error
INSERT INTO char_test14_43(col0,col1) VALUES('5','5');
SELECT * from char_test14_43;
--ok
INSERT INTO char_test14_43(col0,col2) VALUES('2','2');
SELECT * from char_test14_43;

--char_test14_44
SELECT * from char_test14_44;
--ok
INSERT INTO char_test14_44 VALUES('1', '1', '1');
SELECT * from char_test14_44;
--PKEY col0 col2 null error 
INSERT INTO char_test14_44(col1) VALUES('3');
SELECT * from char_test14_44;
--PKEY col0 null error 
INSERT INTO char_test14_44(col1,col2) VALUES('3','3');
SELECT * from char_test14_44;
--PKEY col2 null error 
INSERT INTO char_test14_44(col0,col1) VALUES('3','3');
SELECT * from char_test14_44;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_44(col0,col1,col2) VALUES('1','3','1');
SELECT * from char_test14_44;
--not null constraint col0 error
INSERT INTO char_test14_44(col1,col2) VALUES('5','5');
SELECT * from char_test14_44;
--not null constraint col1 error
INSERT INTO char_test14_44(col0,col2) VALUES('5','5');
SELECT * from char_test14_44;
--ok
INSERT INTO char_test14_44(col0,col1,col2) VALUES('2','6','2');
SELECT * from char_test14_44;

--char_test14_45
SELECT * from char_test14_45;
--ok
INSERT INTO char_test14_45 VALUES('1', '1', '1');
SELECT * from char_test14_45;
--PKEY col0 col2 null error 
INSERT INTO char_test14_45(col1) VALUES('3');
SELECT * from char_test14_45;
--PKEY col0 null error 
INSERT INTO char_test14_45(col1,col2) VALUES('3','3');
SELECT * from char_test14_45;
--PKEY col2 null error 
INSERT INTO char_test14_45(col0,col1) VALUES('3','3');
SELECT * from char_test14_45;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_45(col0,col1,col2) VALUES('1','3','1');
SELECT * from char_test14_45;
--not null constraint col1 error
INSERT INTO char_test14_45(col0,col2) VALUES('5','5');
SELECT * from char_test14_45;
--not null constraint col2 error
INSERT INTO char_test14_45(col0,col1) VALUES('5','5');
SELECT * from char_test14_45;
--ok
INSERT INTO char_test14_45(col0,col1,col2) VALUES('2','6','2');
SELECT * from char_test14_45;

--char_test14_46
SELECT * from char_test14_46;
--ok
INSERT INTO char_test14_46 VALUES('1', '1', '1');
SELECT * from char_test14_46;
--PKEY col0 col2 null error 
INSERT INTO char_test14_46(col1) VALUES('3');
SELECT * from char_test14_46;
--PKEY col0 null error 
INSERT INTO char_test14_46(col1,col2) VALUES('3','3');
SELECT * from char_test14_46;
--PKEY col2 null error 
INSERT INTO char_test14_46(col0,col1) VALUES('3','3');
SELECT * from char_test14_46;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_46(col0,col2) VALUES('1','1');
SELECT * from char_test14_46;
--not null constraint col0 error
INSERT INTO char_test14_46(col1,col2) VALUES('5','5');
SELECT * from char_test14_46;
--not null constraint col2 error
INSERT INTO char_test14_46(col0,col1) VALUES('5','5');
SELECT * from char_test14_46;
--ok
INSERT INTO char_test14_46(col0,col2) VALUES('2','2');
SELECT * from char_test14_46;

--char_test14_47
SELECT * from char_test14_47;
--ok
INSERT INTO char_test14_47 VALUES('1', '1', '1');
SELECT * from char_test14_47;
--PKEY col0 col2 null error 
INSERT INTO char_test14_47(col1) VALUES('3');
SELECT * from char_test14_47;
--PKEY col0 null error 
INSERT INTO char_test14_47(col1,col2) VALUES('3','3');
SELECT * from char_test14_47;
--PKEY col2 null error 
INSERT INTO char_test14_47(col0,col1) VALUES('3','3');
SELECT * from char_test14_47;
--PKEY col0 col2 not unique error
INSERT INTO char_test14_47(col0,col1,col2) VALUES('1','3','1');
SELECT * from char_test14_47;
--not null constraint col0 error
INSERT INTO char_test14_47(col1,col2) VALUES('5','5');
SELECT * from char_test14_47;
--not null constraint col1 error
INSERT INTO char_test14_47(col0,col2) VALUES('5','5');
SELECT * from char_test14_47;
--not null constraint col2 error
INSERT INTO char_test14_47(col0,col1) VALUES('5','5');
SELECT * from char_test14_47;
--ok
INSERT INTO char_test14_47(col0,col1,col2) VALUES('2','6','2');
SELECT * from char_test14_47;

--char_test14_48
SELECT * from char_test14_48;
--ok
INSERT INTO char_test14_48 VALUES('1', '1', '1');
SELECT * from char_test14_48;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_48() VALUES();
SELECT * from char_test14_48;
--PKEY col0 null error 
INSERT INTO char_test14_48(col1,col2) VALUES('3','3');
SELECT * from char_test14_48;
--PKEY col1 null error 
INSERT INTO char_test14_48(col0,col2) VALUES('3','3');
SELECT * from char_test14_48;
--PKEY col2 null error 
INSERT INTO char_test14_48(col0,col1) VALUES('3','3');
SELECT * from char_test14_48;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_48(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_48;
--ok
INSERT INTO char_test14_48(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_48;

--char_test14_49
SELECT * from char_test14_49;
--ok
INSERT INTO char_test14_49 VALUES('1', '1', '1');
SELECT * from char_test14_49;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_49() VALUES();
SELECT * from char_test14_49;
--PKEY col0 null error 
INSERT INTO char_test14_49(col1,col2) VALUES('3','3');
SELECT * from char_test14_49;
--PKEY col1 null error 
INSERT INTO char_test14_49(col0,col2) VALUES('3','3');
SELECT * from char_test14_49;
--PKEY col2 null error 
INSERT INTO char_test14_49(col0,col1) VALUES('3','3');
SELECT * from char_test14_49;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_49(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_49;
--not null constraint col0 error
INSERT INTO char_test14_49(col1,col2) VALUES('5','5');
SELECT * from char_test14_49;
--ok
INSERT INTO char_test14_49(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_49;

--char_test14_50
SELECT * from char_test14_50;
--ok
INSERT INTO char_test14_50 VALUES('1', '1', '1');
SELECT * from char_test14_50;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_50() VALUES();
SELECT * from char_test14_50;
--PKEY col0 null error 
INSERT INTO char_test14_50(col1,col2) VALUES('3','3');
SELECT * from char_test14_50;
--PKEY col1 null error 
INSERT INTO char_test14_50(col0,col2) VALUES('3','3');
SELECT * from char_test14_50;
--PKEY col2 null error 
INSERT INTO char_test14_50(col0,col1) VALUES('3','3');
SELECT * from char_test14_50;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_50(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_50;
--not null constraint col1 error
INSERT INTO char_test14_50(col0,col2) VALUES('5','5');
SELECT * from char_test14_50;
--ok
INSERT INTO char_test14_50(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_50;

--char_test14_51
SELECT * from char_test14_51;
--ok
INSERT INTO char_test14_51 VALUES('1', '1', '1');
SELECT * from char_test14_51;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_51() VALUES();
SELECT * from char_test14_51;
--PKEY col0 null error 
INSERT INTO char_test14_51(col1,col2) VALUES('3','3');
SELECT * from char_test14_51;
--PKEY col1 null error 
INSERT INTO char_test14_51(col0,col2) VALUES('3','3');
SELECT * from char_test14_51;
--PKEY col2 null error 
INSERT INTO char_test14_51(col0,col1) VALUES('3','3');
SELECT * from char_test14_51;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_51(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_51;
--not null constraint col2 error
INSERT INTO char_test14_51(col0,col1) VALUES('5','5');
SELECT * from char_test14_51;
--ok
INSERT INTO char_test14_51(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_51;

--char_test14_52
SELECT * from char_test14_52;
--ok
INSERT INTO char_test14_52 VALUES('1', '1', '1');
SELECT * from char_test14_52;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_52() VALUES();
SELECT * from char_test14_52;
--PKEY col0 null error 
INSERT INTO char_test14_52(col1,col2) VALUES('3','3');
SELECT * from char_test14_52;
--PKEY col1 null error 
INSERT INTO char_test14_52(col0,col2) VALUES('3','3');
SELECT * from char_test14_52;
--PKEY col2 null error 
INSERT INTO char_test14_52(col0,col1) VALUES('3','3');
SELECT * from char_test14_52;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_52(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_52;
--not null constraint col0 error
INSERT INTO char_test14_52(col1,col2) VALUES('5','5');
SELECT * from char_test14_52;
--not null constraint col1 error
INSERT INTO char_test14_52(col0,col2) VALUES('5','5');
SELECT * from char_test14_52;
--ok
INSERT INTO char_test14_52(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_52;

--char_test14_53
SELECT * from char_test14_53;
--ok
INSERT INTO char_test14_53 VALUES('1', '1', '1');
SELECT * from char_test14_53;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_53() VALUES();
SELECT * from char_test14_53;
--PKEY col0 null error 
INSERT INTO char_test14_53(col1,col2) VALUES('3','3');
SELECT * from char_test14_53;
--PKEY col1 null error 
INSERT INTO char_test14_53(col0,col2) VALUES('3','3');
SELECT * from char_test14_53;
--PKEY col2 null error 
INSERT INTO char_test14_53(col0,col1) VALUES('3','3');
SELECT * from char_test14_53;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_53(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_53;
--not null constraint col1 error
INSERT INTO char_test14_53(col0,col2) VALUES('5','5');
SELECT * from char_test14_53;
--not null constraint col2 error
INSERT INTO char_test14_53(col0,col1) VALUES('5','5');
SELECT * from char_test14_53;
--ok
INSERT INTO char_test14_53(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_53;

--char_test14_54
SELECT * from char_test14_54;
--ok
INSERT INTO char_test14_54 VALUES('1', '1', '1');
SELECT * from char_test14_54;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_54() VALUES();
SELECT * from char_test14_54;
--PKEY col0 null error 
INSERT INTO char_test14_54(col1,col2) VALUES('3','3');
SELECT * from char_test14_54;
--PKEY col1 null error 
INSERT INTO char_test14_54(col0,col2) VALUES('3','3');
SELECT * from char_test14_54;
--PKEY col2 null error 
INSERT INTO char_test14_54(col0,col1) VALUES('3','3');
SELECT * from char_test14_54;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_54(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_54;
--not null constraint col0 error
INSERT INTO char_test14_54(col1,col2) VALUES('5','5');
SELECT * from char_test14_54;
--not null constraint col2 error
INSERT INTO char_test14_54(col0,col1) VALUES('5','5');
SELECT * from char_test14_54;
--ok
INSERT INTO char_test14_54(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_54;

--char_test14_55
SELECT * from char_test14_55;
--ok
INSERT INTO char_test14_55 VALUES('1', '1', '1');
SELECT * from char_test14_55;
--PKEY col0 col1 col2 null error 
INSERT INTO char_test14_55() VALUES();
SELECT * from char_test14_55;
--PKEY col0 null error 
INSERT INTO char_test14_55(col1,col2) VALUES('3','3');
SELECT * from char_test14_55;
--PKEY col1 null error 
INSERT INTO char_test14_55(col0,col2) VALUES('3','3');
SELECT * from char_test14_55;
--PKEY col2 null error 
INSERT INTO char_test14_55(col0,col1) VALUES('3','3');
SELECT * from char_test14_55;
--PKEY col0 col1 col2 not unique error
INSERT INTO char_test14_55(col0,col1,col2) VALUES('1','1','1');
SELECT * from char_test14_55;
--not null constraint col0 error
INSERT INTO char_test14_55(col1,col2) VALUES('5','5');
SELECT * from char_test14_55;
--not null constraint col1 error
INSERT INTO char_test14_55(col0,col2) VALUES('5','5');
SELECT * from char_test14_55;
--not null constraint col2 error
INSERT INTO char_test14_55(col0,col1) VALUES('5','5');
SELECT * from char_test14_55;
--ok
INSERT INTO char_test14_55(col0,col1,col2) VALUES('2','2','2');
SELECT * from char_test14_55;

CREATE TABLE varchar_test14_0 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_1 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_2 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_3 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_4 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_5 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_6 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_7 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0)
) tablespace tsurugi;
CREATE TABLE varchar_test14_8 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_9 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_10 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_11 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_12 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_13 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_14 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_15 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_16 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_17 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_18 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_19 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_20 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_21 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_22 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_23 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_24 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_25 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_26 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_27 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_28 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_29 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_30 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_31 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1)
) tablespace tsurugi;
CREATE TABLE varchar_test14_32 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_33 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_34 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_35 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_36 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_37 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_38 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_39 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_40 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_41 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_42 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_43 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_44 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_45 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_46 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_47 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_48 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_49 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_50 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_51 (
col0 varchar(10) ,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_52 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) ,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_53 (
col0 varchar(10) ,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_54 (
col0 varchar(10) NOT NULL,
col1 varchar(10) ,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE TABLE varchar_test14_55 (
col0 varchar(10) NOT NULL,
col1 varchar(10) NOT NULL,
col2 varchar(10) NOT NULL,
PRIMARY KEY(col0,col1,col2)
) tablespace tsurugi;
CREATE FOREIGN TABLE varchar_test14_0 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_1 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_2 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_3 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_4 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_5 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_6 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_7 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_8 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_9 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_10 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_11 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_12 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_13 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_14 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_15 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_16 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_17 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_18 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_19 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_20 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_21 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_22 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_23 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_24 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_25 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_26 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_27 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_28 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_29 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_30 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_31 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_32 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_33 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_34 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_35 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_36 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_37 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_38 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_39 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_40 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_41 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_42 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_43 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_44 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_45 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_46 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_47 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_48 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_49 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_50 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_51 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_52 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_53 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_54 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
CREATE FOREIGN TABLE varchar_test14_55 (
col0 varchar(10) ,col1 varchar(10) ,col2 varchar(10) 
) SERVER ogawayama;
--varchar_test14_0
SELECT * from varchar_test14_0;
--ok
INSERT INTO varchar_test14_0 VALUES('1', '1', '1');
SELECT * from varchar_test14_0;
--PKEY col0 null error 
INSERT INTO varchar_test14_0(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_0;
--PKEY col0 null error 
INSERT INTO varchar_test14_0(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_0;
--PKEY col0 not unique error
INSERT INTO varchar_test14_0(col0) VALUES('1');
SELECT * from varchar_test14_0;
--ok
INSERT INTO varchar_test14_0(col0) VALUES('2');
SELECT * from varchar_test14_0;

--varchar_test14_1
SELECT * from varchar_test14_1;
--ok
INSERT INTO varchar_test14_1 VALUES('1', '1', '1');
SELECT * from varchar_test14_1;
--PKEY col0 null error 
INSERT INTO varchar_test14_1(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_1;
--PKEY col0 null error 
INSERT INTO varchar_test14_1(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_1;
--PKEY col0 not unique error
INSERT INTO varchar_test14_1(col0) VALUES('1');
SELECT * from varchar_test14_1;
--not null constraint col0 error
INSERT INTO varchar_test14_1(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_1;
--ok
INSERT INTO varchar_test14_1(col0) VALUES('2');
SELECT * from varchar_test14_1;

--varchar_test14_2
SELECT * from varchar_test14_2;
--ok
INSERT INTO varchar_test14_2 VALUES('1', '1', '1');
SELECT * from varchar_test14_2;
--PKEY col0 null error 
INSERT INTO varchar_test14_2(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_2;
--PKEY col0 null error 
INSERT INTO varchar_test14_2(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_2;
--PKEY col0 not unique error
INSERT INTO varchar_test14_2(col0,col1) VALUES('1','3');
SELECT * from varchar_test14_2;
--not null constraint col1 error
INSERT INTO varchar_test14_2(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_2;
--ok
INSERT INTO varchar_test14_2(col0,col1) VALUES('2','6');
SELECT * from varchar_test14_2;

--varchar_test14_3
SELECT * from varchar_test14_3;
--ok
INSERT INTO varchar_test14_3 VALUES('1', '1', '1');
SELECT * from varchar_test14_3;
--PKEY col0 null error 
INSERT INTO varchar_test14_3(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_3;
--PKEY col0 null error 
INSERT INTO varchar_test14_3(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_3;
--PKEY col0 not unique error
INSERT INTO varchar_test14_3(col0,col2) VALUES('1','3');
SELECT * from varchar_test14_3;
--not null constraint col2 error
INSERT INTO varchar_test14_3(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_3;
--ok
INSERT INTO varchar_test14_3(col0,col2) VALUES('2','6');
SELECT * from varchar_test14_3;

--varchar_test14_4
SELECT * from varchar_test14_4;
--ok
INSERT INTO varchar_test14_4 VALUES('1', '1', '1');
SELECT * from varchar_test14_4;
--PKEY col0 null error 
INSERT INTO varchar_test14_4(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_4;
--PKEY col0 null error 
INSERT INTO varchar_test14_4(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_4;
--PKEY col0 not unique error
INSERT INTO varchar_test14_4(col0,col1) VALUES('1','3');
SELECT * from varchar_test14_4;
--not null constraint col0 error
INSERT INTO varchar_test14_4(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_4;
--not null constraint col1 error
INSERT INTO varchar_test14_4(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_4;
--ok
INSERT INTO varchar_test14_4(col0,col1) VALUES('2','6');
SELECT * from varchar_test14_4;

--varchar_test14_5
SELECT * from varchar_test14_5;
--ok
INSERT INTO varchar_test14_5 VALUES('1', '1', '1');
SELECT * from varchar_test14_5;
--PKEY col0 null error 
INSERT INTO varchar_test14_5(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_5;
--PKEY col0 null error 
INSERT INTO varchar_test14_5(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_5;
--PKEY col0 not unique error
INSERT INTO varchar_test14_5(col0,col1,col2) VALUES('1','3','3');
SELECT * from varchar_test14_5;
--not null constraint col1 error
INSERT INTO varchar_test14_5(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_5;
--not null constraint col2 error
INSERT INTO varchar_test14_5(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_5;
--ok
INSERT INTO varchar_test14_5(col0,col1,col2) VALUES('2','6','6');
SELECT * from varchar_test14_5;

--varchar_test14_6
SELECT * from varchar_test14_6;
--ok
INSERT INTO varchar_test14_6 VALUES('1', '1', '1');
SELECT * from varchar_test14_6;
--PKEY col0 null error 
INSERT INTO varchar_test14_6(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_6;
--PKEY col0 null error 
INSERT INTO varchar_test14_6(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_6;
--PKEY col0 not unique error
INSERT INTO varchar_test14_6(col0,col2) VALUES('1','3');
SELECT * from varchar_test14_6;
--not null constraint col0 error
INSERT INTO varchar_test14_6(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_6;
--not null constraint col2 error
INSERT INTO varchar_test14_6(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_6;
--ok
INSERT INTO varchar_test14_6(col0,col2) VALUES('2','6');
SELECT * from varchar_test14_6;

--varchar_test14_7
SELECT * from varchar_test14_7;
--ok
INSERT INTO varchar_test14_7 VALUES('1', '1', '1');
SELECT * from varchar_test14_7;
--PKEY col0 null error 
INSERT INTO varchar_test14_7(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_7;
--PKEY col0 null error 
INSERT INTO varchar_test14_7(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_7;
--PKEY col0 not unique error
INSERT INTO varchar_test14_7(col0,col1,col2) VALUES('1','3','3');
SELECT * from varchar_test14_7;
--not null constraint col0 error
INSERT INTO varchar_test14_7(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_7;
--not null constraint col1 error
INSERT INTO varchar_test14_7(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_7;
--not null constraint col2 error
INSERT INTO varchar_test14_7(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_7;
--ok
INSERT INTO varchar_test14_7(col0,col1,col2) VALUES('2','6','6');
SELECT * from varchar_test14_7;

--varchar_test14_8
SELECT * from varchar_test14_8;
--ok
INSERT INTO varchar_test14_8 VALUES('1', '1', '1');
SELECT * from varchar_test14_8;
--PKEY col1 null error 
INSERT INTO varchar_test14_8(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_8;
--PKEY col1 null error 
INSERT INTO varchar_test14_8(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_8;
--PKEY col1 not unique error
INSERT INTO varchar_test14_8(col1) VALUES('1');
SELECT * from varchar_test14_8;
--ok
INSERT INTO varchar_test14_8(col1) VALUES('2');
SELECT * from varchar_test14_8;

--varchar_test14_9
SELECT * from varchar_test14_9;
--ok
INSERT INTO varchar_test14_9 VALUES('1', '1', '1');
SELECT * from varchar_test14_9;
--PKEY col1 null error 
INSERT INTO varchar_test14_9(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_9;
--PKEY col1 null error 
INSERT INTO varchar_test14_9(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_9;
--PKEY col1 not unique error
INSERT INTO varchar_test14_9(col0,col1) VALUES('3','1');
SELECT * from varchar_test14_9;
--not null constraint col0 error
INSERT INTO varchar_test14_9(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_9;
--ok
INSERT INTO varchar_test14_9(col0,col1) VALUES('6','2');
SELECT * from varchar_test14_9;

--varchar_test14_10
SELECT * from varchar_test14_10;
--ok
INSERT INTO varchar_test14_10 VALUES('1', '1', '1');
SELECT * from varchar_test14_10;
--PKEY col1 null error 
INSERT INTO varchar_test14_10(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_10;
--PKEY col1 null error 
INSERT INTO varchar_test14_10(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_10;
--PKEY col1 not unique error
INSERT INTO varchar_test14_10(col1) VALUES('1');
SELECT * from varchar_test14_10;
--not null constraint col1 error
INSERT INTO varchar_test14_10(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_10;
--ok
INSERT INTO varchar_test14_10(col1) VALUES('2');
SELECT * from varchar_test14_10;

--varchar_test14_11
SELECT * from varchar_test14_11;
--ok
INSERT INTO varchar_test14_11 VALUES('1', '1', '1');
SELECT * from varchar_test14_11;
--PKEY col1 null error 
INSERT INTO varchar_test14_11(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_11;
--PKEY col1 null error 
INSERT INTO varchar_test14_11(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_11;
--PKEY col1 not unique error
INSERT INTO varchar_test14_11(col1,col2) VALUES('1','3');
SELECT * from varchar_test14_11;
--not null constraint col2 error
INSERT INTO varchar_test14_11(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_11;
--ok
INSERT INTO varchar_test14_11(col1,col2) VALUES('2','6');
SELECT * from varchar_test14_11;

--varchar_test14_12
SELECT * from varchar_test14_12;
--ok
INSERT INTO varchar_test14_12 VALUES('1', '1', '1');
SELECT * from varchar_test14_12;
--PKEY col1 null error 
INSERT INTO varchar_test14_12(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_12;
--PKEY col1 null error 
INSERT INTO varchar_test14_12(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_12;
--PKEY col1 not unique error
INSERT INTO varchar_test14_12(col0,col1) VALUES('3','1');
SELECT * from varchar_test14_12;
--not null constraint col0 error
INSERT INTO varchar_test14_12(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_12;
--not null constraint col1 error
INSERT INTO varchar_test14_12(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_12;
--ok
INSERT INTO varchar_test14_12(col0,col1) VALUES('6','2');
SELECT * from varchar_test14_12;

--varchar_test14_13
SELECT * from varchar_test14_13;
--ok
INSERT INTO varchar_test14_13 VALUES('1', '1', '1');
SELECT * from varchar_test14_13;
--PKEY col1 null error 
INSERT INTO varchar_test14_13(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_13;
--PKEY col1 null error 
INSERT INTO varchar_test14_13(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_13;
--PKEY col1 not unique error
INSERT INTO varchar_test14_13(col1,col2) VALUES('1','3');
SELECT * from varchar_test14_13;
--not null constraint col1 error
INSERT INTO varchar_test14_13(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_13;
--not null constraint col2 error
INSERT INTO varchar_test14_13(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_13;
--ok
INSERT INTO varchar_test14_13(col1,col2) VALUES('2','6');
SELECT * from varchar_test14_13;

--varchar_test14_14
SELECT * from varchar_test14_14;
--ok
INSERT INTO varchar_test14_14 VALUES('1', '1', '1');
SELECT * from varchar_test14_14;
--PKEY col1 null error 
INSERT INTO varchar_test14_14(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_14;
--PKEY col1 null error 
INSERT INTO varchar_test14_14(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_14;
--PKEY col1 not unique error
INSERT INTO varchar_test14_14(col0,col1,col2) VALUES('3','1','3');
SELECT * from varchar_test14_14;
--not null constraint col0 error
INSERT INTO varchar_test14_14(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_14;
--not null constraint col2 error
INSERT INTO varchar_test14_14(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_14;
--ok
INSERT INTO varchar_test14_14(col0,col1,col2) VALUES('6','2','6');
SELECT * from varchar_test14_14;

--varchar_test14_15
SELECT * from varchar_test14_15;
--ok
INSERT INTO varchar_test14_15 VALUES('1', '1', '1');
SELECT * from varchar_test14_15;
--PKEY col1 null error 
INSERT INTO varchar_test14_15(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_15;
--PKEY col1 null error 
INSERT INTO varchar_test14_15(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_15;
--PKEY col1 not unique error
INSERT INTO varchar_test14_15(col0,col1,col2) VALUES('3','1','3');
SELECT * from varchar_test14_15;
--not null constraint col0 error
INSERT INTO varchar_test14_15(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_15;
--not null constraint col1 error
INSERT INTO varchar_test14_15(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_15;
--not null constraint col2 error
INSERT INTO varchar_test14_15(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_15;
--ok
INSERT INTO varchar_test14_15(col0,col1,col2) VALUES('6','2','6');
SELECT * from varchar_test14_15;

--varchar_test14_16
SELECT * from varchar_test14_16;
--ok
INSERT INTO varchar_test14_16 VALUES('1', '1', '1');
SELECT * from varchar_test14_16;
--PKEY col2 null error 
INSERT INTO varchar_test14_16(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_16;
--PKEY col2 null error 
INSERT INTO varchar_test14_16(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_16;
--PKEY col2 not unique error
INSERT INTO varchar_test14_16(col2) VALUES('1');
SELECT * from varchar_test14_16;
--ok
INSERT INTO varchar_test14_16(col2) VALUES('2');
SELECT * from varchar_test14_16;

--varchar_test14_17
SELECT * from varchar_test14_17;
--ok
INSERT INTO varchar_test14_17 VALUES('1', '1', '1');
SELECT * from varchar_test14_17;
--PKEY col2 null error 
INSERT INTO varchar_test14_17(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_17;
--PKEY col2 null error 
INSERT INTO varchar_test14_17(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_17;
--PKEY col2 not unique error
INSERT INTO varchar_test14_17(col0,col2) VALUES('3','1');
SELECT * from varchar_test14_17;
--not null constraint col0 error
INSERT INTO varchar_test14_17(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_17;
--ok
INSERT INTO varchar_test14_17(col0,col2) VALUES('6','2');
SELECT * from varchar_test14_17;

--varchar_test14_18
SELECT * from varchar_test14_18;
--ok
INSERT INTO varchar_test14_18 VALUES('1', '1', '1');
SELECT * from varchar_test14_18;
--PKEY col2 null error 
INSERT INTO varchar_test14_18(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_18;
--PKEY col2 null error 
INSERT INTO varchar_test14_18(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_18;
--PKEY col2 not unique error
INSERT INTO varchar_test14_18(col1,col2) VALUES('3','1');
SELECT * from varchar_test14_18;
--not null constraint col1 error
INSERT INTO varchar_test14_18(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_18;
--ok
INSERT INTO varchar_test14_18(col1,col2) VALUES('6','2');
SELECT * from varchar_test14_18;

--varchar_test14_19
SELECT * from varchar_test14_19;
--ok
INSERT INTO varchar_test14_19 VALUES('1', '1', '1');
SELECT * from varchar_test14_19;
--PKEY col2 null error 
INSERT INTO varchar_test14_19(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_19;
--PKEY col2 null error 
INSERT INTO varchar_test14_19(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_19;
--PKEY col2 not unique error
INSERT INTO varchar_test14_19(col2) VALUES('1');
SELECT * from varchar_test14_19;
--not null constraint col2 error
INSERT INTO varchar_test14_19(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_19;
--ok
INSERT INTO varchar_test14_19(col2) VALUES('2');
SELECT * from varchar_test14_19;

--varchar_test14_20
SELECT * from varchar_test14_20;
--ok
INSERT INTO varchar_test14_20 VALUES('1', '1', '1');
SELECT * from varchar_test14_20;
--PKEY col2 null error 
INSERT INTO varchar_test14_20(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_20;
--PKEY col2 null error 
INSERT INTO varchar_test14_20(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_20;
--PKEY col2 not unique error
INSERT INTO varchar_test14_20(col0,col1,col2) VALUES('3','3','1');
SELECT * from varchar_test14_20;
--not null constraint col0 error
INSERT INTO varchar_test14_20(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_20;
--not null constraint col1 error
INSERT INTO varchar_test14_20(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_20;
--ok
INSERT INTO varchar_test14_20(col0,col1,col2) VALUES('6','6','2');
SELECT * from varchar_test14_20;

--varchar_test14_21
SELECT * from varchar_test14_21;
--ok
INSERT INTO varchar_test14_21 VALUES('1', '1', '1');
SELECT * from varchar_test14_21;
--PKEY col2 null error 
INSERT INTO varchar_test14_21(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_21;
--PKEY col2 null error 
INSERT INTO varchar_test14_21(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_21;
--PKEY col2 not unique error
INSERT INTO varchar_test14_21(col1,col2) VALUES('3','1');
SELECT * from varchar_test14_21;
--not null constraint col1 error
INSERT INTO varchar_test14_21(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_21;
--not null constraint col2 error
INSERT INTO varchar_test14_21(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_21;
--ok
INSERT INTO varchar_test14_21(col1,col2) VALUES('6','2');
SELECT * from varchar_test14_21;

--varchar_test14_22
SELECT * from varchar_test14_22;
--ok
INSERT INTO varchar_test14_22 VALUES('1', '1', '1');
SELECT * from varchar_test14_22;
--PKEY col2 null error 
INSERT INTO varchar_test14_22(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_22;
--PKEY col2 null error 
INSERT INTO varchar_test14_22(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_22;
--PKEY col2 not unique error
INSERT INTO varchar_test14_22(col0,col2) VALUES('3','1');
SELECT * from varchar_test14_22;
--not null constraint col0 error
INSERT INTO varchar_test14_22(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_22;
--not null constraint col2 error
INSERT INTO varchar_test14_22(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_22;
--ok
INSERT INTO varchar_test14_22(col0,col2) VALUES('6','2');
SELECT * from varchar_test14_22;

--varchar_test14_23
SELECT * from varchar_test14_23;
--ok
INSERT INTO varchar_test14_23 VALUES('1', '1', '1');
SELECT * from varchar_test14_23;
--PKEY col2 null error 
INSERT INTO varchar_test14_23(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_23;
--PKEY col2 null error 
INSERT INTO varchar_test14_23(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_23;
--PKEY col2 not unique error
INSERT INTO varchar_test14_23(col0,col1,col2) VALUES('3','3','1');
SELECT * from varchar_test14_23;
--not null constraint col0 error
INSERT INTO varchar_test14_23(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_23;
--not null constraint col1 error
INSERT INTO varchar_test14_23(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_23;
--not null constraint col2 error
INSERT INTO varchar_test14_23(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_23;
--ok
INSERT INTO varchar_test14_23(col0,col1,col2) VALUES('6','6','2');
SELECT * from varchar_test14_23;

--varchar_test14_24
SELECT * from varchar_test14_24;
--ok
INSERT INTO varchar_test14_24 VALUES('1', '1', '1');
SELECT * from varchar_test14_24;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_24(col2) VALUES('3');
SELECT * from varchar_test14_24;
--PKEY col0 null error 
INSERT INTO varchar_test14_24(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_24;
--PKEY col1 null error 
INSERT INTO varchar_test14_24(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_24;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_24(col0,col1) VALUES('1','1');
SELECT * from varchar_test14_24;
--ok
INSERT INTO varchar_test14_24(col0,col1) VALUES('2','2');
SELECT * from varchar_test14_24;

--varchar_test14_25
SELECT * from varchar_test14_25;
--ok
INSERT INTO varchar_test14_25 VALUES('1', '1', '1');
SELECT * from varchar_test14_25;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_25(col2) VALUES('3');
SELECT * from varchar_test14_25;
--PKEY col0 null error 
INSERT INTO varchar_test14_25(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_25;
--PKEY col1 null error 
INSERT INTO varchar_test14_25(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_25;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_25(col0,col1) VALUES('1','1');
SELECT * from varchar_test14_25;
--not null constraint col0 error
INSERT INTO varchar_test14_25(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_25;
--ok
INSERT INTO varchar_test14_25(col0,col1) VALUES('2','2');
SELECT * from varchar_test14_25;

--varchar_test14_26
SELECT * from varchar_test14_26;
--ok
INSERT INTO varchar_test14_26 VALUES('1', '1', '1');
SELECT * from varchar_test14_26;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_26(col2) VALUES('3');
SELECT * from varchar_test14_26;
--PKEY col0 null error 
INSERT INTO varchar_test14_26(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_26;
--PKEY col1 null error 
INSERT INTO varchar_test14_26(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_26;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_26(col0,col1) VALUES('1','1');
SELECT * from varchar_test14_26;
--not null constraint col1 error
INSERT INTO varchar_test14_26(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_26;
--ok
INSERT INTO varchar_test14_26(col0,col1) VALUES('2','2');
SELECT * from varchar_test14_26;

--varchar_test14_27
SELECT * from varchar_test14_27;
--ok
INSERT INTO varchar_test14_27 VALUES('1', '1', '1');
SELECT * from varchar_test14_27;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_27(col2) VALUES('3');
SELECT * from varchar_test14_27;
--PKEY col0 null error 
INSERT INTO varchar_test14_27(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_27;
--PKEY col1 null error 
INSERT INTO varchar_test14_27(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_27;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_27(col0,col1,col2) VALUES('1','1','3');
SELECT * from varchar_test14_27;
--not null constraint col2 error
INSERT INTO varchar_test14_27(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_27;
--ok
INSERT INTO varchar_test14_27(col0,col1,col2) VALUES('2','2','6');
SELECT * from varchar_test14_27;

--varchar_test14_28
SELECT * from varchar_test14_28;
--ok
INSERT INTO varchar_test14_28 VALUES('1', '1', '1');
SELECT * from varchar_test14_28;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_28(col2) VALUES('3');
SELECT * from varchar_test14_28;
--PKEY col0 null error 
INSERT INTO varchar_test14_28(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_28;
--PKEY col1 null error 
INSERT INTO varchar_test14_28(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_28;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_28(col0,col1) VALUES('1','1');
SELECT * from varchar_test14_28;
--not null constraint col0 error
INSERT INTO varchar_test14_28(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_28;
--not null constraint col1 error
INSERT INTO varchar_test14_28(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_28;
--ok
INSERT INTO varchar_test14_28(col0,col1) VALUES('2','2');
SELECT * from varchar_test14_28;

--varchar_test14_29
SELECT * from varchar_test14_29;
--ok
INSERT INTO varchar_test14_29 VALUES('1', '1', '1');
SELECT * from varchar_test14_29;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_29(col2) VALUES('3');
SELECT * from varchar_test14_29;
--PKEY col0 null error 
INSERT INTO varchar_test14_29(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_29;
--PKEY col1 null error 
INSERT INTO varchar_test14_29(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_29;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_29(col0,col1,col2) VALUES('1','1','3');
SELECT * from varchar_test14_29;
--not null constraint col1 error
INSERT INTO varchar_test14_29(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_29;
--not null constraint col2 error
INSERT INTO varchar_test14_29(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_29;
--ok
INSERT INTO varchar_test14_29(col0,col1,col2) VALUES('2','2','6');
SELECT * from varchar_test14_29;

--varchar_test14_30
SELECT * from varchar_test14_30;
--ok
INSERT INTO varchar_test14_30 VALUES('1', '1', '1');
SELECT * from varchar_test14_30;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_30(col2) VALUES('3');
SELECT * from varchar_test14_30;
--PKEY col0 null error 
INSERT INTO varchar_test14_30(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_30;
--PKEY col1 null error 
INSERT INTO varchar_test14_30(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_30;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_30(col0,col1,col2) VALUES('1','1','3');
SELECT * from varchar_test14_30;
--not null constraint col0 error
INSERT INTO varchar_test14_30(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_30;
--not null constraint col2 error
INSERT INTO varchar_test14_30(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_30;
--ok
INSERT INTO varchar_test14_30(col0,col1,col2) VALUES('2','2','6');
SELECT * from varchar_test14_30;

--varchar_test14_31
SELECT * from varchar_test14_31;
--ok
INSERT INTO varchar_test14_31 VALUES('1', '1', '1');
SELECT * from varchar_test14_31;
--PKEY col0 col1 null error 
INSERT INTO varchar_test14_31(col2) VALUES('3');
SELECT * from varchar_test14_31;
--PKEY col0 null error 
INSERT INTO varchar_test14_31(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_31;
--PKEY col1 null error 
INSERT INTO varchar_test14_31(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_31;
--PKEY col0 col1 not unique error
INSERT INTO varchar_test14_31(col0,col1,col2) VALUES('1','1','3');
SELECT * from varchar_test14_31;
--not null constraint col0 error
INSERT INTO varchar_test14_31(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_31;
--not null constraint col1 error
INSERT INTO varchar_test14_31(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_31;
--not null constraint col2 error
INSERT INTO varchar_test14_31(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_31;
--ok
INSERT INTO varchar_test14_31(col0,col1,col2) VALUES('2','2','6');
SELECT * from varchar_test14_31;

--varchar_test14_32
SELECT * from varchar_test14_32;
--ok
INSERT INTO varchar_test14_32 VALUES('1', '1', '1');
SELECT * from varchar_test14_32;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_32(col0) VALUES('3');
SELECT * from varchar_test14_32;
--PKEY col1 null error 
INSERT INTO varchar_test14_32(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_32;
--PKEY col2 null error 
INSERT INTO varchar_test14_32(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_32;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_32(col1,col2) VALUES('1','1');
SELECT * from varchar_test14_32;
--ok
INSERT INTO varchar_test14_32(col1,col2) VALUES('2','2');
SELECT * from varchar_test14_32;

--varchar_test14_33
SELECT * from varchar_test14_33;
--ok
INSERT INTO varchar_test14_33 VALUES('1', '1', '1');
SELECT * from varchar_test14_33;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_33(col0) VALUES('3');
SELECT * from varchar_test14_33;
--PKEY col1 null error 
INSERT INTO varchar_test14_33(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_33;
--PKEY col2 null error 
INSERT INTO varchar_test14_33(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_33;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_33(col0,col1,col2) VALUES('3','1','1');
SELECT * from varchar_test14_33;
--not null constraint col0 error
INSERT INTO varchar_test14_33(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_33;
--ok
INSERT INTO varchar_test14_33(col0,col1,col2) VALUES('6','2','2');
SELECT * from varchar_test14_33;

--varchar_test14_34
SELECT * from varchar_test14_34;
--ok
INSERT INTO varchar_test14_34 VALUES('1', '1', '1');
SELECT * from varchar_test14_34;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_34(col0) VALUES('3');
SELECT * from varchar_test14_34;
--PKEY col1 null error 
INSERT INTO varchar_test14_34(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_34;
--PKEY col2 null error 
INSERT INTO varchar_test14_34(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_34;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_34(col1,col2) VALUES('1','1');
SELECT * from varchar_test14_34;
--not null constraint col1 error
INSERT INTO varchar_test14_34(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_34;
--ok
INSERT INTO varchar_test14_34(col1,col2) VALUES('2','2');
SELECT * from varchar_test14_34;

--varchar_test14_35
SELECT * from varchar_test14_35;
--ok
INSERT INTO varchar_test14_35 VALUES('1', '1', '1');
SELECT * from varchar_test14_35;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_35(col0) VALUES('3');
SELECT * from varchar_test14_35;
--PKEY col1 null error 
INSERT INTO varchar_test14_35(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_35;
--PKEY col2 null error 
INSERT INTO varchar_test14_35(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_35;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_35(col1,col2) VALUES('1','1');
SELECT * from varchar_test14_35;
--not null constraint col2 error
INSERT INTO varchar_test14_35(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_35;
--ok
INSERT INTO varchar_test14_35(col1,col2) VALUES('2','2');
SELECT * from varchar_test14_35;

--varchar_test14_36
SELECT * from varchar_test14_36;
--ok
INSERT INTO varchar_test14_36 VALUES('1', '1', '1');
SELECT * from varchar_test14_36;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_36(col0) VALUES('3');
SELECT * from varchar_test14_36;
--PKEY col1 null error 
INSERT INTO varchar_test14_36(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_36;
--PKEY col2 null error 
INSERT INTO varchar_test14_36(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_36;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_36(col0,col1,col2) VALUES('3','1','1');
SELECT * from varchar_test14_36;
--not null constraint col0 error
INSERT INTO varchar_test14_36(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_36;
--not null constraint col1 error
INSERT INTO varchar_test14_36(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_36;
--ok
INSERT INTO varchar_test14_36(col0,col1,col2) VALUES('6','2','2');
SELECT * from varchar_test14_36;

--varchar_test14_37
SELECT * from varchar_test14_37;
--ok
INSERT INTO varchar_test14_37 VALUES('1', '1', '1');
SELECT * from varchar_test14_37;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_37(col0) VALUES('3');
SELECT * from varchar_test14_37;
--PKEY col1 null error 
INSERT INTO varchar_test14_37(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_37;
--PKEY col2 null error 
INSERT INTO varchar_test14_37(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_37;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_37(col1,col2) VALUES('1','1');
SELECT * from varchar_test14_37;
--not null constraint col1 error
INSERT INTO varchar_test14_37(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_37;
--not null constraint col2 error
INSERT INTO varchar_test14_37(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_37;
--ok
INSERT INTO varchar_test14_37(col1,col2) VALUES('2','2');
SELECT * from varchar_test14_37;

--varchar_test14_38
SELECT * from varchar_test14_38;
--ok
INSERT INTO varchar_test14_38 VALUES('1', '1', '1');
SELECT * from varchar_test14_38;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_38(col0) VALUES('3');
SELECT * from varchar_test14_38;
--PKEY col1 null error 
INSERT INTO varchar_test14_38(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_38;
--PKEY col2 null error 
INSERT INTO varchar_test14_38(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_38;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_38(col0,col1,col2) VALUES('3','1','1');
SELECT * from varchar_test14_38;
--not null constraint col0 error
INSERT INTO varchar_test14_38(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_38;
--not null constraint col2 error
INSERT INTO varchar_test14_38(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_38;
--ok
INSERT INTO varchar_test14_38(col0,col1,col2) VALUES('6','2','2');
SELECT * from varchar_test14_38;

--varchar_test14_39
SELECT * from varchar_test14_39;
--ok
INSERT INTO varchar_test14_39 VALUES('1', '1', '1');
SELECT * from varchar_test14_39;
--PKEY col1 col2 null error 
INSERT INTO varchar_test14_39(col0) VALUES('3');
SELECT * from varchar_test14_39;
--PKEY col1 null error 
INSERT INTO varchar_test14_39(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_39;
--PKEY col2 null error 
INSERT INTO varchar_test14_39(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_39;
--PKEY col1 col2 not unique error
INSERT INTO varchar_test14_39(col0,col1,col2) VALUES('3','1','1');
SELECT * from varchar_test14_39;
--not null constraint col0 error
INSERT INTO varchar_test14_39(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_39;
--not null constraint col1 error
INSERT INTO varchar_test14_39(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_39;
--not null constraint col2 error
INSERT INTO varchar_test14_39(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_39;
--ok
INSERT INTO varchar_test14_39(col0,col1,col2) VALUES('6','2','2');
SELECT * from varchar_test14_39;

--varchar_test14_40
SELECT * from varchar_test14_40;
--ok
INSERT INTO varchar_test14_40 VALUES('1', '1', '1');
SELECT * from varchar_test14_40;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_40(col1) VALUES('3');
SELECT * from varchar_test14_40;
--PKEY col0 null error 
INSERT INTO varchar_test14_40(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_40;
--PKEY col2 null error 
INSERT INTO varchar_test14_40(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_40;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_40(col0,col2) VALUES('1','1');
SELECT * from varchar_test14_40;
--ok
INSERT INTO varchar_test14_40(col0,col2) VALUES('2','2');
SELECT * from varchar_test14_40;

--varchar_test14_41
SELECT * from varchar_test14_41;
--ok
INSERT INTO varchar_test14_41 VALUES('1', '1', '1');
SELECT * from varchar_test14_41;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_41(col1) VALUES('3');
SELECT * from varchar_test14_41;
--PKEY col0 null error 
INSERT INTO varchar_test14_41(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_41;
--PKEY col2 null error 
INSERT INTO varchar_test14_41(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_41;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_41(col0,col2) VALUES('1','1');
SELECT * from varchar_test14_41;
--not null constraint col0 error
INSERT INTO varchar_test14_41(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_41;
--ok
INSERT INTO varchar_test14_41(col0,col2) VALUES('2','2');
SELECT * from varchar_test14_41;

--varchar_test14_42
SELECT * from varchar_test14_42;
--ok
INSERT INTO varchar_test14_42 VALUES('1', '1', '1');
SELECT * from varchar_test14_42;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_42(col1) VALUES('3');
SELECT * from varchar_test14_42;
--PKEY col0 null error 
INSERT INTO varchar_test14_42(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_42;
--PKEY col2 null error 
INSERT INTO varchar_test14_42(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_42;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_42(col0,col1,col2) VALUES('1','3','1');
SELECT * from varchar_test14_42;
--not null constraint col1 error
INSERT INTO varchar_test14_42(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_42;
--ok
INSERT INTO varchar_test14_42(col0,col1,col2) VALUES('2','6','2');
SELECT * from varchar_test14_42;

--varchar_test14_43
SELECT * from varchar_test14_43;
--ok
INSERT INTO varchar_test14_43 VALUES('1', '1', '1');
SELECT * from varchar_test14_43;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_43(col1) VALUES('3');
SELECT * from varchar_test14_43;
--PKEY col0 null error 
INSERT INTO varchar_test14_43(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_43;
--PKEY col2 null error 
INSERT INTO varchar_test14_43(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_43;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_43(col0,col2) VALUES('1','1');
SELECT * from varchar_test14_43;
--not null constraint col2 error
INSERT INTO varchar_test14_43(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_43;
--ok
INSERT INTO varchar_test14_43(col0,col2) VALUES('2','2');
SELECT * from varchar_test14_43;

--varchar_test14_44
SELECT * from varchar_test14_44;
--ok
INSERT INTO varchar_test14_44 VALUES('1', '1', '1');
SELECT * from varchar_test14_44;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_44(col1) VALUES('3');
SELECT * from varchar_test14_44;
--PKEY col0 null error 
INSERT INTO varchar_test14_44(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_44;
--PKEY col2 null error 
INSERT INTO varchar_test14_44(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_44;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_44(col0,col1,col2) VALUES('1','3','1');
SELECT * from varchar_test14_44;
--not null constraint col0 error
INSERT INTO varchar_test14_44(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_44;
--not null constraint col1 error
INSERT INTO varchar_test14_44(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_44;
--ok
INSERT INTO varchar_test14_44(col0,col1,col2) VALUES('2','6','2');
SELECT * from varchar_test14_44;

--varchar_test14_45
SELECT * from varchar_test14_45;
--ok
INSERT INTO varchar_test14_45 VALUES('1', '1', '1');
SELECT * from varchar_test14_45;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_45(col1) VALUES('3');
SELECT * from varchar_test14_45;
--PKEY col0 null error 
INSERT INTO varchar_test14_45(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_45;
--PKEY col2 null error 
INSERT INTO varchar_test14_45(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_45;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_45(col0,col1,col2) VALUES('1','3','1');
SELECT * from varchar_test14_45;
--not null constraint col1 error
INSERT INTO varchar_test14_45(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_45;
--not null constraint col2 error
INSERT INTO varchar_test14_45(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_45;
--ok
INSERT INTO varchar_test14_45(col0,col1,col2) VALUES('2','6','2');
SELECT * from varchar_test14_45;

--varchar_test14_46
SELECT * from varchar_test14_46;
--ok
INSERT INTO varchar_test14_46 VALUES('1', '1', '1');
SELECT * from varchar_test14_46;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_46(col1) VALUES('3');
SELECT * from varchar_test14_46;
--PKEY col0 null error 
INSERT INTO varchar_test14_46(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_46;
--PKEY col2 null error 
INSERT INTO varchar_test14_46(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_46;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_46(col0,col2) VALUES('1','1');
SELECT * from varchar_test14_46;
--not null constraint col0 error
INSERT INTO varchar_test14_46(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_46;
--not null constraint col2 error
INSERT INTO varchar_test14_46(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_46;
--ok
INSERT INTO varchar_test14_46(col0,col2) VALUES('2','2');
SELECT * from varchar_test14_46;

--varchar_test14_47
SELECT * from varchar_test14_47;
--ok
INSERT INTO varchar_test14_47 VALUES('1', '1', '1');
SELECT * from varchar_test14_47;
--PKEY col0 col2 null error 
INSERT INTO varchar_test14_47(col1) VALUES('3');
SELECT * from varchar_test14_47;
--PKEY col0 null error 
INSERT INTO varchar_test14_47(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_47;
--PKEY col2 null error 
INSERT INTO varchar_test14_47(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_47;
--PKEY col0 col2 not unique error
INSERT INTO varchar_test14_47(col0,col1,col2) VALUES('1','3','1');
SELECT * from varchar_test14_47;
--not null constraint col0 error
INSERT INTO varchar_test14_47(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_47;
--not null constraint col1 error
INSERT INTO varchar_test14_47(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_47;
--not null constraint col2 error
INSERT INTO varchar_test14_47(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_47;
--ok
INSERT INTO varchar_test14_47(col0,col1,col2) VALUES('2','6','2');
SELECT * from varchar_test14_47;

--varchar_test14_48
SELECT * from varchar_test14_48;
--ok
INSERT INTO varchar_test14_48 VALUES('1', '1', '1');
SELECT * from varchar_test14_48;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_48() VALUES();
SELECT * from varchar_test14_48;
--PKEY col0 null error 
INSERT INTO varchar_test14_48(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_48;
--PKEY col1 null error 
INSERT INTO varchar_test14_48(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_48;
--PKEY col2 null error 
INSERT INTO varchar_test14_48(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_48;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_48(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_48;
--ok
INSERT INTO varchar_test14_48(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_48;

--varchar_test14_49
SELECT * from varchar_test14_49;
--ok
INSERT INTO varchar_test14_49 VALUES('1', '1', '1');
SELECT * from varchar_test14_49;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_49() VALUES();
SELECT * from varchar_test14_49;
--PKEY col0 null error 
INSERT INTO varchar_test14_49(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_49;
--PKEY col1 null error 
INSERT INTO varchar_test14_49(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_49;
--PKEY col2 null error 
INSERT INTO varchar_test14_49(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_49;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_49(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_49;
--not null constraint col0 error
INSERT INTO varchar_test14_49(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_49;
--ok
INSERT INTO varchar_test14_49(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_49;

--varchar_test14_50
SELECT * from varchar_test14_50;
--ok
INSERT INTO varchar_test14_50 VALUES('1', '1', '1');
SELECT * from varchar_test14_50;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_50() VALUES();
SELECT * from varchar_test14_50;
--PKEY col0 null error 
INSERT INTO varchar_test14_50(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_50;
--PKEY col1 null error 
INSERT INTO varchar_test14_50(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_50;
--PKEY col2 null error 
INSERT INTO varchar_test14_50(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_50;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_50(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_50;
--not null constraint col1 error
INSERT INTO varchar_test14_50(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_50;
--ok
INSERT INTO varchar_test14_50(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_50;

--varchar_test14_51
SELECT * from varchar_test14_51;
--ok
INSERT INTO varchar_test14_51 VALUES('1', '1', '1');
SELECT * from varchar_test14_51;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_51() VALUES();
SELECT * from varchar_test14_51;
--PKEY col0 null error 
INSERT INTO varchar_test14_51(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_51;
--PKEY col1 null error 
INSERT INTO varchar_test14_51(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_51;
--PKEY col2 null error 
INSERT INTO varchar_test14_51(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_51;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_51(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_51;
--not null constraint col2 error
INSERT INTO varchar_test14_51(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_51;
--ok
INSERT INTO varchar_test14_51(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_51;

--varchar_test14_52
SELECT * from varchar_test14_52;
--ok
INSERT INTO varchar_test14_52 VALUES('1', '1', '1');
SELECT * from varchar_test14_52;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_52() VALUES();
SELECT * from varchar_test14_52;
--PKEY col0 null error 
INSERT INTO varchar_test14_52(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_52;
--PKEY col1 null error 
INSERT INTO varchar_test14_52(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_52;
--PKEY col2 null error 
INSERT INTO varchar_test14_52(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_52;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_52(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_52;
--not null constraint col0 error
INSERT INTO varchar_test14_52(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_52;
--not null constraint col1 error
INSERT INTO varchar_test14_52(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_52;
--ok
INSERT INTO varchar_test14_52(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_52;

--varchar_test14_53
SELECT * from varchar_test14_53;
--ok
INSERT INTO varchar_test14_53 VALUES('1', '1', '1');
SELECT * from varchar_test14_53;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_53() VALUES();
SELECT * from varchar_test14_53;
--PKEY col0 null error 
INSERT INTO varchar_test14_53(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_53;
--PKEY col1 null error 
INSERT INTO varchar_test14_53(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_53;
--PKEY col2 null error 
INSERT INTO varchar_test14_53(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_53;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_53(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_53;
--not null constraint col1 error
INSERT INTO varchar_test14_53(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_53;
--not null constraint col2 error
INSERT INTO varchar_test14_53(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_53;
--ok
INSERT INTO varchar_test14_53(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_53;

--varchar_test14_54
SELECT * from varchar_test14_54;
--ok
INSERT INTO varchar_test14_54 VALUES('1', '1', '1');
SELECT * from varchar_test14_54;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_54() VALUES();
SELECT * from varchar_test14_54;
--PKEY col0 null error 
INSERT INTO varchar_test14_54(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_54;
--PKEY col1 null error 
INSERT INTO varchar_test14_54(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_54;
--PKEY col2 null error 
INSERT INTO varchar_test14_54(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_54;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_54(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_54;
--not null constraint col0 error
INSERT INTO varchar_test14_54(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_54;
--not null constraint col2 error
INSERT INTO varchar_test14_54(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_54;
--ok
INSERT INTO varchar_test14_54(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_54;

--varchar_test14_55
SELECT * from varchar_test14_55;
--ok
INSERT INTO varchar_test14_55 VALUES('1', '1', '1');
SELECT * from varchar_test14_55;
--PKEY col0 col1 col2 null error 
INSERT INTO varchar_test14_55() VALUES();
SELECT * from varchar_test14_55;
--PKEY col0 null error 
INSERT INTO varchar_test14_55(col1,col2) VALUES('3','3');
SELECT * from varchar_test14_55;
--PKEY col1 null error 
INSERT INTO varchar_test14_55(col0,col2) VALUES('3','3');
SELECT * from varchar_test14_55;
--PKEY col2 null error 
INSERT INTO varchar_test14_55(col0,col1) VALUES('3','3');
SELECT * from varchar_test14_55;
--PKEY col0 col1 col2 not unique error
INSERT INTO varchar_test14_55(col0,col1,col2) VALUES('1','1','1');
SELECT * from varchar_test14_55;
--not null constraint col0 error
INSERT INTO varchar_test14_55(col1,col2) VALUES('5','5');
SELECT * from varchar_test14_55;
--not null constraint col1 error
INSERT INTO varchar_test14_55(col0,col2) VALUES('5','5');
SELECT * from varchar_test14_55;
--not null constraint col2 error
INSERT INTO varchar_test14_55(col0,col1) VALUES('5','5');
SELECT * from varchar_test14_55;
--ok
INSERT INTO varchar_test14_55(col0,col1,col2) VALUES('2','2','2');
SELECT * from varchar_test14_55;

