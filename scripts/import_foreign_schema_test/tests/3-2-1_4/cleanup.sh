$TGSQL --exec "
  DROP TABLE IF EXISTS fdw_test_type_str;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS fdw_test_type_str"
