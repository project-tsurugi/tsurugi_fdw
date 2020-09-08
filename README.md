# frontend for Ogawayama (PostgreSQL add-on)

## Requirements
* C++ Compiler `>= C++17`
* Source code of PostgreSQL `>=11.1`

## How to build frontend

1. Install required packages.

	Install required packages for building PostgreSQL.  

	```sh
	sudo apt -y install libreadline-dev zlib1g-dev
	```

	Install required packages for building ogawayama_fdw.

	```sh
	sudo apt -y install make gcc g++
	```

1. Build and Install tsurugi.

	Install tsurugi in default tsurugi install directory $HOME/.local.  
	By changing INSTALL_PREFIX=$HOME/.local in the script, you can change install directory.  

	```sh
	./scripts/devenv.sh
	```

1. Build and Install PostgreSQL.

	```sh
	curl -sL https://ftp.postgresql.org/pub/source/v12.3/postgresql-12.3.tar.bz2 | tar -xj
	cd postgresql-12.3
	./configure --prefix=$HOME/pgsql
	make
	make install
	```

1.  Build and Install ogawayama_fdw.

	Clone fronend to "contrib" directory in PostgreSQL.

	```sh
	cd contrib
	git clone git@github.com:project-tsurugi/frontend.git
	```

	Clone required packages for building ogawayama_fdw. 

	```sh
	cd frontend
	git submodule update --init
	```

	Add LIBRARY_PATH to tsurugi library to build ogawayama_fdw.  
	For example, if tsurugi install directory is \~/.local,  
	export LIBRARY_PATH=$LIBRARY_PATH:\~/.local/lib  

	```sh
	export LIBRARY_PATH=$LIBRARY_PATH:<tsurugi install directory>/lib
	```

	Build and Install ogawayama_fdw.
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

## How to set up for frontend

1. Update the shared library search path for metadata-manager and ogawayama.  
	The method to set the shared library search path varies between platforms, but the most widely-used method is to set the environment variable LD_LIBRARY_PATH like so: In Bourne shells (sh, ksh, bash, zsh):
	```
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<tsurugi install directory>/lib
	export LD_LIBRARY_PATH
	```

1. Update **shared_preload_libraries** parameter in postgresql.conf as below.
	```
	shared_preload_libraries = 'ogawayama_fdw'
	```
	* postgresql.conf exists in "<*PostgreSQL install directory*>/data/".

		
1. Restart PostgreSQL.
	```
	pg_ctl restart
	```

1. Install frontend extension
	* Execute **CREATE EXTENSION** command
		```sql
		CREATE EXTENSION ogawayama_fdw;
		```
	* Check with the meta-command(\dew)
		```sql
		postgres=# \dew
                        List of foreign-data wrappers
             Name      |  Owner   |        Handler        | Validator
		---------------+----------+-----------------------+-----------
 		 ogawayama_fdw | postgres | ogawayama_fdw_handler | -
		```

1. Define external-server
	* Execute **CREATE SERVER** command
		```sql
		CREATE SERVER ogawayama FOREIGN DATA WRAPPER ogawayama_fdw;
		```
	* Check with the meta-command(\des)
		```sql
		postgres=# \des
                    List of foreign servers
   		   Name    |  Owner   | Foreign-data wrapper
		-----------+----------+----------------------
 		 ogawayama | postgres | ogawayama_fdw
		```

1. Define TABLESPACE
	* Create a directory for TABLESPACE.
		```
		$ mkdir -p <PostgreSQL install directory>/data/tsurugi
		```
	* Execute **CREATE TABLESPACE** command
		```sql
		CREATE TABLESPACE tsurugi LOCATION '<PostgreSQL install directory>/data/tsurugi';
		```
	* Check with the meta-command(\db)
		```
		k-postgres=# \db
                   List of tablespaces
			Name    |  Owner   |             Location
		------------+----------+-----------------------------------
		 pg_default | postgres |
		 pg_global  | postgres |
		 tsurugi    | postgres | /home/postgres/local/pgsql/data/tsurugi
		```

### Regression tests
### Structure

* **expected/** test results expectations
* **results/** test results
* **sql/** all the tests

### How to execute the tests
1. Build frontend
	* [How to build frontend](#How-to-build-frontend)

1. Set up frontend
	* [How to set up for frontend](#How-to-set-up-for-frontend)

1. Execute the following command: 

```
make tests
```

If regression tests failed, drop database "test" and "test2"

```
DROP DATABASE test
DROP DATABASE test2
``` 

## Define table

1. Start ogawayama-server
	```
	ogawayama-server &
	```

1. Define table
	* Execute **CREATE TABLE** command
		* You must add "TABLESPACE tsurugi"
		* You must specify PRIMARY KEY
			```sql
			CREATE TABLE table1 (column1 INTEGER NOT NULL PRIMARY KEY) TABLESPACE tsurugi;
			```
	* A new relation named "<*table_name*>_dummy" will be created in the current PostgreSQL database.
		* e.g. "table1_dummy"

1. Define foreign table
	* Execute **CREATE FOREIGN TABLE** command
		* You must define same table name and schema as specified in CREATE TABLE
		* You must **NOT** specify PRIMARY KEY
		* You must specify same server name as specified in CREATE SERVER
			```sql
			CREATE FOREIGN TABLE table1 (column1 INTEGER NOT NULL) SERVER ogawayama;
			```
	* A new foreign relation will be created, named same table name as specified in CREATE FOREIGN TABLE
		* e.g. "table1"

1. Execute DML

	```sql
	SELECT * FROM table1;
	INSERT INTO table1 VALUES (100);
	```
1. If you want to stop ogawayama-server, use
	```
	ogawayama-cli -terminate
	```
