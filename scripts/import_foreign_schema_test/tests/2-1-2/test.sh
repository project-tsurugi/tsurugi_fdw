$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public" \
  -c "INSERT INTO fdw_test_table_a VALUES (111, 'abcdefg', DATE '2025-01-02')"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_table_a" \
  -c "SELECT * FROM fdw_test_table_a"
