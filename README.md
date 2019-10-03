# frontend for Ogawayama (PostgreSQL add-on)

## Requirements
* C++ Compiler `>= C++17`
* Source code of PostgreSQL `>=11.1`

## How to build ogawayama_fdw
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
cd ogawayama_fdw/third_party/ogawayama
mkdir build
cd build
cmake -G Ninja -DBUILD_STUB_ONLY=ON -DBUILD_TESTS=OFF ..
ninja

cd ../../..
make
make install
```

## How to build alt_planner
See "frontend/alt_planner/alt_plannerの使用方法".
