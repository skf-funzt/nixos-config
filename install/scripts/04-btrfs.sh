#!/usr/bin/env bash
set -euo pipefail

# 04-btrfs.sh
# Create Btrfs filesystem on the opened LUKS device,
# then create subvolumes: @ @home @nix @log @snapshots

MAPPER="/dev/mapper/cryptroot"
MOUNT="/mnt"

echo "=== Step 4: Btrfs filesystem and subvolumes ==="

sudo mkfs.btrfs -L nixos "$MAPPER"
sudo mount "$MAPPER" "$MOUNT"

sudo btrfs subvolume create "$MOUNT/@"
sudo btrfs subvolume create "$MOUNT/@home"
sudo btrfs subvolume create "$MOUNT/@nix"
sudo btrfs subvolume create "$MOUNT/@log"
sudo btrfs subvolume create "$MOUNT/@snapshots"

sudo umount "$MOUNT"

echo "Subvolumes created:"
for sub in @ @home @nix @log @snapshots; do
    echo "  $sub"
done

echo "Run ./05-mount.sh next."
