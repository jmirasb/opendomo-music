#!/bin/sh
#desc: Index music device

# As a Event Handler, the first and second parameters are the level and package.
# The third parameter is text and the fourth is a path to a file. In this case,
# the fourth is a name or path to the new detected device:

# Is necessary device name
if ! test -z "$4"; then

    # Variable can be complete route or drive, extract route if exist, check
    # if drive exist and create variables for script
    DRIVE=`echo $4 | sed "s/\/media\///g"`
    MUSICPATH="/media/$DRIVE/"

    if test -d "$MUSICPATH"; then
        MUSICDB="$MUSICPATH/.music.db"
        DISKCFG="$MUSICPATH/opendomo.cfg"
    else
	exit 1
    fi

    # Check drive config, only music disk type can will be scanned
    if test -f "$DISKCFG"; then
        MUSICCFG=`cat $DISKCFG | grep DISKTYPE | grep -m1 -c music`

        if test $MUSICCFG == 0; then
            # If drive isn't music disk clean old databases and exit
            rm $MUSICDB 2>/dev/null
	    exit 0
        fi
    else
        exit 0
    fi

    # Check and create PID
    PID="/var/opendomo/run/$DRIVE-musicscanner.pid"
    if test -f $PID; then
        echo "#ERRO Music media scan for $DRIVE in already working ..."
        exit 1
    else
        touch $PID
    fi

    # Clean old database and write new
    echo -n "" >"$MUSICDB"
    chown admin:admin "$MUSICDB"	2>/dev/null
    chmod a+r "$MUSICDB"	2>/dev/null

    # Search all mp3 in new device and create database
    # TODO: Scan tag with mpg123 isn't optimized is better with taglib, libid3tag or ffmpeg
    IFS=$'\x0A'$'\x0D'

    for mp3 in `find $MUSICPATH -name *.mp3 | sort`; do
        # Extract info from song
        SONG=`/usr/bin/mpg123 --long-tag -u -s -t -n1 "$mp3" 2>&1 | grep "Title" | cut -f2 -d: | sed 's/^[ v]*//'| sed 's/&/and/' | tr "|!$%" " "`
        ARTIST=`/usr/bin/mpg123 --long-tag -u -s -t -n1 "$mp3" 2>&1 | grep "Artist" | cut -f2 -d: | sed 's/^[ v]*//' | sed 's/&/and/' | tr "|!$%" " "`
        ALBUM=`/usr/bin/mpg123 --long-tag -u -s -t -n1 "$mp3" 2>&1 | grep "Album" | cut -f2 -d: | sed 's/^[ v]*//' | sed 's/&/and/' | tr "|!$%" " "`
        YEAR=`/usr/bin/mpg123 --long-tag -u -s -t -n1 "$mp3" 2>&1 | grep "Year" | cut -f2 -d: | sed 's/^[ v]*//'`
        GENRE=`/usr/bin/mpg123 --long-tag -u -s -t -n1 "$mp3" 2>&1 | grep "Genre" | cut -f2 -d: | sed 's/^[ v]*//' | sed 's/&/and/'`

        # Checking void info
        if test -z $ARTIST; then
            ARTIST="Unknown"
        fi
        if test -z $ALBUM; then
            ALBUM="Unknown"
        fi
        if test -z $YEAR; then
            YEAR="Unknown"
        fi
        if test -z $ARTIST; then
            GENRE="Unknown"
        fi
        if test -z $SONG; then
            SONG=`basename "$mp3" | cut -f1 -d.`
        fi

        # Search cover in first mp3 album folder or no cover image file
        # TODO: nocover isn't visible in web interface, only files in /media can be visible
        COVER=`cat $MUSICDB | grep $ALBUM | grep cover.jpg`
        NOCOVER="/var/www/images/nocover.jpg"
        if test -z "$COVER"; then
            FOLDER=`dirname $mp3`
                if test -f "$FOLDER/cover.jpg"; then
                    echo "\"$ARTIST\" ($ALBUM) [$FOLDER/cover.jpg]" >>"$MUSICDB"
                else
                    echo "\"$ARTIST\" ($ALBUM) [$NOCOVER]" >>"$MUSICDB"
                fi
        fi
        echo "\"$ARTIST\" ($ALBUM) {$SONG} <$YEAR> |$GENRE| [$mp3]" >>"$MUSICDB"
    done

    # Clean media scanner pid
    rm $PID 2>/dev/null
fi
