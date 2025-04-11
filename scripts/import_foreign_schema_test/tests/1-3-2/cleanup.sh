$TGSQL --exec "
  DROP TABLE IF EXISTS fdw_test_table_1;
  DROP TABLE IF EXISTS fdw_test_table_2;
  DROP TABLE IF EXISTS fdw_test_table_3;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS fdw_test_table_1" \
  -c "DROP FOREIGN TABLE IF EXISTS fdw_test_table_2" \
  -c "DROP FOREIGN TABLE IF EXISTS fdw_test_table_3"
