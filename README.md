# tsurugi_fdw (PostgreSQL add-on)

## Requirements
* C++ Compiler `>= C++17`
* Source code of PostgreSQL `>=12.4`
* Access to installed dependent modules:
  * managers (metadata-manager, message-manager)
  * ogawayama

## How to build tsurugi_fdw

1. Install required packages.

	Install required packages for building PostgreSQL.  

	```sh
	sudo apt -y install libreadline-dev zlib1g-dev curl
	```

	Install required packages for building tsurugi_fdw.

	```sh
	sudo apt -y install make gcc g++ git
	```

1. Build and Install PostgreSQL.

	```sh
	curl -sL https://ftp.postgresql.org/pub/source/v12.4/postgresql-12.4.tar.bz2 | tar -xj
	cd postgresql-12.4
	./configure --prefix=$HOME/pgsql
	make
	make install
	```
	* Specify the PostgreSQL install directory to "--prefix". In the above example, $HOME/pgsql is specified.
	* Hereafter, this directory is defined as **\<PostgreSQL install directory>**.

    Specify the shared library search path for the PostgreSQL.  
    The method to set the shared library search path varies between platforms, but the most widely-used method is to set the environment variable LD_LIBRARY_PATH like so: In Bourne shells (sh, ksh, bash, zsh):
	```
	LD_LIBRARY_PATH=<PostgreSQL install directory>/lib
	export LD_LIBRARY_PATH
	```
	The \<PostgreSQL install directory>/bin into your PATH. Strictly speaking, this is not necessary, but it will make the use of PostgreSQL much more convenient.  
	To do this, add the following to your shell start-up file, such as ~/.bash_profile (or /etc/profile, if you want it to affect all users):
	```
	PATH=<PostgreSQL install directory>/bin:$PATH
	export PATH
	```

2.  Clone tsurugi_fdw.

	Clone fronend to "contrib" directory in PostgreSQL.

	```sh
	cd contrib
	git clone git@github.com:project-tsurugi/tsurugi_fdw.git
	cd tsurugi_fdw
	git submodule update --init
	```
	* Hereafter, this directory is defined as **\<tsurugi_fdw clone directory>**.

1. Build and Install tsurugi.

	The default tsurugi install directory will be installed in \$HOME/.local.  
	By changing INSTALL_PREFIX=$HOME/.local in the script, you can change install directory.
	* Hereafter, this directory is defined as **\<tsurugi install directory>**.

        See the README of each module.
	
1.  Build and Install tsurugi_fdw.

	Add LIBRARY_PATH to tsurugi library to build tsurugi_fdw.  
	For example, if tsurugi install directory is \~/.local,  
	export LIBRARY_PATH=$LIBRARY_PATH:\~/.local/lib  

	```sh
	export LIBRARY_PATH=$LIBRARY_PATH:<tsurugi install directory>/lib
	```

	Build and Install tsurugi_fdw.
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

1. Update the shared library search path for metadata-manager, message-manager and ogawayama.  
	```
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<tsurugi install directory>/lib
	export LD_LIBRARY_PATH
	```

1. Create PostgreSQL server.

	```sh
	mkdir <PostgreSQL install directory>/data
	initdb -D <PostgreSQL install directory>/data
	```

1. Update **shared_preload_libraries** parameter in postgresql.conf as below.
	```
	shared_preload_libraries = 'tsurugi_fdw'
	```
	* postgresql.conf exists in **\<PostgreSQL install directory>/data/**.

		
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
		```sh
		mkdir -p <PostgreSQL install directory>/tsurugi
		```
		* The above directory is an example of execution, and the location is arbitrary.
	* Execute **CREATE TABLESPACE** command
		```sql
		CREATE TABLESPACE tsurugi LOCATION '<PostgreSQL install directory>/tsurugi';
		```
	* Check with the meta-command(\db)
		```
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
1. Build tsurugi_fdw
	* [How to build tsurugi_fdw](#How-to-build-tsurugi_fdw)

1. Set up tsurugi_fdw
	* [How to set up for tsurugi_fdw](#How-to-set-up-for-tsurugi_fdw)

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
	Notes: In the current version, the regression test fails due to restrictions on the INSERT statement.

1. If regression tests succeeded, drop database "contrib_regression_test":

	```
	psql postgres
	
	postgres=# DROP DATABASE contrib_regression_test;
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
	* A new foreign relation will be created, named same table name as specified in CREATE FOREIGN TABLE
		* e.g. "table1"

1. Execute DML

	```sql
	SELECT * FROM table1;
	INSERT INTO table1 (column1) VALUES (100);
	```
	Notes: In the current version, specify the column name in the INSERT statement.
