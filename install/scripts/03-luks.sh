#!/usr/bin/env bash
set -euo pipefail

# 03-luks.sh
# Format the root partition with LUKS and open it as /dev/mapper/cryptroot

LUKS_PART="/dev/nvme0n1p2"
MAPPER_NAME="cryptroot"

echo "=== Step 3: LUKS setup on $LUKS_PART ==="
echo "You will be asked to set a passphrase for the LUKS container."
read -r -p "Type 'yes' to format (DESTROYS data): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

sudo cryptsetup luksFormat "$LUKS_PART"
sudo cryptsetup open "$LUKS_PART" "$MAPPER_NAME"

echo "LUKS container opened at /dev/mapper/$MAPPER_NAME"
echo "Run ./04-btrfs.sh next."
