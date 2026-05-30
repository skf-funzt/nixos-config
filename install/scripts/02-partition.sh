#!/usr/bin/env bash
set -euo pipefail

# 02-partition.sh
# Wipe the target disk and create GPT partitions:
#   p1: EFI System Partition (FAT32, 1 GiB)
#   p2: LUKS root partition (rest - swap)
#   p3: Swap partition (configurable, default 96 GiB for hibernation)
#
# Uses sgdisk (from gptfdisk) which auto-aligns partitions.

TARGET_DISK="/dev/nvme0n1"

# ── Configurable swap size ──
# For hibernation, swap must be >= RAM size.
# Set SWAP_GB to your RAM size in gigabytes.
# Examples: 16 (default small), 32, 64, 96, 128
SWAP_GB="${SWAP_GB:-96}"

echo "=== Step 2: Partition $TARGET_DISK ==="
echo "Swap size: ${SWAP_GB}G (set SWAP_GB env var to override)"
echo "WARNING: This will DESTROY all data on $TARGET_DISK"
read -r -p "Type 'yes' to continue: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

# ── Close any lingering mappers first ──
for mapper in cryptroot; do
    if sudo cryptsetup status "$mapper" &>/dev/null; then
        echo "Closing /dev/mapper/$mapper ..."
        sudo cryptsetup close "$mapper"
    fi
done

echo "Wiping partition table..."
sudo sgdisk -Z "$TARGET_DISK"

echo "Creating partitions with sgdisk (auto-aligned)..."
sudo sgdisk -n 1:0:+1G                 -t 1:ef00 -c 1:"EFI"   "$TARGET_DISK"
sudo sgdisk -n 2:0:-${SWAP_GB}G        -t 2:8300 -c 2:"LUKS"  "$TARGET_DISK"
sudo sgdisk -n 3:0:0                   -t 3:8200 -c 3:"swap"  "$TARGET_DISK"

echo "Refreshing kernel partition table..."
sudo partprobe "$TARGET_DISK"

echo "Partition layout:"
sudo sgdisk -p "$TARGET_DISK"

echo "Done. Run ./03-luks.sh next."
