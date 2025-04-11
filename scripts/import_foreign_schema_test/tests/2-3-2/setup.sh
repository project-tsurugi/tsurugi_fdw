$TGSQL --exec "
  CREATE TABLE fdw_test_table_a (id INT, name CHAR(64));
  CREATE TABLE fdw_test_TABLE_B (id INT, since DATE);
"

$PSQL \
  -c "CREATE FOREIGN TABLE \"fdw_test_TABLE_A\" (col1 INT, col2 VARCHAR) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE \"fdw_test_table_b\" (col1 INT, col2 DATE) SERVER tsurugi"
