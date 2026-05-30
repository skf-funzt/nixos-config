#!/usr/bin/env bash
set -euo pipefail

# 03-luks.sh
# Format the root partition with LUKS and open it as /dev/mapper/cryptroot.
# Also formats the EFI partition (FAT32) so it can be mounted in step 05.

LUKS_PART="/dev/nvme0n1p2"
EFI_PART="/dev/nvme0n1p1"
MAPPER_NAME="cryptroot"

echo "=== Step 3: LUKS setup on $LUKS_PART ==="
echo "You will be asked to set a passphrase for the LUKS container."
read -r -p "Type 'yes' to format (DESTROYS data): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

# ── Close any lingering mapper from previous attempts ──
if sudo cryptsetup status "$MAPPER_NAME" &>/dev/null; then
    echo "Closing existing /dev/mapper/$MAPPER_NAME ..."
    sudo cryptsetup close "$MAPPER_NAME"
fi

# ── LUKS ──
sudo cryptsetup luksFormat "$LUKS_PART"
sudo cryptsetup open "$LUKS_PART" "$MAPPER_NAME"
echo "LUKS container opened at /dev/mapper/$MAPPER_NAME"

# ── EFI (FAT32) ──
echo "Formatting EFI partition $EFI_PART ..."
sudo mkfs.fat -F 32 -n boot "$EFI_PART"

echo "Run ./04-btrfs.sh next."
