$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (col_1 INT);
  CREATE TABLE udf_test_table_2 (col_1 INT, col_2 VARCHAR, col_3 DATE, col_4 TIME, col_5 DECIMAL);
"

$PSQL \
  -c 'CREATE FOREIGN TABLE udf_test_table_1 (col_1 integer) SERVER tsurugi' \
  -c 'CREATE FOREIGN TABLE udf_test_table_2 (col_1 integer, col_2 text, col_3 date, col_4 time, col_5 numeric) SERVER tsurugi'
  