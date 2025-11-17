#!/bin/bash
psql postgres -c "drop database if exists postgres_db"
psql postgres -c "create database postgres_db"
psql postgres -c "\\l postgres_db"
