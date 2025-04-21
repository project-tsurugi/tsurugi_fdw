$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', true)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'other_server', 'public', 'detail', true)"
