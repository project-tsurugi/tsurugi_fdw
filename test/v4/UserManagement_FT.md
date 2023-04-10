# ユーザ管理機能 FT

2021.10.06 初版 NEC

## 目次

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [ユーザ管理機能 FT](#ユーザ管理機能-ft)
  - [目次](#目次)
  - [正常系](#正常系)
    - [ROLE正常系](#role正常系)
      - [CREATE ROLE 作成(オプションあり)](#create-role-作成オプションあり)
      - [ALTER ROLE 変更(1)](#alter-role-変更1)
      - [GRANT/REVOKE ROLE(1対1, 1対複, 複対1)](#grantrevoke-role1対1-1対複-複対1)
      - [DROP ROLE 削除(1, 複数)](#drop-role-削除1-複数)
    - [TABLE正常系](#table正常系)
      - [GRANT/REVOKE TABLE(1対1, 1対複, 複対1)](#grantrevoke-table1対1-1対複-複対1)
  - [異常系](#異常系)
    - [ROLE異常系](#role異常系)
      - [CREATE ROLE異常系](#create-role異常系)
      - [ALTER ROLE異常系](#alter-role異常系)
      - [GRANT ROLE異常系](#grant-role異常系)
      - [REVOKE ROLE異常系](#revoke-role異常系)
      - [DROP ROLE異常系](#drop-role異常系)
    - [TABLE異常系](#table異常系)
      - [GRANT TABLE異常系](#grant-table異常系)
      - [REVOKE TABLE異常系](#revoke-table異常系)

<!-- /code_chunk_output -->

## 正常系

結果のOID/ユーザ名については適宜読み替えてください。

### ROLE正常系

#### CREATE ROLE 作成(オプションあり)

- 結果 エラーなく動作する。ロールがそれぞれ作成される。
  以下の結果となる。

    ```sql
    #     CREATE ROLE sample_role;
    CREATE ROLE
    #     CREATE ROLE sample_role2;
    CREATE ROLE
    #     CREATE ROLE sample_role3;
    CREATE ROLE
    #     CREATE ROLE sample_role4;
    CREATE ROLE
    #     CREATE ROLE admin SUPERUSER;
    CREATE ROLE
    #     select * from pg_authid where rolname='sample_role' ;
      oid   |   rolname   | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
    --------+-------------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
     155759 | sample_role | f        | t          | f             | f           | f           | f              | f            |           -1 |             |
    (1 row)

    #     select * from pg_authid where rolname='sample_role2' ;
      oid   |   rolname    | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
    --------+--------------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
     155760 | sample_role2 | f        | t          | f             | f           | f           | f              | f            |           -1 |             |
    (1 row)

    #     select * from pg_authid where rolname='sample_role3' ;
      oid   |   rolname    | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
    --------+--------------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
     155761 | sample_role3 | f        | t          | f             | f           | f           | f              | f            |           -1 |             |
    (1 row)

    #     select * from pg_authid where rolname='sample_role4' ;
      oid   |   rolname    | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
    --------+--------------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
     155762 | sample_role4 | f        | t          | f             | f           | f           | f              | f            |           -1 |             |
    (1 row)

    #     select * from pg_authid where rolname='admin' ;
      oid   | rolname | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
    --------+---------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
     155763 | admin   | t        | t          | f             | f           | f           | f              | f            |           -1 |             |
    (1 row)
    ```

  - SQL

    ```sql
    CREATE ROLE sample_role;
    CREATE ROLE sample_role2;
    CREATE ROLE sample_role3;
    CREATE ROLE sample_role4;
    CREATE ROLE admin SUPERUSER;
    select * from pg_authid where rolname='sample_role' ;
    select * from pg_authid where rolname='sample_role2' ;
    select * from pg_authid where rolname='sample_role3' ;
    select * from pg_authid where rolname='sample_role4' ;
    select * from pg_authid where rolname='admin' ;
    ```

#### ALTER ROLE 変更(1)

- 結果 エラーなく動作する。ロールにLOGIN権限が付与される。
    以下の結果となる。

    ```sql
    # ALTER ROLE sample_role LOGIN;
    ALTER ROLE
    # select * from pg_authid where rolname='sample_role' ;
      oid   |   rolname   | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
    --------+-------------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
     155759 | sample_role | f        | t          | f             | f           | t           | f              | f            |           -1 |             |
    (1 row)
    ```

  - SQL

    ```sql
    ALTER ROLE sample_role LOGIN;
    select * from pg_authid where rolname='sample_role' ;
    ```

#### GRANT/REVOKE ROLE(1対1, 1対複, 複対1)

- 結果 エラーなく動作する。ロールに親 ロールが付与され、削除される。
    以下の結果となる。

    ```sql
    # GRANT sample_role TO sample_role2;
    GRANT ROLE
    # GRANT sample_role TO sample_role3,sample_role4;
    GRANT ROLE
    # GRANT sample_role2,sample_role3 TO sample_role4;
    GRANT ROLE
    # select mem.roleid, auth1.rolname , mem.member, auth2.rolname, mem.grantor ,
    mem.admin_option
    from pg_auth_members as mem
      inner join pg_authid as auth1 on(mem.roleid=auth1.oid)
      inner join pg_authid as auth2 on(mem.member=auth2.oid)
    where auth1.rolname='sample_role' or auth1.rolname='sample_role2' or auth1.   rolname='sample_role3';
     roleid |   rolname    | member |   rolname    | grantor | admin_option
    --------+--------------+--------+--------------+---------+--------------
     155759 | sample_role  | 155760 | sample_role2 |      10 | f
     155759 | sample_role  | 155761 | sample_role3 |      10 | f
     155759 | sample_role  | 155762 | sample_role4 |      10 | f
     155760 | sample_role2 | 155762 | sample_role4 |      10 | f
     155761 | sample_role3 | 155762 | sample_role4 |      10 | f
    (5 rows)

    # REVOKE sample_role FROM sample_role2;
    REVOKE ROLE
    # REVOKE sample_role FROM sample_role3,sample_role4;
    REVOKE ROLE
    # REVOKE sample_role2,sample_role3 FROM sample_role4;
    REVOKE ROLE

    # select mem.roleid, auth1.rolname , mem.member, auth2.rolname, mem.grantor ,
    mem.admin_option
    from pg_auth_members as mem
    inner join pg_authid as auth1 on(mem.roleid=auth1.oid)
    inner join pg_authid as auth2 on(mem.member=auth2.oid)
    where auth1.rolname='sample_role' or auth1.rolname='sample_role2' or auth1.   rolname='sample_role3';
     roleid | rolname | member | rolname | grantor | admin_option
    --------+---------+--------+---------+---------+--------------
    (0 rows)
    ```

  - SQL

    ```sql
    GRANT sample_role TO sample_role2;
    GRANT sample_role TO sample_role3,sample_role4;
    GRANT sample_role2,sample_role3 TO sample_role4;
    select mem.roleid, auth1.rolname , mem.member, auth2.rolname, mem.grantor ,
    mem.admin_option
    from pg_auth_members as mem
      inner join pg_authid as auth1 on(mem.roleid=auth1.oid)
      inner join pg_authid as auth2 on(mem.member=auth2.oid)
    where auth1.rolname='sample_role' or auth1.rolname='sample_role2' or auth1.   rolname='sample_role3';


    REVOKE sample_role FROM sample_role2;
    REVOKE sample_role FROM sample_role3,sample_role4;
    REVOKE sample_role2,sample_role3 FROM sample_role4;
    select mem.roleid, auth1.rolname , mem.member, auth2.rolname, mem.grantor ,
    mem.admin_option
    from pg_auth_members as mem
      inner join pg_authid as auth1 on(mem.roleid=auth1.oid)
      inner join pg_authid as auth2 on(mem.member=auth2.oid)
    where auth1.rolname='sample_role' or auth1.rolname='sample_role2' or auth1.   rolname='sample_role3';
    ```

#### DROP ROLE 削除(1, 複数)

- 結果 エラーなく動作する。ロールに親ロールが付与され、削除される。
    以下の結果となる。

    ```sql
    # DROP ROLE sample_role4;
    DROP ROLE
    # DROP ROLE sample_role2,sample_role3;
    DROP ROLE
    # DROP ROLE sample_role,admin;
    DROP ROLE
    # select * from pg_authid where  rolname='sample_role' or rolname='sample_role2' or  rolname='sam
    ple_role3' or  rolname='sample_role4' or  rolname='admin';
     oid | rolname | rolsuper | rolinherit | rolcreaterole | rolcreatedb |    rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword |    rolvaliduntil
    -----+---------+----------+------------+---------------+-------------+----------------+----------------+--------------+--------------+-------------+---------------
    (0 rows)
    ```

  - SQL

    ```sql
    DROP ROLE sample_role4;
    DROP ROLE sample_role2,sample_role3;
    DROP ROLE sample_role,admin;
    select * 
    from pg_authid 
    where rolname='sample_role' or rolname='sample_role2' or rolname='sam
    ple_role3' or rolname='sample_role4' or rolname='admin';
    ```

### TABLE正常系

#### GRANT/REVOKE TABLE(1対1, 1対複, 複対1)

- 結果 エラーなく動作する。外部テーブルにアクセス権が付与され、削除される。
    以下の結果となる。

    ```sql
    # CREATE TABLE table2 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
    CREATE TABLE
    # CREATE FOREIGN TABLE table2 (column1 INTEGER NOT NULL) SERVER ogawayama;
    CREATE FOREIGN TABLE
    # CREATE TABLE table3 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
    CREATE TABLE
    # CREATE FOREIGN TABLE table3 (column1 INTEGER NOT NULL) SERVER ogawayama;
    CREATE FOREIGN TABLE

    # GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table2 to sample_role2;
    GRANT
    # GRANT SELECT ,INSERT ,UPDATE  ON table2 to sample_role3,sample_role4;
    GRANT
    # GRANT ALL ON table2 to admin;
    GRANT
    # GRANT SELECT ,INSERT ,UPDATE  ON table2,table3 to sample_role;
    GRANT
    # select relname,relacl from pg_class where relname='table2' or relname='table3';
     relname |                                                                              relacl
    ---------+--------------------------------------------------------------------------------------------------------------------------------------
     table2  | {postgre=arwdDxt/postgre,sample_role2=arwd/postgre,sample_role3=arw/postgre,sample_role4=arw/postgre,admin=arwdDxt/postgre,sample_role=arw/postgre}
     table3  | {postgre=arwdDxt/postgre,sample_role=arw/postgre}
    (2 rows)

    # REVOKE UPDATE,DELETE  ON table2 FROM sample_role2;
    REVOKE
    # REVOKE UPDATE  ON table2 FROM sample_role3,sample_role4;
    REVOKE
    # REVOKE ALL ON table2 FROM admin;
    REVOKE
    # REVOKE UPDATE  ON table2,table3 FROM sample_role;
    REVOKE

    # select relname,relacl from pg_class where relname='table2' or
    relname='table3';
     relname |                                                                relacl
    ---------+--------------------------------------------------------------------------------------------------------------------------------------
     table2  | {postgre=arwdDxt/postgre,sample_role2=ar/postgre,sample_role3=ar/postgre,sample_role4=ar/postgre,sample_role=ar/postgre}
     table3  | {postgre=arwdDxt/postgre,sample_role=ar/postgre}
    (2 rows)

    # REVOKE ALL ON table2,table3 FROM sample_role,sample_role2,sample_role3,sample_role4;
    REVOKE
    # select relname,relacl from pg_class where relname='table2' or
    relname='table3';
     relname |            relacl
    ---------+-------------------------------
     table2  | {postgre=arwdDxt/postgre}
     table3  | {postgre=arwdDxt/postgre}
    (2 rows)

    ```

  - SQL

    ```sql
    CREATE TABLE table2 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
    CREATE FOREIGN TABLE table2 (column1 INTEGER NOT NULL) SERVER ogawayama;
    CREATE TABLE table3 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
    CREATE FOREIGN TABLE table3 (column1 INTEGER NOT NULL) SERVER ogawayama;

    GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table2 to sample_role2;
    GRANT SELECT ,INSERT ,UPDATE  ON table2 to sample_role3,sample_role4;
    GRANT ALL ON table2 to admin;
    GRANT SELECT ,INSERT ,UPDATE  ON table2,table3 to sample_role;

    select relname,relacl from pg_class where relname='table2' or relname='table3';

    REVOKE UPDATE,DELETE  ON table2 FROM sample_role2;
    REVOKE UPDATE  ON table2 FROM sample_role3,sample_role4;
    REVOKE ALL ON REVOKE ALL ON FROM admin;
    REVOKE UPDATE  ON table2,table3 FROM sample_role;

    select relname,relacl from pg_class where relname='table2' or relname='table3';

    REVOKE ALL ON table2,table3 FROM sample_role,sample_role2,sample_role3,sample_role4;
    select relname,relacl from pg_class where relname='table2' or relname='table3';
    ```

## 異常系

結果のOID/ユーザ名については適宜読み替えてください。

### ROLE異常系

#### CREATE ROLE異常系

- 既存のロールがある
  - 結果
  エラーが発生する。

  ```sql
  # CREATE ROLE sample_role;
  ERROR:  role "sample_role" already exists
  # select * from pg_authid where rolname like 'sample_role%';
    oid  |   rolname   | rolsuper | rolinherit | rolcreaterole | rolcreatedb |  rolcanlogin | rolreplicat
  ion | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
  -------+-------------+----------+------------+---------------+------------- +-------------+------------
  ----+--------------+--------------+-------------+---------------
   24677 | sample_role | f        | t          | f             | f           |  f           | f
      | f            |           -1 |             |
  (1 row)
  ```

  - sql

      ```sql
      CREATE ROLE sample_role;
      CREATE ROLE sample_role;
      select * from pg_authid where rolname like 'sample_role%';
      ```

- ロール名を複数指定する。
  - 結果
  エラーが発生する。

  ```sql
  # CREATE ROLE sample_role3,sample_role4;
  ERROR:  syntax error at or near ","
  LINE 1: CREATE ROLE sample_role3,sample_role4;
  # select * from pg_authid where rolname like 'sample_role%';
    oid  |   rolname   | rolsuper | rolinherit | rolcreaterole | rolcreatedb |  rolcanlogin | rolreplicat
  ion | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
  -------+-------------+----------+------------+---------------+------------- +-------------+------------
  ----+--------------+--------------+-------------+---------------
   24677 | sample_role | f        | t          | f             | f           |  f           | f
      | f            |           -1 |             |
  (1 row)
  ```

  - sql

      ```sql
      CREATE ROLE sample_role2,sample_role3;
      select * from pg_authid where rolname like 'sample_role%';
      ```

#### ALTER ROLE異常系

- ロールが存在しない
  - 結果
  エラーが発生する。

  ```sql
  # ALTER ROLE unknown_role;
  ERROR:  role "unknown_role" does not exist
  # select * from pg_authid where rolname='unknown_role';
   oid | rolname | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
  -----+---------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
  (0 rows)
  ```

  - sql

      ```sql
      ALTER ROLE unknown_role LOGIN;
      ```

- ロール名を複数指定する。
  - 結果
  エラーが発生する。

  ```sql
  # CREATE ROLE sample_role2;
  CREATE ROLE
  # ALTER ROLE sample_role,sample_role2 LOGIN;
  ERROR:  syntax error at or near ","
  LINE 1: ALTER ROLE sample_role,sample_role2 LOGIN;

  # ALTER ROLE unknown_role LOGIN;
  ERROR:  role "unknown_role" does not exist
  # select * from pg_authid where rolname like 'sample_role%';
    oid  |   rolname    | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolbypassrls | rolconnlimit | rolpassword | rolvaliduntil
  -------+--------------+----------+------------+---------------+-------------+-------------+----------------+--------------+--------------+-------------+---------------
   24677 | sample_role  | f        | t          | f             | f           | f           | f              | f            |           -1 |             |
   24678 | sample_role2 | f        | t          | f             | f           | f           | f              | f            |           -1 |             |
  (2 rows)
  ```

  - sql

      ```sql
      CREATE ROLE sample_role2;
      ALTER ROLE sample_role,sample_role2 LOGIN;
      select * from pg_authid where rolname like 'sample_role%';
      ```

#### GRANT ROLE異常系

- ロールが存在しない
  - 結果
  エラーが発生する。

  ```sql
  # GRANT ROLE unknown_role TO sample_role;
  ERROR:  syntax error at or near "unknown_role"
  LINE 1: GRANT ROLE unknown_role TO sample_role;
                     ^
  ```

  - sql

      ```sql
      GRANT ROLE unknown_role TO sample_role;
      ```

- 複数指定時ロールが存在しない(1番目)
  - 結果
  エラーが発生する。

  ```sql
  # GRANT ROLE unknown_role,sample_role2 TO sample_role;
  ERROR:  syntax error at or near "unknown_role"
  LINE 1: GRANT ROLE unknown_role,sample_role2 TO sample_role;
                     ^
  ```

  - sql

      ```sql
      GRANT ROLE unknown_role,sample_role2 TO sample_role;
      ```

- 複数指定時ロールが存在しない(2番目以降)
  - 結果
  エラーが発生する。

  ```sql
  # GRANT ROLE sample_role2,unknown_role TO sample_role;
  ERROR:  syntax error at or near "sample_role2"
  LINE 1: GRANT ROLE sample_role2,unknown_role TO sample_role;
                     ^
  ```
  
  - sql

      ```sql
      GRANT ROLE sample_role2,unknown_role TO sample_role;
      ```

#### REVOKE ROLE異常系

- ロールが存在しない
  - 結果
  エラーが発生する。

  ```sql
  # REVOKE ROLE unknown_role FROM sample_role;
  ERROR:  syntax error at or near "unknown_role"
  LINE 1: REVOKE ROLE unknown_role FROM sample_role;
                      ^
  ```

  - sql

      ```sql
      REVOKE ROLE unknown_role FROM sample_role;
      ```

- 複数指定時ロールが存在しない(1番目)
  - 結果
  エラーが発生する。

  ```sql
  # REVOKE ROLE unknown_role,sample_role2 FROM sample_role;
  ERROR:  syntax error at or near "unknown_role"
  LINE 1: REVOKE ROLE unknown_role,sample_role2 FROM sample_role;
                      ^
  ```

  - sql

      ```sql
      REVOKE ROLE unknown_role,sample_role2 FROM sample_role;
      ```

- 複数指定時ロールが存在しない(2番目以降)
  - 結果
  エラーが発生する。

  ```sql
  # REVOKE ROLE sample_role2,unknown_role FROM sample_role;
  ERROR:  syntax error at or near "sample_role2"
  LINE 1: REVOKE ROLE sample_role2,unknown_role FROM sample_role;
                      ^
  ```

  - sql
  
      ```sql
      REVOKE ROLE sample_role2,unknown_role FROM sample_role;
      ```

#### DROP ROLE異常系

- ロールが存在しない
  - 結果
  エラーが発生する。

  ```sql
  # DROP ROLE unknown_role;
  ERROR:  Could not get role.
  ```

  - sql

      ```sql
      DROP ROLE unknown_role;
      ```

- 複数指定時ロールが存在しない(1番目)
  - 結果
  エラーが発生する。

  ```sql
  # DROP ROLE unknown_role,sample_role2;
  ERROR:  Could not get role.
  ```

  - sql

      ```sql
      DROP ROLE unknown_role,sample_role2;
      ```

- 複数指定時ロールが存在しない(2番目以降)
  - 結果
  エラーが発生する。

  ```sql
  # DROP ROLE sample_role2,unknown_role;
  ERROR:  Could not get role.
  ```

  - sql

      ```sql
      DROP ROLE sample_role2,unknown_role;
      ```

### TABLE異常系

#### GRANT TABLE異常系

- テーブルが存在しない
  - 結果
  エラーが発生する。

  ```sql
  # GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table4 to sample_role2;
  ERROR:  relation "table4" does not exist
  ```

  - sql

      ```sql
      GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table4 to sample_role2;
      ```

- 複数指定時テーブルが存在しない(1番目)
  - 結果
  エラーが発生する。

  ```sql
  # GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table4,table2 to sample_role2;
  ERROR:  relation "table4" does not exist
  ```

  - sql

      ```sql
      GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table4,table2 to sample_role2;
      ```

- 複数指定時テーブルが存在しない(2番目以降)
  - 結果
  エラーが発生する。

  ```sql
  # GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table2,table4 to sample_role2;
  ERROR:  relation "table4" does not exist
  ```

  - sql

      ```sql
      GRANT SELECT ,INSERT ,UPDATE,DELETE  ON table2,table4 to sample_role2;
      ```

#### REVOKE TABLE異常系

- テーブルが存在しない
  - 結果
  エラーが発生する。

  ```sql
  # REVOKE ALL ON table4 FROM sample_role2;
  ERROR:  relation "table4" does not exist
  ```

  - sql

      ```sql
      REVOKE ALL ON table4 FROM sample_role2;
      ```

- 複数指定時テーブルが存在しない(1番目)
  - 結果
  エラーが発生する。

  ```sql
  # REVOKE ALL ON table4,table2 FROM sample_role2;
  ERROR:  relation "table4" does not exist
  ```

  - sql

      ```sql
      REVOKE ALL ON table4,table2 FROM sample_role2;
      ```

- 複数指定時テーブルが存在しない(2番目以降)
  - 結果
  エラーが発生する。

  ```sql
  # REVOKE ALL ON table2,table4 FROM sample_role2;
  ERROR:  relation "table4" does not exist
  ```

  - sql

      ```sql
      REVOKE ALL ON table2,table4 FROM sample_role2;
      ```
