#!/bin/bash

if [[ ! -f "$1" ]]; then
  exit 1
fi

PSQL="psql"
TGCTL="tgctl"
TGSQL="tgsql -c ipc:tsurugi"
TEST_DIR=$(dirname $1)

TIME_FILE="$2"

if [[ ! -z "$TIME_FILE" ]]; then
  _s_time=$(date +'%s.%N')
fi

test ! -z "$DEBUG" && set -x

source $1

test ! -z "$DEBUG" && set +x

if [[ ! -z "$TIME_FILE" ]]; then
  _e_time=$(date +'%s.%N')
  _name="$(basename $(dirname $1))/$(basename $1)"
  printf "%s: %s\n" ${_name} $(echo | awk "{printf \"%.3fsec\n\", $_e_time - $_s_time}") >> $TIME_FILE
fi
