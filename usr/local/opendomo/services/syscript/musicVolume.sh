#!/bin/sh
#desc:Sets the volume of the mpg123 player
#package:odmusic
#type:local

CONFILE=/etc/opendomo/music.conf
. $CONFILE

# Tests the argument received is a number between o and 100.
if ! test $# = 1; then
	echo "$0 needs one argument"
else
	VOL=`echo "$1" | grep -v [a-z] | grep -v [A-Z]`
	if test $VOL -ge 0 && test $VOL -le 100; then
		# If the player is running we send the volume level
		if test -e $PID; then
			echo "VOLUME $VOL"      > $TMPFILE

			# Change volume in PID
			OPTIONS=`cat "$PID" | grep -v VOLUME`
			echo "$OPTIONS"          >$PID
			echo "VOLUME=$1"        >>$PID
		fi
	else
		echo "#ERR Volume must be between 0 and 100"
	fi
fi
