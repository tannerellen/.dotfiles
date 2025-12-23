#!/bin/bash

MOUNT_POINT="/mnt/samba-$1"

# Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "Already mounted at $MOUNT_POINT"
    kitty -e bash -c "cd $MOUNT_POINT && yazi"
    exit 0
fi

# Mount and then open yazi
kitty -e bash -c "sudo mount -t cifs //192.168.50.10/$1 $MOUNT_POINT -o credentials=/etc/samba/credentials,uid=1000,gid=1000,iocharset=utf8 && cd $MOUNT_POINT && yazi"
