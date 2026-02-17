#!/bin/bash
psql tsurugi_db -c "create foreign table if not exists fdw_sample (id varchar(50), num int not null, tim time) server tsurugi"
psql tsurugi_db -c "\\d fdw_sample"
