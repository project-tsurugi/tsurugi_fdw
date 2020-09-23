CREATE EXTENSION IF NOT EXISTS ogawayama_fdw;
CREATE SERVER IF NOT EXISTS ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;

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
  h_c_id int NOT NULL PRIMARY KEY, -- actually this table don't have PRIMARY KEY constraint.
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

SELECT * from order_line;
INSERT INTO order_line(ol_d_id,ol_o_id,ol_number,ol_i_id,ol_delivery_d,ol_amount,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (1,1,1,49876,'2020-09-01 06:19:55',0.00,5,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_o_id,ol_number,ol_i_id,ol_delivery_d,ol_amount,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (974,1,1,49876,'2020-09-01 06:19:55',0.00,5,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_number,ol_i_id,ol_delivery_d,ol_amount,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (974,1,1,49876,'2020-09-01 06:19:55',0.00,5,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_i_id,ol_delivery_d,ol_amount,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (974,1,1,49876,'2020-09-01 06:19:55',0.00,5,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_number,ol_delivery_d,ol_amount,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (974,1,1,1,'2020-09-01 06:19:55',0.00,5,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_number,ol_i_id,ol_amount,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (974,1,1,1,49876,0.00,5,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_number,ol_i_id,ol_delivery_d,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (974,1,1,1,49876,'2020-09-01 06:19:55',5,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_number,ol_i_id,ol_delivery_d,ol_amount,ol_quantity,ol_dist_info) VALUES (974,1,1,1,49876,'2020-09-01 06:19:55',0.00,2.09,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_number,ol_i_id,ol_delivery_d,ol_amount,ol_supply_w_id,ol_dist_info) VALUES (974,1,1,1,49876,'2020-09-01 06:19:55',0.00,5,'ige');
SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_number,ol_i_id,ol_delivery_d,ol_amount,ol_supply_w_id,ol_quantity) VALUES (974,1,1,1,49876,'2020-09-01 06:19:55',0.00,5,2.09);
SELECT * from order_line;
SELECT * from new_order;
INSERT INTO new_order(no_d_id,no_o_id) VALUES (1,1);
SELECT * from new_order;
INSERT INTO new_order(no_w_id,no_o_id) VALUES (2920,1);
SELECT * from new_order;
INSERT INTO new_order(no_w_id,no_d_id) VALUES (2920,1);
SELECT * from new_order;
SELECT * from stock;
INSERT INTO stock(s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_06,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','25s0by','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_07,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','F5is3TawH','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_08,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','jYjPHA','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_09,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','Aidr','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_10) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','sB09');
SELECT * from stock;
INSERT INTO stock(s_w_id,s_i_id,s_quantity,s_ytd,s_order_cnt,s_remote_cnt,s_data,s_dist_01,s_dist_02,s_dist_03,s_dist_04,s_dist_05,s_dist_06,s_dist_07,s_dist_08,s_dist_09) VALUES (1,1,73,0,0,1,'v7HGGr','fk5m8','ItiMb?','o@Kqn','D8CTTn','Djuyt6','25s0by','F5is3TawH','jYjPHA','Aidr');
SELECT * from stock;
SELECT * from orders;
INSERT INTO orders(o_d_id,o_id,o_c_id,o_carrier_id,o_ol_cnt,o_all_local,o_entry_d) VALUES (1,1,1,8,7,1,'2020-09-01 06:19:55');
SELECT * from orders;
INSERT INTO orders(o_w_id,o_id,o_c_id,o_carrier_id,o_ol_cnt,o_all_local,o_entry_d) VALUES (974,1,1,8,7,1,'2020-09-01 06:19:55');
SELECT * from orders;
INSERT INTO orders(o_w_id,o_d_id,o_c_id,o_carrier_id,o_ol_cnt,o_all_local,o_entry_d) VALUES (974,1,1,8,7,1,'2020-09-01 06:19:55');
SELECT * from orders;
INSERT INTO orders(o_w_id,o_d_id,o_id,o_carrier_id,o_ol_cnt,o_all_local,o_entry_d) VALUES (974,1,1,8,7,1,'2020-09-01 06:19:55');
SELECT * from orders;
INSERT INTO orders(o_w_id,o_d_id,o_id,o_c_id,o_ol_cnt,o_all_local,o_entry_d) VALUES (974,1,1,1,7,1,'2020-09-01 06:19:55');
SELECT * from orders;
INSERT INTO orders(o_w_id,o_d_id,o_id,o_c_id,o_carrier_id,o_all_local,o_entry_d) VALUES (974,1,1,1,8,1,'2020-09-01 06:19:55');
SELECT * from orders;
INSERT INTO orders(o_w_id,o_d_id,o_id,o_c_id,o_carrier_id,o_ol_cnt,o_entry_d) VALUES (974,1,1,1,8,7,'2020-09-01 06:19:55');
SELECT * from orders;
INSERT INTO orders(o_w_id,o_d_id,o_id,o_c_id,o_carrier_id,o_ol_cnt,o_all_local) VALUES (974,1,1,1,8,7,1);
SELECT * from orders;
SELECT * from orders_secondary;
INSERT INTO orders_secondary(o_d_id,o_c_id,o_id) VALUES (1,1,4);
SELECT * from orders_secondary;
INSERT INTO orders_secondary(o_w_id,o_c_id,o_id) VALUES (893,1,4);
SELECT * from orders_secondary;
INSERT INTO orders_secondary(o_w_id,o_d_id,o_id) VALUES (893,1,4);
SELECT * from orders_secondary;
INSERT INTO orders_secondary(o_w_id,o_d_id,o_c_id) VALUES (893,1,1);
SELECT * from orders_secondary;
SELECT * from history;
INSERT INTO history(h_c_d_id,h_c_w_id,h_d_id,h_w_id,h_date,h_amount,h_data) VALUES ( 1, 1, 1, 1, '2020-09-01 06:19:55', 10.00, '?qO6YMvDuCVyQQ');
SELECT * from history;
INSERT INTO history(h_c_id,h_c_w_id,h_d_id,h_w_id,h_date,h_amount,h_data) VALUES (1, 1, 1, 1, '2020-09-01 06:19:55', 10.00, '?qO6YMvDuCVyQQ');
SELECT * from history;
INSERT INTO history(h_c_id,h_c_d_id,h_d_id,h_w_id,h_date,h_amount,h_data) VALUES (1, 1, 1, 1, '2020-09-01 06:19:55', 10.00, '?qO6YMvDuCVyQQ');
SELECT * from history;
INSERT INTO history(h_c_id,h_c_d_id,h_c_w_id,h_w_id,h_date,h_amount,h_data) VALUES (1, 1, 1, 1, '2020-09-01 06:19:55', 10.00, '?qO6YMvDuCVyQQ');
SELECT * from history;
INSERT INTO history(h_c_id,h_c_d_id,h_c_w_id,h_d_id,h_date,h_amount,h_data) VALUES (1, 1, 1, 1, '2020-09-01 06:19:55', 10.00, '?qO6YMvDuCVyQQ');
SELECT * from history;
INSERT INTO history(h_c_id,h_c_d_id,h_c_w_id,h_d_id,h_w_id,h_amount,h_data) VALUES (1, 1, 1, 1, 1, 10.00, '?qO6YMvDuCVyQQ');
SELECT * from history;
INSERT INTO history(h_c_id,h_c_d_id,h_c_w_id,h_d_id,h_w_id,h_date,h_data) VALUES (1, 1, 1, 1, 1, '2020-09-01 06:19:55', '?qO6YMvDuCVyQQ');
SELECT * from history;
INSERT INTO history(h_c_id,h_c_d_id,h_c_w_id,h_d_id,h_w_id,h_date,h_amount) VALUES (1, 1, 1, 1, 1, '2020-09-01 06:19:55', 10.00);
SELECT * from history;
SELECT * from customer;
INSERT INTO customer(c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES ( 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_city,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_state,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_zip,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_phone,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', '0120-11111-12222', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_since,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '2020-09-01 06:19:55', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_middle,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', 'GC', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_data) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', '@GvTnhlqcYlW');
SELECT * from customer;
INSERT INTO customer(c_w_id,c_d_id,c_id,c_discount,c_credit,c_last,c_first,c_credit_lim,c_balance,c_ytd_payment,c_payment_cnt,c_delivery_cnt,c_street_1,c_street_2,c_city,c_state,c_zip,c_phone,c_since,c_middle) VALUES (1, 1, 1, 882711111, 'OE', 'YGw89hId', 'BARBARBAR', 50000.00, 0.0135, -10.00, 1, 53, 'kU1gw6cmC?b0', '0Evto', 'WE9wusQn8MlIfyrWwIs', '5Y', 'VlQIzx7Gl', '0120-11111-12222', '2020-09-01 06:19:55', 'GC');
SELECT * from customer;
SELECT * from customer_secondary;
INSERT INTO customer_secondary(c_w_id,c_last,c_first,c_id) VALUES ( 1, 'bZK8UUzZk6OJQwbi','BARBARPRI', 829611111);
SELECT * from customer_secondary;
INSERT INTO customer_secondary(c_d_id,c_last,c_first,c_id) VALUES (4, 'bZK8UUzZk6OJQwbi','BARBARPRI', 829611111);
SELECT * from customer_secondary;
INSERT INTO customer_secondary(c_d_id,c_w_id,c_first,c_id) VALUES (4, 1,'BARBARPRI', 829611111);
SELECT * from customer_secondary;
INSERT INTO customer_secondary(c_d_id,c_w_id,c_last,c_id) VALUES (4, 1, 'bZK8UUzZk6OJQwbi', 829611111);
SELECT * from customer_secondary;
INSERT INTO customer_secondary(c_d_id,c_w_id,c_last,c_first) VALUES (4, 1, 'bZK8UUzZk6OJQwbi','BARBARPRI');
SELECT * from customer_secondary;
SELECT * from district;
INSERT INTO district(d_id,d_ytd,d_tax,d_next_o_id,d_name,d_street_1,d_street_2,d_city,d_state,d_zip) VALUES ( 1, 0.1224, 30000.00, 3001, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_ytd,d_tax,d_next_o_id,d_name,d_street_1,d_street_2,d_city,d_state,d_zip) VALUES (1, 0.1224, 30000.00, 3001, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_tax,d_next_o_id,d_name,d_street_1,d_street_2,d_city,d_state,d_zip) VALUES (1, 1, 30000.00, 3001, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_next_o_id,d_name,d_street_1,d_street_2,d_city,d_state,d_zip) VALUES (1, 1, 0.1224, 3001, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_tax,d_name,d_street_1,d_street_2,d_city,d_state,d_zip) VALUES (1, 1, 0.1224, 30000.00, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_tax,d_next_o_id,d_street_1,d_street_2,d_city,d_state,d_zip) VALUES (1, 1, 0.1224, 30000.00, 3001, '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_tax,d_next_o_id,d_name,d_street_2,d_city,d_state,d_zip) VALUES (1, 1, 0.1224, 30000.00, 3001, '7KxYQrnz', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_tax,d_next_o_id,d_name,d_street_1,d_city,d_state,d_zip) VALUES (1, 1, 0.1224, 30000.00, 3001, '7KxYQrnz', '5fg6lud', '2Jwyu80wQLC', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_tax,d_next_o_id,d_name,d_street_1,d_street_2,d_state,d_zip) VALUES (1, 1, 0.1224, 30000.00, 3001, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', 'Tn', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_tax,d_next_o_id,d_name,d_street_1,d_street_2,d_city,d_zip) VALUES (1, 1, 0.1224, 30000.00, 3001, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'HeUiU8zV2');
SELECT * from district;
INSERT INTO district(d_w_id,d_id,d_ytd,d_tax,d_next_o_id,d_name,d_street_1,d_street_2,d_city,d_state) VALUES (1, 1, 0.1224, 30000.00, 3001, '7KxYQrnz', '5fg6lud', 'IHKgOEqlYdZ', '2Jwyu80wQLC', 'Tn');
SELECT * from district;
SELECT * from item;
INSERT INTO item(i_name,i_price,i_data,i_im_id) VALUES ( '7KxYQrnz', 0.1224, '5fg6lud3tkcnGw', 185311111);
SELECT * from item;
INSERT INTO item(i_id,i_price,i_data,i_im_id) VALUES (1, 0.1224, '5fg6lud3tkcnGw', 185311111);
SELECT * from item;
INSERT INTO item(i_id,i_name,i_data,i_im_id) VALUES (1, '7KxYQrnz', '5fg6lud3tkcnGw', 185311111);
SELECT * from item;
INSERT INTO item(i_id,i_name,i_price,i_im_id) VALUES (1, '7KxYQrnz', 0.1224, 185311111);
SELECT * from item;
INSERT INTO item(i_id,i_name,i_price,i_data) VALUES (1, '7KxYQrnz', 0.1224, '5fg6lud3tkcnGw');
SELECT * from item;
SELECT * from warehouse;
INSERT INTO warehouse(w_ytd,w_tax,w_name,w_street_1,w_street_2,w_city,w_state,w_zip) VALUES ( 0.078, 300000.00, 'HO73DCcj6s', '67oATAPEmE5', 'mM48NK@U7TQTK@Z@ma', 'sitmvvuwAzB', 'g5', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_tax,w_name,w_street_1,w_street_2,w_city,w_state,w_zip) VALUES (1, 300000.00, 'HO73DCcj6s', '67oATAPEmE5', 'mM48NK@U7TQTK@Z@ma', 'sitmvvuwAzB', 'g5', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_ytd,w_name,w_street_1,w_street_2,w_city,w_state,w_zip) VALUES (1, 0.078, 'HO73DCcj6s', '67oATAPEmE5', 'mM48NK@U7TQTK@Z@ma', 'sitmvvuwAzB', 'g5', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_ytd,w_tax,w_street_1,w_street_2,w_city,w_state,w_zip) VALUES (1, 0.078, 300000.00, '67oATAPEmE5', 'mM48NK@U7TQTK@Z@ma', 'sitmvvuwAzB', 'g5', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_ytd,w_tax,w_name,w_street_2,w_city,w_state,w_zip) VALUES (1, 0.078, 300000.00, 'HO73DCcj6s', 'mM48NK@U7TQTK@Z@ma', 'sitmvvuwAzB', 'g5', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_ytd,w_tax,w_name,w_street_1,w_city,w_state,w_zip) VALUES (1, 0.078, 300000.00, 'HO73DCcj6s', '67oATAPEmE5', 'sitmvvuwAzB', 'g5', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_ytd,w_tax,w_name,w_street_1,w_street_2,w_state,w_zip) VALUES (1, 0.078, 300000.00, 'HO73DCcj6s', '67oATAPEmE5', 'mM48NK@U7TQTK@Z@ma', 'g5', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_ytd,w_tax,w_name,w_street_1,w_street_2,w_city,w_zip) VALUES (1, 0.078, 300000.00, 'HO73DCcj6s', '67oATAPEmE5', 'mM48NK@U7TQTK@Z@ma', 'sitmvvuwAzB', '405911111');
SELECT * from warehouse;
INSERT INTO warehouse(w_id,w_ytd,w_tax,w_name,w_street_1,w_street_2,w_city,w_state) VALUES (1, 0.078, 300000.00, 'HO73DCcj6s', '67oATAPEmE5', 'mM48NK@U7TQTK@Z@ma', 'sitmvvuwAzB', 'g5');
SELECT * from warehouse;
SELECT * from nation;
INSERT INTO nation(n_name,n_regionkey,n_comment) VALUES ( 'ALGERIA', 0, 'the bravely busy theodolites will dazzle blithely according to the never silent');
SELECT * from nation;
INSERT INTO nation(n_nationkey,n_regionkey,n_comment) VALUES (48, 0, 'the bravely busy theodolites will dazzle blithely according to the never silent');
SELECT * from nation;
INSERT INTO nation(n_nationkey,n_name,n_comment) VALUES (48, 'ALGERIA', 'the bravely busy theodolites will dazzle blithely according to the never silent');
SELECT * from nation;
INSERT INTO nation(n_nationkey,n_name,n_regionkey) VALUES (48, 'ALGERIA', 0);
SELECT * from nation;
SELECT * from supplier;
INSERT INTO supplier(su_name,su_address,su_nationkey,su_phone,su_acctbal,su_comment) VALUES ( 'Supplier#000000000', 'UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g', 103, '10-520-573-2995', 7942.04, ' slyly on the sometimes permanent somas -- enticingly daring attai');
SELECT * from supplier;
INSERT INTO supplier(su_suppkey,su_address,su_nationkey,su_phone,su_acctbal,su_comment) VALUES (0, 'UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g', 103, '10-520-573-2995', 7942.04, ' slyly on the sometimes permanent somas -- enticingly daring attai');
SELECT * from supplier;
INSERT INTO supplier(su_suppkey,su_name,su_nationkey,su_phone,su_acctbal,su_comment) VALUES (0, 'Supplier#000000000', 103, '10-520-573-2995', 7942.04, ' slyly on the sometimes permanent somas -- enticingly daring attai');
SELECT * from supplier;
INSERT INTO supplier(su_suppkey,su_name,su_address,su_phone,su_acctbal,su_comment) VALUES (0, 'Supplier#000000000', 'UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g', '10-520-573-2995', 7942.04, ' slyly on the sometimes permanent somas -- enticingly daring attai');
SELECT * from supplier;
INSERT INTO supplier(su_suppkey,su_name,su_address,su_nationkey,su_acctbal,su_comment) VALUES (0, 'Supplier#000000000', 'UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g', 103, 7942.04, ' slyly on the sometimes permanent somas -- enticingly daring attai');
SELECT * from supplier;
INSERT INTO supplier(su_suppkey,su_name,su_address,su_nationkey,su_phone,su_comment) VALUES (0, 'Supplier#000000000', 'UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g', 103, '10-520-573-2995', ' slyly on the sometimes permanent somas -- enticingly daring attai');
SELECT * from supplier;
INSERT INTO supplier(su_suppkey,su_name,su_address,su_nationkey,su_phone,su_acctbal) VALUES (0, 'Supplier#000000000', 'UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g', 103, '10-520-573-2995', 7942.04);
SELECT * from supplier;
SELECT * from region;
INSERT INTO region(r_name,r_comment) VALUES ( 'AFRICA', ' ? closely enticing attainments around the quietly careful dinos may was idly over the slowly st');
SELECT * from region;
INSERT INTO region(r_regionkey,r_comment) VALUES (0, ' ? closely enticing attainments around the quietly careful dinos may was idly over the slowly st');
SELECT * from region;
INSERT INTO region(r_regionkey,r_name) VALUES (0, 'AFRICA');
SELECT * from region;

SELECT * from order_line;
INSERT INTO order_line(ol_w_id,ol_d_id,ol_o_id,ol_number,ol_i_id,ol_amount,ol_supply_w_id,ol_quantity,ol_dist_info) VALUES (1000,1,1,1,49876,0.00,5,2.09,'ige');
SELECT * from order_line;

SELECT * from orders;
INSERT INTO orders(o_w_id,o_d_id,o_id,o_c_id,o_ol_cnt,o_all_local,o_entry_d) VALUES (1000,1,1,1,7,1,'2020-09-01 06:19:55');
SELECT * from orders;
