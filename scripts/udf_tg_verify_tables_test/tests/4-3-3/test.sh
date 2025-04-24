$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', true)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'Public', 'detail', true)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'PUBLIC', 'detail', true)"
