$PSQL \
  -c "SELECT tg_verify_tables('invalid_schema', 'tsurugi', 'public', 'detail', true)"
