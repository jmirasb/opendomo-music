#!/bin/sh
#desc:Control background music
#package:odmusic
#type:local

CONFIGFILE="/etc/opendomo/music.conf"
VOL="0,10,20,30,40,50,60,70,80,90,100"
IFS=$'\x0A'$'\x0D'

# Extract variables to config file
. $CONFIGFILE

# If PID exist, see actual play. If not playing, select play interface
if test -e $PID; then
    # Configure play variables and clean temporal parameters, isn't necessary anymore.
    . $PID
    rm $TMPCTLPARM 2>/dev/null

    # Extract song name from tag and cover to see in web interface
    MP3=`cat $TMPCURRENT`
    SONG=`cat $TMPDATABASE | grep "$MP3" | cut -f2 -d"{" | cut -f1 -d"}" | uniq`
    COVER=`echo $COVER | sed "s/\/media\///g"`

    # Select volume level and change
    if ! test -z "$2"; then
        VOLUME="$2"
    fi
    /usr/local/opendomo/musicVolume.sh $VOLUME

    # Web interface
    echo "#> Playing now..."
    echo "list:`basename $0`	iconlist"
    echo "	$COVER	$ARTIST - $ALBUM - $SONG	file image"
    echo "actions:"
    echo "	musicPrev.sh	<<<<"
    echo "	musicStop.sh	Stop"
    echo "	musicPause.sh	Pause"
    echo "	musicNext.sh	>>>>"
    echo
    echo "#> Playing options"
    echo "form:`basename $0`"
    echo "	VOLUME	Volume level	subcommand[$VOL]	$VOLUME"
    echo "actions:"
    echo

else
    # Check media scanner is running.
    SCANNERPID=`ls -1 /var/run/ | grep -m1 -c musicscanner.pid`
    if test "$SCANNERPID" == "1"; then
        echo "#WARN Media scanner is working, database isn't complete"
    fi

    # Update select option parameters and save in temporal file
    touch $TMPCTLPARM
    if ! test -z "$2"; then
        OPTIONS=`cat "$TMPCTLPARM" | grep -v $1`
        echo "$OPTIONS"			 >$TMPCTLPARM
        echo "$1=\"$2\""		>>$TMPCTLPARM
    fi

    # Search available databases and sort music in temporal database
    # TODO: Is necessary clean duplicate albums, same album in diferent drives
    rm -f $TMPDATABASE 2>/dev/null
    touch $TMPDATABASE

    for drive in `ls -1 /media/`; do
        DB="/media/$drive/$MUSICDB"
        if test -f "$DB"; then
            cat $DB  >>$TMPDATABASE
        fi
    done
    sort "$TMPDATABASE" -o "$TMPDATABASE"

    # List artist from temporal database
    for artist in `cat $TMPDATABASE | grep "cover.jpg" | cut -f2 -d"\"" | uniq`; do
        if test "$artist"; then
             if test -z $ARTLIST; then
                 ARTLIST="$artist"
             else
                 ARTLIST="$ARTLIST","$artist"
             fi
        fi
    done

    # Extract temporal config and album list
    ARTIST=`cat $TMPDATABASE | grep "($ALBUM)" | grep cover | cut -f2 -d"\"" | uniq`
    . $TMPCTLPARM
    ALBUMS=`cat $TMPDATABASE | grep "\"$ARTIST\"" | cut -f2 -d"(" | cut -f1 -d")" | uniq`

    # Check a album list, if albums parameter is void, isn't valid artist, select first database artist
    if test -z "$ALBUMS"; then
        ARTIST=`head -n1 "$TMPDATABASE"  | cut -f2 -d"\""`
        ALBUMS=`cat $TMPDATABASE | grep "\"$ARTIST\"" | cut -f2 -d"(" | cut -f1 -d")" | uniq`
    fi

    # Web interface
    echo "#> Configure options"
    echo "form:`basename $0`"
    echo "	ARTIST	Artist param	hidden	ARTIST"
    echo "	SELART	Select artist	list[$ARTIST,$ARTLIST]	$ARTIST"
    echo "	RDM	Random	subcommand[on,off]	$RDM"
    echo "	LOOP	Continuos mode	subcommand[on,off]	$LOOP"
    echo "	VOLUME	Volume level	subcommand[$VOL]	$VOLUME"
    echo
    echo "#> Select album"
    echo "list:`basename $0`	iconlist"
    for album in $ALBUMS; do
        DBCOVER=`cat $TMPDATABASE | grep "($album)" | grep cover.jpg | cut -f2 -d[ | cut -f1 -d] | uniq`
        COVER=`echo $DBCOVER | sed "s/\/media\///g"`
        NAME=`echo ${album:0:30} ...`

        echo "	$COVER	$NAME	file image"
    done
    echo "actions:"
    echo "	musicPlay.sh	Play music"
    echo "	musicSave.sh	Save config"
    echo "	musicUpdateDB.sh	Update database"
    echo
fi
