$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', NULL, 'detail', true)"
