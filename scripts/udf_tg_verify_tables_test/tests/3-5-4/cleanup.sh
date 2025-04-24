$TGSQL --exec "
  DROP TABLE IF EXISTS udf_test_table_int;
  DROP TABLE IF EXISTS udf_test_table_bigint;
  DROP TABLE IF EXISTS udf_test_table_real;
  DROP TABLE IF EXISTS udf_test_table_float;
  DROP TABLE IF EXISTS udf_test_table_double;
  DROP TABLE IF EXISTS udf_test_table_double_precision;
  DROP TABLE IF EXISTS udf_test_table_decimal;
  DROP TABLE IF EXISTS udf_test_table_decimal_p;
  DROP TABLE IF EXISTS udf_test_table_decimal_ps;
  DROP TABLE IF EXISTS udf_test_table_decimal_max;
  DROP TABLE IF EXISTS udf_test_table_decimal_p2;
  DROP TABLE IF EXISTS udf_test_table_decimal_ps2;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_int" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_bigint" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_real" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_float" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_double" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_double_precision" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_decimal" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_decimal_p" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_decimal_ps" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_decimal_max" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_decimal_p2" \
  -c "DROP FOREIGN TABLE IF EXISTS udf_test_table_decimal_ps2"
