DDL_FILE_TG="${TEST_DIR}/test_ddl_drop_tg.sql"
DDL_FILE_PG="${TEST_DIR}/test_ddl_drop_pg.sql"
TABLE_MAX=1000

echo "BEGIN;" > $DDL_FILE_TG
echo "BEGIN;" > $DDL_FILE_PG
for i in $(seq 1 $TABLE_MAX); do
  echo "DROP TABLE IF EXISTS udf_test_table_${i};" >> $DDL_FILE_TG
  echo "DROP FOREIGN TABLE IF EXISTS udf_test_table_${i};" >> $DDL_FILE_PG
done
echo "COMMIT;" >> $DDL_FILE_TG
echo "COMMIT;" >> $DDL_FILE_PG

$TGSQL --script $DDL_FILE_TG
rm $DDL_FILE_TG

$PSQL < $DDL_FILE_PG
rm $DDL_FILE_PG
