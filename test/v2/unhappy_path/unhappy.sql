CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

-- default constraint
CREATE TABLE tmp.customer2 (
  "c_credit" char(2) DEFAULT "apple"
) tablespace tsurugi;

-- default constraint
CREATE TABLE tmp.customer3 (
  id serial
) tablespace tsurugi;

-- multiple column pkey
create table tmp.oorder1 (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int not null primary key,
  ol_number int not null primary key
) tablespace tsurugi;

-- same column name
create table tmp.oorder2 (
  ol_w_id int,
  ol_w_id int,
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.oorder3 (
  ol_w_id int,
  ol_d_id varchar(),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.oorder4 (
) tablespace tsurugi;

create table tmp.oorder5 (
  ol_w_id,
  ol_d_id varchar(100),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp2;

create table tmp2.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE DATABASE test2 TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test2

create table oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp;

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

drop table oorder_dummy;

DROP SCHEMA tmp CASCADE;

\c test

DROP SCHEMA tmp CASCADE;
DROP SCHEMA tmp2 CASCADE;

\c postgres

DROP DATABASE test;
DROP DATABASE test2;
