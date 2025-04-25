$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64));
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE);
"

$PSQL \
  -c 'CREATE SERVER other_server FOREIGN DATA WRAPPER tsurugi_fdw'
