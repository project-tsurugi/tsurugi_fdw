PSQLHOME_FOR_TEST=~/pgsql12cov/bin
../rm_metadata.sh
$PSQLHOME_FOR_TEST/psql -p 5438 -a postgres < ch-benchmark-ddl.sql > expected/ch-benchmark-ddl.out 2>&1
