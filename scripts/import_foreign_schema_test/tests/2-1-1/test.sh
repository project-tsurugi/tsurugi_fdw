$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public" \
  -c "INSERT INTO \"fdw_test_table_A\" VALUES (1, 'information')" \
  -c "INSERT INTO \"fdw_test_Table_A\" VALUES (1, DATE '2025-01-02')" \
  -c "INSERT INTO \"fdw_test_table_a\" VALUES (1, TIME '11:22:33')"

$PSQL \
  -c "\dE" \
  -c "\d \"fdw_test_table_A\"" \
  -c "\d \"fdw_test_Table_A\"" \
  -c "\d \"fdw_test_table_a\"" \
  -c "SELECT * FROM \"fdw_test_table_A\"" \
  -c "SELECT * FROM \"fdw_test_Table_A\"" \
  -c "SELECT * FROM \"fdw_test_table_a\""

