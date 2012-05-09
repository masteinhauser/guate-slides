#!/bin/bash

log=/var/log/vbnet-gc.log
export NODE_ENV=${1:-"production"}

node app.js $1 2>&1 >> $log &

exit 0

