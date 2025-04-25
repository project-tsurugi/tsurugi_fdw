$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64));
  CREATE TABLE Udf_Test_Table_1 (id BIGINT, since DATE);
  CREATE TABLE UDF_test_table_2 (id BIGINT, name VARCHAR);
"

$PSQL \
  -c 'CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugi' \
  -c 'CREATE FOREIGN TABLE "Udf_Test_Table_1" (id bigint, since date) SERVER tsurugi' \
  -c 'CREATE FOREIGN TABLE UDF_test_table_2 (id bigint, name text) SERVER tsurugi'
