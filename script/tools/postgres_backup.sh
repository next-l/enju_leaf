#!/bin/sh
BACKUPDIR="/backup/db/"
DUMPFILE="pgdump.`date '+%Y%m%d%H%M%S'`.gz"
PGDUMP="/usr/local/pgsql/bin/pg_dumpall"
USER=postgres

LD_LIBRARY_PATH=/usr/local/pgsql/lib
export LD_LIBRARY_PATH

$PGDUMP -U $USER | gzip > "$BACKUPDIR$DUMPFILE"
