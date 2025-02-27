$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_table_1" \
  -c "\d fdw_test_table_50" \
  -c "\d fdw_test_table_256" \
  -c "\d fdw_test_table_512" \
  -c "\d fdw_test_table_999" \
  -c "\d fdw_test_table_1000"
