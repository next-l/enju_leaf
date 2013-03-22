#!/bin/sh

FIND=/usr/bin/find
if [ $# -ne 3 ]; then
        echo "usage: $0 dir day(s) name"
        exit 1
fi

$FIND $1 -mtime +$2 -type f -name "$3" -exec /bin/rm -f {} \;
