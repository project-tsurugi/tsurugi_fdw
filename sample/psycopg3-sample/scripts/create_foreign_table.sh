#!/bin/bash
psql tsurugi_db -c "create foreign table if not exists fdw_sample (num int not null, tim time) server tsurugi"
psql tsurugi_db -c "\\d fdw_sample"
