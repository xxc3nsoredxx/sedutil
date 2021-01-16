#! /bin/bash
. conf

VERSIONINFO="$(git describe --dirty)" || VERSIONINFO='tarball'
BUILDTYPE='RESCUE64'
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

[ -f scratch/$SYSLINUX_VER/efi64/efi/syslinux.efi ]                     || die
[ -f scratch/$SYSLINUX_VER/efi64/com32/elflink/ldlinux/ldlinux.e64 ]    || die
[ -f scratch/buildroot/64bit/images/bzImage ]                           || die
[ -f scratch/buildroot/64bit/images/rootfs.cpio.xz ]                    || die
[ -x scratch/buildroot/64bit/target/sbin/linuxpba ]                     || die
[ -x scratch/buildroot/64bit/target/sbin/sedutil-cli ]                  || die
[ -f buildroot/syslinux.cfg ]                                           || die
[ -f UEFI64/UEFI64-*.img.xz ]                                           || die
echo "Building $BUILDTYPE image"

# Clean slate and remaster initramfs
echo 'Remastering initramfs ...'
rm -f scratch/buildroot/64bit/images/rescuefs.cpio.xz 
mkdir scratch/rescuefs
pushd scratch/rescuefs &> /dev/null
    # Unpack initramfs
    echo 'Unpacking rootfs.cpio.xz ...'
    xz -dc ../buildroot/64bit/images/rootfs.cpio.xz | cpio -i -H newc -d
    
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
    rm etc/init.d/S99*

    # Add the PBA image
    echo 'Adding the UEFI image to /usr/sedutil/ ...'
    mkdir -p usr/sedutil
    cp ../../UEFI64/UEFI64-*.img.xz usr/sedutil/

    # Repack initramfs
    echo 'Repacking as rescuefs.cpio.xz ...'
    find . | cpio -o -H newc | xz -9e -C crc32 -c > ../buildroot/64bit/images/rescuefs.cpio.xz
popd &> /dev/null
rm -rf scratch/rescuefs
echo 'Remastering done!'

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
    cp -v ../scratch/buildroot/64bit/images/rescuefs.cpio.xz system/EFI/boot/rootfs.cpio.xz
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
