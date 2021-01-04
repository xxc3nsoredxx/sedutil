#! /bin/bash
. conf

VERSIONINFO="$(git describe --dirty)" || VERSIONINFO='tarball'
BUILDTYPE='RESCUE64'
ROOTDIR='64bit'
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
[ -f scratch/buildroot/$ROOTDIR/images/bzImage ]                        || die
[ -f scratch/buildroot/$ROOTDIR/images/rootfs.cpio.xz ]                 || die
[ -x scratch/buildroot/$ROOTDIR/target/sbin/linuxpba ]                  || die
[ -x scratch/buildroot/$ROOTDIR/target/sbin/sedutil-cli ]               || die
[ -f buildroot/syslinux.cfg ]                                           || die
[ -f UEFI64/UEFI64-*.img.gz ]                                           || die
echo "Building $BUILDTYPE image"

# Clean slate
rm -rf scratch/rescuefs
rm -f scratch/buildroot/$ROOTDIR/images/rescuefs.cpio.xz 
mkdir scratch/rescuefs
cd scratch/rescuefs
xz -dc ../buildroot/$ROOTDIR/images/rootfs.cpio.xz | cpio -i -H newc -d

# Weird permission denied on etc/issue 
echo '*************************************' > etc/issue
echo "* DTA sedutil rescue image $BUILDIMG" >> etc/issue
echo '*' >> etc/issue
echo '* Login as root, there is no password' >> etc/issue
echo '*' >> etc/issue
echo '*************************************' >> etc/issue
rm etc/init.d/S99*
mkdir -p usr/sedutil
cp ../../UEFI64/UEFI64-*.img.gz usr/sedutil/
find . | cpio -o -H newc | xz -9 -C crc32 -c > ../buildroot/$ROOTDIR/images/rescuefs.cpio.xz
cd ../..

# Create image file and loopback device
rm -rf $BUILDTYPE
mkdir $BUILDTYPE
cd $BUILDTYPE
dd if=/dev/zero of=$BUILDIMG bs=1M count=75
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
cp ../scratch/buildroot/64bit/images/rescuefs.cpio.xz image/EFI/boot/rootfs.cpio.xz
cp ../buildroot/syslinux.cfg image/EFI/boot/

# Clean up
umount image
rmdir image
losetup -d $LOOPDEV
gzip $BUILDIMG

cd ..
chown -R --reference=. $BUILDTYPE
