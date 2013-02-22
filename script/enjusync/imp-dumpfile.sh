#! /bin/sh

SCRPT_PATH=/opt/enju_trunk/script/enjusync
export SCRPT_PATH

OPTION=""
if [ $# -ne 0 ]
then
	OPTION="$*"
fi

cd $SCRPT_PATH
./recv-bucket.pl $OPTION
STATUS=$?

if [ $STATUS -ne 0 ]
then
	exit $STATUS
fi
