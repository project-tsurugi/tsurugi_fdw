$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_char;
  DROP TABLE IF EXISTS udf_test_table_char_len;
  DROP TABLE IF EXISTS udf_test_table_character;
  DROP TABLE IF EXISTS udf_test_table_character_len;
  DROP TABLE IF EXISTS udf_test_table_varchar;
  DROP TABLE IF EXISTS udf_test_table_varchar_len;
  DROP TABLE IF EXISTS udf_test_table_char_varying;
  DROP TABLE IF EXISTS udf_test_table_char_varying_len;
  DROP TABLE IF EXISTS udf_test_table_character_varying;
  DROP TABLE IF EXISTS udf_test_table_character_varying_len;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char_len" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character_len" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_varchar" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_varchar_len" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char_varying" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_char_varying_len" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character_varying" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_character_varying_len"
