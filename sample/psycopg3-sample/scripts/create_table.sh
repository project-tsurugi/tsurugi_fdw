#!/bin/bash
tgsql --exec -c ipc:tsurugi "create table if not exists fdw_sample (num int not null, tim time)"
tgsql --exec -c ipc:tsurugi "\\show table fdw_sample"
