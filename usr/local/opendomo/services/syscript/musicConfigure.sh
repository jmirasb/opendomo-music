#!/bin/sh
#desc:Configure player options
#package:odmusic
#type:local

CONFIGFILE="/etc/opendomo/music.conf"
MPDCONFILE="/etc/opendomo/system/mpd.conf"

if test -z "$2"; then
    # Daemon options
    MUSICFOLDER=`grep  music_directory $MPDCONFILE | awk '{print $2}' | tr -d "\""`
    if [ `grep auto_update $MPDCONFILE | awk '{print $2}' | tr -d "\""` == "yes" ]; then
        AUTOUPDATE="on"
    else
        AUTOUPDATE="off"
    fi
    if [ `grep volume_normalization $MPDCONFILE | awk '{print $2}' | tr -d "\""` == "yes" ]; then
        VOLNORMAL="on"
    else
        VOLNORMAL="off"
    fi

    echo "#> Configure music daemon"
    echo "form:`basename $0`"
    echo "	music_directory	Music directory	hidden	music_directory"
    echo "	music_folder	Music folder	text	$MUSICFOLDER"
    echo "	auto_update	Auto update database	subcommand[on,off]	$AUTOUPDATE"
    echo "	volume_normalization	Normalize audio level	subcommand[on,off]	$VOLNORMAL"
    echo
else
    echo "#INFO Configuration saved"
    PARAMETER="$1"
    VALUE="$2"

    # Change value
    if [ "$VALUE" == "on" ]; then
	VALUE="yes"
    elif [ "$VALUE" == "off" ]; then
        VALUE="no"
    fi
    CONFIG=`grep -v $PARAMETER $MPDCONFILE`
    echo "$CONFIG" 		  > $MPDCONFILE
    echo "$PARAMETER \"$VALUE\"" >> $MPDCONFILE
fi
