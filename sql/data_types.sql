/* Numeric Types */
-- supported
CREATE TABLE numeric1(c1 integer) TABLESPACE tsurugi;
CREATE TABLE numeric2(c1 bigint) TABLESPACE tsurugi;
CREATE TABLE numeric3(c1 decimal(5, 2)) TABLESPACE tsurugi;
CREATE TABLE numeric4(c1 numeric(5, 2)) TABLESPACE tsurugi;
CREATE TABLE numeric5(c1 real) TABLESPACE tsurugi;
CREATE TABLE numeric6(c1 double precision) TABLESPACE tsurugi;

-- not supported
CREATE TABLE numeric99(c1 smallint) TABLESPACE tsurugi;

/* Character Types */
-- supported
CREATE TABLE character1(c1 character varying(10)) TABLESPACE tsurugi;
CREATE TABLE character2(c1 character(10)) TABLESPACE tsurugi;

-- not supported
CREATE TABLE character99(c1 text) TABLESPACE tsurugi;

/* Date/Time Types */
-- supported
CREATE TABLE datetime1(c1 timestamp) TABLESPACE tsurugi;
CREATE TABLE datetime2(c1 date) TABLESPACE tsurugi;
CREATE TABLE datetime3(c1 time) TABLESPACE tsurugi;

-- not supported
CREATE TABLE datetime99(c1 timestamp with time zone) TABLESPACE tsurugi;
CREATE TABLE datetime98(c1 time with time zone) TABLESPACE tsurugi;
CREATE TABLE datetime97(c1 interval) TABLESPACE tsurugi;

/* clean up */
DROP TABLE numeric1;
DROP TABLE numeric2;
DROP TABLE numeric3;
DROP TABLE numeric4;
DROP TABLE numeric5;
DROP TABLE numeric6;

DROP TABLE character1;
DROP TABLE character2;

DROP TABLE datetime1;
DROP TABLE datetime2;
DROP TABLE datetime3;
