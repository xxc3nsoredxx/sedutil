#! /bin/bash
. conf

# Build the PBA root
pushd scratch/buildroot &> /dev/null
    echo 'Cealning ...' | tee output/build_output.txt
    make clean |& tee -a output/build_output.txt
    echo 'Building the base system ...' >> output/build_output.txt
    make |& tee -a output/build_output.txt
popd &> /dev/null
