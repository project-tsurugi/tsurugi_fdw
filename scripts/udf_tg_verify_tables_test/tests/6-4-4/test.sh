$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', NULL, true)"
