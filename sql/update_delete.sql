CREATE EXTENSION IF NOT EXISTS ogawayama_fdw;
CREATE SERVER IF NOT EXISTS ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;

/* DDL */
---int
CREATE TABLE update_delete_int1(col1 int PRIMARY KEY, col2 int) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_int1(col1 int, col2 int) SERVER ogawayama;

---bigint
CREATE TABLE update_delete_bigint1(col1 int PRIMARY KEY, col2 bigint) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_bigint1(col1 int, col2 bigint) SERVER ogawayama;

---real
CREATE TABLE update_delete_real1(col1 int PRIMARY KEY, col2 real) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_real1(col1 int, col2 real) SERVER ogawayama;

---double precision
CREATE TABLE update_delete_double1(col1 int PRIMARY KEY, col2 double precision) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_double1(col1 int, col2 double precision) SERVER ogawayama;

---char
CREATE TABLE update_delete_char1(col1 int PRIMARY KEY, col2 char(2)) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_char1(col1 int, col2 char(2)) SERVER ogawayama;

---varchar
CREATE TABLE update_delete_varchar1(col1 int PRIMARY KEY, col2 varchar(2)) TABLESPACE tsurugi;
CREATE FOREIGN TABLE update_delete_varchar1(col1 int, col2 varchar(2)) SERVER ogawayama;

/* DML */
---int
SELECT * FROM update_delete_int1;
INSERT INTO update_delete_int1 (col1, col2) VALUES (1, 1);
INSERT INTO update_delete_int1 (col1, col2) VALUES (2, 2);
SELECT * FROM update_delete_int1;

UPDATE update_delete_int1 SET col2 = col2+2147483645;
SELECT * FROM update_delete_int1;

DELETE FROM update_delete_int1 WHERE col2 = 2147483647;
SELECT * FROM update_delete_int1;

DELETE FROM update_delete_int1 WHERE col3 = 1;
SELECT * FROM update_delete_int1;

---bigint
SELECT * FROM update_delete_bigint1;
INSERT INTO update_delete_bigint1 (col1, col2) VALUES (1, 1);
INSERT INTO update_delete_bigint1 (col1, col2) VALUES (2, 2);
SELECT * FROM update_delete_bigint1;

UPDATE update_delete_bigint1 SET col2 = col2+9223372036854775805;
SELECT * FROM update_delete_bigint1;

DELETE FROM update_delete_bigint1 WHERE col2 = 9223372036854775807;
SELECT * FROM update_delete_bigint1;

DELETE FROM update_delete_bigint1 WHERE col3 = 1;
SELECT * FROM update_delete_bigint1;

---real
SELECT * FROM update_delete_real1;
INSERT INTO update_delete_real1 (col1, col2) VALUES (1, 1.1);
INSERT INTO update_delete_real1 (col1, col2) VALUES (2, 0.1);
INSERT INTO update_delete_real1 (col1, col2) VALUES (3, 3.4);
SELECT * FROM update_delete_real1;

UPDATE update_delete_real1 SET col2 = col2+1;
SELECT * FROM update_delete_real1;

DELETE FROM update_delete_real1 WHERE col2 = 4.4;
SELECT * FROM update_delete_real1;

DELETE FROM update_delete_real1 WHERE col3 = 0.1;
SELECT * FROM update_delete_real1;

---double precision
SELECT * FROM update_delete_double1;
INSERT INTO update_delete_double1 (col1, col2) VALUES (1, 1.1);
INSERT INTO update_delete_double1 (col1, col2) VALUES (2, 0.1);
INSERT INTO update_delete_double1 (col1, col2) VALUES (3, 3.4);
SELECT * FROM update_delete_double1;

UPDATE update_delete_double1 SET col2 = col2+1;
SELECT * FROM update_delete_double1;

DELETE FROM update_delete_double1 WHERE col2 = 4.4;
SELECT * FROM update_delete_double1;

DELETE FROM update_delete_double1 WHERE col3 = 0.1;
SELECT * FROM update_delete_double1;

---char
SELECT * FROM update_delete_char1;
INSERT INTO update_delete_char1 (col1, col2) VALUES (1, 'ab');
INSERT INTO update_delete_char1 (col1, col2) VALUES (2, 'kl');
SELECT * FROM update_delete_char1;

UPDATE update_delete_char1 SET col2 = 'uv' WHERE col2 = 'ab';
SELECT * FROM update_delete_char1;

UPDATE update_delete_char1 SET col2 = 'uvd' WHERE col2 = 'kl';
SELECT * FROM update_delete_char1;

DELETE FROM update_delete_char1 WHERE col2 = 'kl';
SELECT * FROM update_delete_char1;

DELETE FROM update_delete_char1 WHERE col3 = 'ab';
SELECT * FROM update_delete_char1;

---varchar
SELECT * FROM update_delete_varchar1;
INSERT INTO update_delete_varchar1 (col1, col2) VALUES (1, 'ab');
INSERT INTO update_delete_varchar1 (col1, col2) VALUES (2, 'kl');
SELECT * FROM update_delete_varchar1;

UPDATE update_delete_varchar1 SET col2 = 'uv' WHERE col2 = 'ab';
SELECT * FROM update_delete_varchar1;

UPDATE update_delete_varchar1 SET col2 = 'uvd' WHERE col2 = 'kl';
SELECT * FROM update_delete_varchar1;

DELETE FROM update_delete_varchar1 WHERE col2 = 'kl';
SELECT * FROM update_delete_varchar1;

DELETE FROM update_delete_varchar1 WHERE col3 = 'ab';
SELECT * FROM update_delete_varchar1;
