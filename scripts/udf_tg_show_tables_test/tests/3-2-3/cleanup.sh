$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_1;
"

$PSQL \
  -c "DROP SERVER IF EXISTS \"Tsurugi\""
