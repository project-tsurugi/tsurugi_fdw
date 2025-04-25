$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_1;
  DROP TABLE IF EXISTS udf_test_table_2;
  DROP TABLE IF EXISTS udf_test_table_3;
  DROP TABLE IF EXISTS udf_test_table_4;
  "

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_1" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_2" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_3" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_4"
