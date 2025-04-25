$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_remote_1;
  DROP TABLE IF EXISTS udf_test_table_matched_1;
  DROP TABLE IF EXISTS udf_test_table_unmatched_1;
  DROP TABLE IF EXISTS udf_test_table_unmatched_2;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_local_1" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_local_2" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_matched_1" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_unmatched_1" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_unmatched_2"
