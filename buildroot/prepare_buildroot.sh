#! /bin/bash

VERSION='2020.11.1'
NAME="buildroot-$VERSION"
DOWNLOAD="$NAME.tar.gz"

curl "https://git.buildroot.net/buildroot/snapshot/$DOWNLOAD" -O
tar xf $DOWNLOAD
mv $NAME buildroot

echo '*' > buildroot/.gitignore
echo '!.config' >> buildroot/.gitignore
