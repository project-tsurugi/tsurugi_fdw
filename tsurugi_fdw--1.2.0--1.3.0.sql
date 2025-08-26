CREATE OR REPLACE FUNCTION tg_show_tables
  (text DEFAULT null, text DEFAULT null, text DEFAULT 'detail', boolean DEFAULT true)
  RETURNS JSON AS 'tsurugi_fdw' LANGUAGE C;
