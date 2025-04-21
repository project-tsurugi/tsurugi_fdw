$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'Summary', false)" \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'SUMMARY', false)" \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'Detail', false)" \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'DETAIL', false)"
