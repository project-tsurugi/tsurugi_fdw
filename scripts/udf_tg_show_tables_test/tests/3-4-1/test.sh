$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'summary', False)" \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'summary', FALSE)" \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'summary', True)" \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'summary', TRUE)"
