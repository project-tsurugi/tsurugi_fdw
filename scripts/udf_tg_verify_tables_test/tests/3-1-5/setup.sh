$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_2 (id bigint, since date) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_3 (id numeric, schedule timestamp) SERVER tsurugi"
