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

INSERT INTO order_line VALUES (974,1,1,1,49876,'2020-09-01 06:19:55',0.00,5,2.09,'igebHozKYD8JjLxfXTt?uXaR');
INSERT INTO new_order VALUES (2920,1,1);
INSERT INTO new_order VALUES (2839,1,1);
INSERT INTO stock VALUES (1,1,73,0,0,1,'v7HGGr@mYEf0Av1pxNosnrL5','fk5m85ndyvC4FZS9lZaMMDEi','ItiMb?P7Oh@KloVk7JC@pVBt','o@Kqnxttlh06QFXwggBjdH?f','D8CTTn0i4O?iVL?l2sUfnT77','Djuyt6Kn0Z?leuJwXumIyGiE','25s0byEfmFENUs?XYBjpIFs0','F5is3TawHS39R1AaH9pZKlha','jYjPHAHKNb0z5fQ@PbqiUPHp','AidrXn0CRuDVHvWuoc2EsSxS','sB09deduXnuUyXRUpNeSeYohnQtTtnl5RJG');
INSERT INTO orders VALUES (974,1,1,1, '2020-09-01 06:19:55',8,7,1);
INSERT INTO orders_secondary VALUES (893,1,1,4);
INSERT INTO history VALUES (1,1,1,1,1,'2020-09-01 06:19:55',10.00,'?qO6YMvDuCVyQQ');
---INSERT INTO customer VALUES (1,1,1,882711111,'OE','YGw89hId','BARBARBAR',50000.00,0.0135,-10.00,10.00,1,53,'kU1gw6cmC?b0','0EvtoSo6haMZNOgk','WE9wusQn8MlIfyrWwIs','5Y','testtesta','0120-11111-12222','2020-09-01 06:19:55','GC','@GvTnhlqcYlWD?7Fk43@owVlQIzx7GlsTgPXwPW@HxAXV3KyMaoTxaMnnmCTKs6ky17p2i6CxwzHuqefsA5y4sk1LoITnJc5JiH0e0HHrfFmKEZC6DIuC41FdKcLcY6dqx9RCPxGf@ClUEO5Sc9TbSqgoe8XCumo3xkTu7?o4dII87mT@zpLZADMRAL399euHeUiU8zV2rGldCKEI78Rl2hngBz?9GlSuby@dZMdK@NHLaKTlVYdwTcq7J5j1yDKqIDao0@nl623jyWm92xt5fc6ep4ifM3c31gkoAZrD2YkLt2Vyi?hhlaouBYafNrzE1nssAlvQjMIAB62pvuWSoR');
---INSERT INTO customer_secondary VALUES (4,1,'bZK8UUzZk6OJQwbi','BARBARPRI','lq',829611111,2665651681743450,'2020-09-01 06:19:55','GC',50000.00,0.4872,-10.00,10.00,1,0,'q507zbsbCejUSb2Z1LKMXHr3FL0d54azGBejhqR6UVBW5sVl?VNV7ano0moCWdM5jv9kKVNxfsuzQ967wu8iR4z6h5o@akIRbcVqjSEL?K61rxicPAPOGTo6H9FzllZDEoh1MiDPupo5xvQ02E1o16D48wbYa4Hm2QPKFyQC95Mm7covwYD2V6GWQq?rcuHlEjOZUw8EuErGdR71bXXPR@Jjf64kBEXBRsQIsnUzXA8eaC122JlA7eJPG3Z2d4W@BWi8hZV7nm8Yp46CTFlqJKyhI?xOOMpzswVeihZtlIp0noGebczIP2AMV0UUdFtQZmCsLwO@CgOxXrwXfHuq1AjRTFNLKJUA?AJWrrpj?V0IofJjFKdiW4uYOy3dyVHl7sKZ8qZeyUDpq3L3k0tyIFC0rRHMYAhlI4S13x?0W5gsmA8ZPm0ESMWMIfQMs9YKi9ZKvkwguWr322h0XyZ0OjtRx6xuneg5u?N?',108);
---INSERT INTO district VALUES (1,1,'7KxYQrnz','5fg6lud3tkcnGw','IHKgOEqlYdZD543lan','2Jwyu80wQLC','Tn',185311111,0.1224,30000.00,3001);
---INSERT INTO item VALUES (1,1,'7KxYQrnz','5fg6lud3tkcnGw','IHKgOEqlYdZD543lan','2Jwyu80wQLC','Tn',185311111,0.1224,30000.00,3001);
---INSERT INTO warehouse VALUES (1,'HO73DCcj6s','67oATAPEmE5','mM48NK@U7TQTK@Z@ma','sitmvvuwAzB','g5',405911111,0.078,300000.00);
---INSERT INTO nation VALUES (48,'ALGERIA',0,'the bravely busy theodolites will dazzle blithely according to the never silent');
---INSERT INTO supplier VALUES (0,'Supplier#000000000','UFUqtuYH2qwWrqma@FRKKRsTeZpC5pQiKqk6g',103,'10-520-573-2995',7942.04,' slyly on the sometimes permanent somas -- enticingly daring attai');
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
