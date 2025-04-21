$PSQL \
  -c "SELECT tg_verify_tables('', 'tsurugi', 'public', 'summary', true)"
