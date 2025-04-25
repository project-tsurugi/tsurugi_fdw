$PSQL \
  -c "SELECT tg_show_tables('invalid_schema', 'tsurugi', 'detail', true)"
