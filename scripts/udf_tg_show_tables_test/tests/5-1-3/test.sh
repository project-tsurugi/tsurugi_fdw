$PSQL \
  -c "SELECT tg_show_tables(NULL, 'tsurugi', 'summary', true)"
