CREATE OR REPLACE FUNCTION tsurugi_fdw_validator(text[], oid)
  RETURNS void AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

ALTER FOREIGN DATA WRAPPER tsurugi_fdw
  VALIDATOR tsurugi_fdw_validator;

CREATE OR REPLACE FUNCTION tg_show_tables
  (text DEFAULT null, text DEFAULT null, text DEFAULT 'detail', boolean DEFAULT true)
  RETURNS JSON AS 'tsurugi_fdw' LANGUAGE C;
