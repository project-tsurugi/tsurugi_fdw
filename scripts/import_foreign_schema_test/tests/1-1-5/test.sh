$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO other_schema"

$PSQL \
  -c "\dE" \
  -c "\dE other_schema.*" \
  -c "\d other_schema.fdw_test_table_1"
