#!/usr/bin/env bash
# convert-swap-to-luks.sh — Migrate live swap partition from raw to LUKS-encrypted.
#
# WHAT: Converts /dev/nvme0n1p2 (raw swap) to a LUKS container (cryptswap)
#       unlocked via a keyfile stored on the encrypted root. The initrd
#       unlocks cryptroot first (password), then reads the keyfile from
#       /sysroot/etc/cryptswap.key to unlock cryptswap — single password at boot.
#
# SAFETY: This is non-destructive to your data — only the swap partition is touched.
#         Swap contents are ephemeral and do not survive a reboot.
#
# PREREQUISITES: cryptroot must be unlocked (run from inside the booted system).
#
# USAGE: sudo ./convert-swap-to-luks.sh

set -euo pipefail

SWAP_PART="/dev/nvme0n1p2"
MAPPER_NAME="cryptswap"
KEYFILE="/etc/cryptswap.key"

echo "=== Convert swap partition to LUKS-encrypted swap (keyfile on root) ==="
echo "Swap partition: $SWAP_PART"
echo "LUKS mapper:    /dev/mapper/$MAPPER_NAME"
echo "Keyfile:        $KEYFILE"
echo ""

# 1. Generate keyfile (if not already present)
if [ -f "$KEYFILE" ]; then
    echo "[1/7] Keyfile already exists at $KEYFILE — skipping generation."
else
    echo "[1/7] Generating keyfile at $KEYFILE ..."
    dd if=/dev/urandom of="$KEYFILE" bs=512 count=8 status=none
    chmod 600 "$KEYFILE"
    echo "  Keyfile created (4096 bytes, mode 600)."
fi

# 2. Disable swap
echo ""
echo "[2/7] Disabling swap on $SWAP_PART ..."
if swapon --show | grep -q "$SWAP_PART"; then
    swapoff "$SWAP_PART"
    echo "  Swap off."
else
    echo "  Not active — skipping."
fi

# 3. Format as LUKS
echo ""
echo "[3/7] Creating LUKS container on $SWAP_PART ..."
echo "  You'll be prompted for a passphrase (use the same one as cryptroot)."
echo "  This passphrase is a fallback if the keyfile is lost."
cryptsetup luksFormat --type luks2 "$SWAP_PART"
echo "  LUKS formatted."

# 4. Open with passphrase and add keyfile
echo ""
echo "[4/7] Opening LUKS container to add keyfile ..."
cryptsetup luksOpen "$SWAP_PART" "$MAPPER_NAME"
echo "  Opened: /dev/mapper/$MAPPER_NAME"

echo ""
echo "[5/7] Registering keyfile in LUKS header ..."
cryptsetup luksAddKey "$SWAP_PART" "$KEYFILE"
echo "  Keyfile registered."

# Close and reopen with keyfile to verify
cryptsetup luksClose "$MAPPER_NAME"
cryptsetup luksOpen --key-file "$KEYFILE" "$SWAP_PART" "$MAPPER_NAME"
echo "  Keyfile verified — re-opened successfully."

# 5. Create swap on the mapped device
echo ""
echo "[6/7] Creating swap on /dev/mapper/$MAPPER_NAME ..."
mkswap "/dev/mapper/$MAPPER_NAME"
echo "  Swap created."

# 6. Enable swap
echo ""
echo "[7/7] Enabling swap ..."
swapon "/dev/mapper/$MAPPER_NAME"
echo "  Swap enabled."

# Verify
echo ""
echo "=== Done ==="
swapon --show | grep "$MAPPER_NAME" && echo "Swap is active on /dev/mapper/$MAPPER_NAME"
echo ""
echo "Next steps:"
echo "  1. Verify keyfile LUKS slot: sudo cryptsetup luksDump $SWAP_PART | grep -A2 Key"
echo "  2. Rebuild: nh os switch /etc/nixos -H \$(uname -n)"
echo "  3. Reboot to test resume from /dev/mapper/cryptswap"
echo "  4. Verify: cat /proc/cmdline | grep resume"
