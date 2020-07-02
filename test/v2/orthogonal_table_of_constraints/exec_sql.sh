PSQLHOME_FOR_TEST=~/pgsql12cov/bin
../rm_metadata.sh
$PSQLHOME_FOR_TEST/psql -p 5438 -a postgres < orthogonal_table_of_constraints.sql > expected/orthogonal_table_of_constraints.out 2>&1
