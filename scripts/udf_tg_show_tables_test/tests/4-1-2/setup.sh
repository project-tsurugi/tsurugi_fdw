$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (id INT, name CHAR(64));
  CREATE TABLE udf_test_table_2 (id BIGINT, since DATE);
  CREATE TABLE udf_test_table_3 (id DECIMAL, schedule TIMESTAMP);
"
