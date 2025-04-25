$TGSQL --exec "
  CREATE TABLE udf_test_table_char (col CHAR);
  CREATE TABLE udf_test_table_char_len (col CHAR(64));
  CREATE TABLE udf_test_table_character (col CHARACTER);
  CREATE TABLE udf_test_table_character_len (col CHARACTER(64));
  CREATE TABLE udf_test_table_varchar (col VARCHAR);
  CREATE TABLE udf_test_table_varchar_len (col VARCHAR(64));
  CREATE TABLE udf_test_table_char_varying (col CHAR VARYING);
  CREATE TABLE udf_test_table_char_varying_len (col CHAR VARYING(64));
  CREATE TABLE udf_test_table_character_varying (col CHARACTER VARYING);
  CREATE TABLE udf_test_table_character_varying_len (col CHARACTER VARYING(64));
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_char (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_char_len (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character_len (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_varchar (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_varchar_len (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_char_varying (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_char_varying_len (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character_varying (col text) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character_varying_len (col text) SERVER tsurugi"
