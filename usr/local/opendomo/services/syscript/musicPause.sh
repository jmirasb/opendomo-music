#!/bin/sh
#desc:Pause played song
#package:odmusic
#type:local

ODPCOMMAND="/usr/local/opendomo/bin/musicPlayer.sh"
$ODPCOMMAND pause &>/dev/null
/usr/local/opendomo/musicPlay.sh
