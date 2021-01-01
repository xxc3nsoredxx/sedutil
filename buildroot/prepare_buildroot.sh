#! /bin/bash

VERSION='2020.11.1'
NAME="buildroot-$VERSION"
DOWNLOAD="$NAME.tar.gz"

# Download buildroot
rm buildroot-*
rm -rf buildroot
curl "https://git.buildroot.net/buildroot/snapshot/$DOWNLOAD" -O
tar xf $DOWNLOAD
mv $NAME buildroot

cd buildroot

# add the current buildroot packages
sed -i '/sedutil/d' package/Config.in
sed -i '/menu "System tools"/a \\tsource "package/sedutil/Config.in"' package/Config.in
rm -rf package/sedutil
cp -r ../../images/buildroot/packages/sedutil/ package/

# add the old base kernel config
mkdir 64bit
cp ../../images/buildroot/64bit/kernel.config 64bit/

# add the overlay
cp -r ../../images/buildroot/64bit/overlay/ 64bit/

make menuconfig
make linux-menuconfig
