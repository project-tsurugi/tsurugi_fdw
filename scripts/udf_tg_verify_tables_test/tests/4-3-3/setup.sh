$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64));
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE);
  CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP);
"

$PSQL \
  -c "CREATE SCHEMA \"Public\"" \
  -c "CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_2 (id bigint, since date) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE \"Public\".udf_test_table_3 (id numeric, schedule timestamp) SERVER \"tsurugi\""
