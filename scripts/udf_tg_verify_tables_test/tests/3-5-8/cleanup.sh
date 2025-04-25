$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_boolean;
  DROP TABLE IF EXISTS udf_test_table_smallint;
  DROP TABLE IF EXISTS udf_test_table_numeric_p;
  DROP TABLE IF EXISTS udf_test_table_varchar;
  DROP TABLE IF EXISTS udf_test_table_char;
  DROP TABLE IF EXISTS udf_test_table_bytea;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_boolean" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_smallint" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_numeric_p" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_varchar" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_bytea"
