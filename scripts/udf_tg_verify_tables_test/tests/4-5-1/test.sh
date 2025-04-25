$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', True)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', TRUE)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', False)" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary', FALSE)"
