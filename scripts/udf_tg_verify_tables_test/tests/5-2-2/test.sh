$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', false)->'verification'->'tables_on_only_remote_schema'->'list'" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', false)->'verification'->'foreign_tables_on_only_local_schema'->'list'" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', false)->'verification'->'tables_that_need_to_be_altered'->'list'" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', false)->'verification'->'available_foreign_table'->'list'"
