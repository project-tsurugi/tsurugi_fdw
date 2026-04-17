CREATE EXTENSION IF NOT EXISTS tsurugi_fdw;
CREATE SERVER IF NOT EXISTS tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;
CREATE USER MAPPING IF NOT EXISTS FOR postgres SERVER tsurugidb OPTIONS (user 'tsurugi', password 'password');

\dx tsurugi_fdw
\deu postgres
