$PSQL \
  -c "IMPORT FOREIGN SCHEMA public FROM SERVER tsurugi INTO public"

$PSQL \
  -c "\dE" \
  -c "\d fdw_test_type_str"

$PSQL \
  -c "INSERT INTO fdw_test_type_str (col_char, col_char_l, col_character, col_character_l, col_varchar, col_varchar_l, col_char_varying, col_char_varying_l, col_character_varying, col_character_varying_l) VALUES ('1', 'char', '2', 'character', 'varchar', 'varchar_l', 'char_varying', 'char_varying_l', 'character_varying', 'character_varying_l')" \
  -c "SELECT * FROM fdw_test_type_str"

$TGSQL --exec "SELECT * FROM fdw_test_type_str" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"

$PSQL \
  -c "UPDATE fdw_test_type_str SET col_char = '3', col_char_l = 'char_upd', col_character = '4', col_character_l = 'character_upd', col_varchar = 'varchar_upd', col_varchar_l = 'varchar_l_upd', col_char_varying = 'char_varying_upd', col_char_varying_l = 'char_varying_l_upd', col_character_varying = 'character_varying_upd', col_character_varying_l = 'character_varying_l_upd' WHERE col_char = '1'" \
  -c "SELECT * FROM fdw_test_type_str"

$TGSQL --exec "SELECT * FROM fdw_test_type_str" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"

$PSQL \
  -c "DELETE FROM fdw_test_type_str WHERE col_char = '3'" \
  -c "SELECT * FROM fdw_test_type_str"

$TGSQL --exec "SELECT * FROM fdw_test_type_str" 2>&1 | egrep -v "^\[.+\] (INFO) .+$"
