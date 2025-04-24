$PSQL \
  -c "SELECT tg_verify_tables(NULL, 'tsurugi', 'public', 'summary', true)"
