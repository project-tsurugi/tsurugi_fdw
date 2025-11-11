#!/bin/bash
psql pg_test -c "create table if not exists fdw_sample (num int not null, tim time)"
