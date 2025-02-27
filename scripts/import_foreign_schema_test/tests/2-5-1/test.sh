$PSQL \
  -c "IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_Table_A) FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d \"fdw_test_table_A\"" \
  -c "\d \"fdw_test_Table_A\""
