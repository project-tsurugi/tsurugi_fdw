#/bin/bash
rm -rf ~/.local/tsurugi
ogawayama-cli -terminate
ogawayama-server -remove_shm > ogawayama-server.out 2>&1 & 
export USE_PGXS=1
make installcheck
