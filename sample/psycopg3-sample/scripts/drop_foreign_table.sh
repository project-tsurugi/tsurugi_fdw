#!/bin/bash
psql postgres -c "drop foreign table if exists fdw_sample"
