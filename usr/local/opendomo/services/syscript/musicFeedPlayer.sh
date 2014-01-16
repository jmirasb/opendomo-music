#!/bin/sh
#desc:Feeds the player with next song
#package:odmusic
#type:local

CONFILE=/etc/opendomo/music.conf
. $CONFILE
. $PID

# Reset last song played
rm -f $TMPLAST
touch $TMPLAST
chown admin:admin $TMPLAST
chmod a+w $TMPLAST

# While there are songs playing or pending
while test "" != "`cat $TMPPENDING`" || test "" != "`cat $TMPCURRENT`"; do

	# If last song sent differs from current song, send current
	if test "`cat $TMPLAST`" != "`cat $TMPCURRENT`"; then
        	# Load song to play
		echo "LOAD `cat $TMPCURRENT`"   > $TMPFILE

		# Set current as last song sent
		echo "`cat $TMPCURRENT`"      > $TMPLAST

		# Mpg123 takes it's time to load
		sleep 2
	fi

	# If player has ended with the song, we send the next
	if test "0" = "`tail -n1 $INFFILE  | cut -f2 -d" "`" && test "@P" = "`tail -n1 $INFFILE  | cut -f1 -d" "`"; then
		/usr/bin/bgshell "/usr/local/opendomo/musicNext.sh"
	fi
	if test "MPG123" = "`tail -n1 $INFFILE  | cut -f2 -d" "`"; then
		/usr/bin/bgshell "/usr/local/opendomo/musicNext.sh"
	fi

	# When pending list is empty, if loop is activated we refill pending
	if test "`cat $TMPPENDING`" = "" && test "$LOOP" = "on"; then
		mv $TMPPLAYED $TMPPENDING
		touch $TMPPLAYED
		chown admin:admin $TMPPLAYED
		chmod a+w $TMPPLAYED
	fi

	# With this we reduce the usage of resources
	sleep 1
done

# Once we have finished we stop the player
/etc/init.d/music stop
