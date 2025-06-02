-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION tsurugi_fdw UPDATE TO '1.1.1'" to load this file. \quit

CREATE FUNCTION tg_execute_ddl(text DEFAULT null, text DEFAULT null) RETURNS TEXT
  AS 'tsurugi_fdw' LANGUAGE C;
