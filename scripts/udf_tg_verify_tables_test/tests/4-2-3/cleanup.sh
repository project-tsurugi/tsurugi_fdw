$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_1;
  DROP TABLE IF EXISTS udf_test_table_2;
  DROP TABLE IF EXISTS udf_test_table_3;
"

$PSQL \
  -c "DROP SERVER IF EXISTS \"Tsurugi\" CASCADE" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_1" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_2"
