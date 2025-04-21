timeout 5s $PSQL \
  -c "SELECT tg_show_tables('tsurugidb', 'tsurugi', 'detail', true)"

test $? != 0 && pgrep -f "SELECT" | xargs kill -9 2>/dev/null
