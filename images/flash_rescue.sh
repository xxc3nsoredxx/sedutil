#! /bin/bash

function die {
    echo $1
    exit 1
}

RESCUE=$(ls RESCUE64/RESCUE64*.xz 2>/dev/null) || die 'No rescue image found!'
RESCUE_BASE=$(basename $RESCUE)
RESCUE_IMG=$(basename -s '.xz' $RESCUE_BASE)

# Test if running as root
# Needed by dd(1)
if [ $(id -u) -ne 0 ]; then
    echo "$0 must be run as root!"
    exit 1
fi

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
