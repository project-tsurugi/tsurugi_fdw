#!/bin/bash
# Fix below
# PostgreSQL install directory
PSQLHOME_FOR_TEST=~/pgsql
# connection port number
PORT=5432
# Fix above

PSQLBIN=$PSQLHOME_FOR_TEST/bin
TSURUGI_METADATA=tsurugi_metadata
TSURUGI_METADATA_HOME=$PSQLHOME_FOR_TEST/data/$TSURUGI_METADATA

DATATYPES=datatypes.json
OID=oid
TABLES=tables.json

OK_COUNT=0
FAILED_COUNT=0

for TESTCASE in otable_of_constr ch-benchmark-ddl alternative happy unhappy
do
    rm -rf $TSURUGI_METADATA_HOME

    EXPECTED=$TESTCASE/expected
    TEST_SQL=$TESTCASE/$TESTCASE.sql
    TEST_RESULTS_OUTPUT=$TESTCASE.out
    TEST_RESULTS_OUTPUT_TSURUGI_METADATA=$EXPECTED/$TSURUGI_METADATA

    echo "[ RUN    ] TESTCASE NAME: $TESTCASE"
    $PSQLBIN/psql -p $PORT -a postgres < $TEST_SQL > $TEST_RESULTS_OUTPUT 2>&1

    diff $TEST_RESULTS_OUTPUT $EXPECTED/$TEST_RESULTS_OUTPUT
    if [ $? -ne 0 ]; then
        FAILED_COUNT=`expr $FAILED_COUNT + 1`
        echo "[ FAILED ] $TEST_RESULTS_OUTPUT"
    else
        OK_COUNT=`expr $OK_COUNT + 1`
        echo "[     OK ] $TEST_RESULTS_OUTPUT"
    fi

    diff $TEST_RESULTS_OUTPUT_TSURUGI_METADATA/$DATATYPES $TSURUGI_METADATA_HOME/$DATATYPES
    if [ $? -ne 0 ]; then
        FAILED_COUNT=`expr $FAILED_COUNT + 1`
        echo "[ FAILED ] $DATATYPES"
    else
        OK_COUNT=`expr $OK_COUNT + 1`
        echo "[     OK ] $DATATYPES"
    fi

    diff $TEST_RESULTS_OUTPUT_TSURUGI_METADATA/$OID       $TSURUGI_METADATA_HOME/$OID
    if [ $? -ne 0 ]; then
        FAILED_COUNT=`expr $FAILED_COUNT + 1`
        echo "[ FAILED ] $OID"
    else
        OK_COUNT=`expr $OK_COUNT + 1`
        echo "[     OK ] $OID"
    fi

    diff $TEST_RESULTS_OUTPUT_TSURUGI_METADATA/$TABLES    $TSURUGI_METADATA_HOME/$TABLES
    if [ $? -ne 0 ]; then
        FAILED_COUNT=`expr $FAILED_COUNT + 1`
        echo "[ FAILED ] $TABLES"
    else
        OK_COUNT=`expr $OK_COUNT + 1`
        echo "[     OK ] $TABLES"
    fi
done

echo "[========]"
echo "[ FAILED ] $FAILED_COUNT tests"
echo "[ PASSED ] $OK_COUNT tests"
