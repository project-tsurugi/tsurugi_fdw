#!/bin/bash
LOCAL=$HOME/.local
TSURUGI_METADATA_HOME=$LOCAL/tsurugi
TSURUGI_METADATA_STORAGE_PATH=$TSURUGI_METADATA_HOME/metadata

# tests about REGRESS variable written in Makefile
rm -rf $TSURUGI_METADATA_STORAGE_PATH
${LOCAL}/bin/ogawayama-cli -terminate
${LOCAL}/bin/ogawayama-server -remove_shm > ogawayama-server.out 2>&1 & 
make installcheck

rm -rf $TSURUGI_METADATA_STORAGE_PATH
