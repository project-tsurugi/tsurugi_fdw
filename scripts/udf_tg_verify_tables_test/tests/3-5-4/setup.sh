$TGSQL --exec "
  CREATE TABLE udf_test_table_int (col INT);
  CREATE TABLE udf_test_table_bigint (col BIGINT);
  CREATE TABLE udf_test_table_real (col REAL);
  CREATE TABLE udf_test_table_float (col FLOAT);
  CREATE TABLE udf_test_table_double (col DOUBLE);
  CREATE TABLE udf_test_table_double_precision (col DOUBLE PRECISION);
  CREATE TABLE udf_test_table_decimal (col DECIMAL);
  CREATE TABLE udf_test_table_decimal_p (col DECIMAL(5));
  CREATE TABLE udf_test_table_decimal_ps (col DECIMAL(5, 1));
  CREATE TABLE udf_test_table_decimal_max (col DECIMAL(*));
  CREATE TABLE udf_test_table_decimal_p2 (col DECIMAL(5));
  CREATE TABLE udf_test_table_decimal_ps2 (col DECIMAL(5, 1));
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_int (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_bigint (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_real (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_float (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_double (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_double_precision (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal (col integer) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_p (col integer) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_ps (col integer) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_max (col integer) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_p2 (col numeric(5)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_ps2 (col numeric(5, 1)) SERVER tsurugi"
