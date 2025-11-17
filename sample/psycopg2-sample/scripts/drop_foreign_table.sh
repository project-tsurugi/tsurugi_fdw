#!/bin/bash
psql tsurugi_db -c "drop foreign table if exists fdw_sample"
