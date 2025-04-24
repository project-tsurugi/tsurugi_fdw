$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'unknown_server', 'detail', true)"
