PSQLHOME_FOR_TEST=~/pgsql12cov/bin
../rm_metadata.sh
$PSQLHOME_FOR_TEST/psql -p 5438 -a postgres < unhappy.sql > expected/unhappy.out 2>&1
