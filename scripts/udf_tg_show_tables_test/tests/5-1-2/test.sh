$PSQL \
  -c "SELECT tg_show_tables('', 'tsurugi', 'summary', true)"
