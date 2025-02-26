$PSQL \
  -c "IMPORT FOREIGN SCHEMA public LIMIT TO (fdw_test_table_1) FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE"
