CREATE DATABASE test TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'en_US.utf8';

\c test

CREATE SCHEMA tmp;

create table tmp.oorder4 (
) tablespace tsurugi;

CREATE TABLE tmp.customer (
  c_credit char(2)
) tablespace tsurugi;

CREATE TABLE IF NOT EXISTS tmp.customer (
  c_credit char(2)
) tablespace tsurugi;

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
CONSTRAINT TCPKEY_UPPER PRIMARY KEY(COL0)
) TABLESPACE TSURUGI;

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
constraint tcpkey_lower primary key(col16)
) tablespace tsurugi;

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
) TABLESPACE TSURUGI;

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
) tablespace tsurugi;

DROP SCHEMA tmp CASCADE;

\c postgres

DROP DATABASE test;
