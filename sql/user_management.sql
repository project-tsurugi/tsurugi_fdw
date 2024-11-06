SET ROLE 'postgres';
CREATE ROLE sample_role1;
CREATE ROLE sample_role2;
CREATE ROLE sample_role3;
CREATE ROLE sample_role4;
CREATE ROLE admin SUPERUSER;
SELECT 
    rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, 
    rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil
FROM 
    pg_authid 
WHERE 
    rolname = 'sample_role1';
SELECT 
    rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, 
    rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil
FROM 
    pg_authid 
WHERE 
    rolname = 'sample_role2';
SELECT 
    rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, 
    rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil
FROM 
    pg_authid 
WHERE 
    rolname = 'sample_role3';
SELECT 
    rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, 
    rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil
FROM 
    pg_authid 
WHERE 
    rolname = 'sample_role4';
SELECT 
    rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, 
    rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil
FROM 
    pg_authid 
WHERE 
    rolname = 'admin';

ALTER ROLE sample_role1 LOGIN;
SELECT 
    rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, 
    rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil
FROM 
    pg_authid 
WHERE 
    rolname = 'sample_role1';

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

GRANT SELECT, INSERT, UPDATE, DELETE ON t1_user_management to sample_role2;
GRANT SELECT, INSERT, UPDATE ON t1_user_management to sample_role3, sample_role4;
GRANT ALL ON t1_user_management to admin;
GRANT SELECT, INSERT, UPDATE ON t1_user_management, t2_user_management to sample_role1;

SELECT 
    relname, relacl 
FROM 
    pg_class 
WHERE 
    relname = 't1_user_management' or relname = 't2_user_management'
ORDER BY
    relname;

REVOKE UPDATE,DELETE  ON t1_user_management FROM sample_role2;
REVOKE UPDATE ON t1_user_management FROM sample_role3, sample_role4;
REVOKE ALL ON t1_user_management FROM admin;
REVOKE UPDATE ON t1_user_management, t2_user_management FROM sample_role1;

SELECT 
    relname, relacl 
FROM 
    pg_class 
WHERE 
    relname = 't1_user_management' or relname = 't2_user_management'
ORDER BY
    relname;

REVOKE 
    ALL 
ON 
    t1_user_management, t2_user_management 
FROM 
    sample_role1, sample_role2, sample_role3, sample_role4;

SELECT 
    relname, relacl 
FROM 
    pg_class 
WHERE 
    relname = 't1_user_management' or relname = 't2_user_management'
ORDER BY
    relname;

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
CREATE ROLE sample_role1;
CREATE ROLE sample_role1;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%' Order By rolname;

CREATE ROLE sample_role2, sample_role3;
SELECT rolname FROM pg_authid WHERE rolname like 'sample_role%' Order By rolname;

CREATE ROLE sample_role2;
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

-- clean up
DROP ROLE sample_role1;
DROP ROLE sample_role2;
RESET ROLE;
