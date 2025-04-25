$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'other_server', 'detail', true)"
