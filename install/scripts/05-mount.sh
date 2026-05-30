#!/usr/bin/env bash
set -euo pipefail

# 05-mount.sh
# Mount Btrfs subvolumes and the EFI partition to /mnt for nixos-install

MAPPER="/dev/mapper/cryptroot"
EFI="/dev/nvme0n1p1"
SWAP="/dev/nvme0n1p3"
MOUNT="/mnt"

echo "=== Step 5: Mount filesystems ==="

sudo mount -o subvol=@,compress=zstd:1,noatime "$MAPPER" "$MOUNT"
sudo mkdir -p "$MOUNT"/{home,nix,var/log,boot}

sudo mount -o subvol=@home,compress=zstd:1,noatime "$MAPPER" "$MOUNT/home"
sudo mount -o subvol=@nix,compress=zstd:1,noatime "$MAPPER" "$MOUNT/nix"
sudo mount -o subvol=@log,compress=zstd:1,noatime "$MAPPER" "$MOUNT/var/log"
sudo mount "$EFI" "$MOUNT/boot"

echo "Creating swap..."
sudo mkswap -L swap "$SWAP"
sudo swapon "$SWAP"

echo "Mount status:"
findmnt -R "$MOUNT"

echo "Run ./06-generate-hardware.sh next."
