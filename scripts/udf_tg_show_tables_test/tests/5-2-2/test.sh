$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', '', 'summary', true)"
