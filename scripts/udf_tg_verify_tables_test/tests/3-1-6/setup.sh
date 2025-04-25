$TGSQL --exec "
  CREATE TABLE udf_test_table_remote_1 (id INT, name VARCHAR);
  CREATE TABLE udf_test_table_matched_1 (id INT, name CHAR(64));
  CREATE TABLE udf_test_table_unmatched_1 (id BIGINT, since DATE);
  CREATE TABLE udf_test_table_unmatched_2 (id DECIMAL, schedule TIMESTAMP);
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_local_1 (id integer, name text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_local_2 (id integer, name text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_matched_1 (id integer, name text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_unmatched_1 (id real, since date) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_unmatched_2 (id integer, schedule timestamptz) SERVER tsurugi"