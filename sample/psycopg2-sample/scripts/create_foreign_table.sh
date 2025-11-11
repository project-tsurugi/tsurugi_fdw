#!/bin/bash
psql postgres -c "create foreign table if not exists fdw_sample (num int not null, tim time) server tsurugi"
psql postgres -c "\\d fdw_sample"
