#!/bin/sh
#desc:Play music
#package:odmusic
#type:local

MPDCONFILE="/etc/opendomo/system/mpd.conf"
MPDPIDFILE="/var/opendomo/run/mpd.pid"
MUSICFOLDER=`grep  music_directory $MPDCONFILE | awk '{print $2}' | sed 's/\/media\///' | tr -d "\""`
TMPCTLPARM="/var/opendomo/tmp/music.tmp"
COVERCACHE="/var/opendomo/tmp/musiccover.cache"
MUSICPID="/var/opendomo/run/musicplayer.pid"

MPCCOMMAND="/usr/bin/mpc"
ODPCOMMAND="/usr/local/opendomo/bin/musicPlayer.sh"

IFS=$'\x0A'$'\x0D'
VOL="0,10,20,30,40,50,60,70,80,90,100"

web_interface () {
    cd /media
    SONG=`$MPCCOMMAND current | sed 's/ - /-/' | cut -f2 -d-`
    ARTIST=`$MPCCOMMAND current | sed 's/ - /-/' | cut -f1 -d-`
    SONGPATH=`$MPCCOMMAND find Title "$SONG" Artist "$ARTIST" | head -n1`
    COVER=`dirname "$MUSICFOLDER/$SONGPATH"`/cover.jpg

    # Web interface
    echo "#> Playing now ..."
    echo "list:`basename $0`	iconlist"
    echo "	$COVER	 	file image"
    echo "actions:"
    echo
    /usr/local/opendomo/musicOptions.sh
}

if test -z $1 && [ `$MPCCOMMAND status | head -n2 | tail -n1 | awk '{print $1}'` = "[playing]" ]; then
    # Actual play (play)
    web_interface

elif test -z $1 && [ `$MPCCOMMAND status | head -n2 | tail -n1 | awk '{print $1}'` = "[paused]" ]; then
    # Actual play (paused)
    web_interface

elif ! test -z $1 && test -f $MPDPIDFILE; then
    # Extract artist and albums
    ARTIST=`grep ARTIST $TMPCTLPARM | cut -f2 -d=`

    # Suport multiple albums
    for cover in "$@"; do
        ALBUM=`grep $cover $COVERCACHE | cut -f1 -d= | uniq`
        if test -z "$ALBUMS"; then
            ALBUMS="$ARTIST/$ALBUM"
        else
            ALBUMS="$ALBUMS;$ARTIST/$ALBUM"
        fi
    done

    # Start play
    /usr/local/opendomo/bin/musicPlayer.sh play "$ALBUMS" #&>/dev/null
    web_interface

elif test -z "$1"; then
    echo "#ERRO You need select album"
    /usr/local/opendomo/musicControl.sh

elif ! test -f "$MPDPIDFILE"; then
    echo "#ERRO Music player daemon is not started"
    /usr/local/opendomo/musicControl.sh

fi
