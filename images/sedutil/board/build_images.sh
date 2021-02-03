#! /bin/bash

#   Build the UEFI and rescue system images
#   Copyright (C) 2020-2021  xxc3nsoredxx
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Arg 1: images directory   (default, by buildroot)
# Arg 2: disk layout        (set in buildroot config file)

# Global info
# Get version info through git(1) or the VERSION file if not in a git repo or no git(1)
VERSIONINFO="$(git describe --dirty)" || VERSIONINFO="$(< $BUILD_DIR/sedutil-xxc*/build/VERSION)"
LAYOUT="$2"
SECTOR_SIZE=512
# Sectors per cluster
CLUSTER_SIZE=4
ROOT_ENTRIES=16
RESERVED_SECTORS=1

# Arg 1: image type (UEFI/RESCUE)
function build_img {
    BUILDTYPE="$1"
    BUILDIMG="$BUILDTYPE-$VERSIONINFO.img"

    echo "Building $BUILDTYPE image ..."

    # Clean slate
    rm -rfv $BINARIES_DIR/$BUILDTYPE
    mkdir -v $BINARIES_DIR/$BUILDTYPE
    pushd $BINARIES_DIR/$BUILDTYPE &> /dev/null
        # Create system directory structure
        echo 'Creating system directory structure ...'
        mkdir -pv EFI/boot
        cp -v $BINARIES_DIR/syslinux/bootx64.efi EFI/boot/
        cp -v $BINARIES_DIR/syslinux/ldlinux.e64 EFI/boot/
        cp -v $BINARIES_DIR/bzImage EFI/boot/
        # Copy the correct rootfs
        if [ "$BUILDTYPE" == "UEFI" ]; then
            cp -v $BINARIES_DIR/rootfs.cpio.xz EFI/boot/
        else
            cp -v $BINARIES_DIR/rescuefs.cpio.xz EFI/boot/rootfs.cpio.xz
        fi
        cp -v $BINARIES_DIR/syslinux/syslinux.cfg EFI/boot/

        # Calculate the total size in FAT clusters
        CLUSTERS=("$(du -a --apparent-size -B $((CLUSTER_SIZE * SECTOR_SIZE)) EFI/boot/* | cut -f 1)")
        CLUSTER_TOTAL=0
        for c in $CLUSTERS; do
            CLUSTER_TOTAL=$((CLUSTER_TOTAL + c))
        done
        # Add clusters to store the special entries (clusters 0 and 1)
        CLUSTER_TOTAL=$((CLUSTER_TOTAL + 2))

        # Calculate the size of disk image (in sectors)
        # +34 for GPT
        # +1 for FAT reserved sector (boot sector)
        # +5 for FAT1 (UEFI) / +9 for FAT1 (RESCUE)
        # +5 for FAT2 (UEFI) / +9 for FAT2 (RESCUE)
        # +1 for FAT root (16 entries * 32 bytes per entry)
        # Data region
        # +34 for backup GPT
        if [ "$BUILDTYPE" == "UEFI" ]; then
            IMAGE_SIZE=$((34 + 1 + 5 + 5 + 1 + (CLUSTER_TOTAL * CLUSTER_SIZE) + 34))
        else
            IMAGE_SIZE=$((34 + 1 + 9 + 9 + 1 + (CLUSTER_TOTAL * CLUSTER_SIZE) + 34))
        fi

        # Create disk image
        echo 'Creating disk image ...'
        dd if=/dev/zero of="$BUILDIMG" count="$IMAGE_SIZE"
        $HOST_DIR/sbin/sfdisk $BUILDIMG < $LAYOUT

        # Get the start of the partition (in sectors)
        OFFSET=$($HOST_DIR/sbin/sfdisk -d $BUILDIMG | $HOST_DIR/bin/gawk -e '/start=/ {print $4;}')
        OFFSET=${OFFSET//,}
        # Get the size of the partition (in sectors)
        SIZE=$($HOST_DIR/sbin/sfdisk -d $BUILDIMG | $HOST_DIR/bin/gawk -e '/size=/ {print $6;}')
        SIZE=${SIZE//,}

        # Create a separate filesystem image
        echo 'Creating temporary filesystem image ...'
        dd if=/dev/zero of=fs.temp.img count="$SIZE"
        $HOST_DIR/sbin/mkfs.vfat -a -r $ROOT_ENTRIES -R $RESERVED_SECTORS -s $CLUSTER_SIZE -v fs.temp.img

        # Transfer the system onto the filesystem image
        echo 'Transfering system to temprary filesystem ...'
        $HOST_DIR/bin/mcopy -v -s -i fs.temp.img EFI ::EFI

        # Write filesystem to disk image
        echo 'Writing filesystem to disk image ...'
        dd if=fs.temp.img of="$BUILDIMG" seek="$OFFSET" conv=notrunc

        # Clean up
        rm -rfv EFI fs.temp.img

        echo 'Compressing boot image ...'
        xz -9v $BUILDIMG
    popd &> /dev/null
}

# Check if running as root
# Required for the device files in the initramfs
if [ $(id -u) -ne 0 ]; then
    build_img 'UEFI'
    echo 'Rerunning as fakeroot ...'
    $HOST_DIR/bin/fakeroot -- $0 $@
    echo 'Fakeroot done ...'
    build_img 'RESCUE'
else
    # Clean slate and remaster initramfs
    echo 'Remastering initramfs ...'
    rm -fv $BINARIES_DIR/rescuefs.cpio.xz 
    mkdir -v $BINARIES_DIR/rescuefs
    pushd $BINARIES_DIR/rescuefs &> /dev/null
        # Unpack initramfs
        echo 'Unpacking rootfs.cpio.xz ...'
        unxz -cv $BINARIES_DIR/rootfs.cpio.xz | cpio -i -H newc -d
        
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
fi
