#! /bin/bash

# Run in the main Buildroot tree
# Arg 1: path to target filesystem

pushd $1 &> /dev/null
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
popd &> /dev/null
