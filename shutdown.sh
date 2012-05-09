pid=$(cat /tmp/vbnet-gc.pid)


if kill -0 $pid > /dev/null 2>&1; then
   kill $pid
fi

exit 0
