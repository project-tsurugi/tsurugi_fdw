$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_1
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_1"
