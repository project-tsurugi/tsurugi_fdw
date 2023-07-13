CREATE FUNCTION tg_set_transaction(text, text, text) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_transaction(text, text) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_transaction(text) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_write_preserve(variadic text[]) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_show_transaction() RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_start_transaction(text, text, text) RETURNS void
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_start_transaction(text, text) RETURNS void
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_start_transaction(text) RETURNS void
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_start_transaction() RETURNS void
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_commit() RETURNS void
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_rollback() RETURNS void
  AS 'ogawayama_fdw' LANGUAGE C STRICT;
