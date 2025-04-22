timeout 10s $TGCTL shutdown

if [[ $? != 0 ]]; then
  pkill $TGCTL || sudo pkill $TGCTL
  pkill tsurugidb || sudo pkill tsurugidb

  $TGCTL start; sleep 1; $TGCTL shutdown; sleep 1
fi
