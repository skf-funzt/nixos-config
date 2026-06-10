#!/usr/bin/env bash
# convert-swap-to-luks.sh — Set up LUKS-encrypted swap with keyfile on root.
#
# WHAT: Ensures /dev/nvme0n1p2 is a LUKS container (cryptswap) unlocked via
#       a keyfile stored on the encrypted root. The initrd unlocks cryptroot
#       first (password), then reads the keyfile from /sysroot/etc/cryptswap.key
#       to unlock cryptswap — single password prompt at boot.
#
# IDEMPOTENT: Safe to run multiple times. Skips already-completed steps.
#             Will NOT re-luksFormat an existing LUKS container.
#
# PREREQUISITES: cryptroot must be unlocked (run from inside the booted system).
#
# USAGE: sudo ./convert-swap-to-luks.sh

set -euo pipefail

SWAP_PART="/dev/nvme0n1p2"
MAPPER_NAME="cryptswap"
KEYFILE="/etc/cryptswap.key"

echo "=== LUKS-encrypted swap setup (keyfile on root) ==="
echo "Swap partition: $SWAP_PART"
echo "LUKS mapper:    /dev/mapper/$MAPPER_NAME"
echo "Keyfile:        $KEYFILE"
echo ""

# ── Check current state ──────────────────────────────────────
IS_LUKS=false
IS_OPEN=false
IS_SWAP=false

if cryptsetup isLuks "$SWAP_PART" 2>/dev/null; then
    IS_LUKS=true
    echo "[info] $SWAP_PART is already a LUKS container."
else
    echo "[info] $SWAP_PART is NOT a LUKS container — will format."
fi

if [ -e "/dev/mapper/$MAPPER_NAME" ]; then
    IS_OPEN=true
    echo "[info] /dev/mapper/$MAPPER_NAME is already open."
else
    echo "[info] /dev/mapper/$MAPPER_NAME is not open."
fi

if swapon --show | grep -q "/dev/mapper/$MAPPER_NAME"; then
    IS_SWAP=true
    echo "[info] Swap is active on /dev/mapper/$MAPPER_NAME."
else
    echo "[info] Swap is not active on /dev/mapper/$MAPPER_NAME."
fi

# ── Step 1: Generate keyfile ─────────────────────────────────
echo ""
if [ -f "$KEYFILE" ]; then
    echo "[1] Keyfile already exists at $KEYFILE — skipping."
else
    echo "[1] Generating keyfile at $KEYFILE ..."
    dd if=/dev/urandom of="$KEYFILE" bs=512 count=8 status=none
    chmod 600 "$KEYFILE"
    echo "    Keyfile created (4096 bytes, mode 600)."
fi

# ── Step 2: Disable swap on the raw partition (if still active) ──
echo ""
echo "[2] Ensuring swap is off on $SWAP_PART ..."
if swapon --show | grep -q "$SWAP_PART[[:space:]]"; then
    swapoff "$SWAP_PART"
    echo "    Swapped off raw partition."
else
    echo "    Raw partition swap not active — ok."
fi

# ── Step 3: Format as LUKS (only if not already LUKS) ────────
if $IS_LUKS; then
    echo ""
    echo "[3] $SWAP_PART already LUKS — skipping format."
else
    echo ""
    echo "[3] Creating LUKS container on $SWAP_PART ..."
    echo "    You'll be prompted for a passphrase (use the same one as cryptroot)."
    echo "    This passphrase is a fallback if the keyfile is lost."
    cryptsetup luksFormat --type luks2 "$SWAP_PART"
    echo "    LUKS formatted."
    IS_LUKS=true
fi

# ── Step 4: Add keyfile to LUKS header ───────────────────────
echo ""
echo "[4] Registering keyfile in LUKS header ..."

# Check if keyfile is already enrolled (slot 1+ with token)
if cryptsetup luksDump "$SWAP_PART" | grep -q "cryptswap"; then
    echo "    Keyfile appears already registered — skipping."
else
    echo "    You'll be prompted for the existing LUKS passphrase to add a key slot."
    cryptsetup luksAddKey "$SWAP_PART" "$KEYFILE"
    echo "    Keyfile registered."
fi

# ── Step 5: Open with keyfile (or close+reopen to verify) ────
echo ""
if $IS_OPEN; then
    echo "[5] $MAPPER_NAME already open — closing and re-opening with keyfile to verify ..."
    # Disable swap on mapper first if active
    if $IS_SWAP; then
        swapoff "/dev/mapper/$MAPPER_NAME"
    fi
    cryptsetup luksClose "$MAPPER_NAME"
fi
echo "[5] Opening with keyfile ..."
cryptsetup luksOpen --key-file "$KEYFILE" "$SWAP_PART" "$MAPPER_NAME"
echo "    Keyfile works — /dev/mapper/$MAPPER_NAME opened."
IS_OPEN=true

# ── Step 6: Create swap on mapped device ─────────────────────
echo ""
echo "[6] Creating swap on /dev/mapper/$MAPPER_NAME ..."
# mkswap is idempotent; only warns if swap signature already present
mkswap "/dev/mapper/$MAPPER_NAME" 2>&1 | head -1
echo "    Done."

# ── Step 7: Enable swap ──────────────────────────────────────
echo ""
echo "[7] Enabling swap ..."
swapon "/dev/mapper/$MAPPER_NAME"
echo "    Swap enabled."

# ── Verify ────────────────────────────────────────────────────
echo ""
echo "=== Done ==="
swapon --show
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT /dev/nvme0n1p2 2>/dev/null || true
echo ""
echo "Next steps:"
echo "  1. Verify keyfile slot: sudo cryptsetup luksDump $SWAP_PART | grep -A2 'Key Slot'"
echo "  2. Rebuild: nh os switch /etc/nixos -H \$(uname -n)"
echo "  3. Reboot to test resume from /dev/mapper/cryptswap"
echo "  4. After reboot: cat /proc/cmdline | grep resume"
