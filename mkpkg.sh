#!/bin/sh

mkdir -p pkg
rm pkg/*.tar.gz 2>/dev/null
PLUGIN="odmusic"
VERSION=`date '+%Y%m%d'`
USR="--owner 1000 --group 1000 --same-permissions"
EXCLUDE=' --exclude "*~" --exclude .svn --exclude README.md --exclude LICENCE'

rm -fr pkg/*.tar.gz
tar zcf  pkg/$PLUGIN-$VERSION.tar.gz usr var  $USR $EXCLUDE
