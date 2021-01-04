#! /bin/bash
. conf

# Build the PBA root
pushd scratch/buildroot &> /dev/null
    echo 'Building the 64bit PBA Linux system ...'
    make O=64bit |& tee 64bit/build_output.txt
popd &> /dev/null
