# frontend for Ogawayama (PostgreSQL add-on)

## Requirements
* C++ Compiler `>= C++17`
* Source code of PostgreSQL `>=11.1`

## How to build frontend
Clone fronend to "contrib" directory in PostgreSQL.
```sh
apt -y install libreadline-dev zlib1g-dev # for PostgreSQL
apt -y install make gcc g++
# and packages to build ogawayama

# build PostgreSQL
curl -sL https://ftp.postgresql.org/pub/source/v11.1/postgresql-11.1.tar.bz2 | tar -xj
cd postgresql-11.1
./configure --prefix=$HOME/pgsql
make
make install

cd contrib
git clone git@github.com:project-tsurugi/frontend.git
cd frontend
git submodule update --init

# build ogawayama
cd third_party/ogawayama
mkdir build
cd build
cmake -G Ninja -DBUILD_STUB_ONLY=ON -DBUILD_TESTS=OFF ..
ninja

# build metadata-manager
cd third_party/manager/metadata-manager
mkdir build
cd build
cmake -G 'Unix Makefiles' ..
make

cd ../../..
make
make install
```

## How to set up for frontend

1. Update **shared_preload_libraries** parameter in postgresql.conf as below.
	```
    shared_preload_libraries = 'ogawayama_fdw'
	```
   * postgresql.conf exists in "<*PostgreSQL install directory*>/data/".

1. Restart PostgreSQL.
	```
     pg_ctl restart
	```
