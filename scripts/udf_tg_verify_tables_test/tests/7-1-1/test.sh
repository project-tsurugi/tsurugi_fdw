timeout 5s $PSQL \
  -c "SELECT tg_verify_tables('tsurugidb', 'tsurugi', 'public', 'detail', true)"

test $? == 127 && pgrep -f "SELECT" | xargs kill -9 2>/dev/null
