$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'detail', true)->'remote_schema'->'tables_on_remote_schema'->'list'"
