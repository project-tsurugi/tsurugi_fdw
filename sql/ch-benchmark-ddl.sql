CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE EXTENSION ogawayama_fdw;
CREATE SERVER ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;

CREATE TABLE order_line (
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


CREATE TABLE new_order (
  no_w_id int NOT NULL,
  no_d_id int NOT NULL,
  no_o_id int NOT NULL,
  PRIMARY KEY (no_w_id,no_d_id,no_o_id)
) tablespace tsurugi;


CREATE TABLE stock (
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

CREATE TABLE orders (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY (o_w_id,o_d_id,o_id)
) tablespace tsurugi;


CREATE TABLE orders_secondary (
  o_d_id INT NOT NULL,
  o_w_id INT NOT NULL,
  o_c_id INT NOT NULL,
  o_id INT NOT NULL,
  PRIMARY KEY(o_w_id, o_d_id, o_c_id, o_id)
) tablespace tsurugi;

-- TODO: h_date ON UPDATE CURRENT_TIMESTAMP

CREATE TABLE history (
  h_c_id int NOT NULL,
  h_c_d_id int NOT NULL,
  h_c_w_id int NOT NULL,
  h_d_id int NOT NULL,
  h_w_id int NOT NULL,
  h_date char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  h_amount double precision NOT NULL, -- decimal(6,2) NOT NULL
  h_data varchar(24) NOT NULL
) tablespace tsurugi;


CREATE TABLE customer (
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


CREATE TABLE customer_secondary (
  c_d_id INT NOT NULL,
  c_w_id INT NOT NULL,
  c_last VARCHAR(16) NOT NULL,
  c_first VARCHAR(16) NOT NULL,
  c_id INT NOT NULL,
  PRIMARY KEY(c_w_id, c_d_id, c_last, c_first)
) tablespace tsurugi;


CREATE TABLE district (
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



CREATE TABLE item (
  i_id int NOT NULL,
  i_name varchar(24) NOT NULL,
  i_price double precision NOT NULL, -- decimal(5,2) NOT NULL
  i_data varchar(50) NOT NULL,
  i_im_id int NOT NULL,
  PRIMARY KEY (i_id)
) tablespace tsurugi;


CREATE TABLE warehouse (
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


CREATE TABLE nation (
    n_nationkey integer NOT NULL,
    n_name character(25) NOT NULL,
    n_regionkey integer NOT NULL,
    n_comment character(152) NOT NULL,
    PRIMARY KEY (n_nationkey)
) tablespace tsurugi;


CREATE TABLE supplier (
    su_suppkey integer NOT NULL,
    su_name character(25) NOT NULL,
    su_address character(40) NOT NULL,
    su_nationkey integer NOT NULL,
    su_phone character(15) NOT NULL,
    su_acctbal double precision NOT NULL, -- numeric(12,2) NOT NULL
    su_comment character(101) NOT NULL,
    PRIMARY KEY (su_suppkey)
) tablespace tsurugi;


CREATE TABLE region (
    r_regionkey integer NOT NULL,
    r_name character(55) NOT NULL,
    r_comment character(152) NOT NULL,
    PRIMARY KEY (r_regionkey)
) tablespace tsurugi;


CREATE FOREIGN TABLE order_line (
  ol_w_id int NOT NULL,
  ol_d_id int NOT NULL,
  ol_o_id int NOT NULL,
  ol_number int NOT NULL,
  ol_i_id int NOT NULL,
  ol_delivery_d char(24), -- timestamp NULL DEFAULT NULL
  ol_amount double precision NOT NULL, -- decimal(6,2) NOT NULL
  ol_supply_w_id int NOT NULL,
  ol_quantity double precision NOT NULL, -- decimal(2,0) NOT NULL
  ol_dist_info char(24) NOT NULL
) SERVER ogawayama;


CREATE FOREIGN TABLE new_order (
  no_w_id int NOT NULL,
  no_d_id int NOT NULL,
  no_o_id int NOT NULL
) SERVER ogawayama;


CREATE FOREIGN TABLE stock (
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
  s_dist_10 char(24) NOT NULL
) SERVER ogawayama;

-- TODO: o_entry_d  ON UPDATE CURRENT_TIMESTAMP

CREATE FOREIGN TABLE orders (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) SERVER ogawayama;


CREATE FOREIGN TABLE orders_secondary (
  o_d_id INT NOT NULL,
  o_w_id INT NOT NULL,
  o_c_id INT NOT NULL,
  o_id INT NOT NULL
) SERVER ogawayama;

-- TODO: h_date ON UPDATE CURRENT_TIMESTAMP

CREATE FOREIGN TABLE history (
  h_c_id int NOT NULL,
  h_c_d_id int NOT NULL,
  h_c_w_id int NOT NULL,
  h_d_id int NOT NULL,
  h_w_id int NOT NULL,
  h_date char(24) NOT NULL, -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  h_amount double precision NOT NULL, -- decimal(6,2) NOT NULL
  h_data varchar(24) NOT NULL
) SERVER ogawayama;


CREATE FOREIGN TABLE customer (
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


CREATE FOREIGN TABLE customer_secondary (
  c_d_id INT NOT NULL,
  c_w_id INT NOT NULL,
  c_last VARCHAR(16) NOT NULL,
  c_first VARCHAR(16) NOT NULL,
  c_id INT NOT NULL
) SERVER ogawayama;


CREATE FOREIGN TABLE district (
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
  d_zip char(9) NOT NULL
) SERVER ogawayama;



CREATE FOREIGN TABLE item (
  i_id int NOT NULL,
  i_name varchar(24) NOT NULL,
  i_price double precision NOT NULL, -- decimal(5,2) NOT NULL
  i_data varchar(50) NOT NULL,
  i_im_id int NOT NULL
) SERVER ogawayama;


CREATE FOREIGN TABLE warehouse (
  w_id int NOT NULL,
  w_ytd double precision NOT NULL, -- decimal(12,2) NOT NULL
  w_tax double precision NOT NULL, -- decimal(4,4) NOT NULL
  w_name varchar(10) NOT NULL,
  w_street_1 varchar(20) NOT NULL,
  w_street_2 varchar(20) NOT NULL,
  w_city varchar(20) NOT NULL,
  w_state char(2) NOT NULL,
  w_zip char(9) NOT NULL
) SERVER ogawayama;

-- Add table for ch-benchmark


CREATE FOREIGN TABLE nation (
    n_nationkey integer NOT NULL,
    n_name character(25) NOT NULL,
    n_regionkey integer NOT NULL,
    n_comment character(152) NOT NULL
) SERVER ogawayama;


CREATE FOREIGN TABLE supplier (
    su_suppkey integer NOT NULL,
    su_name character(25) NOT NULL,
    su_address character(40) NOT NULL,
    su_nationkey integer NOT NULL,
    su_phone character(15) NOT NULL,
    su_acctbal double precision NOT NULL, -- numeric(12,2) NOT NULL
    su_comment character(101) NOT NULL
) SERVER ogawayama;


CREATE FOREIGN TABLE region (
    r_regionkey integer NOT NULL,
    r_name character(55) NOT NULL,
    r_comment character(152) NOT NULL
) SERVER ogawayama;


SELECT * from order_line;
SELECT * from new_order;
SELECT * from stock;
SELECT * from orders;
SELECT * from orders_secondary;
SELECT * from history;
SELECT * from customer;
SELECT * from customer_secondary;
SELECT * from district;
SELECT * from item;
SELECT * from warehouse;
SELECT * from nation;
SELECT * from supplier;
SELECT * from region;

INSERT INTO order_line VALUES (974,1,1,1,49876,'2020-09-01 06:19:55',0.00,5,2.09,'ige');
INSERT INTO new_order VALUES (2920,1,1);
INSERT INTO new_order VALUES (2839,1,1);
INSERT INTO stock VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
INSERT INTO orders VALUES (974,1,1,1,8,7,1,'2020-09-01 06:19:55');
INSERT INTO orders_secondary VALUES (893,1,1,4);
INSERT INTO history VALUES (1,1,1,1,1,'2020-09-01 06:19:55',10.00,'?qO6YMvDuCVyQQ');
INSERT INTO customer VALUES (1,1,1,882711111,'OE','YGw89hId','BARBARBAR',50000.00,0.0135,-10.00,1,53,'kU1gw6cmC?b0','0Evto','WE9wusQn8MlIfyrWwIs','5Y','VlQIzx7Gl','0120-11111-12222','2020-09-01 06:19:55','GC','@GvTnhlqcYlW');
INSERT INTO customer_secondary VALUES (4,1,'bZK8UUzZk6OJQwbi','BARBARPRI',829611111);
INSERT INTO district VALUES (1,1,0.1224,30000.00,3001,'7KxYQrnz','5fg6lud','IHKgOEqlYdZ','2Jwyu80wQLC','Tn','HeUiU8zV2');
INSERT INTO item VALUES (1,'7KxYQrnz',0.1224,'5fg6lud3tkcnGw',185311111);
INSERT INTO warehouse VALUES (1,0.078,300000.00,'HO73DCcj6s','67oATAPEmE5','mM48NK@U7TQTK@Z@ma','sitmvvuwAzB','g5','405911111');
INSERT INTO nation VALUES (48,'ALGERIA',0,'the bravely busy theodolites will dazzle blithely according to the never silent');
INSERT INTO supplier VALUES (0,'Supplier#000000000','UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g',103,'10-520-573-2995',7942.04,' slyly on the sometimes permanent somas -- enticingly daring attai');
INSERT INTO region VALUES (0,'AFRICA',' ? closely enticing attainments around the quietly careful dinos may was idly over the slowly st');
INSERT INTO region VALUES (1,'AMERICA','the pearls : doggedly final platelets alongside of the quickly even pinto beans sh');
INSERT INTO region VALUES (2,'ASIA','s try to engage quickly past the regul');
INSERT INTO region VALUES (3,'EUROPE','ss the idly ironic somas ! evenly busy warthogs past the slyly even notornis must print q');
INSERT INTO region VALUES (4,'MIDDLE EAST','ructions ; quietly sly dolphins besi');

SELECT * from order_line;
SELECT * from new_order;
SELECT * from stock;
SELECT * from orders;
SELECT * from orders_secondary;
SELECT * from history;
SELECT * from customer;
SELECT * from customer_secondary;
SELECT * from district;
SELECT * from item;
SELECT * from warehouse;
SELECT * from nation;
SELECT * from supplier;
SELECT * from region;

\c postgres

DROP DATABASE test;
