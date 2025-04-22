$TGSQL --exec "
  DROP TABLE IF EXISTS fdw_test_type_datetime;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS fdw_test_type_datetime"
