DDL_FILE="${TEST_DIR}/test_ddl_create.sql"
TABLE_MAX=1000
COLUMN_MAX=50

echo "BEGIN;" > $DDL_FILE
for i in $(seq 1 $TABLE_MAX); do
  CREATE_TABLE="CREATE TABLE fdw_test_table_${i} ("
  for j in $(seq 1 $COLUMN_MAX); do
    if [[ $j != 1 ]]; then
      CREATE_TABLE+=","
    fi
    CREATE_TABLE+="col_${j} INT"
  done
  CREATE_TABLE+=");"
  echo "$CREATE_TABLE" >> $DDL_FILE
done
echo "COMMIT;" >> $DDL_FILE

$TGSQL --script $DDL_FILE
rm $DDL_FILE
