PSQLHOME_FOR_TEST=~/pgsql12cov/bin
$PSQLHOME_FOR_TEST/psql -p 5438 -a postgres < orthogonal_table_of_constraints.sql > expected/orthogonal_table_of_constraints.table_name_already_exists 2>&1
