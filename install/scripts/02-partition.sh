#!/usr/bin/env bash
set -euo pipefail

# 02-partition.sh
# Wipe the target disk and create GPT partitions:
#   p1: EFI System Partition (FAT32, 1 GiB)
#   p2: LUKS root partition (rest - 16 GiB)
#   p3: Swap partition (last 16 GiB)

TARGET_DISK="/dev/nvme0n1"

echo "=== Step 2: Partition $TARGET_DISK ==="
echo "WARNING: This will DESTROY all data on $TARGET_DISK"
read -r -p "Type 'yes' to continue: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

echo "Wiping filesystem signatures..."
sudo wipefs -a "$TARGET_DISK"

echo "Creating GPT label and partitions..."
sudo parted "$TARGET_DISK" -- mklabel gpt
sudo parted "$TARGET_DISK" -- mkpart ESP fat32 1MiB 1GiB
sudo parted "$TARGET_DISK" -- set 1 esp on
sudo parted "$TARGET_DISK" -- mkpart primary 1GiB -16GiB
sudo parted "$TARGET_DISK" -- mkpart primary -16GiB 100%

echo "Partition layout:"
sudo parted "$TARGET_DISK" -- print

echo "Done. Run ./03-luks.sh next."
