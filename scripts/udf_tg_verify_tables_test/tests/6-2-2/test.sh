$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', '', 'public', 'summary', true)"
