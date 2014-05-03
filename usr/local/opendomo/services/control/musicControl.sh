#!/bin/sh
#desc:Control background music
#package:odmusic
#type:local

CONFIGFILE="/etc/opendomo/music.conf"
MPDCONFILE="/etc/opendomo/system/mpd.conf"
TMPCTLPARM="/var/opendomo/tmp/music.tmp"
COVERCACHE="/var/opendomo/tmp/musiccover.cache"

MPCCOMMAND="/usr/bin/mpc"
MUSICFOLDER=`grep  music_directory $MPDCONFILE | awk '{print $2}' | sed 's/\/media\///' | tr -d "\""`

IFS=$'\x0A'$'\x0D'
VOL="0,10,20,30,40,50,60,70,80,90,100"

# Checking configuration and daemon
if ! test -d "/media/$MUSICFOLDER"; then
    /usr/local/opendomo/musicConfigure.sh

elif [ `$MPCCOMMAND status | head -n2 | tail -n1 | awk '{print $1}'` = "[playing]" ]; then
    # Play is started
    /usr/local/opendomo/musicPlay.sh
elif [ `$MPCCOMMAND status | head -n2 | tail -n1 | awk '{print $1}'` = "[paused]" ]; then
    # Play is paused
    /usr/local/opendomo/musicPlay.sh

else
    # Creating artist list
    for artist in `$MPCCOMMAND ls`; do
        if test -z $ARTLIST; then
            ARTLIST="$artist"
        else
            ARTLIST="$ARTLIST","$artist"
        fi
    done

    # Checking mpd database
    if test -z $ARTLIST; then
        # Database is emply, updating
        echo "#WARN Updating database, isn't complete"
        $MPCCOMMAND update

    elif [ `$MPCCOMMAND status | head -n1 | awk '{print $1}'` = "Updating" ]; then
        # Database isn't complete yet
        echo "#WARN The database is updating, isn't complete"
    fi

    # Updating variables
    if ! test -z "$2" && test -f $TMPCTLPARM; then
        # Modifing parameter
        OPTIONS=`grep -v $1 $TMPCTLPARM`
        echo "$OPTIONS"     > $TMPCTLPARM
        echo "$1=$2"       >> $TMPCTLPARM

    elif ! test -f $TMPCTLPARM && [ `head -n1 "$CONFIGFILE" | cut -f1 -d=` != "no_configured" ]; then
        # Updating temporal file with default configuration
        echo "ARTIST=`grep ALBUM $CONFIGFILE | cut -f2 -d= | cut -f1 -d"/"`" >$TMPCTLPARM
        echo "RDM=`grep RDM $CONFIGFILE | cut -f2 -d=`"                     >>$TMPCTLPARM
        echo "LOOP=`grep LOOP $CONFIGFILE | cut -f2 -d=`"                   >>$TMPCTLPARM
        echo "VOLUME=`grep VOLUME $CONFIGFILE | cut -f2 -d=`"               >>$TMPCTLPARM

    elif ! test -f $TMPCTLPARM; then

        # Creating temporal config file
	echo "ARTIST=`echo $ARTLIST | cut -f1 -d,`"    > $TMPCTLPARM
        echo "RDM=off"	                              >> $TMPCTLPARM
        echo "LOOP=off"	                              >> $TMPCTLPARM
        echo "VOLUME=100"                             >> $TMPCTLPARM
    fi

    ARTIST=`grep ARTIST $TMPCTLPARM | cut -f2 -d=`
    RDM=`grep RDM $TMPCTLPARM | cut -f2 -d=`
    LOOP=`grep LOOP $TMPCTLPARM | cut -f2 -d=`
    VOLUME=`grep VOLUME $TMPCTLPARM | cut -f2 -d=`

    # Web interface
    echo "#> Configure options"
    echo "form:`basename $0`"
    echo "	ARTIST	Artist param	hidden	ARTIST"
    echo "	SELART	Select artist	list[$ARTIST,$ARTLIST]	$ARTIST"
    echo "	RDM	Random	subcommand[on,off]	$RDM"
    echo "	LOOP	Continuos mode	subcommand[on,off]	$LOOP"
    echo "	VOLUME	Volume level	subcommand[$VOL]	$VOLUME"
    echo

    # Creating list of albums
    cd /media
    echo "#> Select album"
    echo "list:`basename $0`	iconlist"
    for album in `$MPCCOMMAND ls "$ARTIST"`; do
	# Find album and cover
        ALBUM=`echo $album | cut -f2 -d"/"`
        COVER=`find "$MUSICFOLDER" -name $ALBUM | tail -n1`/cover.jpg

        # Saving cover cache
        echo "$ALBUM=$COVER" >> $COVERCACHE

	echo "	$COVER	$ALBUM	file image"
    done
    echo "actions:"
    echo "	musicPlay.sh	Play music"
    echo "	musicSearch.sh	Search"
    echo "	musicSave.sh	Save config"
    echo "	musicConfigure.sh	Configure daemon"
    echo
fi
