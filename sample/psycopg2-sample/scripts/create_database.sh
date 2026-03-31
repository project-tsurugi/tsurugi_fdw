#!/bin/bash
psql postgres -c "drop database if exists tsurugi_db"
psql postgres -c "create database tsurugi_db"
psql postgres -c "\\l tsurugi_db"
psql tsurugi_db -c "create extension tsurugi_fdw"
psql tsurugi_db -c "create server tsurugi foreign data wrapper tsurugi_fdw"
psql tsurugi_db -c "\\dx tsurugi_fdw"
psql tsurugi_db -c "\\des tsurugi"
