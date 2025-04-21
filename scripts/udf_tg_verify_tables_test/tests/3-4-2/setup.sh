$TGSQL --exec "
  CREATE TABLE udf_test_table_1 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 DATE,
    col_4 TIME,
    col_5 DECIMAL,
    col_6 INT,
    col_7 VARCHAR,
    col_8 DATE,
    col_9 TIME,
    col_10 DECIMAL
  );
  CREATE TABLE udf_test_table_2 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 DATE,
    col_4 TIME,
    col_5 DECIMAL,
    col_6 INT,
    col_7 VARCHAR,
    col_8 DATE,
    col_9 TIME,
    col_10 DECIMAL
  );
  CREATE TABLE udf_test_table_3 (
    col_1 INT,
    col_2 VARCHAR,
    col_3 DATE,
    col_4 TIME,
    col_5 DECIMAL,
    col_6 INT,
    col_7 VARCHAR,
    col_8 DATE,
    col_9 TIME,
    col_10 DECIMAL
  );
"

$PSQL \
  -c "CREATE FOREIGN TABLE udf_test_table_1 (
        col_2 text,
        col_1 integer,
        col_3 date,
        col_4 time,
        col_5 numeric,
        col_6 integer,
        col_7 text,
        col_8 date,
        col_9 time,
        col_10 numeric
     ) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_2 (
        col_1 integer,
        col_2 text,
        col_3 date,
        col_7 text,
        col_5 numeric,
        col_6 integer,
        col_4 time,
        col_8 date,
        col_9 time,
        col_10 numeric
     ) SERVER tsurugi" \
  -c "CREATE FOREIGN TABLE udf_test_table_3 (
        col_10 numeric,
        col_2 text,
        col_3 date,
        col_4 time,
        col_5 numeric,
        col_6 integer,
        col_7 text,
        col_8 date,
        col_9 time,
        col_1 integer
     ) SERVER tsurugi"
