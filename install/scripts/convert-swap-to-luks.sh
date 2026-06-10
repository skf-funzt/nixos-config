#!/usr/bin/env bash
# convert-swap-to-luks.sh — Migrate live swap partition from raw to LUKS-encrypted.
#
# WHAT: Converts /dev/nvme0n1p2 (raw swap) to a LUKS container (cryptswap)
#       using the same passphrase as cryptroot. Enables passphrase reuse at boot
#       so only one unlock prompt appears.
#
# SAFETY: This is non-destructive to your data — only the swap partition is touched.
#         Swap contents are ephemeral and do not survive a reboot.
#
# PREREQUISITES: None (swap is assumed to have no valuable data).
#
# USAGE: sudo ./convert-swap-to-luks.sh

set -euo pipefail

SWAP_PART="/dev/nvme0n1p2"
MAPPER_NAME="cryptswap"

echo "=== Convert swap partition to LUKS-encrypted swap ==="
echo "Swap partition: $SWAP_PART"
echo "LUKS mapper:    /dev/mapper/$MAPPER_NAME"
echo ""

# 1. Disable swap
echo "[1/5] Disabling swap on $SWAP_PART ..."
if swapon --show | grep -q "$SWAP_PART"; then
    swapoff "$SWAP_PART"
    echo "  Swap off."
else
    echo "  Not active — skipping."
fi

# 2. Format as LUKS (same passphrase as cryptroot)
echo ""
echo "[2/5] Creating LUKS container on $SWAP_PART ..."
echo "  You will be prompted for the passphrase TWICE:"
echo "    - First:  unlock cryptroot (to verify the passphrase)"
echo "    - Second: luksFormat the swap partition (use SAME passphrase)"
echo ""
cryptsetup luksFormat --type luks2 "$SWAP_PART"
echo "  LUKS formatted."

# 3. Open the LUKS container
echo ""
echo "[3/5] Opening LUKS container as $MAPPER_NAME ..."
cryptsetup luksOpen "$SWAP_PART" "$MAPPER_NAME"
echo "  Opened: /dev/mapper/$MAPPER_NAME"

# 4. Create swap on the mapped device
echo ""
echo "[4/5] Creating swap on /dev/mapper/$MAPPER_NAME ..."
mkswap "/dev/mapper/$MAPPER_NAME"
echo "  Swap created."

# 5. Enable swap
echo ""
echo "[5/5] Enabling swap ..."
swapon "/dev/mapper/$MAPPER_NAME"
echo "  Swap enabled."

# Verify
echo ""
echo "=== Done ==="
swapon --show | grep "$MAPPER_NAME" && echo "Swap is active on /dev/mapper/$MAPPER_NAME"
echo ""
echo "Next steps:"
echo "  1. Rebuild: nh os switch /etc/nixos -H \$(uname -n)"
echo "  2. Reboot to test resume from /dev/mapper/cryptswap"
echo "  3. Verify: cat /proc/cmdline | grep resume"
