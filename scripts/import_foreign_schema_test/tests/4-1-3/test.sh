$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_table_name2_________3_________4_________5_________6___"
