$PSQL \
  -c "IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_1, fdw_test_table_3) FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_table_*"
