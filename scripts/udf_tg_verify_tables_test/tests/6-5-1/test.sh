$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'summary')" \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail')"