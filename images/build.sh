#! /bin/bash
. conf

# Build the images
pushd scratch/buildroot &> /dev/null
    echo 'Cleaning ...' | tee output/build_output.txt
    make clean |& tee -a output/build_output.txt
    echo 'Building the base system ...' >> output/build_output.txt
    make |& tee -a output/build_output.txt
popd &> /dev/null

# Clean old images
echo 'Cleaning old images ...'
rm -rfv UEFI EFI

# Copy the images
cp -rv scratch/buildroot/output/images/{UEFI,RESCUE} ./
