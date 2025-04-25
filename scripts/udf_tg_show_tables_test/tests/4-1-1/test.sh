$PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'summary', true)->'remote_schema'->'tables_on_remote_schema'->'count'"
