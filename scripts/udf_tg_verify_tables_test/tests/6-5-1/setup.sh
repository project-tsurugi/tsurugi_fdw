$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64));
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_1 (id integer, name text) SERVER tsurugi"