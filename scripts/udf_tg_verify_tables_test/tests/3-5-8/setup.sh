$TGSQL --exec "
  CREATE TABLE udf_test_table_boolean (col INT);
  CREATE TABLE udf_test_table_smallint (col INT);
  CREATE TABLE udf_test_table_numeric_p (col DECIMAL(5));
  CREATE TABLE udf_test_table_varchar (col VARCHAR);
  CREATE TABLE udf_test_table_char (col CHAR);
  CREATE TABLE udf_test_table_bytea (col BINARY);
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_boolean (col boolean) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_smallint (col smallint) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_numeric_p (col numeric(5)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_varchar (col varchar) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_char (col char) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_bytea (col bytea) SERVER tsurugi"
