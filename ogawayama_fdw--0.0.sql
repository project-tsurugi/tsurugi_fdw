-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION ogawayama_fdw" to load this file. \quit

CREATE FUNCTION ogawayama_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER ogawayama_fdw
  HANDLER ogawayama_fdw_handler;
