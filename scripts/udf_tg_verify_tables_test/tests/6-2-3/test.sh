$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', NULL, 'public', 'summary', true)"
