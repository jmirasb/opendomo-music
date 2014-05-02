#!/bin/sh
#desc:Save default configuration
#package:odmusic
#type:local

CONFIGFILE="/etc/opendomo/music.conf"
TMPCTLPARM="/var/opendomo/tmp/music.tmp"
COVERCACHE="/var/opendomo/tmp/musiccover.cache"

ARTIST=`grep ARTIST $TMPCTLPARM | cut -f2 -d=`
RDM=`grep RDM $TMPCTLPARM | cut -f2 -d=`
LOOP=`grep LOOP $TMPCTLPARM | cut -f2 -d=`
VOLUME=`grep VOLUME $TMPCTLPARM | cut -f2 -d=`

if test -z "$1"; then
    echo "#ERRO You need select album"
else
    ALBUM=`grep "$1" $COVERCACHE | cut -f1 -d= | uniq`

    echo "#INFO Saving ..."
    echo "ALBUM=$ARTIST/$ALBUM" > $CONFIGFILE
    echo "RDM=$RDM"		>> $CONFIGFILE
    echo "LOOP=$LOOP"		>> $CONFIGFILE
    echo "VOLUME=$VOLUME"	>> $CONFIGFILE
fi
/usr/local/opendomo/musicControl.sh
