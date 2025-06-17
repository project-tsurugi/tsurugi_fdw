# tsurugi_fdw (PostgreSQL add-on)

## Requirements

* C++ Compiler `>= C++17`
* Source code of PostgreSQL 12 or 13 `>=12.4`, `>=13.18`
* Access to installed dependent modules:
  * managers ([metadata-manager](https://github.com/project-tsurugi/metadata-manager), [message-manager](https://github.com/project-tsurugi/message-manager))
  * [takatori](https://github.com/project-tsurugi/takatori)
  * [ogawayama](https://github.com/project-tsurugi/ogawayama)

## How to build for tsurugi_fdw

1. Install required packages.
    Install required packages for building tsurugi_fdw.
    If you already know that the required packages are installed, skip this procedure.
    * Refer to the PostgreSQL documentation or online manuals for the required packages to build PostgreSQL.

    ```sh
    sudo apt -y install curl bzip2 libreadline-dev libz-dev make gcc g++ git libboost-filesystem-dev
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

1. Install libraries required to build dependent modules.

    ```sh
    sudo apt -y install build-essential cmake ninja-build \
      libboost-container-dev libboost-stacktrace-dev libicu-dev flex bison libssl-dev \
      libboost-thread-dev libgoogle-glog-dev libprotobuf-dev protobuf-compiler
    ```

    For libraries required, refer to README of each dependent module.

1. Build and Install dependent modules.

    ```sh
    make install_dependencies
    ```

    If tsurugi_fdw was cloned into a directory other than the "contrib" directory in PostgreSQL,
    add a directory of pg_config to PATH and use "USE_PGXS=1".

    ```sh
    make install_dependencies USE_PGXS=1
    ```

    Dependent modules installed in **\<PostgreSQL install directory>**.  

1. Add **\<PostgreSQL install directory>** to LIBRARY_PATH.

    ```sh
    export LIBRARY_PATH=$LIBRARY_PATH:<PostgreSQL install directory>/lib
    ```

1. Build and Install tsurugi_fdw.

    ```sh
    make
    make install
    ```

    If tsurugi_fdw was cloned into a directory other than the "contrib" directory in PostgreSQL,
    add a directory of pg_config to PATH and use "USE_PGXS=1".

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

    If tsurugi_fdw was cloned into a directory other than the "contrib" directory in PostgreSQL,
    add a directory of pg_config to PATH and use "USE_PGXS=1".

    ```sh
    make tests USE_PGXS=1
    ```

## How to access Tsurugi from PostgreSQL

1. Define foreign table
   * Execute **CREATE FOREIGN TABLE** command
     * You must define same table name as table name in Tsurugi
     * You must specify same server name as specified in CREATE SERVER

        ```sql
        CREATE FOREIGN TABLE table1 (column1 INTEGER NOT NULL) SERVER tsurugi;
        ```

1. Execute DML

    ```sql
    SELECT * FROM table1;
    INSERT INTO table1 (column1) VALUES (100);
    ```

> [!NOTE]
> see [docs/setup.md](./docs/setup.md) and [docs/tutorial.md](./docs/tutorial.md), it has more information.
