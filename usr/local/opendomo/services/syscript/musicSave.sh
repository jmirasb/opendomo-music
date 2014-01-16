#!/bin/sh
#desc:Save config in music player
#package:odmusic
#type:local

CONFIGFILE="/etc/opendomo/music.conf"
. $CONFIGFILE

# Is necessary album to save config
if test -z "$1"; then
	echo "#WARN Need select album first"
else
	if test -f $TMPCTLPARM; then
		. $TMPCTLPARM
	fi

	# Convert cover parameter in album
	ALBUM=`cat $TMPDATABASE | grep "$1" | cut -f2 -d"(" | cut -f1 -d")" | uniq`

	# Save options, changed or not
	echo "ALBUM=\"$ALBUM\""				 > $CONFIGFILE
	echo "VOLUME=$VOLUME"				>> $CONFIGFILE
	echo "RDM=$RDM"					>> $CONFIGFILE
	echo "LOOP=$LOOP"				>> $CONFIGFILE
	echo "MUSICDB=.music.db"                        >> $CONFIGFILE
	echo "TMPFILE=/tmp/music.command"               >> $CONFIGFILE
	echo "INFFILE=/tmp/music.info"                  >> $CONFIGFILE
	echo "TMPPENDING=/tmp/music.pending"            >> $CONFIGFILE
	echo "TMPPENDINGAUX=/tmp/music.pendingaux"      >> $CONFIGFILE
	echo "TMPLAST=/tmp/music.last"                  >> $CONFIGFILE
	echo "TMPCURRENT=/tmp/music.current"            >> $CONFIGFILE
	echo "TMPPLAYED=/tmp/music.played"              >> $CONFIGFILE
	echo "TMPCTLPARM=/tmp/music.ctlparam"           >> $CONFIGFILE
	echo "TMPDATABASE=/tmp/music.tmpdb"         	>> $CONFIGFILE
	echo "PID=/var/run/music.pid"                   >> $CONFIGFILE

	echo "#INFO Configuration saved"

fi
# Always return to music web controller
/usr/local/opendomo/musicControl.sh
