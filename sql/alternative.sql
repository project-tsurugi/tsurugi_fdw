CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE EXTENSION ogawayama_fdw;
CREATE SERVER ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;

-- referred by FOREIGN KEY table constraint
DROP TABLE IF EXISTS customer_third;
CREATE TABLE customer_third (
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

-- referred by FOREIGN KEY table constraint
DROP TABLE IF EXISTS customer_forth;
CREATE TABLE customer_forth (
  c_d_id INT NOT NULL,
  c_w_id INT NOT NULL PRIMARY KEY,
  c_last VARCHAR(16) NOT NULL,
  c_first VARCHAR(16) NOT NULL,
  c_id INT NOT NULL
) tablespace tsurugi;

-- type error not supported
CREATE TABLE orders_type_error (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt decimal(2,0) NOT NULL,
  o_all_local decimal(1,0) NOT NULL,
  o_entry_d timestamp NOT NULL,
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

CREATE TABLE type_error_bigserial (
  col1 bigserial,
  col2 serial8
) tablespace tsurugi;

CREATE TABLE type_error_bit (
  col1 bit,
  col2 bit(1)
) tablespace tsurugi;

CREATE TABLE type_error_bit_varying (
  col1 bit varying,
  col2 bit varying(100),
  col3 varbit,
  col4 varbit(1)
) tablespace tsurugi;

CREATE TABLE type_error_bool (
  col1 boolean,
  col2 bool
) tablespace tsurugi;

CREATE TABLE type_error_box (
  col2 box
) tablespace tsurugi;

CREATE TABLE type_error_bytea (
  col3 bytea
) tablespace tsurugi;

CREATE TABLE type_error_cidr_circle_date_inet (
  col1 cidr,
  col2 circle,
  col3 date,
  col4 inet
) tablespace tsurugi;

CREATE TABLE type_error_interval (
  col1 interval,
  col2 interval YEAR,
  col3 interval YEAR TO MONTH,
  col4 interval HOUR,
  col5 interval SECOND(0),
  col6 interval MINUTE TO SECOND(6)
) tablespace tsurugi;

CREATE TABLE type_error_json (
  col1 json,
  col2 jsonb
) tablespace tsurugi;

CREATE TABLE type_error_line_lseg (
  col1 line,
  col2 lseg
) tablespace tsurugi;

CREATE TABLE type_error_macaddr_money (
  col1 macaddr,
  col2 money
) tablespace tsurugi;

CREATE TABLE type_error_numeric (
  col1 numeric,
  col2 numeric(1000),
  col3 numeric(1000,1000),
  col4 decimal,
  col5 decimal(1),
  col6 decimal(1000,1)
) tablespace tsurugi;

CREATE TABLE type_error_p (
  col1 path,
  col2 pg_lsn,
  col3 point,
  col4 polygon
) tablespace tsurugi;

CREATE TABLE type_error_small (
  col1 smallint,
  col2 int2,
  col3 smallserial,
  col4 serial2
) tablespace tsurugi;

CREATE TABLE type_error_serial (
  col1 serial
) tablespace tsurugi;

CREATE TABLE type_error_text (
  col1 text
) tablespace tsurugi;

CREATE TABLE type_error_time (
  col0 time,
  col1 time (0),
  col2 time (6),
  col3 time (0) without time zone,
  col4 time (6) without time zone,
  col5 time with time zone,
  col6 time (0) with time zone,
  col7 time (6) with time zone,
  col8 timestamp,
  col9 timestamp (0),
  col10 timestamp (6),
  col11 timestamp (0) without time zone,
  col12 timestamp (6) without time zone,
  col13 timestamp with time zone,
  col14 timestamp (0) with time zone,
  col15 timestamp (6) with time zone
) tablespace tsurugi;

CREATE TABLE type_error_all_other_than_above (
  col0 tsquery,
  col1 tsvector,
  col2 txid_snapshot,
  col3 uuid,
  col4 xml
) tablespace tsurugi;

-- varchar data length (n) is not specified
create table varchar (
  ol_w_id int,
  ol_d_id varchar,
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- varchar data length is empty
create table varchar_length_empty (
  ol_w_id int,
  ol_d_id varchar(),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- varchar data length is zero
create table varchar_length_0 (
  ol_w_id int ,
  ol_d_id varchar(0),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

create table varchar_length_empty (
  ol_w_id int,
  ol_d_id char(),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- char data length is zero
create table char_length_0 (
  ol_w_id int ,
  ol_d_id char(0),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- type of ol_w_id is not specified
create table type_is_not_specified (
  ol_w_id,
  ol_d_id varchar(100),
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- TEMP TABLE
create temp table temptbl (
  id integer,
  name varchar(10)
) tablespace tsurugi;

create temporary table temporarytbl (
  id integer,
  name varchar(10)
) tablespace tsurugi;

-- UNLOGGED TABLE
create unlogged table unloggedtbl (
  id integer,
  name varchar(10)
) tablespace tsurugi;

-- COLLATE column
CREATE TABLE distributors_unique_cc (
    did     varchar(1000) COLLATE "C"
) tablespace tsurugi;

-- LIKE clause
CREATE TABLE customer_copied (
    LIKE customer_third
) tablespace tsurugi;

-- LIKE INCLUDING ALL
CREATE TABLE customer_copied_including (
    LIKE customer_third INCLUDING ALL
) tablespace tsurugi;

-- LIKE EXCLUDING
CREATE TABLE customer_copied_excluding (
    LIKE customer_third EXCLUDING CONSTRAINTS
) tablespace tsurugi;

-- LIKE clause refers to no table
CREATE TABLE customer_copied_failed (
    LIKE customer_dummy
) tablespace tsurugi;

-- LIKE INCLUDING ALL refers to no table
CREATE TABLE customer_copied_including_failed (
    LIKE customer_dummy INCLUDING ALL
) tablespace tsurugi;

-- LIKE EXCLUDING refers to no table
CREATE TABLE customer_copied_excluding_failed (
    LIKE customer_dummy EXCLUDING CONSTRAINTS
) tablespace tsurugi;

-- INHERITS clause
-- parent table
CREATE TABLE cities (
    name            varchar(1000),
    population      float,
    altitude        int     -- in feet
) tablespace tsurugi;

-- INHERITS clause (child table)
CREATE TABLE capitals (
    state           char(2)
) INHERITS (cities) tablespace tsurugi;

-- INHERITS clause (child table) inherit no table
CREATE TABLE capitals_fail_to_inherit (
    state           char(2)
) INHERITS (cities) tablespace tsurugi;

-- PARTITION BY RANGE
CREATE TABLE measurement (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) PARTITION BY RANGE (logdate) tablespace tsurugi;

-- PARTITION BY RANGE COLLATE
CREATE TABLE measurement_collate (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) PARTITION BY RANGE (logdate COLLATE "C") tablespace tsurugi;

CREATE TABLE measurement_y2016m07
PARTITION OF measurement
FOR VALUES FROM ('2016-07-01') TO ('2016-08-01') tablespace tsurugi;

CREATE TABLE measurement_y2016m07_of_no_table
PARTITION OF measurement
FOR VALUES FROM ('2016-07-01') TO ('2016-08-01') tablespace tsurugi;

-- PARTITION BY LIST
CREATE TABLE cities (
    city_id      bigint not null,
    name         varchar(1000) not null,
    population   bigint
) PARTITION BY LIST (name) tablespace tsurugi;

CREATE TABLE cities_ab
PARTITION OF cities
FOR VALUES IN ('a', 'b') tablespace tsurugi;

CREATE TABLE cities_ab_of_no_table
PARTITION OF cities
FOR VALUES IN ('a', 'b') tablespace tsurugi;

-- PARTITION BY HASH
CREATE TABLE orders_partition_by_hash (
    order_id     bigint not null,
    cust_id      bigint not null,
    status       varchar(1000)
) PARTITION BY HASH (order_id) tablespace tsurugi;

CREATE TABLE orders_p1 PARTITION OF orders_partition_by_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 0) tablespace tsurugi;

CREATE TABLE orders_p1_of_no_table PARTITION OF orders_partition_by_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 0) tablespace tsurugi;

-- USING method
CREATE ACCESS METHOD myheap TYPE TABLE HANDLER heap_tableam_handler;
CREATE TABLE t_myheap (
    id int, v text
) USING myheap tablespace tsurugi;

-- WITH clause of table
CREATE TABLE distributors_table_with (
    did     integer,
    name    varchar(40)
)
WITH (fillfactor=70) tablespace tsurugi;

-- ON COMMIT PRESERVE ROWS
create global temporary table oncommit_prows (
  id int not null primary key,
  txt varchar(32)
)
on commit preserve rows tablespace tsurugi;

-- ON COMMIT DELETE ROWS
create global temporary table oncommit_drows (
  id int not null primary key,
  txt varchar(32)
)
on commit delete rows tablespace tsurugi;

-- ON COMMIT DROP
create global temporary table oncommit_drop (
  id int not null primary key,
  txt varchar(32)
)
on commit drop tablespace tsurugi;

-- OF clause
CREATE TYPE employee_type AS (name text, salary numeric);
CREATE TABLE employees OF employee_type (
    PRIMARY KEY (name),
    salary
) tablespace tsurugi;

-- *** column constraint ***
-- NULL column constraint
CREATE TABLE orders_null_cc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int NULL,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

-- CHECK column constraint
CREATE TABLE distributors_check_cc (
    did     integer CHECK (did > 100),
    name    varchar(40)
) tablespace tsurugi;

-- CHECK column constraint NO INHERIT
CREATE TABLE distributors_check_cc_ni (
    did     integer CHECK (did > 100) NO INHERIT,
    name    varchar(40)
) tablespace tsurugi;

-- DEFAULT column constraint
CREATE TABLE orders_default_cc (
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

-- GENERATED ALWAYS AS
CREATE TABLE generated_always_as (
    x float,
    y float,
    "(x + y)" float GENERATED ALWAYS AS (x + y) STORED,
    "(x - y)" float GENERATED ALWAYS AS (x - y) STORED,
    "(x * y)" float GENERATED ALWAYS AS (x * y) STORED,
    "(x / y)" float GENERATED ALWAYS AS (x / y) STORED
) tablespace tsurugi;

-- GENERATED BY DEFAULT AS IDENTITY
CREATE TABLE distributors_generated_by_default (
     did    integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
     name   varchar(40) NOT NULL
) tablespace tsurugi;

-- GENERATED ALWAYS AS IDENTITY
CREATE TABLE distributors_generated_always (
     did    integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
     name   varchar(40) NOT NULL
) tablespace tsurugi;

-- UNIQUE column constraint
CREATE TABLE distributors_unique_cc_collate (
    did     integer,
    name    varchar(40) UNIQUE
) tablespace tsurugi;

-- PRIMARY KEY WITH
CREATE TABLE distributors_pkey_cc_include (
    id             integer PRIMARY KEY WITH (fillfactor=70),
    first_name     varchar(1000),
    last_name      varchar(1000)
) tablespace tsurugi;

-- PRIMARY KEY USING INDEX
CREATE TABLE distributors_pkey_cc_using_index (
    id             integer PRIMARY KEY USING INDEX TABLESPACE tsurugi,
    first_name     varchar(1000),
    last_name      varchar(1000)
) tablespace tsurugi;

CREATE TABLE distributors_pkey_cc_using_index_syntax_error (
    id             integer PRIMARY KEY USING INDEX,
    first_name     varchar(1000),
    last_name      varchar(1000)
) tablespace tsurugi;

-- FOREIGN KEY column constraint
CREATE TABLE orders_fkey_cc (
  o_w_id int NOT NULL REFERENCES customer_forth (c_w_id),
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

CREATE TABLE orders_fkey_cc_no_unique_pkey (
  o_w_id int NOT NULL REFERENCES customer_forth (c_w_id),
  o_d_id int NOT NULL REFERENCES customer_forth (c_d_id),
  o_id int NOT NULL REFERENCES customer_forth (c_id),
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

CREATE TABLE orders_fkey_cc_refers_to_no_table (
  o_w_id int NOT NULL REFERENCES customer_does_not_exist (c_w_id),
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

-- FOREIGN KEY column constraint MATCH FULL
CREATE TABLE orders_fkey_cc_mf (
  o_w_id int NOT NULL REFERENCES customer_forth (c_w_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

CREATE TABLE orders_fkey_cc_mf_no_unique_pkey (
  o_w_id int NOT NULL REFERENCES customer_forth (c_w_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
  o_d_id int NOT NULL REFERENCES customer_forth (c_d_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
  o_id int NOT NULL REFERENCES customer_forth (c_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

CREATE TABLE orders_fkey_cc_mf_refers_to_no_table (
  o_w_id int NOT NULL REFERENCES customer_does_not_exist (c_w_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

-- FOREIGN KEY column constraint MATCH PARTIAL
CREATE TABLE orders_fkey_cc_mp (
  o_w_id int NOT NULL REFERENCES customer_forth (c_w_id) MATCH PARTIAL ON UPDATE NO ACTION ON DELETE NO ACTION,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

CREATE TABLE orders_fkey_cc_mp_no_unique_pkey (
  o_w_id int NOT NULL REFERENCES customer_forth (c_w_id) MATCH PARTIAL ON UPDATE NO ACTION ON DELETE NO ACTION,
  o_d_id int NOT NULL REFERENCES customer_forth (c_d_id) MATCH PARTIAL ON UPDATE NO ACTION ON DELETE NO ACTION,
  o_id int NOT NULL REFERENCES customer_forth (c_id) MATCH PARTIAL ON UPDATE NO ACTION ON DELETE NO ACTION,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

-- FOREIGN KEY column constraint MATCH SIMPLE
CREATE TABLE orders_fkey_cc_ms (
  o_w_id int REFERENCES customer_forth (c_w_id) MATCH SIMPLE ON UPDATE SET NULL ON DELETE SET NULL,
  o_d_id int,
  o_id int,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

CREATE TABLE orders_fkey_cc_ms_no_unique_pkey (
  o_w_id int REFERENCES customer_forth (c_w_id) MATCH SIMPLE ON UPDATE SET NULL ON DELETE SET NULL,
  o_d_id int REFERENCES customer_forth (c_d_id) MATCH SIMPLE ON UPDATE SET NULL ON DELETE SET NULL,
  o_id int REFERENCES customer_forth (c_id) MATCH SIMPLE ON UPDATE SET NULL ON DELETE SET NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;

-- DEFERRABLE INITIALLY DEFERRED column constraint
CREATE TABLE deferrable_initially_deferred_cc(
    id integer PRIMARY KEY DEFERRABLE INITIALLY DEFERRED
) tablespace tsurugi;

-- DEFERRABLE INITIALLY IMMEDIATE column constraint
CREATE TABLE deferrable_initially_immediate_cc(
    id integer PRIMARY KEY DEFERRABLE INITIALLY IMMEDIATE
) tablespace tsurugi;

-- DEFERRABLE column constraint
CREATE TABLE deferrable_cc(
    id integer PRIMARY KEY DEFERRABLE
) tablespace tsurugi;

-- NOT DEFERRABLE column constraint
CREATE TABLE not_deferrable_cc(
    id integer PRIMARY KEY NOT DEFERRABLE
) tablespace tsurugi;

-- *** table constraint ***
-- CHECK table constraint
CREATE TABLE distributors_check_tc (
    did     integer,
    name    varchar(40),
    CONSTRAINT con1 CHECK (did > 100 AND name <> '')
) tablespace tsurugi;

-- CHECK table constraint NO INHERIT
CREATE TABLE distributors_check_tc_ni (
    did     integer,
    name    varchar(40),
    CONSTRAINT con1 CHECK (did > 100 AND name <> '') NO INHERIT
) tablespace tsurugi;

-- UNIQUE table constraint
CREATE TABLE orders_unique_tc (
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
) tablespace tsurugi;

-- WITH clause
CREATE TABLE distributors_column_with (
    did     integer,
    name    varchar(40),
    PRIMARY KEY(name) WITH (fillfactor=70)
) tablespace tsurugi;

-- PRIMARY KEY INCLUDE
CREATE TABLE distributors_pkey_tc_include (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000),
    PRIMARY KEY(id) INCLUDE (first_name,last_name)
) tablespace tsurugi;

-- PRIMARY KEY USING INDEX
CREATE TABLE distributors_pkey_tc_using_index (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000),
    PRIMARY KEY(id) USING INDEX TABLESPACE tsurugi
) tablespace tsurugi;

CREATE TABLE distributors_pkey_tc_using_index_syntax_error (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000),
    PRIMARY KEY(id) USING INDEX
) tablespace tsurugi;

-- EXCLUDE USING
CREATE TABLE distributotrs_exclude_using (
    name varchar(1000),
    age integer,
    EXCLUDE USING btree (age WITH =)
) tablespace tsurugi;

CREATE TABLE distributotrs_exclude_using_failed (
    name varchar(1000),
    age integer,
    EXCLUDE USING gist (age WITH <>)
) tablespace tsurugi;

CREATE TABLE distributotrs_exclude_using_where (
    name varchar(1000),
    age integer,
    EXCLUDE USING btree (age WITH =) WHERE (age between 0 and 200)
) tablespace tsurugi;

CREATE TABLE distributotrs_exclude_using_where_failed (
    name varchar(1000),
    age integer,
    EXCLUDE USING gist (age WITH <>) WHERE (age between 0 and 200)
) tablespace tsurugi;

create table account_exclude_using_op_class
(
  MANUAL_NO         VARCHAR(12),
  EXCLUDE USING btree (MANUAL_NO varchar_pattern_ops WITH =)
) tablespace tsurugi;

create table account_exclude_using_op_class_desc_nulls_last
(
  MANUAL_NO         VARCHAR(12),
  EXCLUDE USING btree (MANUAL_NO varchar_pattern_ops DESC NULLS LAST WITH =)
) tablespace tsurugi;

-- FOREIGN KEY table constraint
CREATE TABLE orders_fkey_tc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES customer_third(c_w_id,c_d_id,c_id)
) tablespace tsurugi;

CREATE TABLE orders_fkey_tc_fail_to_refer (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES customer_third(c_w_id,c_d_id,c_id)
) tablespace tsurugi;

-- FOREIGN KEY table constraint
CREATE TABLE orders_fkey_tc_mf (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES customer_third(c_w_id,c_d_id,c_id)
  MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT
) tablespace tsurugi;

CREATE TABLE orders_fkey_tc_mf_fail_to_refer (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES customer_third(c_w_id,c_d_id,c_id)
  MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT
) tablespace tsurugi;

-- FOREIGN KEY table constraint
CREATE TABLE orders_fkey_tc_mp (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES customer_third(c_w_id,c_d_id,c_id)
  MATCH PARTIAL ON UPDATE SET DEFAULT ON DELETE SET DEFAULT
) tablespace tsurugi;

-- FOREIGN KEY table constraint
CREATE TABLE orders_fkey_tc_ms (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id),
  FOREIGN KEY(o_w_id,o_d_id,o_c_id) REFERENCES customer_third(c_w_id,c_d_id,c_id)
  MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
) tablespace tsurugi;

-- DEFERRABLE INITIALLY DEFERRED
CREATE TABLE deferrable_initially_deferred_tc(
    id integer NOT NULL,
    CONSTRAINT deferrable_initially_deferred_tc_pk PRIMARY KEY (id) DEFERRABLE INITIALLY DEFERRED
) tablespace tsurugi;

-- DEFERRABLE INITIALLY IMMEDIATE
CREATE TABLE deferrable_initially_immediate_tc(
    id integer NOT NULL,
    CONSTRAINT deferrable_initially_immediate_tc_pk PRIMARY KEY (id) DEFERRABLE INITIALLY IMMEDIATE
) tablespace tsurugi;

CREATE TABLE deferrable_initially_immediate_tc_pk_exists (
    id integer NOT NULL,
    CONSTRAINT deferrable_initially_deferred_tc_pk PRIMARY KEY (id) DEFERRABLE INITIALLY IMMEDIATE
) tablespace tsurugi;

-- DEFERRABLE
CREATE TABLE deferrable_tc(
    id integer NOT NULL,
    CONSTRAINT deferrable_tc_pk PRIMARY KEY (id) DEFERRABLE
) tablespace tsurugi;

-- referred by FOREIGN KEY table constraint
CREATE FOREIGN TABLE customer_third (
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
  c_data varchar(500) NOT NULL
) SERVER ogawayama;

-- referred by FOREIGN KEY table constraint
CREATE FOREIGN TABLE customer_forth (
  c_d_id INT NOT NULL,
  c_w_id INT NOT NULL,
  c_last VARCHAR(16) NOT NULL,
  c_first VARCHAR(16) NOT NULL,
  c_id INT NOT NULL
) SERVER ogawayama;

CREATE FOREIGN TABLE cities (
    name            varchar(1000),
    population      float,
    altitude        int     -- in feet
) SERVER ogawayama;

SELECT * FROM customer_third;
SELECT * FROM customer_forth;
SELECT * FROM cities;

\c postgres

DROP DATABASE test;
