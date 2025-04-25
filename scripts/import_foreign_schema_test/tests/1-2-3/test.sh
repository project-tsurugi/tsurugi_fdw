$PSQL \
  -c "IMPORT FOREIGN SCHEMA public LIMIT TO (not_exist) FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE"
