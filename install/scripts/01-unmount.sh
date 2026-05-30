#!/usr/bin/env bash
set -euo pipefail

# 01-unmount.sh
# Unmount old filesystems and close LUKS containers on nvme0n1
# Run this first before any destructive disk operations

TARGET_DISK="/dev/nvme0n1"
OLD_LUKS_ROOT="luks-4ee0041b-b1cf-4371-8dbb-69455fc07cae"
OLD_LUKS_SWAP="luks-c840e017-1623-4896-a1b9-ed9053eb7d9b"
OLD_MOUNT="/run/media/nixos/7c01f71d-b98c-4afe-8715-81df7c9f97c7"

echo "=== Step 1: Unmount and close old LUKS containers ==="

if mountpoint -q "$OLD_MOUNT" 2>/dev/null; then
    echo "Unmounting $OLD_MOUNT ..."
    sudo umount "$OLD_MOUNT"
fi

if sudo cryptsetup status "$OLD_LUKS_ROOT" &>/dev/null; then
    echo "Closing $OLD_LUKS_ROOT ..."
    sudo cryptsetup close "$OLD_LUKS_ROOT"
fi

if sudo cryptsetup status "$OLD_LUKS_SWAP" &>/dev/null; then
    echo "Closing $OLD_LUKS_SWAP ..."
    sudo cryptsetup close "$OLD_LUKS_SWAP"
fi

echo "Done. Old containers closed."
echo "Run ./02-partition.sh next."
