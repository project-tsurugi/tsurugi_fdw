/* Test case: happy path - Privilege */

/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE fdw_privilege_test (col INTEGER)
', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE fdw_privilege_test (col integer) SERVER tsurugidb;
CREATE ROLE tgfdw_regress_user;

-- No privileges
SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (1);            -- failed
SELECT * FROM fdw_privilege_test ORDER BY col;        -- failed
UPDATE fdw_privilege_test SET col = 10 WHERE col = 1; -- failed
DELETE FROM fdw_privilege_test;                       -- failed
RESET ROLE;

-- privileges: INSERT
GRANT INSERT ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (1);
SELECT * FROM fdw_privilege_test ORDER BY col;        -- failed
UPDATE fdw_privilege_test SET col = 11 WHERE col = 1; -- failed
DELETE FROM fdw_privilege_test WHERE col = 1;         -- failed
RESET ROLE;

-- privileges: INSERT, SELECT
GRANT SELECT ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (2);
SELECT * FROM fdw_privilege_test ORDER BY col;
UPDATE fdw_privilege_test SET col = 12 WHERE col = 2; -- failed
DELETE FROM fdw_privilege_test WHERE col = 2;         -- failed
RESET ROLE;

-- privileges: INSERT, SELECT, UPDATE
GRANT UPDATE ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (3);
SELECT * FROM fdw_privilege_test ORDER BY col;
UPDATE fdw_privilege_test SET col = 13 WHERE col = 3;
DELETE FROM fdw_privilege_test WHERE col = 3;         -- failed
RESET ROLE;

-- privileges: INSERT, SELECT, UPDATE, DELETE
GRANT DELETE ON fdw_privilege_test TO tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (4);
SELECT * FROM fdw_privilege_test ORDER BY col;
UPDATE fdw_privilege_test SET col = 14 WHERE col = 4;
DELETE FROM fdw_privilege_test WHERE col = 14;
RESET ROLE;

-- privileges: SELECT, UPDATE, DELETE
REVOKE INSERT ON fdw_privilege_test FROM tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (1);            -- failed
SELECT * FROM fdw_privilege_test ORDER BY col;
UPDATE fdw_privilege_test SET col = 21 WHERE col = 1;
DELETE FROM fdw_privilege_test WHERE col = 21;
RESET ROLE;

-- privileges: UPDATE, DELETE
REVOKE SELECT ON fdw_privilege_test FROM tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (2);            -- failed
SELECT * FROM fdw_privilege_test ORDER BY col;        -- failed
UPDATE fdw_privilege_test SET col = 22 WHERE col = 2; -- failed
DELETE FROM fdw_privilege_test WHERE col = 22;        -- failed
UPDATE fdw_privilege_test SET col = 100;
DELETE FROM fdw_privilege_test;
RESET ROLE;

-- privileges: DELETE
REVOKE UPDATE ON fdw_privilege_test FROM tgfdw_regress_user;

SET ROLE tgfdw_regress_user;
INSERT INTO fdw_privilege_test VALUES (3);            -- failed
SELECT * FROM fdw_privilege_test ORDER BY col;        -- failed
UPDATE fdw_privilege_test SET col = 23 WHERE col = 3; -- failed
DELETE FROM fdw_privilege_test WHERE col = 23;        -- failed
UPDATE fdw_privilege_test SET col = 100;              -- failed
DELETE FROM fdw_privilege_test;
RESET ROLE;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE fdw_privilege_test;
DROP ROLE tgfdw_regress_user;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE fdw_privilege_test', 'tsurugidb');
