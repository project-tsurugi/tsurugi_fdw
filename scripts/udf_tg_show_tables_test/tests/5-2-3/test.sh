$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', NULL, 'summary', true)"
