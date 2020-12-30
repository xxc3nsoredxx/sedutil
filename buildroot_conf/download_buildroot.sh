#! /bin/bash

VERSION='2020.11.1'
DOWNLOAD="buildroot-$VERSION.tar.gz"

curl "https://git.buildroot.net/buildroot/snapshot/$DOWNLOAD" -O
tar xf $DOWNLOAD
