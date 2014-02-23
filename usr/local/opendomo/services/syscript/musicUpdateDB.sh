#!/bin/sh
#desc:Start a playlist in mpg123
#package:odmusic
#type:local

# Check admin user
if test "$USER" != "admin"; then
    echo "#WARN Only admin can create databases"
    /usr/local/opendomo/musicControl.sh
    exit 1
fi

# Force update database in all mounted drives
cd /media
for drive in *; do
    if test -d $drive; then
        /usr/local/opendomo/eventhandlers/indexMusicDevice.sh info odmusic "Indexing music device in $drive" "$drive" &
    fi
done

sleep 1
echo "#INFO Database update in process, needs wait"
echo "actions:"
echo
