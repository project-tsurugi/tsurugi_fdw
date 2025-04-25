$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', false)->'verification'->'tables_on_only_remote_schema'->'count'" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', false)->'verification'->'foreign_tables_on_only_local_schema'->'count'" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', false)->'verification'->'tables_that_need_to_be_altered'->'count'" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', false)->'verification'->'available_foreign_table'->'count'"
