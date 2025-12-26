-- Setup
SET ROLE postgres;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'tsurugi', password 'password');
CREATE ROLE um_test_a LOGIN;
CREATE ROLE um_test_b LOGIN;
GRANT USAGE ON FOREIGN SERVER tsurugidb TO um_test_a, um_test_b;

-- Create mapping for explicit role
SET ROLE um_test_a;
CREATE USER MAPPING FOR um_test_a SERVER tsurugidb OPTIONS (user 'ua', password 'pa');
\deu+

-- Create mapping for CURRENT_USER
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ua', password 'pa');
\deu+

-- Create mappings for multiple roles
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR um_test_a SERVER tsurugidb OPTIONS (user 'ua', password 'pa');
SET ROLE um_test_b;
CREATE USER MAPPING FOR um_test_b SERVER tsurugidb OPTIONS (user 'ub', password 'pb');
\deu+

-- Create mapping specifying only 'user'
DROP USER MAPPING IF EXISTS FOR um_test_b SERVER tsurugidb;
SET ROLE um_test_a;
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ub');
\deu+

-- Create mapping specifying only 'password'
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (password 'pb');
\deu+

-- Add 'user' option to CURRENT_USER mapping
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (ADD user 'ua');
\deu+

-- Set 'user' option for CURRENT_USER mapping
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (SET user 'ub');
\deu+

-- Set 'password' option for CURRENT_USER mapping
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (SET password 'pa');
\deu+

-- Drop 'password' option from CURRENT_USER mapping
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (DROP password);
\deu+

-- Drop 'user' option from CURRENT_USER mapping
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (DROP user);
\deu+

-- Set both 'user' and 'password' options
DROP USER MAPPING IF EXISTS FOR CURRENT_USER SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ua', password 'pa');
ALTER USER MAPPING FOR um_test_a SERVER tsurugidb OPTIONS (SET user 'ub', SET password 'pb');
\deu+

-- Setup for authentication tests
SELECT tg_execute_ddl('
  CREATE TABLE fdw_um_auth_table_1 (
    c1 INTEGER NOT NULL PRIMARY KEY,
    c2 VARCHAR(30) NOT NULL
  )
', 'tsurugidb');
CREATE FOREIGN TABLE fdw_um_auth_table_1 (
  c1 INTEGER NOT NULL,
  c2 VARCHAR(30) NOT NULL
) SERVER tsurugidb;
INSERT INTO fdw_um_auth_table_1 (c1, c2)
VALUES
  (1, 'Alice'),
  (2, 'Bob'),
  (3, 'Carol');
GRANT ALL ON TABLE fdw_um_auth_table_1 TO um_test_b;

-- Valid credentials SELECT succeeds
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ua', password 'pa');
SELECT * FROM fdw_um_auth_table_1;

SET ROLE um_test_b;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ub', password 'pb');

-- SELECT with valid mapping
SET ROLE um_test_a;
SELECT * FROM fdw_um_auth_table_1;

-- INSERT with valid mapping
SET ROLE um_test_b;
INSERT INTO fdw_um_auth_table_1 (c1, c2) VALUES (4, 'Dave');
SELECT * FROM fdw_um_auth_table_1;

-- UPDATE with valid mapping
SET ROLE um_test_a;
UPDATE fdw_um_auth_table_1 SET c2 = 'David' WHERE c1 = 4;
SELECT * FROM fdw_um_auth_table_1;

-- DELETE with valid mapping
SET ROLE um_test_b;
DELETE FROM fdw_um_auth_table_1 WHERE c1 = 4;
SELECT * FROM fdw_um_auth_table_1;

-- SELECT via PREPARE/EXECUTE with valid mapping
SET ROLE um_test_a;
PREPARE sel_all_a AS
  SELECT * FROM fdw_um_auth_table_1;
EXECUTE sel_all_a;

-- INSERT via PREPARE/EXECUTE with valid mapping
SET ROLE um_test_b;
PREPARE ins_row (integer, text) AS
  INSERT INTO fdw_um_auth_table_1 (c1, c2) VALUES ($1, $2);
EXECUTE ins_row(4, 'Dave');
SELECT * FROM fdw_um_auth_table_1;

-- UPDATE via PREPARE/EXECUTE with valid mapping
SET ROLE um_test_a;
PREPARE upd_row (text, integer) AS
  UPDATE fdw_um_auth_table_1 SET c2 = $1 WHERE c1 = $2;
EXECUTE upd_row('David', 4);
SELECT * FROM fdw_um_auth_table_1;

-- DELETE via PREPARE/EXECUTE with valid mapping
SET ROLE um_test_b;
PREPARE del_row (integer) AS
  DELETE FROM fdw_um_auth_table_1 WHERE c1 = $1;
EXECUTE del_row(4);
SELECT * FROM fdw_um_auth_table_1;

-- Cleanup
SET ROLE um_test_a;
DROP FOREIGN TABLE fdw_um_auth_table_1;
SELECT tg_execute_ddl('DROP TABLE fdw_um_auth_table_1', 'tsurugidb');
SET ROLE postgres;
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
DROP USER MAPPING IF EXISTS FOR um_test_b SERVER tsurugidb;
REVOKE USAGE ON FOREIGN SERVER tsurugidb FROM um_test_a, um_test_b;
DROP USER MAPPING FOR CURRENT_USER SERVER tsurugidb;
DROP ROLE IF EXISTS um_test_a;
DROP ROLE IF EXISTS um_test_b;