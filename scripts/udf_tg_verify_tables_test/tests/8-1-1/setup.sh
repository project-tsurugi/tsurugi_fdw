DDL_FILE_TG="${TEST_DIR}/test_ddl_create_tg.sql"
DDL_FILE_PG="${TEST_DIR}/test_ddl_create_pg.sql"

TABLE_MAX=1000
COLUMN_MAX=50

COLUMNS_DEF=""
for i in $(seq 1 $COLUMN_MAX); do
  if [[ $i != 1 ]]; then
    COLUMNS_DEF+=","
  fi
  COLUMNS_DEF+="col_${i} INT"
done

echo "BEGIN;" > $DDL_FILE_TG
echo "BEGIN;" > $DDL_FILE_PG
for i in $(seq 1 $TABLE_MAX); do
  TABLE_DEF="udf_test_table_${i} (${COLUMNS_DEF})"

  echo "CREATE TABLE ${TABLE_DEF};" >> $DDL_FILE_TG
  echo "CREATE FOREIGN TABLE ${TABLE_DEF} SERVER tsurugi;" >> $DDL_FILE_PG
done
echo "COMMIT;" >> $DDL_FILE_TG
echo "COMMIT;" >> $DDL_FILE_PG

$TGSQL --script $DDL_FILE_TG
rm $DDL_FILE_TG

$PSQL < $DDL_FILE_PG
rm $DDL_FILE_PG
