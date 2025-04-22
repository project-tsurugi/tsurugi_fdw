timeout 5s $PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

test $? != 0 && pgrep -f "IMPORT FOREIGN SCHEMA" | xargs kill -9 2>/dev/null
