$TGSQL --exec "
  CREATE TABLE udf_test_table_char (col CHAR);
  CREATE TABLE udf_test_table_char_l (col CHAR(64));
  CREATE TABLE udf_test_table_character (col CHARACTER);
  CREATE TABLE udf_test_table_character_l (col CHARACTER(64));
  CREATE TABLE udf_test_table_varchar (col VARCHAR);
  CREATE TABLE udf_test_table_varchar_l (col VARCHAR(64));
  CREATE TABLE udf_test_table_char_varying (col CHAR VARYING);
  CREATE TABLE udf_test_table_char_varying_l (col CHAR VARYING(64));
  CREATE TABLE udf_test_table_character_varying (col CHARACTER VARYING);
  CREATE TABLE udf_test_table_character_varying_l (col CHARACTER VARYING(64));
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_char (col character) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_char_l (col character(64)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character (col character) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character_l (col character(64)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_varchar (col varchar) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_varchar_l (col varchar(64)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_char_varying (col varchar) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_char_varying_l (col varchar(64)) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character_varying (col varchar) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_character_varying_l (col varchar(64)) SERVER tsurugi"
