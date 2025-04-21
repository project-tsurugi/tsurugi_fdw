$PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'unknown_server', 'public', 'summary', true)" 
