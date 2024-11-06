 -- error
CREATE TABLE tsurugifdw_regressiontest_table(id INTEGER);
CREATE EXTENSION tsurugi_fdw;
DROP TABLE tsurugifdw_regressiontest_table;

CREATE EXTENSION IF NOT EXISTS tsurugi_fdw;
CREATE SERVER IF NOT EXISTS tsurugidb FOREIGN DATA WRAPPER tsurugi_fdw;

\dx tsurugi_fdw
