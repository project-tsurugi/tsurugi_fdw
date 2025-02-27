$PSQL \
  -c "IMPORT FOREIGN SCHEMA public LIMIT TO (\"fdw_test_Table_A\") FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_*"
