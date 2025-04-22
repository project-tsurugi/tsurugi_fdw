$TGSQL --exec "
  CREATE TABLE fdw_test_type_datetime (
    col_date DATE,
    col_time TIME,
    col_time_tz TIME WITH TIME ZONE,
    col_timestamp TIMESTAMP,
    col_timestamp_tz TIMESTAMP WITH TIME ZONE);
"
