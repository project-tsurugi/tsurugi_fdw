$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (id INT);
  CREATE TABLE udf_test_table_2 (id INT, name CHAR(128), address VARCHAR, tel CHAR(24), since DATE, schedule TIMESTAMP);
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_1 (id integer) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_2 (id integer, name text, address text, tel text, since date, schedule timestamp) SERVER tsurugi"
