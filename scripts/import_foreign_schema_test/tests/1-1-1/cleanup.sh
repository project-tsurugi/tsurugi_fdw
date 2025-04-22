$TGSQL --exec "DROP TABLE IF EXISTS fdw_test_table_1"

$PSQL -c "DROP FOREIGN TABLE IF EXISTS fdw_test_table_1"
