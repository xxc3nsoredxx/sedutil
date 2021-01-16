#! /bin/bash
. conf

# Build a custom UEFI linux based PBA image
VERSIONINFO="$(git describe --dirty)" || VERSIONINFO='tarball'
BUILDTYPE='UEFI64'
BUILDIMG="$BUILDTYPE-$VERSIONINFO.img"

function die {
    echo 'Prereqs not available'
    exit 1
}

# Check if running as root
# Reuired by losetup(8)
if [ $(id -u) -ne 0 ]; then
    echo 'Must be run as root!'
    exit 1
fi

# Check prereqs
[ -f scratch/$SYSLINUX_VER/efi64/efi/syslinux.efi ]                     || die
[ -f scratch/$SYSLINUX_VER/efi64/com32/elflink/ldlinux/ldlinux.e64 ]    || die
[ -f scratch/buildroot/64bit/images/bzImage ]                           || die
[ -f scratch/buildroot/64bit/images/rootfs.cpio.xz ]                    || die
[ -f scratch/buildroot/64bit/target/sbin/linuxpba ]                     || die
[ -f scratch/buildroot/64bit/target/sbin/sedutil-cli ]                  || die
[ -f buildroot/syslinux.cfg ]                                           || die
echo "Building $BUILDTYPE image"

# Clean slate
rm -rf $BUILDTYPE
mkdir $BUILDTYPE
pushd $BUILDTYPE &> /dev/null
    # Create system directory structure
    echo 'Creating system directory structure ...'
    mkdir -p system/EFI/boot
    cp -v ../scratch/$SYSLINUX_VER/efi64/efi/syslinux.efi system/EFI/boot/bootx64.efi
    cp -v ../scratch/$SYSLINUX_VER/efi64/com32/elflink/ldlinux/ldlinux.e64 system/EFI/boot/
    cp -v ../scratch/buildroot/64bit/images/bzImage system/EFI/boot/
    cp -v ../scratch/buildroot/64bit/images/rootfs.cpio.xz system/EFI/boot/
    cp -v ../buildroot/syslinux.cfg system/EFI/boot/

    # Calculate the total file size in 512B blocks
    IMGSIZE=$(du -d 0 -B 512 system | cut -f 1)
    # Add space for the FAT structures
    IMGSIZE=$((IMGSIZE + 125))

    # Create image file and loopback device
    echo 'Creating boot image ...'
    dd if=/dev/zero of=$BUILDIMG count=$IMGSIZE
    sfdisk $BUILDIMG < ../layout.sfdisk
    # Get the start of the partition (in bytes)
    OFFSET=$(sfdisk -d $BUILDIMG | awk -e '/start/ {print $4;}')
    OFFSET=${OFFSET//,}
    OFFSET=$((OFFSET * 512))
    # Get the size of the partition (in bytes)
    SIZE=$(sfdisk -d $BUILDIMG | awk -e '/size/ {print $6;}')
    SIZE=${SIZE//,}
    SIZE=$((SIZE * 512))
    LOOPDEV=$(losetup --show -f -o $OFFSET --sizelimit $SIZE $BUILDIMG)
    mkfs.vfat $LOOPDEV -n $BUILDTYPE

    # Mount the image
    mkdir image
    mount $LOOPDEV image
    chmod 644 image

    # Transfer the system onto the image
    echo 'Transfering system to boot image ...'
    mv -v system/EFI image

    # Clean up
    umount image
    rmdir image
    losetup -d $LOOPDEV
    rmdir system

    echo 'Compressing boot image ...'
    xz -9e $BUILDIMG
popd &> /dev/null

# Make not owned by root
chown -R --reference=. $BUILDTYPE
