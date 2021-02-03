#! /bin/bash

#   Write the rescue system onto a storage medium
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


function die {
    echo $1
    exit 1
}

RESCUE=$(ls RESCUE/RESCUE*.xz 2>/dev/null) || die 'No rescue image found!'
RESCUE_BASE=$(basename $RESCUE)
RESCUE_IMG=$(basename -s '.xz' $RESCUE_BASE)

# Test if running as root
# Needed by dd(1)
[ $(id -u) -ne 0 ] && die "$0 must be run as root, quitting!"

echo -n "Copying $RESCUE to /tmp ..."
cp $RESCUE /tmp && \
echo ' DONE'

cd /tmp
echo -n "Decompressing $RESCUE_BASE ..."
xz -df $RESCUE_BASE && \
echo ' DONE'

# Prompt for target device
lsblk
read -ep 'Target block device> '

# Validate input
[ -z "$REPLY" ] && die 'Empty input, quitting!'
[ -b "$REPLY" ] || die "Not a block device: ${REPLY}, quitting!"
for PART in $REPLY*; do
    findmnt --fstab $PART &> /dev/null && die "$PART is mounted, quitting!"
done

# Flash image
echo -n "Flashing $RESCUE_IMG to $REPLY ..."
dd if=$RESCUE_IMG iflag=direct of=$REPLY oflag=direct bs=5M status=none && sync && \
echo ' DONE'

# Verify the flash
IMG_SIZE=$(du --apparent-size -B 512 $RESCUE_IMG | cut -f 1)

echo -n 'Verifying the flashed image ...'
IMG_HASH=$(sha512sum $RESCUE_IMG | cut -d ' ' -f 1)
FLASH_HASH=$(dd if=$REPLY iflag=direct count=$IMG_SIZE status=none | sha512sum | cut -d ' ' -f 1)
echo -n ' DONE'

if [ "$IMG_HASH" == "$FLASH_HASH" ]; then
    echo ' [GOOD]'
else
    echo ' [FAIL]'
    STATUS=1
fi

# Clean up
echo -n 'Cleaning up temporary image ...'
rm $RESCUE_IMG && \
echo ' DONE'

exit $STATUS
