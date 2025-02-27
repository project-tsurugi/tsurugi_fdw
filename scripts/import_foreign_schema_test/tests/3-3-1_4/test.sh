$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_type_datetime"

$PSQL \
  -c "INSERT INTO fdw_test_type_datetime (col_date, col_time, col_timestamp, col_timestamp_tz) VALUES (DATE '2025-01-23', TIME '08:09:10', TIMESTAMP '2025-01-23 08:09:10', TIMESTAMP WITH TIME ZONE '2025-01-23 08:09:10+09')" \
  -c "SELECT * FROM fdw_test_type_datetime"

$TGSQL --exec "SELECT * FROM fdw_test_type_datetime" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"

$PSQL \
  -c "UPDATE fdw_test_type_datetime SET col_date = DATE '2025-02-12', col_time = TIME '09:10:11', col_timestamp = TIMESTAMP '2025-02-12 09:10:11', col_timestamp_tz = TIMESTAMP WITH TIME ZONE '2025-02-12 09:10:11+09' WHERE col_date = DATE '2025-01-23'" \
  -c "SELECT * FROM fdw_test_type_datetime"

$TGSQL --exec "SELECT * FROM fdw_test_type_datetime" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"

$PSQL \
  -c "DELETE FROM fdw_test_type_datetime WHERE col_date = DATE '2025-02-12'" \
  -c "SELECT * FROM fdw_test_type_datetime"

$TGSQL --exec "SELECT * FROM fdw_test_type_datetime" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"
