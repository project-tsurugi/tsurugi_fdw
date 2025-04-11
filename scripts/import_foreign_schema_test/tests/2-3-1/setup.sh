$TGSQL --exec "
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64));
  CREATE TABLE fdw_test_table_2 (id INT, since DATE);
  CREATE TABLE fdw_test_table_3 (id INT, timer TIME);
"

$PSQL \
  -c "CREATE FOREIGN TABLE fdw_test_table_2 (id INT, since DATE) SERVER tsurugi"
