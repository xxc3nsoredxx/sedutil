#! /bin/bash
. conf

# Build the PBA root
pushd scratch/buildroot &> /dev/null
    echo 'Cealning ...' | tee 64bit/build_output.txt
    make O=64bit clean |& tee -a 64bit/build_output.txt
    echo 'Building the 64bit PBA Linux system ...' >> 64bit/build_output.txt
    make O=64bit |& tee -a 64bit/build_output.txt
popd &> /dev/null
