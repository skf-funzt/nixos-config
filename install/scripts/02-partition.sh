#!/usr/bin/env bash
set -euo pipefail

# 02-partition.sh
# Wipe the target disk and create GPT partitions:
#   p1: EFI System Partition (FAT32, 1 GiB)
#   p2: LUKS root partition (rest - 16 GiB)
#   p3: Swap partition (last 16 GiB)
#
# Uses sgdisk (from gptfdisk) which auto-aligns partitions to
# optimal boundaries — no manual alignment warnings.

TARGET_DISK="/dev/nvme0n1"

echo "=== Step 2: Partition $TARGET_DISK ==="
echo "WARNING: This will DESTROY all data on $TARGET_DISK"
read -r -p "Type 'yes' to continue: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

echo "Wiping partition table..."
sudo sgdisk -Z "$TARGET_DISK"

echo "Creating partitions with sgdisk (auto-aligned)..."
sudo sgdisk -n 1:0:+1G   -t 1:ef00 -c 1:"EFI"   "$TARGET_DISK"
sudo sgdisk -n 2:0:-16G  -t 2:8300 -c 2:"LUKS"  "$TARGET_DISK"
sudo sgdisk -n 3:0:0     -t 3:8200 -c 3:"swap"  "$TARGET_DISK"

echo "Partition layout:"
sudo sgdisk -p "$TARGET_DISK"

echo "Done. Run ./03-luks.sh next."
