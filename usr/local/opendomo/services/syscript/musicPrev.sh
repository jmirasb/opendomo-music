#!/bin/sh
#desc:Changes the previous song as the current
#package:odmusic
#type:local

CONFILE=/etc/opendomo/music.conf
. $CONFILE
. $PID

update_pid () {
    # Search song in database and update pid with new info
    MP3=`cat $TMPCURRENT`
    ARTIST=`cat $TMPDATABASE | grep "$MP3" | cut -f2 -d"\""`
    ALBUM=`cat $TMPDATABASE | grep "$MP3" | cut -f2 -d"(" | cut -f1 -d")"`
    SONG=`cat $TMPDATABASE | grep "$MP3" | cut -f2 -d"{" | cut -f1 -d"}"`
    YEAR=`cat $TMPDATABASE | grep "$MP3" | cut -f2 -d"<" | cut -f1 -d">"`
    GENRE=`cat $TMPDATABASE | grep "$MP3" | cut -f2 -d"|"`
    COVER=`cat $TMPDATABASE | grep "$ALBUM" | grep cover | cut -f2 -d"[" | cut -f1 -d"]" | uniq`

    echo "ARTIST=\"$ARTIST\"" 	 >$PID
    echo "ALBUM=\"$ALBUM\""	>>$PID
    echo "SONG=\"$SONG\""	>>$PID
    echo "YEAR=$YEAR"		>>$PID
    echo "GENRE=$GENRE"		>>$PID
    echo "LOOP=$LOOP"		>>$PID
    echo "RDM=$RDM"		>>$PID
    echo "COVER=\"$COVER\""	>>$PID
    echo "VOLUME=$VOLUME"	>>$PID
}

# Check there are songs in played
if test "" != "`cat $TMPPLAYED`"; then
    rm -f $TMPPENDINGAUX
    touch $TMPPENDINGAUX
    chown admin:admin $TMPPENDINGAUX
    chmod a+w $TMPPENDINGAUX

    # Move the current song to the first in pending
    echo "`cat $TMPCURRENT`"        > $TMPPENDINGAUX
    echo "`cat $TMPPENDING`"        >> $TMPPENDINGAUX
    mv $TMPPENDINGAUX $TMPPENDING
    # Move the las in played to current
    echo "`cat $TMPPLAYED | tail -1`"       > $TMPCURRENT
    # Erase the last in played
    echo "`cat $TMPPLAYED | sed '$d'`" > $TMPPLAYED
    # Update pid file
    update_pid
else
    echo "#INFO No previously played songs"
fi

# Always return to music web controler
/usr/local/opendomo/musicControl.sh
