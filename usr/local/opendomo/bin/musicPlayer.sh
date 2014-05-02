#!/bin/sh
#desc:Opendomo music player
#package:odmusic
#type:local

TMPCTLPARM="/var/opendomo/tmp/music.tmp"
MPCCOMMAND="/usr/bin/mpc"
MUSICPID="/var/opendomo/run/musicplayer.pid"

IFS=$'\x0A'$'\x0D'

# Functions options
play_random () {
    if ! test -z "$1"; then
        $MPCCOMMAND random $1
    fi
}

play_loop () {
    if ! test -z "$1"; then
        $MPCCOMMAND repeat $1
    fi
}

play_volume () {
    if ! test -z "$1"; then
        $MPCCOMMAND volume $1
    fi
}

# Commands
case "$1" in
    play )
        # Check if started, stop in this case
        if [ `$MPCCOMMAND status | head -n2 | tail -n1 | awk '{print $1}'` == "[playing]" ]; then
           $MPCCOMMAND stop
           rm $MUSICPID 2>/dev/null
        fi
        $MPCCOMMAND clear

        # Extract temporal configuration file and configure player
        RDM=`grep RDM $TMPCTLPARM | cut -f2 -d=`
        LOOP=`grep LOOP $TMPCTLPARM | cut -f2 -d=`
        VOLUME=`grep VOLUME $TMPCTLPARM | cut -f2 -d=`
        play_random $RDM
        play_loop $LOOP
        play_volume $VOLUME

        # Configuring playlist
        PLAYLIST=`echo "$2" | sed 's/;/\r\n/g'`
        for album in `echo "$PLAYLIST"`; do
            $MPCCOMMAND add "$album"
        done

        # Creatind PID and start play
        touch $MUSICPID
        $MPCCOMMAND play
    ;;
    stop )
        # Stop and clear playlist
        $MPCCOMMAND stop
        $MPCCOMMAND clear
        rm $MUSICPID 2>/dev/null
    ;;
    pause )
        if [ `$MPCCOMMAND status | head -n2 | tail -n1 | awk '{print $1}'` == "[paused]" ]; then
            $MPCCOMMAND play
        elif [ `$MPCCOMMAND status | head -n2 | tail -n1 | awk '{print $1}'` == "[playing]" ]; then
            $MPCCOMMAND pause
        fi
    ;;
    next )
        $MPCCOMMAND next
    ;;
    prev )
        $MPCCOMMAND prev
    ;;
    volume )
        play_volume $2
    ;;
    random )
        play_random $2
    ;;
    loop )
        play_loop $2
    ;;
    * )
        echo "USAGE:  musicPlayer.sh { play | pause | stop | next | prev | volume | random | loop }"
    ;;
esac
