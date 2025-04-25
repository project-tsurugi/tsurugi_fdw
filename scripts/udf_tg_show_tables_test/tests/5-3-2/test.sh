$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'invalid_mode', true)"
