#!/bin/sh
#desc:Play next song
#package:odmusic
#type:local

MPCCOMMAND="/usr/bin/mpc"
ODPCOMMAND="/usr/local/opendomo/bin/musicPlayer.sh"
VOL="0,10,20,30,40,50,60,70,80,90,100"

# Updating elements
if   [ "$1" = "RDM" ]; then
    $ODPCOMMAND random $2 &>/dev/null

elif [ "$1" = "LOOP" ]; then
    $ODPCOMMAND loop $2 &>/dev/null

elif [ "$1" = "VOLUME" ]; then
    $ODPCOMMAND volume $2 &>/dev/null
fi

# Actual status
STATUS=`$MPCCOMMAND status | tail -n2 | head -n1 | cut -f2 -d[ | cut -f1 -d]`
SONG=`$MPCCOMMAND status | head -n1 | cut -f2 -d- | sed 's/ //'`
ARTIST=`$MPCCOMMAND status | head -n1 | cut -f1 -d-`
if [ `$MPCCOMMAND volume | cut -f2 -d:| tr -d %` == "100" ]; then
    LOOP=`$MPCCOMMAND status | tail -n1 | awk '{print $3}'`
    RDM=`$MPCCOMMAND status | tail -n1 | awk '{print $5}'`
    VOLUME="100"
else
    LOOP=`$MPCCOMMAND status | tail -n1 | awk '{print $4}'`
    RDM=`$MPCCOMMAND status | tail -n1 | awk '{print $6}'`
    VOLUME=`$MPCCOMMAND volume | cut -f2 -d:| sed 's/ //' | tr -d %`
fi

# Web interface
echo "#> Player Options"
echo "form:`basename $0`"
echo "	ARTIST	Artist	readonly	$ARTIST"
echo "	SONG	Song	readonly	$SONG"
echo "	status	Player status	readonly	$STATUS"
echo "	RDM	Random	subcommand[on,off]	$RDM"
echo "	LOOP	Continuos mode	subcommand[on,off]	$LOOP"
echo "	VOLUME	Volume level	subcommand[$VOL]	$VOLUME"
echo "actions:"
echo "	musicPrev.sh	<<<<"
echo "	musicStop.sh	Stop"
echo "	musicPause.sh	Pause"
echo "	musicNext.sh	>>>>"
echo
