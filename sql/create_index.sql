/* INDEX TEST */
/* DDL */
CREATE FOREIGN TABLE t3_create_index(c1 INTEGER NOT NULL) SERVER tsurugidb;
CREATE FOREIGN TABLE t4_create_index(c1 INTEGER NOT NULL, c2 BIGINT, c3 DOUBLE PRECISION) SERVER tsurugidb;

/* DML */
SELECT * FROM t3_create_index;
INSERT INTO t3_create_index (c1) VALUES (1);
SELECT * FROM t3_create_index;

SELECT * FROM t4_create_index;
INSERT INTO t4_create_index (c1, c2, c3) VALUES (1, 100, 1.1);
INSERT INTO t4_create_index (c1, c2, c3) VALUES (2, 200, 2.2);
SELECT * FROM t4_create_index;

SELECT * FROM t3_create_index;
INSERT INTO t3_create_index (c1) VALUES (10);
INSERT INTO t3_create_index (c1) VALUES (100);
SELECT * FROM t3_create_index;

SELECT * FROM t4_create_index;
UPDATE t4_create_index SET c2 = c2+10;
UPDATE t4_create_index SET c3 = c3+1.1 WHERE c2 = 110;
SELECT * FROM t4_create_index;

SELECT * FROM t3_create_index;
DELETE FROM t3_create_index WHERE c1 = 10;
SELECT * FROM t3_create_index;

/* DDL */
DROP FOREIGN TABLE t3_create_index;
DROP FOREIGN TABLE t4_create_index;
