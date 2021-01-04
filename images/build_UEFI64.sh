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
rm -rf scratch/rootfs
mkdir scratch/rootfs
pushd scratch/rootfs &> /dev/null
    # Unpack initramfs
    xz -dc ../buildroot/64bit/images/rootfs.cpio.xz | cpio -i -H newc -d

    # Remove /dev/root entry from /etc/fstab (mounts ext2)
    sed -i '\|/dev/root|d' etc/fstab
    # Remove sysfs entry from /etc/fstab
    sed -i '/sysfs/d' etc/fstab
    # Replace tmpfs with ramfs in /etc/fstab
    sed -i 's/tmpfs/ramfs/g' etc/fstab

    # Repack initramfs
    find . | cpio -o -H newc | xz -9 -C crc32 -c > ../buildroot/64bit/images/rootfs.cpio.xz
popd &> /dev/null

# Clean slate
rm -rf $BUILDTYPE
mkdir $BUILDTYPE
cd $BUILDTYPE

# Create image file and loopback device
dd if=/dev/zero of=$BUILDIMG bs=1M count=32
sfdisk $BUILDIMG < ../layout.sfdisk
LOOPDEV=$(losetup --show -f -o 1048576 $BUILDIMG)
mkfs.vfat $LOOPDEV -n $BUILDTYPE

# Mount the image
mkdir image
mount $LOOPDEV image
chmod 644 image

# Copy the system onto the image
mkdir -p image/EFI/boot
cp ../scratch/$SYSLINUX_VER/efi64/efi/syslinux.efi image/EFI/boot/bootx64.efi
cp ../scratch/$SYSLINUX_VER/efi64/com32/elflink/ldlinux/ldlinux.e64 image/EFI/boot/
cp ../scratch/buildroot/64bit/images/bzImage image/EFI/boot/
cp ../scratch/buildroot/64bit/images/rootfs.cpio.xz image/EFI/boot/
cp ../buildroot/syslinux.cfg image/EFI/boot/

# Clean up
umount image
rmdir image
losetup -d $LOOPDEV
gzip $BUILDIMG

cd ..
chown -R --reference=. $BUILDTYPE
