$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_type_num"

$PSQL \
  -c "INSERT INTO fdw_test_type_num (col_int, col_bigint, col_real, col_float, col_double, col_double_precision, col_decimal, col_decimal_p, col_decimal_ps, col_decimal_max) VALUES (1, 2, 3.33, 4.44, 5.55, 6.66, 77777, 88, 9.99, 1000)" \
  -c "SELECT * FROM fdw_test_type_num"

$TGSQL --exec "SELECT * FROM fdw_test_type_num" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"

$PSQL \
  -c "UPDATE fdw_test_type_num SET col_int = 2, col_bigint = 3, col_real = 4.567, col_float = 5.678, col_double = 6.78901, col_double_precision = 7.89012, col_decimal = 890, col_decimal_p = 90, col_decimal_ps = 1.23, col_decimal_max = 99999 WHERE col_int = 1" \
  -c "SELECT * FROM fdw_test_type_num"

$TGSQL --exec "SELECT * FROM fdw_test_type_num" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"

$PSQL \
  -c "DELETE FROM fdw_test_type_num WHERE col_double = 6.78901" \
  -c "SELECT * FROM fdw_test_type_num"

$TGSQL --exec "SELECT * FROM fdw_test_type_num" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"
