#!/bin/bash
tgsql --exec -c ipc:tsurugi "create table if not exists fdw_sample (id varchar(50) primary key, num int not null, tim time)"
tgsql --exec -c ipc:tsurugi "\\show table fdw_sample"
