$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (col_1 INT, col_2 VARCHAR, Col_2 DATE, COL_2 TIME);
  CREATE TABLE udf_test_table_2 (Col_1 INT, Col_2 VARCHAR);
"

$PSQL \
  -c 'CREATE FOREIGN TABLE udf_test_table_1 (col_1 integer, col_2 text, "Col_2" date, "COL_2" time) SERVER tsurugi' \
  -c 'CREATE FOREIGN TABLE udf_test_table_2 (col_1 integer, col_2 text) SERVER tsurugi'
