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
  
# Remaster initramfs
echo 'Remastering initramfs ...'
mkdir scratch/rootfs
pushd scratch/rootfs &> /dev/null
    # Unpack initramfs
    echo 'Unpacking rootfs.cpio.xz ...'
    xz -dc ../buildroot/64bit/images/rootfs.cpio.xz | cpio -i -H newc -d

    # Patch /etc/fstab
    # Remove /dev/root entry (mounts ext2)
    sed -i '\|/dev/root|d' etc/fstab && \
    echo 'Patching out /dev/root from /etc/fstab (mounts ext2) ...'
    # Remove sysfs entry
    sed -i '/sysfs/d' etc/fstab && \
    echo 'Patching out /sys from /etc/fstab (sysfs disabled) ...'
    # Replace tmpfs with ramfs
    sed -i 's/tmpfs/ramfs/g' etc/fstab && \
    echo 'Patching tmpfs to mount as ramfs in /etc/fstab ...'
    # Remove devpts entry
    sed -i '/devpts/d' etc/fstab && \
    echo 'Patching out /dev/pts from /etc/fstab (pseudoterminals disabled) ...'

    # Patch /etc/inittab
    # Remove creating /dev/pts/
    sed -Ei 's/^(.*)\/dev\/pts (\/dev\/shm.*)$/\1\2/' etc/inittab && \
    echo 'Patching out /dev/pts creation from /etc/inittab'
    # Remove swap entries
    sed -i '/swap/d' etc/inittab && \
    echo 'Patching out swap from /etc/inittab (swap support disabled) ...'
    # Remove setting hostname
    sed -i '/hostname/d' etc/inittab && \
    echo 'Patching out hostname from /etc/inittab (no /bin/hostname) ...'

    # Repack initramfs
    echo 'Repacking rootfs.cpio.xz ...'
    find . | cpio -o -H newc | xz -9e -C crc32 -c > ../buildroot/64bit/images/rootfs.cpio.xz
popd &> /dev/null
rm -rf scratch/rootfs
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
    cp -v ../scratch/buildroot/64bit/images/rootfs.cpio.xz system/EFI/boot/
    cp -v ../buildroot/syslinux.cfg system/EFI/boot/

    # Calculate the total file size in 512B blocks
    SIZE=$(du -d 0 -B 512 system | cut -f 1)
    # Add space for the FAT structures
    SIZE=$((SIZE + 50))

    # Create image file and loopback device
    echo 'Creating boot image ...'
    # +2048 to create the 1MiB padding
    dd if=/dev/zero of=$BUILDIMG count=$((SIZE + 2048))
    sfdisk $BUILDIMG < ../layout.sfdisk
    LOOPDEV=$(losetup --show -f -o 1048576 $BUILDIMG)
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
