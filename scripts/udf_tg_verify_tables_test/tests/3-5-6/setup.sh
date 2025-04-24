$TGSQL --exec "
  CREATE TABLE udf_test_table_date (col DATE);
  CREATE TABLE udf_test_table_time (col TIME);
  CREATE TABLE udf_test_table_timestamp (col TIMESTAMP);
  CREATE TABLE udf_test_table_time_with_time_zone (col TIME WITH TIME ZONE);
  CREATE TABLE udf_test_table_timestamp_with_time_zone (col TIMESTAMP WITH TIME ZONE);
  CREATE TABLE udf_test_table_time_p (col TIME);
  CREATE TABLE udf_test_table_timestamp_p (col TIMESTAMP);
  CREATE TABLE udf_test_table_time_with_time_zone_p (col TIME WITH TIME ZONE);
  CREATE TABLE udf_test_table_timestamp_with_time_zone_p (col TIMESTAMP WITH TIME ZONE);
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_date (col time) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_time (col time with time zone) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamp (col timestamp with time zone) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_time_with_time_zone (col time) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamp_with_time_zone (col timestamp) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_time_p (col time(3)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamp_p (col timestamp(3)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_time_with_time_zone_p (col time(3) with time zone) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_timestamp_with_time_zone_p (col timestamp(3) with time zone) SERVER tsurugi"
