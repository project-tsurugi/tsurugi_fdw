# tsurugi_fdw (PostgreSQL add-on)

## Requirements

* C++ Compiler `>= C++17`
* Source code of PostgreSQL `>=12.4`
* Access to installed dependent modules:
  * managers (metadata-manager, message-manager)
  * ogawayama

## How to build for tsurugi_fdw

1. Install required packages.
    Install required packages for building tsurugi_fdw.

    ```sh
    sudo apt -y install make gcc g++ git libboost-filesystem-dev
    ```

1. Build and Install PostgreSQL.
    tsurugi_fdw uses the PostgreSQL build environment.  
    If you already know that the environment is set up, skip this procedure.
    * Specify the PostgreSQL install directory to "--prefix". In the following example, $HOME/pgsql is specified.
    * From now on, this directory is defined as **\<PostgreSQL install directory>**.
    * Refer to the PostgreSQL documentation or online manuals for the installation of PostgreSQL.

    ```sh
    curl -sL https://ftp.postgresql.org/pub/source/v12.4/postgresql-12.4.tar.bz2 | tar -xj
    cd postgresql-12.4
    ./configure --prefix=$HOME/pgsql
    make
    make install
    ```

1. Clone tsurugi_fdw.
    Clone tsurugi_fdw to "contrib" directory in PostgreSQL.
    * From now on, this directory is defined as **\<tsurugi_fdw clone directory>**.

    ```sh
    cd contrib
    git clone git@github.com:project-tsurugi/tsurugi_fdw.git
    cd tsurugi_fdw
    git submodule update --init --recursive
    ```

1. Build and Install dependent modules.

    ```sh
    make install_dependencies
    ```

    Dependent modules installed in **\<PostgreSQL install directory>**.  
    Add **\<PostgreSQL install directory>** to LIBRARY_PATH.

    ```sh
    export LIBRARY_PATH=$LIBRARY_PATH:<PostgreSQL install directory>/lib
    ```

1. Build and Install tsurugi_fdw.

    ```sh
    make
    make install
    ```

    Or in case when PostgreSQL is installed in a custom location,  
    add a directory of pg_config to PATH and use

    ```sh
    make USE_PGXS=1
    make install USE_PGXS=1
    ```

## How to set up for tsurugi_fdw

1. Create PostgreSQL server.

    ```sh
    mkdir <PostgreSQL install directory>/data
    initdb -D <PostgreSQL install directory>/data
    ```

1. Update **shared_preload_libraries** parameter in postgresql.conf as below.
    * postgresql.conf exists in **\<PostgreSQL install directory>/data/**.

    ```conf
    shared_preload_libraries = 'tsurugi_fdw'
    ```

1. Start PostgreSQL.

    ```sh
    pg_ctl -D <PostgreSQL install directory>/data/ start
    ```

1. Define metadata tables and load initial metadata.

    ```sh
    psql postgres < <tsurugi_fdw clone directory>/third_party/metadata-manager/sql/ddl.sql
    ```

1. Install tsurugi_fdw extension
    * Execute **CREATE EXTENSION** command

        ```sql
        CREATE EXTENSION tsurugi_fdw;
        ```

    * Check with the meta-command(\dew)

        ```sql
        postgres=# \dew
                        List of foreign-data wrappers
                Name      |  Owner   |        Handler        | Validator
           ---------------+----------+-----------------------+-----------
            tsurugi_fdw   | postgres | tsurugi_fdw_handler   | -
        ```

1. Define external-server

   * Execute **CREATE SERVER** command

        ```sql
        CREATE SERVER tsurugi FOREIGN DATA WRAPPER tsurugi_fdw;
        ```

   * Check with the meta-command(\des)

        ```sql
        postgres=# \des
                    List of foreign servers
            Name    |  Owner   | Foreign-data wrapper
         -----------+----------+----------------------
          tsurugi   | postgres | tsurugi_fdw
        ```

1. Define TABLESPACE

   * Create a directory for TABLESPACE.
     * The following directory is an example of execution and can be created at any location.

        ```sh
        mkdir -p <PostgreSQL install directory>/tsurugi
        ```

   * Execute **CREATE TABLESPACE** command

        ```sql
        CREATE TABLESPACE tsurugi LOCATION '<PostgreSQL install directory>/tsurugi';
        ```

   * Check with the meta-command(\db)

        ```sql
        postgres=# \db
                    List of tablespaces
            Name    |  Owner   |             Location
        ------------+----------+-----------------------------------
         pg_default | postgres |
         pg_global  | postgres |
         tsurugi    | postgres | /home/postgres/local/pgsql/tsurugi
        ```

## Regression tests

### Structure

* **expected/** test results expectations
* **results/** test results
* **sql/** all the tests

### How to execute the tests

1. Start Tsurugi Server
    * Refer to the Tsurugi documentation on how to start the Tsurugi server.

1. Build tsurugi_fdw
   * [How to build for tsurugi_fdw](#how-to-build-for-tsurugi_fdw)

1. Set up tsurugi_fdw
   * [How to set up for tsurugi_fdw](#how-to-set-up-for-tsurugi_fdw)

1. Execute the following command

    in case when you run only basic tests

    ```sh
    make tests
    ```

    Or in case when run extra tests with basic tests,  
    execute the following command:

    ```sh
    make tests REGRESS_EXTRA=1
    ```

## Define table

1. Define table
   * Execute **CREATE TABLE** command
     * You must add "TABLESPACE tsurugi"
     * You must specify PRIMARY KEY

        ```sql
        CREATE TABLE table1 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
        ```

1. Define foreign table
   * Execute **CREATE FOREIGN TABLE** command
     * You must define same table name and schema as specified in CREATE TABLE
     * You must **NOT** specify PRIMARY KEY
     * You must specify same server name as specified in CREATE SERVER

        ```sql
        CREATE FOREIGN TABLE table1 (column1 INTEGER NOT NULL) SERVER tsurugi;
        ```

1. Execute DML

    ```sql
    SELECT * FROM table1;
    INSERT INTO table1 (column1) VALUES (100);
    ```
