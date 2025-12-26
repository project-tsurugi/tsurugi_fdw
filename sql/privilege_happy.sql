/* Test case: happy path - Privilege */

/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE fdw_privilege_test (col INTEGER)
', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE fdw_privilege_test (col integer) SERVER tsurugidb;
CREATE ROLE tgfdw_regress_user;

-- All privileges
GRANT ALL ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (1);
SELECT * FROM fdw_privilege_test ORDER BY col;
UPDATE fdw_privilege_test SET col = 10 WHERE col = 1;
DELETE FROM fdw_privilege_test WHERE col = 10;
RESET ROLE;

-- privileges: INSERT
REVOKE ALL ON fdw_privilege_test FROM tgfdw_regress_user;
GRANT INSERT ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (1);
RESET ROLE;

-- privileges: INSERT, SELECT
GRANT SELECT ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (2);
SELECT * FROM fdw_privilege_test ORDER BY col;
RESET ROLE;

-- privileges: INSERT, SELECT, UPDATE
GRANT UPDATE ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (3);
SELECT * FROM fdw_privilege_test ORDER BY col;
UPDATE fdw_privilege_test SET col = col + 10;
RESET ROLE;

-- privileges: INSERT, SELECT, UPDATE, DELETE
GRANT DELETE ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (4);
SELECT * FROM fdw_privilege_test ORDER BY col;
UPDATE fdw_privilege_test SET col = 14 WHERE col = 4;
DELETE FROM fdw_privilege_test;
RESET ROLE;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE fdw_privilege_test;
DROP ROLE tgfdw_regress_user;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE fdw_privilege_test', 'tsurugidb');
