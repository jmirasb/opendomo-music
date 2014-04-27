#!/bin/sh
#desc:Start a playlist in mpg123
#package:odmusic
#type:local

CONFIGFILE="/etc/opendomo/music.conf"
. $CONFIGFILE

# Clean pending songs list
echo -n "" >$TMPPENDING

# Convert cover parameter in album with multiple album support
for cover in "$@"; do

    # Create a new pending file with all select files
    ALBUM=`cat $TMPDATABASE | grep "$cover" | cut -f2 -d"(" | cut -f1 -d")" | uniq`
    SONGS=`cat "$TMPDATABASE" | grep "($ALBUM)" | grep -v "cover" | cut -f2 -d[ | cut -f1 -d] | sort`

    for song in "$SONGS"; do
        echo "$song" >> $TMPPENDING
    done
done

# Start music service
sudo changestate.sh service music on

# Wait a moment, please ... for player start
sleep 3

# Always return to music web controler
/usr/local/opendomo/musicControl.sh
