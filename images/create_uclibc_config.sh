#! /bin/bash
. conf

cd scratch/buildroot
echo 'Create uClibc config ...'
make O=64bit uclibc-menuconfig

cd 64bit
echo 'Copying uClibc config to 64bit/uclibc.config ...'
cp build/uclibc*/.config uclibc.config

echo 'Copying 64bit/uclibc.config to temp storage ...'
cp uclibc.config ../../../
