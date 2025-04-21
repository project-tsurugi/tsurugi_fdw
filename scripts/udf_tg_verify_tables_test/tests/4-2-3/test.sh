$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', true)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'Tsurugi', 'public', 'detail', true)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'TSURUGI', 'public', 'detail', true)"
