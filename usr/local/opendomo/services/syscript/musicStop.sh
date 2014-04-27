#!/bin/sh
#desc:Stops the mpg123 player
#package:odmusic
#type:local

CONFILE=/etc/opendomo/music.conf
. $CONFILE

# If music is running we stop it
if test -e $PID; then
    sudo changestate.sh service music off
fi

# Always return to music web controler
/usr/local/opendomo/musicControl.sh
