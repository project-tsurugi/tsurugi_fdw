DATATYPES=datatypes.json
OID=oid
TABLES=tables.json
OUTPUT=~/pgsql12cov/data/tsurugi_metadata/

diff $DATATYPES $OUTPUT$DATATYPES
diff $OID $OUTPUT$OID
diff $TABLES $OUTPUT$TABLES
