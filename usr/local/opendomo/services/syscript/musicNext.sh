#!/bin/sh
#desc:Changes the next song as the current
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
    COVER=`cat $TMPDATABASE | grep "$ALBUM" | grep cover | cut -f2 -d"[" | cut -f1 -d"]"`

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

send_to_played_song () {
    if test "" = "`cat $TMPPLAYED`"; then
        echo "`cat $TMPCURRENT`"        > $TMPPLAYED
    else
        echo "`cat $TMPCURRENT`"        >> $TMPPLAYED
    fi
}

# Check random mode
if test "$RDM" == off; then
    # Check there are songs in pending
    if test "" != "`cat $TMPPENDING`"; then

        # Move song to played
        send_to_played_song
	# Move the first song of pending to current
        echo "`cat $TMPPENDING | grep -m 1 $`"   >$TMPCURRENT
        # Erase the first song of pending
        echo "`sed '1d' $TMPPENDING`" > $TMPPENDING
        # Update song information to PID
        update_pid
    else
        echo "#INFO No pending songs to be played"
        if test "0" = "`tail -n1 $INFFILE  | cut -f2 -d" "`" && test "@P" = "`tail -n1 $INFFILE  | cut -f1 -d" "`"; then
            echo "`sed '1d' $TMPCURRENT`" > $TMPCURRENT
        fi
    fi
else

    # Check there are songs in pending in random mode
    if test "" != "`cat $TMPPENDING`"; then

        # Move song to played
        send_to_played_song
        # Get the number of pending songs
        pending=`wc -l $TMPPENDING | cut -d" " -f1`
        # Get the number of song
        item=$(($RANDOM%$pending+1))
        # Set the song as current
        echo "`cat $TMPPENDING | sed -n ''$item'p'`"   >$TMPCURRENT
        # Remove the song from pending
        echo "`sed ''$item'd' $TMPPENDING`" > $TMPPENDING
        # Add song information to PID
        update_pid
    else
        echo "#INFO No pending songs to be played"
        if test "0" = "`tail -n1 $INFFILE  | cut -f2 -d" "`" && test "@P" = "`tail -n1 $INFFILE  | cut -f1 -d" "`"; then
            echo "`sed '1d' $TMPCURRENT`" > $TMPCURRENT
        fi
    fi
fi

# Always return to music web controler
/usr/local/opendomo/musicControl.sh
