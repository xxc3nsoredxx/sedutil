#! /bin/bash

# Arg 1: images directory
# Arg 2: syslinux.cfg path  (set in buildroot config file)
# Arg 3: disk layout        (set in buildroot config file)

# Build the rescue image
VERSIONINFO="$(git describe --dirty)" || VERSIONINFO='tarball'
BUILDTYPE='RESCUE'
BUILDIMG="$BUILDTYPE-$VERSIONINFO.img"

echo "Building $BUILDTYPE image ..."

# Check if running as root
# Required for the device files in the initramfs
if [ $(id -u) -ne 0 ]; then
    echo 'Rerunning as fakeroot ...'
    $HOST_DIR/bin/fakeroot -- $0 $@
else
    # Clean slate and remaster initramfs
    echo 'Remastering initramfs ...'
    rm -fv $BINARIES_DIR/rescuefs.cpio.xz 
    mkdir -v $BINARIES_DIR/rescuefs
    pushd $BINARIES_DIR/rescuefs &> /dev/null
        # Unpack initramfs
        echo 'Unpacking rootfs.cpio.xz ...'
        xz -dcv $BINARIES_DIR/rootfs.cpio.xz | cpio -i -H newc -d
        
        # Create /etc/issue
        echo 'Creating /etc/issue ...'
        cat > etc/issue << 'EOF'
\Cxxc3nsoredxx's Sedutil Rescue Image
===================================

\s \m \r
EOF

        # Tell getty to auto-login as root
        echo 'Patching /etc/inittab to auto-login as root ...'
        sed -i 's/\/sbin\/getty/& -r/' etc/inittab

        # Remove PBA service
        echo 'Deleting PBA init service ...'
        rm -v etc/init.d/S99*

        # Add the PBA image
        echo 'Adding the UEFI image to /usr/sedutil/ ...'
        mkdir -pv usr/sedutil
        cp -v $BINARIES_DIR/UEFI/UEFI-*.img.xz usr/sedutil/

        # Repack initramfs
        echo 'Repacking as rescuefs.cpio.xz ...'
        find . | cpio -o -H newc | xz -9 -C crc32 -c -v > $BINARIES_DIR/rescuefs.cpio.xz
    popd &> /dev/null
    rm -rf $BINARIES_DIR/rescuefs
    echo 'Remastering done!'
    exit
fi

# Clean slate
rm -rfv $BINARIES_DIR/$BUILDTYPE
mkdir -v $BINARIES_DIR/$BUILDTYPE
pushd $BINARIES_DIR/$BUILDTYPE &> /dev/null
    # Create system directory structure
    echo 'Creating system directory structure ...'
    mkdir -pv EFI/boot
    cp -v $BINARIES_DIR/syslinux/syslinux.efi EFI/boot/bootx64.efi
    cp -v $HOST_DIR/usr/share/syslinux/efi64/ldlinux.e64 EFI/boot/
    cp -v $BINARIES_DIR/bzImage EFI/boot/
    cp -v $BINARIES_DIR/rescuefs.cpio.xz EFI/boot/rootfs.cpio.xz
    cp -v $2 EFI/boot/

    # Calculate the total file size in 512B blocks
    IMGSIZE=$(du -d 0 -B 512 EFI | cut -f 1)
    # Add space for the disk structures
    IMGSIZE=$((IMGSIZE + 150))

    # Create disk image
    echo 'Creating disk image ...'
    dd if=/dev/zero of=$BUILDIMG count=$IMGSIZE
    sfdisk $BUILDIMG < $3

    # Get the start of the partition (in blocks)
    OFFSET=$(sfdisk -d $BUILDIMG | awk -e '/start/ {print $4;}')
    OFFSET=${OFFSET//,}
    # Get the size of the partition (in blocks)
    SIZE=$(sfdisk -d $BUILDIMG | awk -e '/size/ {print $6;}')
    SIZE=${SIZE//,}

    # Create a separate filesystem image
    echo 'Creating temporary filesystem image ...'
    dd if=/dev/zero of=fs.temp.img count=$SIZE
    mkfs.vfat -v fs.temp.img

    # Transfer the system onto the filesystem image
    echo 'Transfering system to temprary filesystem ...'
    $HOST_DIR/bin/mcopy -v -s -i fs.temp.img EFI ::EFI

    # Write filesystem to disk image
    echo 'Writing filesystem to disk image ...'
    dd if=fs.temp.img of=$BUILDIMG seek=$OFFSET conv=notrunc

    # Clean up
    rm -rfv EFI fs.temp.img

    echo 'Compressing boot image ...'
    xz -9v $BUILDIMG
popd &> /dev/null
