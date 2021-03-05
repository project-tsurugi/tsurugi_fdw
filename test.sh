#!/bin/bash

# Fix below
LOCAL=$HOME/.local
# Fix above

${LOCAL}/bin/ogawayama-cli -terminate
${LOCAL}/bin/ogawayama-server -remove_shm > ogawayama-server.out 2>&1 & 

make installcheck
