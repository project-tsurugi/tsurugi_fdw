CREATE OR REPLACE FUNCTION tg_show_tables
  (text DEFAULT null, text DEFAULT null, text DEFAULT 'summary', boolean DEFAULT true)
  RETURNS JSON AS 'tsurugi_fdw' LANGUAGE C;

CREATE OR REPLACE FUNCTION tg_verify_tables
  (text DEFAULT null, text DEFAULT null, text DEFAULT null, text DEFAULT 'summary', boolean DEFAULT true)
  RETURNS JSON AS 'tsurugi_fdw' LANGUAGE C;

CREATE OR REPLACE FUNCTION tg_execute_ddl(text DEFAULT null, text DEFAULT null) RETURNS TEXT
  AS 'tsurugi_fdw' LANGUAGE C;
