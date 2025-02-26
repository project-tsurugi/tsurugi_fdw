$TGSQL --exec "
  CREATE TABLE fdw_test_table_1 (id INT, name CHAR(64));
  CREATE TABLE fdw_test_table_2 (id BIGINT, since DATE);
"
