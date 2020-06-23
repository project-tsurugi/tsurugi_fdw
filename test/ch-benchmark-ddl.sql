CREATE DATABASE test;

\c test

CREATE SCHEMA tmp;

DROP TABLE IF EXISTS tmp.order_line;
CREATE TABLE tmp.order_line (
  ol_w_id int NOT NULL,
  ol_d_id int NOT NULL,
  ol_o_id int NOT NULL,
  ol_number int NOT NULL,
  ol_i_id int NOT NULL,
  ol_delivery_d char(24), -- timestamp NULL DEFAULT NULL
  ol_amount double precision NOT NULL, -- decimal(6,2) NOT NULL
  ol_supply_w_id int NOT NULL,
  ol_quantity double precision NOT NULL, -- decimal(2,0) NOT NULL
  ol_dist_info char(24) NOT NULL,
  PRIMARY KEY (ol_w_id,ol_d_id,ol_o_id,ol_number)
) tablespace tsurugi;

DROP TABLE IF EXISTS tmp.new_order;
CREATE TABLE tmp.new_order (
  no_w_id int NOT NULL,
  no_d_id int NOT NULL,
  no_o_id int NOT NULL,
  PRIMARY KEY (no_w_id,no_d_id,no_o_id)
) tablespace tsurugi;

DROP TABLE IF EXISTS tmp.stock;
CREATE TABLE tmp.stock (
  s_w_id int NOT NULL,
  s_i_id int NOT NULL,
  s_quantity double precision NOT NULL, -- decimal(4,0) NOT NULL
  s_ytd double precision NOT NULL, -- decimal(8,2) NOT NULL
  s_order_cnt int NOT NULL,
  s_remote_cnt int NOT NULL,
  s_data varchar(50) NOT NULL,
  s_dist_01 char(24) NOT NULL,
  s_dist_02 char(24) NOT NULL,
  s_dist_03 char(24) NOT NULL,
  s_dist_04 char(24) NOT NULL,
  s_dist_05 char(24) NOT NULL,
  s_dist_06 char(24) NOT NULL,
  s_dist_07 char(24) NOT NULL,
  s_dist_08 char(24) NOT NULL,
  s_dist_09 char(24) NOT NULL,
  s_dist_10 char(24) NOT NULL,
  PRIMARY KEY (s_w_id,s_i_id)
) tablespace tsurugi;

-- TODO: o_entry_d  ON UPDATE CURRENT_TIMESTAMP
DROP TABLE IF EXISTS tmp.orders;
CREATE TABLE tmp.orders (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int DEFAULT NULL,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

-- TODO: h_date ON UPDATE CURRENT_TIMESTAMP
DROP TABLE IF EXISTS tmp.history;
CREATE TABLE tmp.history (
  h_c_id int NOT NULL,
  h_c_d_id int NOT NULL,
  h_c_w_id int NOT NULL,
  h_d_id int NOT NULL,
  h_w_id int NOT NULL,
  h_date char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  h_amount double precision NOT NULL, -- decimal(6,2) NOT NULL
  h_data varchar(24) NOT NULL
) tablespace tsurugi;

DROP TABLE IF EXISTS tmp.customer;
CREATE TABLE tmp.customer (
  c_w_id int NOT NULL,
  c_d_id int NOT NULL,
  c_id int NOT NULL,
  c_discount double precision NOT NULL, -- decimal(4,4) NOT NULL
  c_credit char(2) NOT NULL,
  c_last varchar(16) NOT NULL,
  c_first varchar(16) NOT NULL,
  c_credit_lim double precision NOT NULL, -- decimal(12,2) NOT NULL
  c_balance double precision NOT NULL, -- decimal(12,2) NOT NULL
  c_ytd_payment float NOT NULL,
  c_payment_cnt int NOT NULL,
  c_delivery_cnt int NOT NULL,
  c_street_1 varchar(20) NOT NULL,
  c_street_2 varchar(20) NOT NULL,
  c_city varchar(20) NOT NULL,
  c_state char(2) NOT NULL,
  c_zip char(9) NOT NULL,
  c_phone char(16) NOT NULL,
  c_since char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  c_middle char(2) NOT NULL,
  c_data varchar(500) NOT NULL,
  PRIMARY KEY (c_w_id,c_d_id,c_id)
) tablespace tsurugi;

DROP TABLE IF EXISTS tmp.district;
CREATE TABLE tmp.district (
  d_w_id int NOT NULL,
  d_id int NOT NULL,
  d_ytd double precision NOT NULL, -- decimal(12,2) NOT NULL
  d_tax double precision NOT NULL, -- decimal(4,4) NOT NULL
  d_next_o_id int NOT NULL,
  d_name varchar(10) NOT NULL,
  d_street_1 varchar(20) NOT NULL,
  d_street_2 varchar(20) NOT NULL,
  d_city varchar(20) NOT NULL,
  d_state char(2) NOT NULL,
  d_zip char(9) NOT NULL,
  PRIMARY KEY (d_w_id,d_id)
) tablespace tsurugi;


DROP TABLE IF EXISTS tmp.item;
CREATE TABLE tmp.item (
  i_id int NOT NULL,
  i_name varchar(24) NOT NULL,
  i_price double precision NOT NULL, -- decimal(5,2) NOT NULL
  i_data varchar(50) NOT NULL,
  i_im_id int NOT NULL,
  PRIMARY KEY (i_id)
) tablespace tsurugi;

DROP TABLE IF EXISTS tmp.warehouse;
CREATE TABLE tmp.warehouse (
  w_id int NOT NULL,
  w_ytd double precision NOT NULL, -- decimal(12,2) NOT NULL
  w_tax double precision NOT NULL, -- decimal(4,4) NOT NULL
  w_name varchar(10) NOT NULL,
  w_street_1 varchar(20) NOT NULL,
  w_street_2 varchar(20) NOT NULL,
  w_city varchar(20) NOT NULL,
  w_state char(2) NOT NULL,
  w_zip char(9) NOT NULL,
  PRIMARY KEY (w_id)
) tablespace tsurugi;

-- Add table for ch-benchmark

DROP TABLE IF EXISTS tmp.nation;
CREATE TABLE tmp.nation (
    n_nationkey integer NOT NULL,
    n_name character(25) NOT NULL,
    n_regionkey integer NOT NULL,
    n_comment character(152) NOT NULL,
    PRIMARY KEY (n_nationkey)
) tablespace tsurugi;

DROP TABLE IF EXISTS tmp.supplier;
CREATE TABLE tmp.supplier (
    su_suppkey integer NOT NULL,
    su_name character(25) NOT NULL,
    su_address character(40) NOT NULL,
    su_nationkey integer NOT NULL,
    su_phone character(15) NOT NULL,
    su_acctbal double precision NOT NULL, -- numeric(12,2) NOT NULL
    su_comment character(101) NOT NULL,
    PRIMARY KEY (su_suppkey)
) tablespace tsurugi;

DROP TABLE IF EXISTS tmp.region;
CREATE TABLE tmp.region (
    r_regionkey integer NOT NULL,
    r_name character(55) NOT NULL,
    r_comment character(152) NOT NULL,
    PRIMARY KEY (r_regionkey)
) tablespace tsurugi;

DROP SCHEMA tmp CASCADE;

\c postgres

DROP DATABASE test;
