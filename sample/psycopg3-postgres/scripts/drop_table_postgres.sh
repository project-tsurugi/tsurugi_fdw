#!/bin/bash
psql postgres_db -c "drop table if exists fdw_sample"
