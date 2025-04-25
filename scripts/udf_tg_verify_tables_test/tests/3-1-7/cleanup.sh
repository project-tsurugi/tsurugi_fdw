$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_1;
  DROP TABLE IF EXISTS Udf_Test_Table_1;
  DROP TABLE IF EXISTS UDF_test_table_2;
"

$PSQL \
  -c 'DROP FOREIGN TABLE IF EXISTS udf_test_table_1' \
  -c 'DROP FOREIGN TABLE IF EXISTS "Udf_Test_Table_1"' \
  -c 'DROP FOREIGN TABLE IF EXISTS UDF_test_table_2'