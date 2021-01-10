#! /bin/bash
. conf

cd scratch/buildroot
echo 'Create busybox config ...'
make O=64bit busybox-menuconfig

cd 64bit
echo 'Copying busybox config to 64bit/busybox.config ...'
cp build/busybox*/.config busybox.config

echo 'Copying 64bit/busybox.config to temp storage ...'
cp busybox.config ../../../
