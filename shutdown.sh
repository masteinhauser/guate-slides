pid=$(cat /tmp/guate-slides.pid)


if kill -0 $pid > /dev/null 2>&1; then
   kill $pid
fi

exit 0
