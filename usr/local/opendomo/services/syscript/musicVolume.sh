#!/bin/sh
#desc:Change volume level
#package:odmusic
#type:local

ODPCOMMAND="/usr/local/opendomo/bin/musicPlayer.sh"
$ODPCOMMAND volume $1 &>/dev/null
/usr/local/opendomo/musicPlay.sh
