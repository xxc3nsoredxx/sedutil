#! /bin/bash

# Arg 1: images directory
# Arg 2: syslinux.cfg path  (set in buildroot config file)
# Arg 3: disk layout        (set in buildroot config file)

# Build the UEFI image
VERSIONINFO="$(git describe --dirty)" || VERSIONINFO='tarball'
BUILDTYPE='UEFI'
BUILDIMG="$BUILDTYPE-$VERSIONINFO.img"

echo "Building $BUILDTYPE image ..."

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
    cp -v $BINARIES_DIR/rootfs.cpio.xz EFI/boot/
    cp -v $2 EFI/boot/

    # Calculate the total file size in 512B blocks
    IMGSIZE=$(du -d 0 -B 512 EFI | cut -f 1)
    # Add space for the disk structures
    IMGSIZE=$((IMGSIZE + 125))

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
