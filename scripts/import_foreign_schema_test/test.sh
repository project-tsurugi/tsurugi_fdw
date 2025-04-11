#!/bin/bash

DIFF="/bin/diff -Bw"
BASE_DIR=$(dirname "$0")
TEST_RUNNER=${BASE_DIR}/_test_runner.sh
TEST_DIR=${BASE_DIR}/tests
RES_DIR=${BASE_DIR}/results
unset DEBUG

check_env() {
  local _res=0

  REQUIRED="$TEST_RUNNER psql tgsql tgctl"
  for _req_cmd in $REQUIRED; do
    if ! command -v ${_req_cmd} > /dev/null 2>&1; then
      echo "${_req_cmd}: No such command or no execution privileges"
      _res=1
    fi
  done

  return $_res
}

setup() {
  while getopts cdth _opt; do
    case "$_opt" in
      c)
        cleanup
        exit 0
        ;;
      d)
        DEBUG=1
        ;;
      t)
        TIME_FILE=${RES_DIR}/time_record.txt
        ;;
      h)
        usage
        exit 0
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  done

  rm -rf ${RES_DIR}
  mkdir -p ${RES_DIR}
}

cleanup() {
  printf "cleaning"
  for test_case in "$TEST_DIR"/*; do
    printf "."
    $TEST_RUNNER "${test_case}/cleanup.sh" > /dev/null 2>&1
  done
  rm -rf ${RES_DIR}
  printf "\nTest data cleaned up.\n"
}

usage() {
  echo "Usage: "$(basename $0)" [OPTIONS]"
  echo "  -c  Clean up tests data"
  echo "  -t  Time records mode"
  echo "  -d  Debug mode"
  echo "  -h  Show help message"
}

logging() {
  if [[ ! -z "$DEBUG" ]]; then
    printf "\n"
    printf "%0.s=" {1..80}
    printf "\n[$(date '+%Y-%m-%d %H:%M:%S')] $*\n"
    printf "%0.s-" {1..80}
    printf "\n"
  fi
}

main() {
  local _ok=0
  local _ng=0
  local _skip=0

  break_flag=0
  trap 'break_flag=1' SIGINT

  if [ ! -d $TEST_DIR ]; then
    exit 0
  fi

  for test_case in "$TEST_DIR"/*; do
    local _test_id=$(basename "$test_case")
    local _actual=${RES_DIR}/${_test_id}.out
    local _expected=${test_case}/expected.out
    local _output="/dev/null"

    if [[ $break_flag == 1 ]]; then
      break
    fi

    if [[ ! -d "$test_case" || "$_test_id" == "disable" ]]; then
      continue
    elif [[ "$_test_id" == *.skip ]]; then
      ((_skip++))
      continue
    fi

    if [[ ! -z "$DEBUG" ]]; then
      _output=${RES_DIR}/${_test_id}.log
      rm -f $_output
    fi

    printf "\r%64s\rTesting... %s" "" ${_test_id}

    FMT='%_DEBUG_%[$(date "+%Y-%m-%d %H:%M:%S")] '

    # Preparation
    logging "Preparation - cleanup" >> ${_output}
    PS4=$FMT DEBUG=$DEBUG $TEST_RUNNER "${test_case}/cleanup.sh" >> ${_output} 2>&1

    # Setup
    logging "Setup" >> ${_output}
    PS4=$FMT DEBUG=$DEBUG $TEST_RUNNER "${test_case}/setup.sh" $TIME_FILE >> ${_output} 2>&1

    # Testing
    logging "Testing" >> ${_output}
    PS4=$FMT DEBUG=$DEBUG $TEST_RUNNER "${test_case}/test.sh" $TIME_FILE > ${_actual}.tmp 2>&1
    test ! -z "$DEBUG" && cat ${_actual}.tmp >> ${_output}
    egrep -v "^%+_DEBUG_%" ${_actual}.tmp > ${_actual}
    rm -f ${_actual}.tmp

    # Tear down
    logging "Tear down - cleanup" >> ${_output}
    PS4=$FMT DEBUG=$DEBUG $TEST_RUNNER "${test_case}/cleanup.sh" $TIME_FILE >> ${_output} 2>&1

    # Verify results
    if [[ -f $_expected ]]; then
      res=$($DIFF $_actual $_expected > /dev/null 2>&1; echo $?)
    else
      res=-1
    fi

    case $res in
      0)
        ((_ok++))
        rm -f $_actual
        ;;
      -1)
        printf "Skip"
        ((_skip++))
        ;;
      *)
        printf " => Failure ($_actual)\n" 
        ((_ng++))
        ;;
    esac

    test ! -z "$DEBUG" && sed -i "s/^%\+_DEBUG_%//" ${_output}
  done

  printf "\r%64s\r" ""
  if [[ $_ng != 0 || $break_flag == 1 ]]; then
    printf "%0.s-" {1..25}
    printf "\n"
  fi
  echo "Success: $_ok"
  echo "Failure: $_ng"
  echo "Skip   : $_skip"
  set +x
}

if ! check_env; then
  exit 1
fi

setup $*
main
