#!/usr/bin/env bash
set -euo pipefail

# disko-install.sh
# One-command reinstall using Disko declarative partitioning.
# Run from the NixOS installer USB.
#
# This script:
#   1. Closes any existing LUKS mappers
#   2. Prompts for LUKS password
#   3. Runs Disko to partition, format, LUKS, Btrfs subvolumes, mount
#   4. Copies flake to /mnt/etc/nixos
#   5. Runs nixos-install
#
# USAGE:
#   cd /home/nixos/nixos-config/install/scripts
#   sudo ./disko-install.sh

REPO="/home/nixos/nixos-config"
TARGET="/mnt/etc/nixos"
DISKO_CONFIG="$REPO/modules/system/disko-laptop.nix"

echo "========================================"
echo "  NixOS Install with Disko"
echo "  Framework Laptop 13 AMD"
echo "========================================"

# ── 1. Safety checks ──
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Must run as root (use sudo)"
    exit 1
fi

echo ""
echo "WARNING: This will DESTROY all data on /dev/nvme0n1"
read -r -p "Type 'yes' to continue: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

# ── 2. Close any existing mappers ──
echo ""
echo "--- Closing existing LUKS mappers ---"
for mapper in cryptroot; do
    if cryptsetup status "$mapper" &>/dev/null; then
        echo "  Closing /dev/mapper/$mapper"
        cryptsetup close "$mapper" || true
    fi
done

# ── 3. Unmount anything on /mnt ──
echo ""
echo "--- Unmounting /mnt ---"
umount -R /mnt/boot 2>/dev/null || true
umount -R /mnt 2>/dev/null || true
swapoff /dev/nvme0n1p3 2>/dev/null || true

# ── 4. LUKS password ──
echo ""
echo "--- LUKS Password ---"
read -r -s -p "Enter LUKS password for /dev/nvme0n1p2: " LUKS_PASS
echo ""
# Write password without trailing newline (required by Disko)
printf '%s' "$LUKS_PASS" > /tmp/luks-password

# ── 5. Run Disko (destroy, format, mount) ──
echo ""
echo "--- Running Disko ---"
echo "  Device: /dev/nvme0n1"
echo "  Config: $DISKO_CONFIG"
nix run 'github:nix-community/disko/latest#disko' -- \
    --mode destroy,format,mount "$DISKO_CONFIG"

# ── 6. Verify mounts ──
echo ""
echo "--- Mount status ---"
findmnt -R /mnt

# ── 7. Copy flake to /mnt/etc/nixos ──
echo ""
echo "--- Copying flake to $TARGET ---"
rm -rf "$TARGET"/* "$TARGET"/.* 2>/dev/null || true
tar -C "$REPO" -cf - . | tar -C "$TARGET" -xf -
rm -f "$TARGET/configuration.nix" "$TARGET/hardware-configuration.nix"

# ── 8. nixos-install ──
echo ""
echo "--- Running nixos-install ---"
cd "$TARGET"
NIXPKGS_ALLOW_INSECURE=1 nixos-install --flake .#framework-stephan --impure

# ── 9. Set passwords ──
echo ""
echo "--- Setting passwords ---"
nixos-enter --root /mnt -c 'echo "root:root" | chpasswd'
nixos-enter --root /mnt -c 'echo "stephan:stephan" | chpasswd'

echo ""
echo "========================================"
echo "  INSTALL COMPLETE"
echo "========================================"
echo ""
echo "Reboot:  sudo reboot"
echo ""
echo "After first boot, run:"
echo "  ~/nixos-config/install/scripts/09-post-install.sh"
