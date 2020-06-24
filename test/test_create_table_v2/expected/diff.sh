DATATYPES=datatypes.json
OID=oid
TABLES=tables.json
OUTPUT=~/pgsql12/data/

diff $DATATYPES $OUTPUT$DATATYPES
diff $OID $OUTPUT$OID
diff $TABLES $OUTPUT$TABLES
