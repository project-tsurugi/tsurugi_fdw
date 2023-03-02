SET ROLE 'postgres';
CREATE ROLE sample_role1;
CREATE ROLE sample_role2;
CREATE ROLE sample_role3;
CREATE ROLE sample_role4;
CREATE ROLE admin SUPERUSER;
SELECT rolname FROM pg_authid WHERE rolname = 'sample_role1';
SELECT rolname FROM pg_authid WHERE rolname = 'sample_role2';
SELECT rolname FROM pg_authid WHERE rolname = 'sample_role3';
SELECT rolname FROM pg_authid WHERE rolname = 'sample_role4';
SELECT rolname FROM pg_authid WHERE rolname = 'admin';

ALTER ROLE sample_role1 LOGIN;
SELECT rolname FROM pg_authid WHERE rolname = 'sample_role1';

GRANT sample_role1 TO sample_role2;
GRANT sample_role1 TO sample_role3, sample_role4;
GRANT sample_role2, sample_role3 TO sample_role4;
SELECT 
    auth1.rolname , auth2.rolname, auth3.rolname, mem.admin_option
FROM 
    pg_auth_members as mem
    inner join pg_authid as auth1 on (mem.roleid = auth1.oid)
    inner join pg_authid as auth2 on (mem.member = auth2.oid)
    inner join pg_authid as auth3 on (mem.grantor = auth3.oid)
WHERE 
    auth1.rolname = 'sample_role1' or auth1.rolname = 'sample_role2' or 
    auth1.rolname = 'sample_role3'
ORDER BY
    auth1.rolname, auth2.rolname, auth3.rolname;

REVOKE sample_role1 FROM sample_role2;
REVOKE sample_role1 FROM sample_role3, sample_role4;
REVOKE sample_role2, sample_role3 FROM sample_role4;
SELECT 
    auth1.rolname, auth2.rolname, mem.admin_option
FROM 
    pg_auth_members as mem
    inner join pg_authid as auth1 on (mem.roleid = auth1.oid)
    inner join pg_authid as auth2 on (mem.member = auth2.oid)
WHERE 
    auth1.rolname = 'sample_role1' or auth1.rolname = 'sample_role2' or 
    auth1.rolname = 'sample_role3'
ORDER BY
    auth1.rolname;

CREATE TABLE table2 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
CREATE FOREIGN TABLE table2 (column1 INTEGER NOT NULL) SERVER ogawayama;
CREATE TABLE table3 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
CREATE FOREIGN TABLE table3 (column1 INTEGER NOT NULL) SERVER ogawayama;

GRANT SELECT, INSERT, UPDATE, DELETE ON table2 to sample_role2;
GRANT SELECT, INSERT, UPDATE ON table2 to sample_role3, sample_role4;
GRANT ALL ON table2 to admin;
GRANT SELECT, INSERT, UPDATE ON table2, table3 to sample_role1;

SELECT 
    relname, relacl 
FROM 
    pg_class 
WHERE 
    relname = 'table2' or relname = 'table3'
ORDER BY
    relname;

REVOKE UPDATE,DELETE  ON table2 FROM sample_role2;
REVOKE UPDATE ON table2 FROM sample_role3, sample_role4;
REVOKE ALL ON table2 FROM admin;
REVOKE UPDATE ON table2, table3 FROM sample_role1;

SELECT 
    relname, relacl 
FROM 
    pg_class 
WHERE 
    relname = 'table2' or relname = 'table3';

REVOKE 
    ALL 
ON 
    table2, table3 
FROM 
    sample_role1, sample_role2, sample_role3, sample_role4;

SELECT 
    relname, relacl 
FROM 
    pg_class 
WHERE 
    relname = 'table2' or relname = 'table3';

DROP TABLE table2;
DROP FOREIGN TABLE table2;
DROP ROLE sample_role4;
DROP ROLE sample_role2, sample_role3;
DROP ROLE sample_role1, admin;
SELECT 
    *
FROM 
    pg_authid 
WHERE 
    rolname = 'sample_role1' or rolname = 'sample_role2' or 
    rolname = 'sample_role3' or rolname = 'sample_role4' or rolname = 'admin';

-- unhappy case
CREATE TABLE table2 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
CREATE FOREIGN TABLE table2 (column1 INTEGER NOT NULL) SERVER ogawayama;

CREATE ROLE sample_role1;
CREATE ROLE sample_role1;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%';

CREATE ROLE sample_role2, sample_role3;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%';

CREATE ROLE sample_role2;
ALTER ROLE sample_role1, sample_role2 LOGIN;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%';

GRANT ROLE unknown_role TO sample_role1;
GRANT ROLE unknown_role, sample_role2 TO sample_role1;
GRANT ROLE sample_role2, unknown_role TO sample_role1;

REVOKE ROLE unknown_role FROM sample_role1;
REVOKE ROLE unknown_role, sample_role2 FROM sample_role1;
REVOKE ROLE sample_role2, unknown_role FROM sample_role1;

DROP ROLE unknown_role;
DROP ROLE unknown_role, sample_role2;
DROP ROLE sample_role2, unknown_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON table4 to sample_role2;
GRANT SELECT, INSERT, UPDATE, DELETE ON table4, table2 to sample_role2;
GRANT SELECT, INSERT, UPDATE, DELETE ON table2, table4 to sample_role2;

REVOKE ALL ON table4 FROM sample_role2;
REVOKE ALL ON table4, table2 FROM sample_role2;
REVOKE ALL ON table2, table4 FROM sample_role2;

-- clean up
DROP ROLE sample_role1;
DROP ROLE sample_role2;
DROP TABLE table2;
DROP FOREIGN TABLE table2;
DROP TABLE table3;
DROP FOREIGN TABLE table3;
RESET ROLE;
