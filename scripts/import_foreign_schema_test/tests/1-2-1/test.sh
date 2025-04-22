$PSQL \
  -c "IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_2) FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_table_*"
