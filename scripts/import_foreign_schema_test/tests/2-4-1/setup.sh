$TGSQL --exec "
  CREATE TABLE fdw_test_table_A (id INT, name CHAR(64));
  CREATE TABLE fdw_test_Table_A (id BIGINT, since DATE);
  CREATE TABLE fdw_test_table_a (id DECIMAL, timer TIME);
"
