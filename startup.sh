#!/bin/bash

log=/var/log/guate-slides.log
export NODE_ENV=${1:-"production"}

coffee app.coffee $1 2>&1 >> $log &

exit 0

