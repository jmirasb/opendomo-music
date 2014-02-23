#!/bin/sh
#desc:Pauses/unpauses the mpg123
#package:odmusic
#type:local

CONFILE=/etc/opendomo/music.conf
. $CONFILE

# If music is running we pause/unpause it
if test -e $PID; then
    echo "PAUSE"	> $TMPFILE
fi

# Always return to music web controler
/usr/local/opendomo/musicControl.sh
