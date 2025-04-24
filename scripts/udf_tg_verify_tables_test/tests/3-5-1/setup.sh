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
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_int (col integer) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_bigint (col bigint) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_real (col real) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_float (col real) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_double (col double precision) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_double_precision (col double precision) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_p (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_ps (col numeric) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_decimal_max (col numeric) SERVER tsurugi"
