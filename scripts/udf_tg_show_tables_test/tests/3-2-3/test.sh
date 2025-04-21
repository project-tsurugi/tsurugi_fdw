$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'detail', true)" \
  -c "SELECT tg_show_tables('tsurugidb', 'Tsurugi', 'detail', true)" \
  -c "SELECT tg_show_tables('tsurugidb', 'TSURUGI', 'detail', true)"
