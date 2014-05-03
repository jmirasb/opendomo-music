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

    JPG=`basename "$1" | cut -f2 -d.`
    # Support multiple parameters
    if [ "$JPG" == "jpg" ]; then
        # Is a cover provided by musicControl
        for cover in "$@"; do
            ALBUM=`grep $cover $COVERCACHE | cut -f1 -d= | uniq`
            if test -z "$TOPLAY"; then
                TOPLAY="$ARTIST/$ALBUM"
            else
                TOPLAY="$ALBUMS;$ARTIST/$ALBUM"
            fi
        done
    else
        # Is something provided by musicSearch
        for any in "$@"; do
            if test -z "$TOPLAY"; then
                TOPLAY="$any"
            else
                TOPLAY="$any;$TOPLAY"
            fi
        done
    fi

    # Start play
    /usr/local/opendomo/bin/musicPlayer.sh play "$TOPLAY" &>/dev/null
    web_interface

elif test -z "$1"; then
    echo "#ERRO You need select album"
    /usr/local/opendomo/musicControl.sh

elif ! test -f "$MPDPIDFILE"; then
    echo "#ERRO Music player daemon is not started"
    /usr/local/opendomo/musicControl.sh

fi
