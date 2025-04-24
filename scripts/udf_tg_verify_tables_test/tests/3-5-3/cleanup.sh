$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_date;
  DROP TABLE IF EXISTS udf_test_table_time;
  DROP TABLE IF EXISTS udf_test_table_time_without_time_zone;
  DROP TABLE IF EXISTS udf_test_table_timestamp;
  DROP TABLE IF EXISTS udf_test_table_timestamp_without_time_zone;
  DROP TABLE IF EXISTS udf_test_table_timetz;
  DROP TABLE IF EXISTS udf_test_table_time_with_time_zone;
  DROP TABLE IF EXISTS udf_test_table_timestamptz;
  DROP TABLE IF EXISTS udf_test_table_timestamp_with_time_zone;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_date" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_time" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_time_without_time_zone" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamp" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamp_without_time_zone" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timetz" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_time_with_time_zone" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamptz" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamp_with_time_zone"
