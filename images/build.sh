#! /bin/bash
. conf

# Build the images
pushd scratch/buildroot &> /dev/null
    echo 'Building the base system ...' >> output/build_output.txt
    make |& tee -a output/build_output.txt
popd &> /dev/null

# Clean old images
echo 'Cleaning old images ...'
rm -rfv UEFI RESCUE

# Copy the images
echo 'Copying new images ...'
cp -rv scratch/buildroot/output/images/{UEFI,RESCUE} ./
