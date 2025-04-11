$TGSQL --exec "
  DROP TABLE IF EXISTS fdw_test_table_a;
  DROP TABLE IF EXISTS fdw_test_TABLE_B;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS \"fdw_test_TABLE_A\"" \
  -c "DROP FOREIGN TABLE IF EXISTS \"fdw_test_table_b\"" \
  -c "DROP FOREIGN TABLE IF EXISTS \"fdw_test_table_a\"" \
  -c "DROP FOREIGN TABLE IF EXISTS \"fdw_test_TABLE_B\""
