CREATE EXTENSION IF NOT EXISTS tsurugi_fdw;
CREATE SERVER IF NOT EXISTS tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;

SELECT e.extname "Name", e.extversion "Version", d.description "Description"
  FROM pg_extension e JOIN pg_description d ON e.oid = d.objoid
  WHERE e.extname = 'tsurugi_fdw';
