CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

CREATE TABLE tmp.test1 (
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
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000)
);

CREATE TABLE tmp.test2 (
col0  integer PRIMARY KEY,
col1  int,
col2  int4,
col3  bigint,
col4  int8,
col5  real,
col6  float4,
col7  double precision,
col8  float8,
col9  char,
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000)
);

CREATE TABLE tmp.test3 (
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL
);

CREATE TABLE tmp.test4_1 (
col0  integer PRIMARY KEY NOT NULL,
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL
);

CREATE TABLE tmp.test4_2 (
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
col10 char(1000) NOT NULL PRIMARY KEY,
col11 character NOT NULL,
col12 character(1000) NOT NULL,
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL
);

CREATE TABLE tmp.test5 (
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
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col9)
);

--error
CREATE TABLE tmp.test6 (
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
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col1)
);

CREATE TABLE tmp.test7 (
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col4)
);

--error
CREATE TABLE tmp.test8_1 (
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col4)
);

--error
CREATE TABLE tmp.test8_2 (
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col5)
);

CREATE TABLE tmp.test9 (
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
col10 char(1000),
col11 character,
col12 character(1000),
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col1,col2,col5,col15)
);

--error
CREATE TABLE tmp.test10 (
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
col13 varchar,
col14 varchar(1000),
col15 character varying,
col16 character varying(1000),
PRIMARY KEY(col1,col2)
);

CREATE TABLE tmp.test11 (
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL,
PRIMARY KEY(col3,col4,col5,col14,col15)
);

--error
CREATE TABLE tmp.test12_1 (
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) NOT NULL PRIMARY KEY,
PRIMARY KEY(col7,col8,col9,col10)
);

--error
CREATE TABLE tmp.test12_2 (
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
col13 varchar NOT NULL,
col14 varchar(1000) NOT NULL,
col15 character varying NOT NULL,
col16 character varying(1000) PRIMARY KEY NOT NULL,
PRIMARY KEY(col7,col8,col9,col10)
);

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
);

DROP TABLE IF EXISTS tmp.new_order;
CREATE TABLE tmp.new_order (
  no_w_id int NOT NULL,
  no_d_id int NOT NULL,
  no_o_id int NOT NULL,
  PRIMARY KEY (no_w_id,no_d_id,no_o_id)
);

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
);

-- TODO: o_entry_d  ON UPDATE CURRENT_TIMESTAMP
DROP TABLE IF EXISTS tmp.orders;
CREATE TABLE tmp.orders (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

DROP TABLE IF EXISTS tmp.orders_secondary;
CREATE TABLE tmp.orders_secondary (
  o_d_id INT NOT NULL,
  o_w_id INT NOT NULL,
  o_c_id INT NOT NULL,
  o_id INT NOT NULL,
  PRIMARY KEY(o_w_id, o_d_id, o_c_id, o_id)
);

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
);

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
);

DROP TABLE IF EXISTS tmp.customer_secondary;
CREATE TABLE tmp.customer_secondary (
  c_d_id INT NOT NULL,
  c_w_id INT NOT NULL,
  c_last VARCHAR(16) NOT NULL,
  c_first VARCHAR(16) NOT NULL,
  c_id INT NOT NULL,
  PRIMARY KEY(c_w_id, c_d_id, c_last, c_first)
);

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
);


DROP TABLE IF EXISTS tmp.item;
CREATE TABLE tmp.item (
  i_id int NOT NULL,
  i_name varchar(24) NOT NULL,
  i_price double precision NOT NULL, -- decimal(5,2) NOT NULL
  i_data varchar(50) NOT NULL,
  i_im_id int NOT NULL,
  PRIMARY KEY (i_id)
);

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
);

-- Add table for ch-benchmark

DROP TABLE IF EXISTS tmp.nation;
CREATE TABLE tmp.nation (
    n_nationkey integer NOT NULL,
    n_name character(25) NOT NULL,
    n_regionkey integer NOT NULL,
    n_comment character(152) NOT NULL,
    PRIMARY KEY (n_nationkey)
);

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
);

DROP TABLE IF EXISTS tmp.region;
CREATE TABLE tmp.region (
    r_regionkey integer NOT NULL,
    r_name character(55) NOT NULL,
    r_comment character(152) NOT NULL,
    PRIMARY KEY (r_regionkey)
);

DROP SCHEMA tmp CASCADE;

\c postgres

DROP DATABASE test;

CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

-- referred by FOREIGN KEY constraint
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
);

DROP TABLE IF EXISTS tmp.customer_secondary;
CREATE TABLE tmp.customer_secondary (
  c_d_id INT NOT NULL,
  c_w_id INT NOT NULL PRIMARY KEY,
  c_last VARCHAR(16) NOT NULL,
  c_first VARCHAR(16) NOT NULL,
  c_id INT NOT NULL
);

-- type error not supported
CREATE TABLE tmp.orders_type_error (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt decimal(2,0) NOT NULL,
  o_all_local decimal(1,0) NOT NULL,
  o_entry_d timestamp NOT NULL,
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

-- TEMP TABLE
create temp table temptbl (
  id integer,
  name varchar(10)
);

create temporary table temporarytbl (
  id integer,
  name varchar(10)
);

-- UNLOGGED TABLE
create unlogged table tmp.unloggedtbl (
  id integer,
  name varchar(10)
);

-- COLLATE column
CREATE TABLE tmp.distributors_unique_cc (
    did     varchar(1000) COLLATE "C"
);

-- LIKE clause
CREATE TABLE tmp.customer_copied (
    LIKE tmp.customer
);

-- LIKE INCLUDING ALL
CREATE TABLE tmp.customer_copied_including (
    LIKE tmp.customer INCLUDING ALL
);

-- LIKE EXCLUDING
CREATE TABLE tmp.customer_copied_excluding (
    LIKE tmp.customer EXCLUDING CONSTRAINTS
);

-- INHERITS clause
-- parent table
CREATE TABLE tmp.cities (
    name            varchar,
    population      float,
    altitude        int     -- in feet
);

-- INHERITS clause (child table)
CREATE TABLE tmp.capitals (
    state           char(2)
) INHERITS (tmp.cities);

-- PARTITION BY RANGE
CREATE TABLE tmp.measurement (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) PARTITION BY RANGE (logdate);

-- PARTITION BY RANGE COLLATE
CREATE TABLE tmp.measurement_collate (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) PARTITION BY RANGE (logdate COLLATE "C");

CREATE TABLE tmp.measurement_y2016m07
PARTITION OF tmp.measurement
FOR VALUES FROM ('2016-07-01') TO ('2016-08-01');

-- PARTITION BY LIST
CREATE TABLE tmp.cities_partition_by_list (
    city_id      bigint not null,
    name         varchar not null,
    population   bigint
) PARTITION BY LIST (name);

CREATE TABLE tmp.cities_ab
PARTITION OF tmp.cities_partition_by_list
FOR VALUES IN ('a', 'b');

-- PARTITION BY HASH
CREATE TABLE tmp.orders_partition_by_hash (
    order_id     bigint not null,
    cust_id      bigint not null,
    status       varchar
) PARTITION BY HASH (order_id);

CREATE TABLE tmp.orders_p1 PARTITION OF tmp.orders_partition_by_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

-- USING method
CREATE ACCESS METHOD myheap TYPE TABLE HANDLER heap_tableam_handler;
CREATE TABLE tmp.t_myheap (
    id int, v text
) USING myheap;

-- WITH clause of table
CREATE TABLE tmp.distributors_table_with (
    did     integer,
    name    varchar(40)
)
WITH (fillfactor=70);

-- ON COMMIT PRESERVE ROWS
create global temporary table oncommit_prows (
  id int not null primary key,
  txt varchar(32)
)
on commit preserve rows;

-- ON COMMIT DELETE ROWS
create global temporary table oncommit_drows (
  id int not null primary key,
  txt varchar(32)
)
on commit delete rows;

-- ON COMMIT DROP
create global temporary table oncommit_drop (
  id int not null primary key,
  txt varchar(32)
)
on commit drop;

-- OF clause
CREATE TYPE employee_type AS (name text, salary numeric);
CREATE TABLE tmp.employees OF employee_type (
    PRIMARY KEY (name),
    salary
);

-- *** column constraint ***
-- NULL column constraint
CREATE TABLE tmp.orders_null_cc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int NULL,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

-- CHECK column constraint
CREATE TABLE tmp.distributors_check_cc (
    did     integer CHECK (did > 100),
    name    varchar(40)
);

-- CHECK column constraint NO INHERIT
CREATE TABLE tmp.distributors_check_cc_ni (
    did     integer CHECK (did > 100) NO INHERIT,
    name    varchar(40)
);

-- DEFAULT column constraint
CREATE TABLE tmp.orders_default_cc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int DEFAULT NULL,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

-- GENERATED ALWAYS AS
CREATE TABLE tmp.generated_always_as (
    x float,
    y float,
    "(x + y)" float GENERATED ALWAYS AS (x + y) STORED,
    "(x - y)" float GENERATED ALWAYS AS (x - y) STORED,
    "(x * y)" float GENERATED ALWAYS AS (x * y) STORED,
    "(x / y)" float GENERATED ALWAYS AS (x / y) STORED
);

-- GENERATED BY DEFAULT AS IDENTITY
CREATE TABLE tmp.distributors_generated_by_default (
     did    integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
     name   varchar(40) NOT NULL
);

-- GENERATED ALWAYS AS IDENTITY
CREATE TABLE tmp.distributors_generated_always (
     did    integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
     name   varchar(40) NOT NULL
);

-- UNIQUE column constraint
CREATE TABLE tmp.distributors_unique_cc_collate (
    did     integer,
    name    varchar(40) UNIQUE
);

-- PRIMARY KEY WITH
CREATE TABLE tmp.distributors_pkey_cc_include (
    id             integer PRIMARY KEY WITH (fillfactor=70),
    first_name     varchar,
    last_name      varchar
);

-- PRIMARY KEY USING INDEX
CREATE TABLE tmp.distributors_pkey_cc_using_index (
    id             integer PRIMARY KEY USING INDEX TABLESPACE tsurugi,
    first_name     varchar,
    last_name      varchar
);

-- FOREIGN KEY column constraint
CREATE TABLE tmp.orders_fkey_cc (
  o_w_id int NOT NULL REFERENCES tmp.customer_secondary (c_w_id),
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

-- FOREIGN KEY column constraint MATCH FULL
CREATE TABLE tmp.orders_fkey_cc_mf (
  o_w_id int NOT NULL REFERENCES tmp.customer_secondary (c_w_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

-- FOREIGN KEY column constraint MATCH PARTIAL
CREATE TABLE tmp.orders_fkey_cc_mp (
  o_w_id int NOT NULL REFERENCES tmp.customer_secondary (c_w_id) MATCH PARTIAL ON UPDATE NO ACTION ON DELETE NO ACTION,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

-- FOREIGN KEY column constraint MATCH SIMPLE
CREATE TABLE tmp.orders_fkey_cc_ms (
  o_w_id int REFERENCES tmp.customer_secondary (c_w_id) MATCH SIMPLE ON UPDATE SET NULL ON DELETE SET NULL,
  o_d_id int,
  o_id int,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
);

-- DEFERRABLE INITIALLY DEFERRED column constraint
CREATE TABLE tmp.deferrable_initially_deferred_cc(
    id integer PRIMARY KEY DEFERRABLE INITIALLY DEFERRED
);

-- DEFERRABLE INITIALLY IMMEDIATE column constraint
CREATE TABLE tmp.deferrable_initially_immediate_cc(
    id integer PRIMARY KEY DEFERRABLE INITIALLY IMMEDIATE
);

-- DEFERRABLE column constraint
CREATE TABLE tmp.deferrable_cc(
    id integer PRIMARY KEY DEFERRABLE
);

-- NOT DEFERRABLE column constraint
CREATE TABLE tmp.not_deferrable_cc(
    id integer PRIMARY KEY NOT DEFERRABLE
);

-- *** table constraint ***
-- CHECK table constraint
CREATE TABLE tmp.distributors_check_tc (
    did     integer,
    name    varchar(40),
    CONSTRAINT con1 CHECK (did > 100 AND name <> '')
);

-- CHECK table constraint NO INHERIT
CREATE TABLE tmp.distributors_check_tc_ni (
    did     integer,
    name    varchar(40),
    CONSTRAINT con1 CHECK (did > 100 AND name <> '') NO INHERIT
);

-- UNIQUE table constraint
CREATE TABLE tmp.orders_unique_tc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  UNIQUE (o_w_id,o_d_id,o_c_id,o_id)
);

-- WITH clause
CREATE TABLE tmp.distributors_column_with (
    did     integer,
    name    varchar(40),
    PRIMARY KEY(name) WITH (fillfactor=70)
);

-- PRIMARY KEY INCLUDE
CREATE TABLE tmp.distributors_pkey_tc_include (
    id             integer,
    first_name     varchar,
    last_name      varchar,
    PRIMARY KEY(id) INCLUDE (first_name,last_name)
);

-- PRIMARY KEY USING INDEX
CREATE TABLE tmp.distributors_pkey_tc_using_index (
    id             integer,
    first_name     varchar,
    last_name      varchar,
    PRIMARY KEY(id) USING INDEX TABLESPACE tsurugi
);

-- EXCLUDE USING
CREATE TABLE tmp.distributotrs_exclude_using (
    name varchar,
    age integer,
    EXCLUDE USING btree (age WITH =)
);

CREATE TABLE tmp.distributotrs_exclude_using_where (
    name varchar,
    age integer,
    EXCLUDE USING btree (age WITH =) WHERE (age between 0 and 200)
);

create table tmp.account_exclude_using_op_class
(
  MANUAL_NO         VARCHAR(12),
  EXCLUDE USING btree (MANUAL_NO varchar_pattern_ops WITH =)
);

create table tmp.account_exclude_using_op_class_desc_nulls_last
(
  MANUAL_NO         VARCHAR(12),
  EXCLUDE USING btree (MANUAL_NO varchar_pattern_ops DESC NULLS LAST WITH =)
);

-- FOREIGN KEY table constraint
CREATE TABLE tmp.orders_fkey_tc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES tmp.customer(c_w_id,c_d_id,c_id)
);

-- FOREIGN KEY table constraint
CREATE TABLE tmp.orders_fkey_tc_mf (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES tmp.customer(c_w_id,c_d_id,c_id)
  MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- FOREIGN KEY table constraint
CREATE TABLE tmp.orders_fkey_tc_mp (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES tmp.customer(c_w_id,c_d_id,c_id)
  MATCH PARTIAL ON UPDATE SET DEFAULT ON DELETE SET DEFAULT
);

-- FOREIGN KEY table constraint
CREATE TABLE tmp.orders_fkey_tc_ms (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES tmp.customer(c_w_id,c_d_id,c_id)
  MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);

-- DEFERRABLE INITIALLY DEFERRED
CREATE TABLE tmp.deferrable_initially_deferred_tc(
    id integer NOT NULL,
    CONSTRAINT deferrable_initially_deferred_tc_pk PRIMARY KEY (id) DEFERRABLE INITIALLY DEFERRED
);

-- DEFERRABLE INITIALLY IMMEDIATE
CREATE TABLE tmp.deferrable_initially_immediate_tc(
    id integer NOT NULL,
    CONSTRAINT deferrable_initially_immediate_tc_pk PRIMARY KEY (id) DEFERRABLE INITIALLY IMMEDIATE
);

-- DEFERRABLE
CREATE TABLE tmp.deferrable_tc(
    id integer NOT NULL,
    CONSTRAINT deferrable_tc_pk PRIMARY KEY (id) DEFERRABLE
);

DROP SCHEMA tmp CASCADE;

\c postgres

DROP DATABASE test;

CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

create table tmp.no_column (
);

CREATE TABLE tmp.customer (
  c_credit char(2)
);

CREATE TABLE IF NOT EXISTS tmp.customer (
  c_credit char(2)
);

CREATE TABLE TMP.TCPKEY_UPPER (
COL0  INTEGER                 CONSTRAINT NN0 NOT NULL,
COL1  INT                     CONSTRAINT NN1 NOT NULL,
COL2  INT4                    CONSTRAINT NN2 NOT NULL,
COL3  BIGINT                  CONSTRAINT NN3 NOT NULL,
COL4  INT8                    CONSTRAINT NN4 NOT NULL,
COL5  REAL                    CONSTRAINT NN5 NOT NULL,
COL6  FLOAT4                  CONSTRAINT NN6 NOT NULL,
COL7  DOUBLE PRECISION        CONSTRAINT NN7 NOT NULL,
COL8  FLOAT8                  CONSTRAINT NN8 NOT NULL,
COL9  CHAR                    CONSTRAINT NN9 NOT NULL,
COL10 CHAR(1000)              CONSTRAINT NN10 NOT NULL,
COL11 CHARACTER               CONSTRAINT NN11 NOT NULL,
COL12 CHARACTER(1000)         CONSTRAINT NN12 NOT NULL,
COL13 VARCHAR                 CONSTRAINT NN13 NOT NULL,
COL14 VARCHAR(1000)           CONSTRAINT NN14 NOT NULL,
COL15 CHARACTER VARYING       CONSTRAINT NN15 NOT NULL,
COL16 CHARACTER VARYING(1000) CONSTRAINT NN16 NOT NULL,
CONSTRAINT TCPKEY_UPPER_PK PRIMARY KEY(COL0)
);

create table tmp.tcpkey_lower (
col0  integer                 constraint nn0 not null,
col1  int                     constraint nn1 not null,
col2  int4                    constraint nn2 not null,
col3  bigint                  constraint nn3 not null,
col4  int8                    constraint nn4 not null,
col5  real                    constraint nn5 not null,
col6  float4                  constraint nn6 not null,
col7  double precision        constraint nn7 not null,
col8  float8                  constraint nn8 not null,
col9  char                    constraint nn9 not null,
col10 char(1000)              constraint nn10 not null,
col11 character               constraint nn11 not null,
col12 character(1000)         constraint nn12 not null,
col13 varchar                 constraint nn13 not null,
col14 varchar(1000)           constraint nn14 not null,
col15 character varying       constraint nn15 not null,
col16 character varying(1000) constraint nn16 not null,
constraint tcpkey_lower_pk primary key(col16)
);

CREATE TABLE TMP.CCPKEY_UPPER (
COL0  INTEGER                 CONSTRAINT NN0 NOT NULL PRIMARY KEY,
COL1  INT                     CONSTRAINT NN1 NOT NULL,
COL2  INT4                    CONSTRAINT NN2 NOT NULL,
COL3  BIGINT                  CONSTRAINT NN3 NOT NULL,
COL4  INT8                    CONSTRAINT NN4 NOT NULL,
COL5  REAL                    CONSTRAINT NN5 NOT NULL,
COL6  FLOAT4                  CONSTRAINT NN6 NOT NULL,
COL7  DOUBLE PRECISION        CONSTRAINT NN7 NOT NULL,
COL8  FLOAT8                  CONSTRAINT NN8 NOT NULL,
COL9  CHAR                    CONSTRAINT NN9 NOT NULL,
COL10 CHAR(1000)              CONSTRAINT NN10 NOT NULL,
COL11 CHARACTER               CONSTRAINT NN11 NOT NULL,
COL12 CHARACTER(1000)         CONSTRAINT NN12 NOT NULL,
COL13 VARCHAR                 CONSTRAINT NN13 NOT NULL,
COL14 VARCHAR(1000)           CONSTRAINT NN14 NOT NULL,
COL15 CHARACTER VARYING       CONSTRAINT NN15 NOT NULL,
COL16 CHARACTER VARYING(1000) CONSTRAINT NN16 NOT NULL
);

create table tmp.ccpkey_lower (
col0  integer                 constraint nn0 not null,
col1  int                     constraint nn1 not null,
col2  int4                    constraint nn2 not null,
col3  bigint                  constraint nn3 not null,
col4  int8                    constraint nn4 not null,
col5  real                    constraint nn5 not null,
col6  float4                  constraint nn6 not null,
col7  double precision        constraint nn7 not null,
col8  float8                  constraint nn8 not null,
col9  char                    constraint nn9 not null,
col10 char(1000)              constraint nn10 not null,
col11 character               constraint nn11 not null,
col12 character(1000)         constraint nn12 not null,
col13 varchar                 constraint nn13 not null,
col14 varchar(1000)           constraint nn14 not null,
col15 character varying       constraint nn15 not null,
col16 character varying(1000) constraint nn16 not null primary key
);

CREATE TABLE TMP.pkey_all_column (
COL0  INTEGER                 ,
COL1  INT                     ,
COL2  INT4                    ,
COL3  BIGINT                  ,
COL4  INT8                    ,
COL5  REAL                    ,
COL6  FLOAT4                  ,
COL7  DOUBLE PRECISION        ,
COL8  FLOAT8                  ,
COL9  CHAR                    ,
COL10 CHAR(1000)              ,
COL11 CHARACTER               ,
COL12 CHARACTER(1000)         ,
COL13 VARCHAR                 ,
COL14 VARCHAR(1000)           ,
COL15 CHARACTER VARYING       ,
COL16 CHARACTER VARYING(1000) ,
CONSTRAINT pkey_all_column_pk
PRIMARY KEY(COL0 ,COL1 ,COL2 ,COL3 ,COL4 ,COL5 ,COL6 ,COL7 ,COL8 ,COL9 ,COL10,COL11,COL12,COL13,COL14,COL15,COL16 )
);

create table tmp.order1 (
  ol_w_id int ,
  ol_d_id char(1),
  ol_o_id int,
  ol_number int not null primary key
);

create table tmp.order2 (
  ã‚«ãƒ©ãƒ  int
);

create table tmp.order3 (
  o int
);

DROP SCHEMA tmp CASCADE;

\c postgres

DROP DATABASE test;

CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

-- default constraint
CREATE TABLE tmp.customer2 (
  "c_credit" char(2) DEFAULT "apple"
);

-- default constraint
CREATE TABLE tmp.customer3 (
  id serial
);

-- multiple column pkey
create table tmp.oorder1 (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int not null primary key,
  ol_number int not null primary key
);

-- same column name
create table tmp.oorder2 (
  ol_w_id int,
  ol_w_id int,
  ol_o_id int,
  ol_number int not null primary key
);

create table tmp.oorder3 (
  ol_w_id int,
  ol_d_id varchar(),
  ol_o_id int,
  ol_number int not null primary key
);

create table tmp.order4 (
  ol_w_id int ,
  ol_d_id varchar(0),
  ol_o_id int,
  ol_number int not null primary key
);

create table tmp.oorder5 (
  ol_w_id,
  ol_d_id varchar(100),
  ol_o_id int,
  ol_number int not null primary key
);

create table tmp.order6 (
  int
);

create table (
  column int
);

create table tmp.order7 (
  ol_w_id int ,
  ol_d_id char(0),
  ol_o_id int,
  ol_number int not null primary key
);

create table tmp.order8 (
  1 int
);

create table tmp.order9 (
  ??? int
);

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
);

CREATE SCHEMA tmp2;

create table tmp2.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
);

CREATE DATABASE test2 TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test2

create table oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
);

CREATE SCHEMA tmp;

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
);

create table tmp.oorder (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
);

CREATE TABLE TMP.pkey_not_specified (
COL0  INTEGER                 ,
COL1  INT                     ,
COL2  INT4                    ,
COL3  BIGINT                  ,
COL4  INT8                    ,
COL5  REAL                    ,
COL6  FLOAT4                  ,
COL7  DOUBLE PRECISION        ,
COL8  FLOAT8                  ,
COL9  CHAR                    ,
COL10 CHAR(1000)              ,
COL11 CHARACTER               ,
COL12 CHARACTER(1000)         ,
COL13 VARCHAR                 ,
COL14 VARCHAR(1000)           ,
COL15 CHARACTER VARYING       ,
COL16 CHARACTER VARYING(1000) ,
CONSTRAINT pkey_not_specified PRIMARY KEY()
);

CREATE TABLE TMP.pkey_not_exists (
COL0  INTEGER                 ,
COL1  INT                     ,
COL2  INT4                    ,
COL3  BIGINT                  ,
COL4  INT8                    ,
COL5  REAL                    ,
COL6  FLOAT4                  ,
COL7  DOUBLE PRECISION        ,
COL8  FLOAT8                  ,
COL9  CHAR                    ,
COL10 CHAR(1000)              ,
COL11 CHARACTER               ,
COL12 CHARACTER(1000)         ,
COL13 VARCHAR                 ,
COL14 VARCHAR(1000)           ,
COL15 CHARACTER VARYING       ,
COL16 CHARACTER VARYING(1000) ,
CONSTRAINT pkey_not_specified PRIMARY KEY(COL17)
);

drop table oorder_dummy;

DROP SCHEMA tmp CASCADE;

\c test

DROP SCHEMA tmp CASCADE;
DROP SCHEMA tmp2 CASCADE;

\c postgres

DROP DATABASE test;
DROP DATABASE test2;
