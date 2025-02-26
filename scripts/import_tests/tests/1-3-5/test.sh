$PSQL \
  -c "IMPORT FOREIGN SCHEMA public EXCEPT (fdw_test_table_1) FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE"
