$TGSQL --exec "
  DROP TABLE IF EXISTS fdw_test_table_a;
"

$PSQL \
  -c 'DROP FOREIGN TABLE IF EXISTS fdw_test_table_a'
