$TGSQL --exec "
  DROP TABLE IF EXISTS fdw_test_table_name2_________3_________4_________5_________6__;
"

$PSQL \
  -c "DROP FOREIGN TABLE IF EXISTS fdw_test_table_name2_________3_________4_________5_________6__"
