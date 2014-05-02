#!/bin/sh
#desc:Play previous song
#package:odmusic
#type:local

ODPCOMMAND="/usr/local/opendomo/bin/musicPlayer.sh"
$ODPCOMMAND prev &>/dev/null
/usr/local/opendomo/musicPlay.sh
