$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'Summary', false)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'SUMMARY', false)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'Detail', false)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'DETAIL', false)"
