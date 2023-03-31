CREATE FUNCTION tg_set_transaction(text, text, text, variadic text[]) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_transaction(text, text, text) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_set_transaction(text) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_show_transaction() RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;
