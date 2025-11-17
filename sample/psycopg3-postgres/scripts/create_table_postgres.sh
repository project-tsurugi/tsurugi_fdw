#!/bin/bash
psql postgres_db -c "create table if not exists fdw_sample (num int not null, tim time)"
