CREATE FUNCTION tg_transaction() RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_transaction(text) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;

CREATE FUNCTION tg_transaction(text, variadic text[]) RETURNS cstring
  AS 'ogawayama_fdw' LANGUAGE C STRICT;
