$TGSQL --exec "
  CREATE TABLE fdw_test_type_num (
    col_int INT,
    col_bigint BIGINT,
    col_real REAL,
    col_float FLOAT,
    col_double DOUBLE,
    col_double_precision DOUBLE PRECISION,
    col_decimal DECIMAL,
    col_decimal_p DECIMAL(2),
    col_decimal_ps DECIMAL(3, 2),
    col_decimal_max DECIMAL(*));
"
