$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_binary;
  DROP TABLE IF EXISTS udf_test_table_binary_l;
  DROP TABLE IF EXISTS udf_test_table_varbinary;
  DROP TABLE IF EXISTS udf_test_table_varbinary_l;
  DROP TABLE IF EXISTS udf_test_table_binary_varying;
  DROP TABLE IF EXISTS udf_test_table_binary_varying_l;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_binary" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_binary_l" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_varbinary" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_varbinary_l" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_binary_varying" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_binary_varying_l"
