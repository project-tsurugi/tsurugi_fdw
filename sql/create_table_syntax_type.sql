CREATE EXTENSION IF NOT EXISTS tsurugi_fdw;
CREATE SERVER IF NOT EXISTS ogawayama FOREIGN DATA WRAPPER tsurugi_fdw;

CREATE TABLE customer_fifth (
  c_credit char(2) PRIMARY KEY
) tablespace tsurugi;

CREATE TABLE IF NOT EXISTS customer_fifth (
  c_credit char(2) PRIMARY KEY
) tablespace tsurugi;

CREATE TABLE TCPKEY_UPPER (
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
COL10 CHAR(1)                 CONSTRAINT NN10 NOT NULL,
COL11 CHARACTER               CONSTRAINT NN11 NOT NULL,
COL12 CHARACTER(10)           CONSTRAINT NN12 NOT NULL,
COL13 CHARACTER(1000)         CONSTRAINT NN13 NOT NULL,
COL14 VARCHAR(1000)           CONSTRAINT NN14 NOT NULL,
COL15 VARCHAR(1000)           CONSTRAINT NN15 NOT NULL,
COL16 CHARACTER VARYING(1000) CONSTRAINT NN16 NOT NULL,
CONSTRAINT TCPKEY_UPPER_PKEY PRIMARY KEY(COL0)
) TABLESPACE TSURUGI;

create table tcpkey_lower (
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
col10 char(1)                 constraint nn10 not null,
col11 character               constraint nn11 not null,
col12 character(10)           constraint nn12 not null,
col13 character(1000)         constraint nn13 not null,
col14 varchar(1000)           constraint nn14 not null,
col15 varchar(1000)           constraint nn15 not null,
col16 character varying(1000) constraint nn16 not null,
constraint tcpkey_lower_pkey primary key(col16)
) tablespace tsurugi;

CREATE TABLE CCPKEY_UPPER (
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
COL10 CHAR(1)                 CONSTRAINT NN10 NOT NULL,
COL11 CHARACTER               CONSTRAINT NN11 NOT NULL,
COL12 CHARACTER(10)           CONSTRAINT NN12 NOT NULL,
COL13 CHARACTER(1000)         CONSTRAINT NN13 NOT NULL,
COL14 VARCHAR(1000)           CONSTRAINT NN14 NOT NULL,
COL15 VARCHAR(1000)           CONSTRAINT NN15 NOT NULL,
COL16 CHARACTER VARYING(1000) CONSTRAINT NN16 NOT NULL PRIMARY KEY
) TABLESPACE TSURUGI;

create table ccpkey_lower (
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
col10 char(1)                 constraint nn10 not null,
col11 character               constraint nn11 not null,
col12 character(10)           constraint nn12 not null,
col13 character(1000)         constraint nn13 not null,
col14 varchar(1000)           constraint nn14 not null,
col15 varchar(1000)           constraint nn15 not null,
col16 character varying(1000) constraint nn16 not null primary key
) tablespace tsurugi;

CREATE TABLE pkey_all_column (
col0  integer                 ,
col1  int                     ,
col2  int4                    ,
col3  bigint                  ,
col4  int8                    ,
col5  real                    ,
col6  float4                  ,
col7  double precision        ,
col8  float8                  ,
col9  char                    ,
col10 char(1)                 ,
col11 character               ,
col12 character(10)           ,
col13 character(1000)         ,
col14 varchar(1000)           ,
col15 varchar(1000)           ,
col16 character varying(1000) ,
CONSTRAINT pkey_all_column_pkey
PRIMARY KEY(COL0 ,COL1 ,COL2 ,COL3 ,COL4 ,COL5 ,COL6 ,COL7 ,COL8 ,COL9 ,COL10,COL11,COL12,COL13,COL14,COL15,COL16 )
) TABLESPACE TSURUGI;

create table japanese_column_name (
  カラム int PRIMARY KEY
) tablespace tsurugi;

create table one_english_column_name (
  o int PRIMARY KEY
) tablespace tsurugi;

CREATE FOREIGN TABLE customer_fifth (
  c_credit char(2)
) SERVER ogawayama;

CREATE FOREIGN TABLE TCPKEY_UPPER (
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
COL10 CHAR(1)                 CONSTRAINT NN10 NOT NULL,
COL11 CHARACTER               CONSTRAINT NN11 NOT NULL,
COL12 CHARACTER(10)           CONSTRAINT NN12 NOT NULL,
COL13 CHARACTER(1000)         CONSTRAINT NN13 NOT NULL,
COL14 VARCHAR(1000)           CONSTRAINT NN14 NOT NULL,
COL15 VARCHAR(1000)           CONSTRAINT NN15 NOT NULL,
COL16 CHARACTER VARYING(1000) CONSTRAINT NN16 NOT NULL 
) SERVER ogawayama;

CREATE FOREIGN TABLE tcpkey_lower (
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
col10 char(1)                 constraint nn10 not null,
col11 character               constraint nn11 not null,
col12 character(10)           constraint nn12 not null,
col13 character(1000)         constraint nn13 not null,
col14 varchar(1000)           constraint nn14 not null,
col15 varchar(1000)           constraint nn15 not null,
col16 character varying(1000) constraint nn16 not null 
) SERVER ogawayama;

CREATE FOREIGN TABLE CCPKEY_UPPER (
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
COL10 CHAR(1)                 CONSTRAINT NN10 NOT NULL,
COL11 CHARACTER               CONSTRAINT NN11 NOT NULL,
COL12 CHARACTER(10)           CONSTRAINT NN12 NOT NULL,
COL13 CHARACTER(1000)         CONSTRAINT NN13 NOT NULL,
COL14 VARCHAR(1000)           CONSTRAINT NN14 NOT NULL,
COL15 VARCHAR(1000)           CONSTRAINT NN15 NOT NULL,
COL16 CHARACTER VARYING(1000) CONSTRAINT NN16 NOT NULL 
) SERVER ogawayama;

CREATE FOREIGN TABLE ccpkey_lower (
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
col10 char(1)                 constraint nn10 not null,
col11 character               constraint nn11 not null,
col12 character(10)           constraint nn12 not null,
col13 character(1000)         constraint nn13 not null,
col14 varchar(1000)           constraint nn14 not null,
col15 varchar(1000)           constraint nn15 not null,
col16 character varying(1000) constraint nn16 not null 
) SERVER ogawayama;

CREATE FOREIGN TABLE pkey_all_column (
col0  integer                 ,
col1  int                     ,
col2  int4                    ,
col3  bigint                  ,
col4  int8                    ,
col5  real                    ,
col6  float4                  ,
col7  double precision        ,
col8  float8                  ,
col9  char                    ,
col10 char(1)                 ,
col11 character               ,
col12 character(10)           ,
col13 character(1000)         ,
col14 varchar(1000)           ,
col15 varchar(1000)           ,
col16 character varying(1000)
) SERVER ogawayama;
/* workaround
create foreign table japanese_column_name (
  カラム int
) SERVER ogawayama;
*/
create foreign table one_english_column_name (
  o int
) SERVER ogawayama;

SELECT * FROM customer_fifth;
INSERT INTO customer_fifth (c_credit) VALUES ('TE');
SELECT * FROM customer_fifth;

SELECT * FROM tcpkey_upper;
INSERT INTO tcpkey_upper (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (-2147483648, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789', 'b','KLMNOPQRST','ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKL');
SELECT * FROM tcpkey_upper;

SELECT * FROM tcpkey_lower;
INSERT INTO tcpkey_lower (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (-2147483648, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789', 'b','KLMNOPQRST','ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKL');
SELECT * FROM tcpkey_lower;

SELECT * FROM ccpkey_upper;
INSERT INTO ccpkey_upper (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (-2147483648, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789', 'b','KLMNOPQRST','ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKL');
SELECT * FROM ccpkey_upper;

SELECT * FROM ccpkey_lower;
INSERT INTO ccpkey_lower (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (-2147483648, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789', 'b','KLMNOPQRST','ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKL');
SELECT * FROM ccpkey_lower;

SELECT * FROM pkey_all_column;
INSERT INTO pkey_all_column (col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16) VALUES (-2147483648, 0, 2147483647,-3147483648, 3147483647,3.24000001, -2.27600002,-0.299999999999999989, 25.8000000000000007,'A','B','a','abcdefghij','0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789', 'b','KLMNOPQRST','ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKL');
SELECT * FROM pkey_all_column;

SELECT * FROM japanese_column_name;
INSERT INTO japanese_column_name (カラム) VALUES (1);
SELECT * FROM japanese_column_name;

SELECT * FROM one_english_column_name;
INSERT INTO one_english_column_name (o) VALUES (1);
SELECT * FROM one_english_column_name;


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

create table char_length_empty (
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
    LIKE customer_third_dummy INCLUDING ALL
) tablespace tsurugi;

-- LIKE EXCLUDING
CREATE TABLE customer_copied_excluding (
    LIKE customer_third_dummy EXCLUDING CONSTRAINTS
) tablespace tsurugi;

-- LIKE clause refers to no table
CREATE TABLE customer_copied_failed (
    LIKE customer_third
) tablespace tsurugi;

-- LIKE INCLUDING ALL refers to no table
CREATE TABLE customer_copied_including_failed (
    LIKE customer_third INCLUDING ALL
) tablespace tsurugi;

-- LIKE EXCLUDING refers to no table
CREATE TABLE customer_copied_excluding_failed (
    LIKE customer_third EXCLUDING CONSTRAINTS
) tablespace tsurugi;

-- INHERITS clause
-- parent table
CREATE TABLE cities (
    name            varchar(1000) PRIMARY KEY,
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
) INHERITS (nothing) tablespace tsurugi;

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
PARTITION OF nothing
FOR VALUES FROM ('2016-07-01') TO ('2016-08-01') tablespace tsurugi;

-- PARTITION BY LIST
CREATE TABLE cities_partition_by_list (
    city_id      bigint not null,
    name         varchar(1000) not null,
    population   bigint
) PARTITION BY LIST (name) tablespace tsurugi;

CREATE TABLE cities_ab
PARTITION OF cities_partition_by_list
FOR VALUES IN ('a', 'b') tablespace tsurugi;

CREATE TABLE cities_ab_of_no_table
PARTITION OF nothing
FOR VALUES IN ('a', 'b') tablespace tsurugi;

-- PARTITION BY HASH
CREATE TABLE orders_partition_by_hash (
    order_id     bigint not null,
    cust_id      bigint not null,
    status       varchar(1000)
) PARTITION BY HASH (order_id) tablespace tsurugi;

CREATE TABLE orders_p1 PARTITION OF orders_partition_by_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 0) tablespace tsurugi;

CREATE TABLE orders_p1_of_no_table PARTITION OF noting
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
CREATE TYPE employee_type AS (name varchar(1000), salary double precision);
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
) server ogawayama;

-- referred by FOREIGN KEY table constraint
CREATE FOREIGN TABLE customer_forth (
  c_d_id INT NOT NULL,
  c_w_id INT NOT NULL,
  c_last VARCHAR(16) NOT NULL,
  c_first VARCHAR(16) NOT NULL,
  c_id INT NOT NULL
) server ogawayama;

-- type error not supported
CREATE FOREIGN TABLE orders_type_error (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt decimal(2,0) NOT NULL,
  o_all_local decimal(1,0) NOT NULL,
  o_entry_d timestamp NOT NULL
) server ogawayama;

CREATE FOREIGN TABLE type_error_bigserial (
  col1 bigserial,
  col2 serial8
) server ogawayama;

CREATE FOREIGN TABLE type_error_bit (
  col1 bit,
  col2 bit(1)
) server ogawayama;

CREATE FOREIGN TABLE type_error_bit_varying (
  col1 bit varying,
  col2 bit varying(100),
  col3 varbit,
  col4 varbit(1)
) server ogawayama;

CREATE FOREIGN TABLE type_error_bool (
  col1 boolean,
  col2 bool
) server ogawayama;

CREATE FOREIGN TABLE type_error_box (
  col2 box
) server ogawayama;

CREATE FOREIGN TABLE type_error_bytea (
  col3 bytea
) server ogawayama;

CREATE FOREIGN TABLE type_error_cidr_circle_date_inet (
  col1 cidr,
  col2 circle,
  col3 date,
  col4 inet
) server ogawayama;

CREATE FOREIGN TABLE type_error_interval (
  col1 interval,
  col2 interval YEAR,
  col3 interval YEAR TO MONTH,
  col4 interval HOUR,
  col5 interval SECOND(0),
  col6 interval MINUTE TO SECOND(6)
) server ogawayama;

CREATE FOREIGN TABLE type_error_json (
  col1 json,
  col2 jsonb
) server ogawayama;

CREATE FOREIGN TABLE type_error_line_lseg (
  col1 line,
  col2 lseg
) server ogawayama;

CREATE FOREIGN TABLE type_error_macaddr_money (
  col1 macaddr,
  col2 money
) server ogawayama;

CREATE FOREIGN TABLE type_error_numeric (
  col1 numeric,
  col2 numeric(1000),
  col3 numeric(1000,1000),
  col4 decimal,
  col5 decimal(1),
  col6 decimal(1000,1)
) server ogawayama;

CREATE FOREIGN TABLE type_error_p (
  col1 path,
  col2 pg_lsn,
  col3 point,
  col4 polygon
) server ogawayama;

CREATE FOREIGN TABLE type_error_small (
  col1 smallint,
  col2 int2,
  col3 smallserial,
  col4 serial2
) server ogawayama;

CREATE FOREIGN TABLE type_error_serial (
  col1 serial
) server ogawayama;

CREATE FOREIGN TABLE type_error_text (
  col1 text
) server ogawayama;

CREATE FOREIGN TABLE type_error_time (
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
) server ogawayama;

CREATE FOREIGN TABLE type_error_all_other_than_above (
  col0 tsquery,
  col1 tsvector,
  col2 txid_snapshot,
  col3 uuid,
  col4 xml
) server ogawayama;

-- varchar data length (n) is not specified
CREATE FOREIGN TABLE varchar (
  ol_w_id int,
  ol_d_id varchar,
  ol_o_id int,
  ol_number int not null
) server ogawayama;

-- varchar data length is empty
CREATE FOREIGN TABLE varchar_length_empty (
  ol_w_id int,
  ol_d_id varchar(10),
  ol_o_id int,
  ol_number int not null
) server ogawayama;

-- varchar data length is zero
CREATE FOREIGN TABLE varchar_length_0 (
  ol_w_id int ,
  ol_d_id varchar(1),
  ol_o_id int,
  ol_number int not null
) server ogawayama;

CREATE FOREIGN TABLE char_length_empty (
  ol_w_id int,
  ol_d_id char,
  ol_o_id int,
  ol_number int not null
) server ogawayama;

-- char data length is zero
CREATE FOREIGN TABLE char_length_0 (
  ol_w_id int ,
  ol_d_id char(1),
  ol_o_id int,
  ol_number int not null
) server ogawayama;

-- type of ol_w_id is not specified
CREATE FOREIGN TABLE type_is_not_specified (
  ol_w_id int,
  ol_d_id varchar(100),
  ol_o_id int,
  ol_number int not null
) server ogawayama;

-- TEMP TABLE
CREATE FOREIGN TABLE temptbl (
  id integer,
  name varchar(10)
) server ogawayama;

CREATE FOREIGN TABLE temporarytbl (
  id integer,
  name varchar(10)
) server ogawayama;

-- UNLOGGED TABLE
CREATE FOREIGN TABLE unloggedtbl (
  id integer,
  name varchar(10)
) server ogawayama;

-- COLLATE column
CREATE FOREIGN TABLE distributors_unique_cc (
    did     varchar(1000)
) server ogawayama;

-- LIKE clause
CREATE FOREIGN TABLE customer_copied (
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
) server ogawayama;

-- LIKE INCLUDING ALL
CREATE FOREIGN TABLE customer_copied_including (
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
) server ogawayama;

-- LIKE EXCLUDING
CREATE FOREIGN TABLE customer_copied_excluding (
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
) server ogawayama;

-- LIKE clause refers to no table
CREATE FOREIGN TABLE customer_copied_failed (
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
) server ogawayama;

-- LIKE INCLUDING ALL refers to no table
CREATE FOREIGN TABLE customer_copied_including_failed (
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
) server ogawayama;

-- LIKE EXCLUDING refers to no table
CREATE FOREIGN TABLE customer_copied_excluding_failed (
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
) server ogawayama;

-- INHERITS clause
-- parent table
CREATE FOREIGN TABLE cities (
    name            varchar(1000),
    population      float,
    altitude        int     -- in feet
) server ogawayama;

-- INHERITS clause (child table)
CREATE FOREIGN TABLE capitals(
    name            varchar(1000),
    population      float,
    altitude        int,     -- in feet
    state           char(2)
) server ogawayama;

-- INHERITS clause (child table) inherit no table
CREATE FOREIGN TABLE capitals_fail_to_inherit(
    name            varchar(1000),
    population      float,
    altitude        int,     -- in feet
    state           char(2)
) server ogawayama;

-- PARTITION BY RANGE
CREATE FOREIGN TABLE measurement (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) server ogawayama;

-- PARTITION BY RANGE COLLATE
CREATE FOREIGN TABLE measurement_collate (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) server ogawayama;

CREATE FOREIGN TABLE measurement_y2016m07 (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) server ogawayama;

CREATE FOREIGN TABLE measurement_y2016m07_of_no_table (
    logdate         varchar(24) not null,
    peaktemp        int,
    unitsales       int
) server ogawayama;

-- PARTITION BY LIST
CREATE FOREIGN TABLE cities_partition_by_list (
    city_id      bigint not null,
    name         varchar(1000) not null,
    population   bigint
) server ogawayama;

CREATE FOREIGN TABLE cities_ab (
    city_id      bigint not null,
    name         varchar(1000) not null,
    population   bigint
) server ogawayama;

CREATE FOREIGN TABLE cities_ab_of_no_table (
    city_id      bigint not null,
    name         varchar(1000) not null,
    population   bigint
) server ogawayama;

-- PARTITION BY HASH
CREATE FOREIGN TABLE orders_partition_by_hash (
    order_id     bigint not null,
    cust_id      bigint not null,
    status       varchar(1000)
) server ogawayama;

CREATE FOREIGN TABLE orders_p1 (
    order_id     bigint not null,
    cust_id      bigint not null,
    status       varchar(1000)
) server ogawayama;

CREATE FOREIGN TABLE orders_p1_of_no_table (
    order_id     bigint not null,
    cust_id      bigint not null,
    status       varchar(1000)
) server ogawayama;

-- USING method
CREATE FOREIGN TABLE t_myheap (
    id int, v text
) server ogawayama;

-- WITH clause of table
CREATE FOREIGN TABLE distributors_table_with (
    did     integer,
    name    varchar(40)
) server ogawayama;

-- ON COMMIT PRESERVE ROWS
CREATE FOREIGN TABLE oncommit_prows (
  id int not null,
  txt varchar(32)
) server ogawayama;

-- ON COMMIT DELETE ROWS
CREATE FOREIGN TABLE oncommit_drows (
  id int not null,
  txt varchar(32)
) server ogawayama;

-- ON COMMIT DROP
CREATE FOREIGN TABLE oncommit_drop (
  id int not null,
  txt varchar(32)
) server ogawayama;

-- OF clause
CREATE FOREIGN TABLE employees(
    name varchar(1000),
    salary double precision
) server ogawayama;

-- *** column constraint ***
-- NULL column constraint
CREATE FOREIGN TABLE orders_null_cc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int NULL,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- CHECK column constraint
CREATE FOREIGN TABLE distributors_check_cc (
    did     integer,
    name    varchar(40)
) server ogawayama;

-- CHECK column constraint NO INHERIT
CREATE FOREIGN TABLE distributors_check_cc_ni (
    did     integer,
    name    varchar(40)
) server ogawayama;

-- DEFAULT column constraint
CREATE FOREIGN TABLE orders_default_cc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int DEFAULT NULL,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- GENERATED ALWAYS AS
CREATE FOREIGN TABLE generated_always_as (
    x float,
    y float,
    "(x + y)" float,
    "(x - y)" float,
    "(x * y)" float,
    "(x / y)" float
) server ogawayama;

-- GENERATED BY DEFAULT AS IDENTITY
CREATE FOREIGN TABLE distributors_generated_by_default (
     did    integer,
     name   varchar(40) NOT NULL
) server ogawayama;

-- GENERATED ALWAYS AS IDENTITY
CREATE FOREIGN TABLE distributors_generated_always (
     did    integer,
     name   varchar(40) NOT NULL
) server ogawayama;

-- UNIQUE column constraint
CREATE FOREIGN TABLE distributors_unique_cc_collate (
    did     integer,
    name    varchar(40)
) server ogawayama;

-- PRIMARY KEY WITH
CREATE FOREIGN TABLE distributors_pkey_cc_include (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000)
) server ogawayama;

-- PRIMARY KEY USING INDEX
CREATE FOREIGN TABLE distributors_pkey_cc_using_index (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000)
) server ogawayama;

CREATE FOREIGN TABLE distributors_pkey_cc_using_index_syntax_error (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000)
) server ogawayama;

-- FOREIGN KEY column constraint
CREATE FOREIGN TABLE orders_fkey_cc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_cc_no_unique_pkey (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL  ,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_cc_refers_to_no_table (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- FOREIGN KEY column constraint MATCH FULL
CREATE FOREIGN TABLE orders_fkey_cc_mf (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_cc_mf_no_unique_pkey (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL  ,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_cc_mf_refers_to_no_table (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- FOREIGN KEY column constraint MATCH PARTIAL
CREATE FOREIGN TABLE orders_fkey_cc_mp (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_cc_mp_no_unique_pkey (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- FOREIGN KEY column constraint MATCH SIMPLE
CREATE FOREIGN TABLE orders_fkey_cc_ms (
  o_w_id int,
  o_d_id int,
  o_id int,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_cc_ms_no_unique_pkey (
  o_w_id int,
  o_d_id int,
  o_id int,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- DEFERRABLE INITIALLY DEFERRED column constraint
CREATE FOREIGN TABLE deferrable_initially_deferred_cc(
    id integer
) server ogawayama;

-- DEFERRABLE INITIALLY IMMEDIATE column constraint
CREATE FOREIGN TABLE deferrable_initially_immediate_cc(
    id integer
) server ogawayama;

-- DEFERRABLE column constraint
CREATE FOREIGN TABLE deferrable_cc(
    id integer
) server ogawayama;

-- NOT DEFERRABLE column constraint
CREATE FOREIGN TABLE not_deferrable_cc(
    id integer
) server ogawayama;

-- *** table constraint ***
-- CHECK table constraint
CREATE FOREIGN TABLE distributors_check_tc (
    did     integer,
    name    varchar(40)
) server ogawayama;

-- CHECK table constraint NO INHERIT
CREATE FOREIGN TABLE distributors_check_tc_ni (
    did     integer,
    name    varchar(40)
) server ogawayama;

-- UNIQUE table constraint
CREATE FOREIGN TABLE orders_unique_tc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- WITH clause
CREATE FOREIGN TABLE distributors_column_with (
    did     integer,
    name    varchar(40)
) server ogawayama;

-- PRIMARY KEY INCLUDE
CREATE FOREIGN TABLE distributors_pkey_tc_include (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000)
) server ogawayama;

-- PRIMARY KEY USING INDEX
CREATE FOREIGN TABLE distributors_pkey_tc_using_index (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000)
) server ogawayama;

CREATE FOREIGN TABLE distributors_pkey_tc_using_index_syntax_error (
    id             integer,
    first_name     varchar(1000),
    last_name      varchar(1000)
) server ogawayama;

-- EXCLUDE USING
CREATE FOREIGN TABLE distributotrs_exclude_using (
    name varchar(1000),
    age integer
) server ogawayama;

CREATE FOREIGN TABLE distributotrs_exclude_using_failed (
    name varchar(1000),
    age integer
) server ogawayama;

CREATE FOREIGN TABLE distributotrs_exclude_using_where (
    name varchar(1000),
    age integer
) server ogawayama;

CREATE FOREIGN TABLE distributotrs_exclude_using_where_failed (
    name varchar(1000),
    age integer
) server ogawayama;

CREATE FOREIGN TABLE account_exclude_using_op_class
(
  MANUAL_NO         VARCHAR(12)
) server ogawayama;

CREATE FOREIGN TABLE account_exclude_using_op_class_desc_nulls_last
(
  MANUAL_NO         VARCHAR(12)
) server ogawayama;

-- FOREIGN KEY table constraint
CREATE FOREIGN TABLE orders_fkey_tc (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_tc_fail_to_refer (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- FOREIGN KEY table constraint
CREATE FOREIGN TABLE orders_fkey_tc_mf (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

CREATE FOREIGN TABLE orders_fkey_tc_mf_fail_to_refer (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- FOREIGN KEY table constraint
CREATE FOREIGN TABLE orders_fkey_tc_mp (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- FOREIGN KEY table constraint
CREATE FOREIGN TABLE orders_fkey_tc_ms (
  o_w_id int NOT NULL,
  o_d_id int NOT NULL,
  o_id int NOT NULL,
  o_c_id int NOT NULL,
  o_carrier_id int,
  o_ol_cnt double precision NOT NULL, -- decimal(2,0) NOT NULL
  o_all_local double precision NOT NULL, -- decimal(1,0) NOT NULL
  o_entry_d char(24) NOT NULL -- timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) server ogawayama;

-- DEFERRABLE INITIALLY DEFERRED
CREATE FOREIGN TABLE deferrable_initially_deferred_tc(
    id integer NOT NULL
) server ogawayama;

-- DEFERRABLE INITIALLY IMMEDIATE
CREATE FOREIGN TABLE deferrable_initially_immediate_tc(
    id integer NOT NULL
) server ogawayama;

CREATE FOREIGN TABLE deferrable_initially_immediate_tc_pk_exists (
    id integer NOT NULL
) server ogawayama;

-- DEFERRABLE
CREATE FOREIGN TABLE deferrable_tc(
    id integer NOT NULL
) server ogawayama;

SELECT * from customer_third ;
SELECT * from customer_forth ;
SELECT * from orders_type_error ;
SELECT * from type_error_bigserial ;
SELECT * from type_error_bit ;
SELECT * from type_error_bit_varying ;
SELECT * from type_error_bool ;
SELECT * from type_error_box ;
SELECT * from type_error_bytea ;
SELECT * from type_error_cidr_circle_date_inet ;
SELECT * from type_error_interval ;
SELECT * from type_error_json ;
SELECT * from type_error_line_lseg ;
SELECT * from type_error_macaddr_money ;
SELECT * from type_error_numeric ;
SELECT * from type_error_p ;
SELECT * from type_error_small ;
SELECT * from type_error_serial ;
SELECT * from type_error_text ;
SELECT * from type_error_time ;
SELECT * from type_error_all_other_than_above ;
SELECT * from varchar ;
SELECT * from varchar_length_empty ;
SELECT * from varchar_length_0 ;
SELECT * from char_length_empty ;
SELECT * from char_length_0 ;
SELECT * from type_is_not_specified ;
SELECT * from distributors_unique_cc ;
SELECT * from customer_copied ;
SELECT * from customer_copied_including ;
SELECT * from customer_copied_excluding ;
SELECT * from customer_copied_failed ;
SELECT * from customer_copied_including_failed ;
SELECT * from customer_copied_excluding_failed ;
SELECT * from cities ;
SELECT * from capitals ;
SELECT * from capitals_fail_to_inherit ;
SELECT * from measurement ;
SELECT * from measurement_collate ;
SELECT * from measurement_y2016m07;
SELECT * from measurement_y2016m07_of_no_table;
SELECT * from cities_partition_by_list ;
SELECT * from cities_ab;
SELECT * from cities_ab_of_no_table;
SELECT * from orders_partition_by_hash ;
SELECT * from orders_p1;
SELECT * from orders_p1_of_no_table;
SELECT * from t_myheap ;
SELECT * from distributors_table_with ;
SELECT * from employees;
SELECT * from orders_null_cc ;
SELECT * from distributors_check_cc ;
SELECT * from distributors_check_cc_ni ;
SELECT * from orders_default_cc ;
SELECT * from generated_always_as ;
SELECT * from distributors_generated_by_default ;
SELECT * from distributors_generated_always ;
SELECT * from distributors_unique_cc_collate ;
SELECT * from distributors_pkey_cc_include ;
SELECT * from distributors_pkey_cc_using_index ;
SELECT * from distributors_pkey_cc_using_index_syntax_error ;
SELECT * from orders_fkey_cc ;
SELECT * from orders_fkey_cc_no_unique_pkey ;
SELECT * from orders_fkey_cc_refers_to_no_table ;
SELECT * from orders_fkey_cc_mf ;
SELECT * from orders_fkey_cc_mf_no_unique_pkey ;
SELECT * from orders_fkey_cc_mf_refers_to_no_table ;
SELECT * from orders_fkey_cc_mp ;
SELECT * from orders_fkey_cc_mp_no_unique_pkey ;
SELECT * from orders_fkey_cc_ms ;
SELECT * from orders_fkey_cc_ms_no_unique_pkey ;
SELECT * from deferrable_initially_deferred_cc;
SELECT * from deferrable_initially_immediate_cc;
SELECT * from deferrable_cc;
SELECT * from not_deferrable_cc;
SELECT * from distributors_check_tc ;
SELECT * from distributors_check_tc_ni ;
SELECT * from orders_unique_tc ;
SELECT * from distributors_column_with ;
SELECT * from distributors_pkey_tc_include ;
SELECT * from distributors_pkey_tc_using_index ;
SELECT * from distributors_pkey_tc_using_index_syntax_error ;
SELECT * from distributotrs_exclude_using ;
SELECT * from distributotrs_exclude_using_failed ;
SELECT * from distributotrs_exclude_using_where ;
SELECT * from distributotrs_exclude_using_where_failed ;
SELECT * from account_exclude_using_op_class;
SELECT * from account_exclude_using_op_class_desc_nulls_last;
SELECT * from orders_fkey_tc ;
SELECT * from orders_fkey_tc_fail_to_refer ;
SELECT * from orders_fkey_tc_mf ;
SELECT * from orders_fkey_tc_mf_fail_to_refer ;
SELECT * from orders_fkey_tc_mp ;
SELECT * from orders_fkey_tc_ms ;
SELECT * from deferrable_initially_deferred_tc;
SELECT * from deferrable_initially_immediate_tc;
SELECT * from deferrable_initially_immediate_tc_pk_exists ;
SELECT * from deferrable_tc;

-- double quote in default constraint
CREATE TABLE default_constr_double_quote (
  "c_credit" char(2) DEFAULT "apple"
) tablespace tsurugi;

-- default constraint serial
CREATE TABLE default_constr_serial (
  id serial
) tablespace tsurugi;

-- multiple column pkey
create table multiple_col_pkey (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int not null primary key,
  ol_number int not null primary key
) tablespace tsurugi;

-- primary key is not specified
CREATE TABLE pkey_not_specified (
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
) TABLESPACE TSURUGI;

-- primary key column does not exist
CREATE TABLE pkey_not_exists (
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
) TABLESPACE TSURUGI;

-- same column name
create table same_col_name (
  ol_w_id int,
  ol_w_id int,
  ol_o_id int,
  ol_number int not null primary key
) tablespace tsurugi;

-- column name is not specified
create table col_name_is_not_specified (
  int
) tablespace tsurugi;

-- column name is 1
create table col_name_is_1 (
  1 int
) tablespace tsurugi;

-- column name is 1c
create table col_name_is_1c (
  1c int
) tablespace tsurugi;

-- column name is japanese
create table col_name_is_japanese (
  ??? int
) tablespace tsurugi;

-- table name is not specified
create table (
  column int
) tablespace tsurugi;

-- table name is 1
create table 1 (
  column int
) tablespace tsurugi;

-- column name is 1c
create table 1c (
  column int
) tablespace tsurugi;

-- column name is japanese
create table ??? (
  column int
) tablespace tsurugi;

-- double quote in default constraint
CREATE FOREIGN TABLE default_constr_double_quote (
  "c_credit" char(2)
) server ogawayama;

-- default constraint serial
CREATE FOREIGN TABLE default_constr_serial (
  id serial
) server ogawayama;

-- multiple column pkey
CREATE FOREIGN TABLE multiple_col_pkey (
  ol_w_id int not null,
  ol_d_id int,
  ol_o_id int not null,
  ol_number int not null
) server ogawayama;

-- primary key is not specified
CREATE FOREIGN TABLE pkey_not_specified (
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
COL16 CHARACTER VARYING(1000)
) server ogawayama;

-- primary key column does not exist
CREATE FOREIGN TABLE pkey_not_exists (
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
COL16 CHARACTER VARYING(1000)
) server ogawayama;

-- same column name
CREATE FOREIGN TABLE same_col_name (
  ol_w_id int,
  ol_w_id int,
  ol_o_id int,
  ol_number int not null
) server ogawayama;

-- column name is japanese
CREATE FOREIGN TABLE col_name_is_japanese (
  ??? int
) server ogawayama;

-- table name is not specified
CREATE FOREIGN TABLE (
  column int
) server ogawayama;

-- table name is 1
CREATE FOREIGN TABLE 1 (
  column int
) server ogawayama;

-- column name is 1c
CREATE FOREIGN TABLE 1c (
  column int
) server ogawayama;

-- column name is japanese
CREATE FOREIGN TABLE ??? (
  column int
) server ogawayama;

SELECT * from  default_constr_double_quote ; 
SELECT * from  default_constr_serial ; 
SELECT * from  multiple_col_pkey ; 
SELECT * from  pkey_not_specified ; 
SELECT * from  pkey_not_exists ; 
SELECT * from  same_col_name ; 
SELECT * from  col_name_is_japanese ; 
SELECT * from  ; 
SELECT * from  1 ; 
SELECT * from  1c ; 
SELECT * from  ??? ; 

-- *** same table name is specified ***
CREATE SCHEMA tmp;
-- success to create table in the schema "tmp"
create table tmp.same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp2;

-- If same table name is defined in another schema,
-- fail to create table.
create table tmp2.same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE DATABASE contrib_regression_test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c contrib_regression_test

-- If same table name is defined in another database,
-- fail to create table.
create table same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE SCHEMA tmp;

-- If same table name is defined in another schema of another database,
-- fail to create table.
create table tmp.same_table_name_test (
  ol_w_id int not null primary key,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) tablespace tsurugi;

CREATE EXTENSION tsurugi_fdw;
CREATE SERVER ogawayama FOREIGN DATA WRAPPER tsurugi_fdw;

-- success to CREATE FOREIGN TABLE in the schema "tmp"
CREATE FOREIGN TABLE same_table_name_test (
  ol_w_id int not null,
  ol_d_id int,
  ol_o_id int,
  ol_number int
) server ogawayama;

SELECT * from same_table_name_test ;

\c postgres
