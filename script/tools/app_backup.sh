#!/bin/sh
BACKUPDIR="/backup/app/"
BASEDIR="/opt"

DUMPFILE="enju_app_backup.`date '+%Y%m%d%H%M%S'`.tar.gz"
ARCFULLPATH="$BACKUPDIR$DUMPFILE"
TARPG="/usr/bin/tar"

echo "backup start file: $ARCFULLPATH"
echo "basedir: $BASEDIR"

cd $BASEDIR
$TARPG -zcvf $ARCFULLPATH enju_trunk 

echo "done."

