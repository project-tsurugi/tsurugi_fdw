#!/bin/bash
$TSURUGI_HOME/bin/tgsql --script --connection ipc:tsurugi ./scripts/create_tsurugi_tables.sql > /dev/null 2>&1
make installcheck
$TSURUGI_HOME/bin/tgsql --script --connection ipc:tsurugi ./scripts/drop_tsurugi_tables.sql > /dev/null 2>&1
