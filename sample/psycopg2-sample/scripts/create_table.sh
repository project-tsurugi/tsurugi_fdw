#!/bin/bash
tgsql --exec -c ipc:tsurugi_fuji "create table if not exists fdw_sample (num int not null, tim time)"
tgsql --exec -c ipc:tsurugi_fuji "\\show table fdw_sample"
