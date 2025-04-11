$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d \"fdw_test_table_a\"" \
  -c "\d \"fdw_test_TABLE_B\""
