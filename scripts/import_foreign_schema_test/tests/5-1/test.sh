$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER unknown_server INTO public"
