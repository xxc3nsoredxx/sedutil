#! /bin/bash
. conf

cd scratch/buildroot
echo 'Create buildroot config ...'
make O=64bit menuconfig

cd 64bit
echo 'Copying 64bit/.config to temp storage ...'
cp .config ../../../
