#!/bin/sh
BACKUPDIR="/backup/db/"
USER=postgres
#DUMPFILE="pgdump.`date '+%Y%m%d%H%M%S'`.gz"
#PGDUMP="/usr/bin/pg_dumpall"

DUMPFILE="pgdump.`date '+%Y%m%d%H%M%S'`.custom"
PGDUMP="/usr/bin/pg_dump"

LD_LIBRARY_PATH=/usr/local/pgsql/lib
export LD_LIBRARY_PATH

echo "backup start file: $BACKUPDIR$DUMPFILE"

#$PGDUMP -U $USER | gzip > "$BACKUPDIR$DUMPFILE"
$PGDUMP -U $USER enju_production -Fc > "$BACKUPDIR$DUMPFILE"

echo "done."

