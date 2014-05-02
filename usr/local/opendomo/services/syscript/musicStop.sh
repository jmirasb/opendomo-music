#!/bin/sh
#desc:Stop music
#package:odmusic
#type:local

ODPCOMMAND="/usr/local/opendomo/bin/musicPlayer.sh"
$ODPCOMMAND stop &>/dev/null
sleep 1
/usr/local/opendomo/musicControl.sh
