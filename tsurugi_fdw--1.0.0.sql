-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION tsurugi_fdw" to load this file. \quit

CREATE FUNCTION tsurugi_fdw_handler() 
  RETURNS fdw_handler AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER tsurugi_fdw
  HANDLER tsurugi_fdw_handler;

CREATE FUNCTION tg_set_transaction(text, text, text) RETURNS cstring
  AS 'tsurugi_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_transaction(text, text) RETURNS cstring
  AS 'tsurugi_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_transaction(text) RETURNS cstring
  AS 'tsurugi_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_write_preserve(variadic text[]) RETURNS cstring
  AS 'tsurugi_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_inclusive_read_areas(variadic text[]) RETURNS cstring
  AS 'tsurugi_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_exclusive_read_areas(variadic text[]) RETURNS cstring
  AS 'tsurugi_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_show_transaction() RETURNS cstring
  AS 'tsurugi_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_show_tables
  (text DEFAULT null, text DEFAULT null, text DEFAULT 'summary', boolean DEFAULT true)
  RETURNS JSON AS 'tsurugi_fdw' LANGUAGE C;

CREATE FUNCTION tg_verify_tables
  (text DEFAULT null, text DEFAULT null, text DEFAULT null, text DEFAULT 'summary', boolean DEFAULT true)
  RETURNS JSON AS 'tsurugi_fdw' LANGUAGE C;

CREATE FUNCTION tg_execute_ddl(text DEFAULT null, text DEFAULT null) RETURNS TEXT
  AS 'tsurugi_fdw' LANGUAGE C;
