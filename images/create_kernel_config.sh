#! /bin/bash

cd scratch/buildroot
echo 'Create kernel config ...'
make O=64bit kernel-menuconfig

cd 64bit
echo 'Copying kernel config to 64bit/kernel.config ...'
cp build/linux-5.*/.config kernel.config

echo 'Copying 64bit/kernel.config to temp storage ...'
cp kernel.config ../../../
