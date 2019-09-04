#!/bin/sh

pg_ctl stop
gcc -Wall -shared -o alt_planner.so -I/home/yanagisawa/postgresql-11.1/src/include -fPIC -g3 alt_planner.c
cp alt_planner.so /home/yanagisawa/pgsql/lib/
pg_ctl start
