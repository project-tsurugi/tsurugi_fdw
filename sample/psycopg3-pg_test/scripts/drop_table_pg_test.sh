#!/bin/bash
psql pg_test -c "drop table if exists fdw_sample"
