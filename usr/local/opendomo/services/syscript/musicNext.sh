#!/bin/sh
#desc:Play next song
#package:odmusic
#type:local

ODPCOMMAND="/usr/local/opendomo/bin/musicPlayer.sh"
$ODPCOMMAND next &>/dev/null
/usr/local/opendomo/musicPlay.sh
