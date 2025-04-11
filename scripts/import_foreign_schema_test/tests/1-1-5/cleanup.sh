$TGSQL --exec "DROP TABLE IF EXISTS fdw_test_table_1"

$PSQL -c "DROP SCHEMA IF EXISTS other_schema CASCADE" 
