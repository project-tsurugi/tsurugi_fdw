#!/bin/bash
TSURUGI_METADATA_HOME=$HOME/.local/tsurugi
TSURUGI_METADATA_STORAGE_PATH=$TSURUGI_METADATA_HOME/metadata

# tests about REGRESS variable written in Makefile
rm -rf $TSURUGI_METADATA_HOME
ogawayama-cli -terminate
ogawayama-server -remove_shm > ogawayama-server.out 2>&1 & 
make installcheck
