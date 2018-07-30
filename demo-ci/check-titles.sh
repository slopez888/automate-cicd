#/bin/bash

DIR=$1
PATTERN="${2#check-}"
set -x
./check-titles.py $1 | grep --color=auto "$PATTERN" -C 99
