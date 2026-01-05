-- Setup
SET ROLE postgres;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'tsurugi', password 'password');
CREATE ROLE um_test_a LOGIN;
CREATE ROLE um_test_b LOGIN;
GRANT USAGE ON FOREIGN SERVER tsurugidb TO um_test_a, um_test_b;
SET ROLE um_test_a;

-- Invalid option name "username"
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (username 'ub');

-- Invalid option name "badpassword"
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (badpassword 'pb');

-- Contains invalid option "badpassword"
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ub', badpassword 'pb');

-- Contains invalid option "username"
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (username 'ub', password 'pb');

-- Duplicate "user" option
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ub', user 'ub');

-- "user" value is blank/whitespace
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user ' ');

-- Duplicate CREATE for CURRENT_USER
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ub', password 'pb');
\deu+
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ubqq', password 'pb');
\deu+
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;

-- ADD user when it already exists
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ub');
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (ADD user 'ub');

-- DROP option when none is set
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb;
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (DROP password);

-- Option names quoted as strings
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS ('user' 'ub', 'password' 'pb');

-- Setup for authentication tests
SET ROLE um_test_a;
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (ADD user 'ua', ADD password 'pa');
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
-- Invalid username authentication fails (ERROR)
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'bad_ua', password 'pa');
SELECT * FROM fdw_um_auth_table_1;

-- Invalid password authentication fails (ERROR)
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ua', password 'bad_pa');
SELECT * FROM fdw_um_auth_table_1;

-- Invalid username and password authentication fails (ERROR)
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'bad_ua', password 'bad_pa');
SELECT * FROM fdw_um_auth_table_1;

-- Missing username authentication fails (ERROR)
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (password 'pa');
SELECT * FROM fdw_um_auth_table_1;

-- Missing password authentication fails (ERROR)
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ua');
SELECT * FROM fdw_um_auth_table_1;

-- Missing credentials authentication fails (ERROR)
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb;
SELECT * FROM fdw_um_auth_table_1;

-- Same session connection reuse second SELECT runs without reauthentication
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ua', password 'pa');
SELECT * FROM fdw_um_auth_table_1;
ALTER USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (SET user 'bad_ua', SET password 'bad_pa');
SELECT * FROM fdw_um_auth_table_1;

-- Role switch requires authentication
SET ROLE um_test_b;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'bad_ub', password 'bad_pb');
SET ROLE um_test_a;
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
CREATE USER MAPPING FOR CURRENT_USER SERVER tsurugidb OPTIONS (user 'ua', password 'pa');
SELECT * FROM fdw_um_auth_table_1;
SET ROLE um_test_b;
SELECT * FROM fdw_um_auth_table_1;

-- Cleanup
SET ROLE postgres;
DROP FOREIGN TABLE fdw_um_auth_table_1;
SELECT tg_execute_ddl('DROP TABLE fdw_um_auth_table_1', 'tsurugidb');
DROP USER MAPPING IF EXISTS FOR um_test_a SERVER tsurugidb;
REVOKE USAGE ON FOREIGN SERVER tsurugidb FROM um_test_a, um_test_b;
DROP USER MAPPING IF EXISTS FOR um_test_b SERVER tsurugidb;
DROP ROLE IF EXISTS um_test_a;
DROP ROLE IF EXISTS um_test_b;