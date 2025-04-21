$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', true)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'other_schema', 'detail', true)"
