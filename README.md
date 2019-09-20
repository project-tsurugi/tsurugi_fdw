# frontend for Ogawayama (PostgreSQL add-on)

## Requirements
* C++ Compiler `>= C++17`
* Source code of PostgreSQL `>=11.1`

## How to build ogawayama_fdw
Clone fronend to "contrib" directory in PostgreSQL.
```sh
cd postgresql-xx.x/contrib/frontend/ogawayama_fdw
make
make install
```

## How to build alt_planner
See "frontend/alt_planner/alt_plannerの使用方法".
