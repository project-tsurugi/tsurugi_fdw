-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION tsurugi_fdw" to load this file. \quit

CREATE FUNCTION tsurugi_fdw_handler() 
  RETURNS fdw_handler AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER tsurugi_fdw
  HANDLER tsurugi_fdw_handler;
