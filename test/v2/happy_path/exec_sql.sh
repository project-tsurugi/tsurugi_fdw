PSQLHOME_FOR_TEST=~/pgsql12cov/bin
 ../../rm_metadata.sh
$PSQLHOME_FOR_TEST/psql -p 5438 -a postgres < happy.sql > expected/happy.out 2>&1
