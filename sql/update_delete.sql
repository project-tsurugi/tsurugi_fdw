CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE EXTENSION ogawayama_fdw;
CREATE SERVER ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;

/* DDL */
---int
CREATE TABLE update_delete_int1(col1 int) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_int1(col1 int) SERVER ogawayama;

---bigint
CREATE TABLE update_delete_bigint1(col1 bigint) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_bigint1(col1 bigint) SERVER ogawayama;

---real
CREATE TABLE update_delete_real1(col1 real) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_real1(col1 real) SERVER ogawayama;

---double precision
CREATE TABLE update_delete_double1(col1 double precision) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_double1(col1 double precision) SERVER ogawayama;

---char
CREATE TABLE update_delete_char1(col1 char(10)) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_char1(col1 char(10)) SERVER ogawayama;

---varchar
CREATE TABLE update_delete_varchar1(col1 varchar(10)) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_varchar1(col1 varchar(10)) SERVER ogawayama;

/* DML */
---int
SELECT * FROM update_delete_int1;
INSERT INTO update_delete_int1 VALUES (1);
INSERT INTO update_delete_int1 VALUES (2);
SELECT * FROM update_delete_int1;

SELECT * FROM update_delete_int1;
UPDATE update_delete_int1 SET col1 = col1+2147483646;
SELECT * FROM update_delete_int1;

SELECT * FROM update_delete_int1;
DELETE FROM update_delete_int1 WHERE col1 = 2147483647;
SELECT * FROM update_delete_int1;

SELECT * FROM update_delete_int1;
DELETE FROM update_delete_int1 WHERE col1 = 2147483646;
SELECT * FROM update_delete_int1;

---int
SELECT * FROM update_delete_int1;
INSERT INTO update_delete_int1 VALUES (1);
INSERT INTO update_delete_int1 VALUES (2);
SELECT * FROM update_delete_int1;

SELECT * FROM update_delete_int1;
UPDATE update_delete_int1 SET col1 = col1+2147483646;
SELECT * FROM update_delete_int1;

SELECT * FROM update_delete_int1;
DELETE FROM update_delete_int1 WHERE col1 = 2147483647;
SELECT * FROM update_delete_int1;

SELECT * FROM update_delete_int1;
DELETE FROM update_delete_int1 WHERE col1 = 2147483646;
SELECT * FROM update_delete_int1;

---bigint
SELECT * FROM update_delete_bigint1;
INSERT INTO update_delete_bigint1 VALUES (1);
INSERT INTO update_delete_bigint1 VALUES (2);
SELECT * FROM update_delete_bigint1;

SELECT * FROM update_delete_bigint1;
UPDATE update_delete_bigint1 SET col1 = col1+9223372036854775806;
SELECT * FROM update_delete_bigint1;

SELECT * FROM update_delete_bigint1;
DELETE FROM update_delete_bigint1 WHERE col1 = 9223372036854775807;
SELECT * FROM update_delete_bigint1;

SELECT * FROM update_delete_bigint1;
DELETE FROM update_delete_bigint1 WHERE col1 = 9223372036854775806;
SELECT * FROM update_delete_bigint1;

---real
SELECT * FROM update_delete_real1;
INSERT INTO update_delete_real1 VALUES (1.1);
INSERT INTO update_delete_real1 VALUES (0.1);
SELECT * FROM update_delete_real1;

SELECT * FROM update_delete_real1;
UPDATE update_delete_real1 SET col1 = col1+1;
SELECT * FROM update_delete_real1;

SELECT * FROM update_delete_real1;
DELETE FROM update_delete_real1 WHERE col1 = 1.1;
SELECT * FROM update_delete_real1;

SELECT * FROM update_delete_real1;
DELETE FROM update_delete_real1 WHERE col1 = 0.1;
SELECT * FROM update_delete_real1;

---double precision
SELECT * FROM update_delete_double1;
INSERT INTO update_delete_double1 VALUES (1.1);
INSERT INTO update_delete_double1 VALUES (0.1);
SELECT * FROM update_delete_double1;

SELECT * FROM update_delete_double1;
UPDATE update_delete_double1 SET col1 = col1+1;
SELECT * FROM update_delete_double1;

SELECT * FROM update_delete_double1;
DELETE FROM update_delete_double1 WHERE col1 = 1.1;
SELECT * FROM update_delete_double1;

SELECT * FROM update_delete_double1;
DELETE FROM update_delete_double1 WHERE col1 = 0.1;
SELECT * FROM update_delete_double1;

---char
SELECT * FROM update_delete_char1;
INSERT INTO update_delete_char1 VALUES ('abcdefghij');
INSERT INTO update_delete_char1 VALUES ('klmnopqrst');
SELECT * FROM update_delete_char1;

SELECT * FROM update_delete_char1;
UPDATE update_delete_char1 SET col1 = 'uvdxyzabcd' WHERE col1 = 'abcdefghij';
SELECT * FROM update_delete_char1;

SELECT * FROM update_delete_char1;
UPDATE update_delete_char1 SET col1 = 'uvdxyzabcde' WHERE col1 = 'klmnopqrst';
SELECT * FROM update_delete_char1;

SELECT * FROM update_delete_char1;
DELETE FROM update_delete_char1 WHERE col1 = 'klmnopqrst';
SELECT * FROM update_delete_char1;

SELECT * FROM update_delete_char1;
DELETE FROM update_delete_char1 WHERE col1 = 'abcdefghij';
SELECT * FROM update_delete_char1;

---char
SELECT * FROM update_delete_varchar1;
INSERT INTO update_delete_varchar1 VALUES ('abcdefghij');
INSERT INTO update_delete_varchar1 VALUES ('klmnopqrst');
SELECT * FROM update_delete_varchar1;

SELECT * FROM update_delete_varchar1;
UPDATE update_delete_varchar1 SET col1 = 'uvdxyzabcd' WHERE col1 = 'abcdefghij';
SELECT * FROM update_delete_varchar1;

SELECT * FROM update_delete_varchar1;
UPDATE update_delete_varchar1 SET col1 = 'uvdxyzabcde' WHERE col1 = 'klmnopqrst';
SELECT * FROM update_delete_varchar1;

SELECT * FROM update_delete_varchar1;
DELETE FROM update_delete_varchar1 WHERE col1 = 'klmnopqrst';
SELECT * FROM update_delete_varchar1;

SELECT * FROM update_delete_varchar1;
DELETE FROM update_delete_varchar1 WHERE col1 = 'abcdefghij';
SELECT * FROM update_delete_varchar1;

\c postgres

DROP DATABASE test;
