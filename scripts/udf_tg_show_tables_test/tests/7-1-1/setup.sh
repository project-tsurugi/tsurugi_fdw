DDL_FILE="${TEST_DIR}/test_ddl_create.sql"
TABLE_MAX=1000
COLUMN_MAX=50

COLUMNS_DEF=""
for i in $(seq 1 $COLUMN_MAX); do
  if [[ $i != 1 ]]; then
    COLUMNS_DEF+=","
  fi
  COLUMNS_DEF+="col_${i} INT"
done

echo "BEGIN;" > $DDL_FILE
for i in $(seq 1 $TABLE_MAX); do
  TABLE_DEF="udf_test_table_${i} (${COLUMNS_DEF})"

  echo "CREATE TABLE ${TABLE_DEF};" >> $DDL_FILE
done
echo "COMMIT;" >> $DDL_FILE

$TGSQL --script $DDL_FILE
rm $DDL_FILE
