$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE"
