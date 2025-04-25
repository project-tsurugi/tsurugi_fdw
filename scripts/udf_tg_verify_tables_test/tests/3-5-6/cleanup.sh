$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_date;
  DROP TABLE IF EXISTS udf_test_table_time;
  DROP TABLE IF EXISTS udf_test_table_timestamp;
  DROP TABLE IF EXISTS udf_test_table_time_with_time_zone;
  DROP TABLE IF EXISTS udf_test_table_timestamp_with_time_zone;
  DROP TABLE IF EXISTS udf_test_table_time_p;
  DROP TABLE IF EXISTS udf_test_table_timestamp_p;
  DROP TABLE IF EXISTS udf_test_table_time_with_time_zone_p;
  DROP TABLE IF EXISTS udf_test_table_timestamp_with_time_zone_p;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_date" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_time" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamp" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_time_with_time_zone" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamp_with_time_zone" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_time_p" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamp_p" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_time_with_time_zone_p" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_timestamp_with_time_zone_p"
