#!/bin/sh
#desc:Search Music
#package:odmusic
#type:local

MPCCOMMAND="/usr/bin/mpc"
SEARCHOPTS="any,Artist,Album,Title,Track,Name,Genre,Date,Composer,Performer,Comment,Disc"
IFS=$'\x0A'$'\x0D'

echo "#> Player Options"
echo "form:`basename $0`"
echo "	SOPTS	Type	list[$SEARCHOPTS]	$TYPE"
echo "	SEARCH	Search	text	$VOLUME"
echo
echo "#> Results"
echo "list:`basename $0`	selectable"
if ! test -z "$2"; then
    for result in `$MPCCOMMAND search "$1" "$2"`; do
        ARTIST=`dirname $result | cut -f1 -d"/"`
        ALBUM=`dirname $result | cut -f2 -d"/"`
        SONG=`basename $result | cut -f1 -d.`
        echo "	$result	$ARTIST - $ALBUM ($SONG)	song"
    done
else
    echo "# Select type and key to search"
fi
echo "actions:"
echo "	musicPlay.sh	Play"
echo
