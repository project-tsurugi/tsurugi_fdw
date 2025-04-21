$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'invalid_schema', 'detail', true)"
