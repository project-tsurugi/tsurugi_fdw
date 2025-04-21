$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_1;
  DROP TABLE IF EXISTS udf_test_table_2;
"

$PSQL \
  -c 'DROP SERVER IF EXISTS other_server'
