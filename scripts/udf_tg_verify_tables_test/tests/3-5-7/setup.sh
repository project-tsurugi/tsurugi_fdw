$TGSQL --exec "
  CREATE TABLE udf_test_table_binary (col BINARY);
  CREATE TABLE udf_test_table_binary_l (col BINARY(64));
  CREATE TABLE udf_test_table_varbinary (col VARBINARY);
  CREATE TABLE udf_test_table_varbinary_l (col VARBINARY(64));
  CREATE TABLE udf_test_table_binary_varying (col BINARY VARYING);
  CREATE TABLE udf_test_table_binary_varying_l (col BINARY VARYING(64));
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_binary (col bytea) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_binary_l (col bytea) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_varbinary (col bytea) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_varbinary_l (col bytea) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_binary_varying (col bytea) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_binary_varying_l (col bytea) SERVER tsurugi"
