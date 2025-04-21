$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugi"
