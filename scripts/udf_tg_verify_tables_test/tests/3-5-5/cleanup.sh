$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_char;
  DROP TABLE IF EXISTS udf_test_table_char_l;
  DROP TABLE IF EXISTS udf_test_table_character;
  DROP TABLE IF EXISTS udf_test_table_character_l;
  DROP TABLE IF EXISTS udf_test_table_varchar;
  DROP TABLE IF EXISTS udf_test_table_varchar_l;
  DROP TABLE IF EXISTS udf_test_table_char_varying;
  DROP TABLE IF EXISTS udf_test_table_char_varying_l;
  DROP TABLE IF EXISTS udf_test_table_character_varying;
  DROP TABLE IF EXISTS udf_test_table_character_varying_l;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char_l" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character_l" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_varchar" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_varchar_l" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char_varying" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char_varying_l" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character_varying" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character_varying_l"
