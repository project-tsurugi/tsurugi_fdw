/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', '
    CREATE TABLE t3_user_management (
        column1 INTEGER NOT NULL PRIMARY KEY
    )
');

/* Test setup: DDL of the PostgreSQL */
SET ROLE 'postgres';
CREATE FOREIGN TABLE t3_user_management (
    column1 INTEGER NOT NULL
) SERVER tsurugidb;
CREATE ROLE sample_role1;
CREATE ROLE sample_role2;

/* DML */
-- unhappy case
CREATE ROLE sample_role1;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%' Order By rolname;

CREATE ROLE sample_role2, sample_role3;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%' Order By rolname;

ALTER ROLE sample_role1, sample_role2 LOGIN;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%' Order By rolname;

GRANT ROLE unknown_role TO sample_role1;
GRANT ROLE unknown_role, sample_role2 TO sample_role1;
GRANT ROLE sample_role2, unknown_role TO sample_role1;

REVOKE ROLE unknown_role FROM sample_role1;
REVOKE ROLE unknown_role, sample_role2 FROM sample_role1;
REVOKE ROLE sample_role2, unknown_role FROM sample_role1;

DROP ROLE unknown_role;
DROP ROLE unknown_role, sample_role2;
DROP ROLE sample_role2, unknown_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON t4_user_management to sample_role2;
GRANT SELECT, INSERT, UPDATE, DELETE ON t4_user_management, t3_user_management to sample_role2;
GRANT SELECT, INSERT, UPDATE, DELETE ON t3_user_management, t4_user_management to sample_role2;

REVOKE ALL ON t4_user_management FROM sample_role2;
REVOKE ALL ON t4_user_management, t3_user_management FROM sample_role2;
REVOKE ALL ON t3_user_management, t4_user_management FROM sample_role2;

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE t3_user_management;
DROP ROLE sample_role1;
DROP ROLE sample_role2;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('tsurugidb', 'DROP TABLE t3_user_management');
