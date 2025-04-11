$TGSQL --exec "
  CREATE TABLE fdw_test_type_str (
    col_char CHAR,
    col_char_l CHAR(64),
    col_character CHARACTER,
    col_character_l CHARACTER(64),
    col_varchar VARCHAR,
    col_varchar_l VARCHAR(64),
    col_char_varying CHAR VARYING,
    col_char_varying_l CHAR VARYING(64),
    col_character_varying CHARACTER VARYING,
    col_character_varying_l CHARACTER VARYING(64));
"
