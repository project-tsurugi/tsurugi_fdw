# Foreign Data Wrapper for Tsurugi

tsurugi_fdw is a PostgreSQL extension that provides a Foreign Data Wrapper for access to Tsurugi.

## Notice

tsurugi_fdw specializes in accessing Tsurugi database, so in the PostgreSQL database using this extension, only foreign tables for accessing Tsurugi database can be used. Local tables in PostgreSQL cannot be used.  

The current version of tsurugi_fdw pushes down queries directly to Tsurugi, which may result in execution failure for queries containing PostgreSQL-specific syntax.

## Installation

### Requirements

Since tsurugi_fdw accesses the Tsurugi database via IPC, the PostgreSQL installing this extension must be located on the same host as Tsurugi.

* C++ Compiler `>= C++17`
* Source code of PostgreSQL 12/13/14 `>=12.4`, `>=13.18`, `>=14.18`
* Access to installed dependent modules:
  * managers ([metadata-manager](https://github.com/project-tsurugi/metadata-manager), [message-manager](https://github.com/project-tsurugi/message-manager))
  * [takatori](https://github.com/project-tsurugi/takatori)
  * [ogawayama](https://github.com/project-tsurugi/ogawayama)

### How to build for tsurugi_fdw

1. Install required packages.

    Install required packages for building tsurugi_fdw.
    If you already know that the required packages are installed, skip this procedure.

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
        sudo apt -y install curl bzip2 libreadline-dev libz-dev
        ```

    ```sh
    curl -sL https://ftp.postgresql.org/pub/source/v12.4/postgresql-12.4.tar.bz2 | tar -xj
    cd postgresql-12.4
    ./configure --prefix=$HOME/pgsql
    make
    make install
    ```

1. Clone tsurugi_fdw.

    Clone tsurugi_fdw to `contrib` directory in PostgreSQL.
    * From now on, this directory is defined as **\<tsurugi_fdw clone directory>**.

    ```sh
    cd contrib
    git clone git@github.com:project-tsurugi/tsurugi_fdw.git
    cd tsurugi_fdw
    git submodule update --init --recursive
    ```

1. Install libraries required to build dependent modules.

    ```sh
    # Common dependency library for each dependent module.
    sudo apt -y install build-essential cmake ninja-build
    # Dependency libraries for takarori.
    sudo apt -y install libboost-container-dev libboost-stacktrace-dev libicu-dev flex bison
    # Dependency libraries for metadata-manager.
    sudo apt -y install libssl-dev
    # Dependency libraries for ogawayama(stub).
    sudo apt -y install libboost-thread-dev libgoogle-glog-dev libprotobuf-dev protobuf-compiler
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

## Usage

1. Update **shared_preload_libraries** parameter in postgresql.conf as below.
    * postgresql.conf exists in **\<PostgreSQL install directory>/data/**.

    ```conf
    shared_preload_libraries = 'tsurugi_fdw'
    ```

1. Restart PostgreSQL.

    ```sh
    pg_ctl -D <PostgreSQL install directory>/data/ restart
    ```

1. Install tsurugi_fdw extension
    * Execute **CREATE EXTENSION** command

        ```sql
        CREATE EXTENSION tsurugi_fdw;
        ```

    * Check with the meta-command(`\dew`)

        ```sql
        postgres=# \dew
                        List of foreign-data wrappers
                Name      |  Owner   |        Handler        | Validator
           ---------------+----------+-----------------------+-----------
            tsurugi_fdw   | postgres | tsurugi_fdw_handler   | -
        ```

1. Create foreign server for Tsurugi

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

1. Create foreign tables

    ```sql
    CREATE FOREIGN TABLE tg_table (... columns ... ) SERVER tsurugi;
    ```

    You can also import the tables of a specific schema in Tsurugi database.

    ```sql
    IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public;
    ```

1. Execute DML using foreign tables.

    ```sql
    SELECT * FROM tg_table;
    ```

## Regression tests

1. Start up tsurugidb
    * Refer to the Tsurugi documentation on how to start the Tsurugi server.

1. Execute the following command

    in case when you run only basic tests

    ```sh
    make tests
    ```

    If tsurugi_fdw was cloned into a directory other than the "contrib" directory in PostgreSQL,
    add a directory of pg_config to PATH and use "USE_PGXS=1".

    ```sh
    make tests USE_PGXS=1
    ```
