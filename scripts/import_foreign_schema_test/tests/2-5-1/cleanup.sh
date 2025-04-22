$TGSQL --exec "
  DROP TABLE IF EXISTS fdw_test_table_A;
  DROP TABLE IF EXISTS fdw_test_Table_A;
  DROP TABLE IF EXISTS fdw_test_table_a;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS \"fdw_test_table_A\"" \
  -c "DROP FOREIGN TABLE IF EXISTS \"fdw_test_Table_A\""
