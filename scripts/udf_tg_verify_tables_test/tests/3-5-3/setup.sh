$TGSQL --exec "
  CREATE TABLE udf_test_table_date (col DATE);
  CREATE TABLE udf_test_table_time (col TIME);
  CREATE TABLE udf_test_table_time_without_time_zone (col TIME);
  CREATE TABLE udf_test_table_timestamp (col TIMESTAMP);
  CREATE TABLE udf_test_table_timestamp_without_time_zone (col TIMESTAMP);
  CREATE TABLE udf_test_table_timetz (col TIME WITH TIME ZONE);
  CREATE TABLE udf_test_table_time_with_time_zone (col TIME WITH TIME ZONE);
  CREATE TABLE udf_test_table_timestamptz (col TIMESTAMP WITH TIME ZONE);
  CREATE TABLE udf_test_table_timestamp_with_time_zone (col TIMESTAMP WITH TIME ZONE);
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_date (col date) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_time (col time) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_time_without_time_zone (col time without time zone) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamp (col timestamp) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamp_without_time_zone (col timestamp without time zone) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timetz (col timetz) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_time_with_time_zone (col time with time zone) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamptz (col timestamptz) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamp_with_time_zone (col timestamp with time zone) SERVER tsurugi"
  