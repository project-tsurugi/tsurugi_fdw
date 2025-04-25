$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (col_1 INT, col_2 VARCHAR, col_3 VARCHAR, col_4 VARCHAR, col_5 VARCHAR);
  CREATE TABLE udf_test_table_2 (col_1 INT, col_2 VARCHAR, col_3 VARCHAR, col_4 VARCHAR, col_5 VARCHAR);
  CREATE TABLE udf_test_table_3 (col_1 INT, col_2 VARCHAR, col_3 VARCHAR, col_4 VARCHAR, col_5 VARCHAR);
  CREATE TABLE udf_test_table_4 (col_1 INT, col_2 VARCHAR, col_3 VARCHAR, col_4 VARCHAR, col_5 VARCHAR);
"

$PSQL \
  -c 'CREATE FOREIGN TABLE udf_test_table_1 (invalid integer, col_2 text, col_3 text, col_4 text, col_5 text ) SERVER tsurugi' \
  -c 'CREATE FOREIGN TABLE udf_test_table_2 (col_1 integer, col_2 text, invalid text, col_4 text, col_5 text) SERVER tsurugi' \
  -c 'CREATE FOREIGN TABLE udf_test_table_3 (col_1 integer, col_2 text, col_3 text, col_4 text, invalid text) SERVER tsurugi' \
  -c 'CREATE FOREIGN TABLE udf_test_table_4 (col_1 integer, invalid_1 text, col_3 text, invalid_2 text, col_5 text) SERVER tsurugi'
