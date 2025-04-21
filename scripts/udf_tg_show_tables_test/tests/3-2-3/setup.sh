$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64));
"

$PSQL \
  -c "CREATE SERVER \"Tsurugi\" FOREIGN DATA WRAPPER tsurugi_fdw"
