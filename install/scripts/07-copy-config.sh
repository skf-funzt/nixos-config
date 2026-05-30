#!/usr/bin/env bash
set -euo pipefail

# 07-copy-config.sh
# Copy the modular flake configuration into /mnt/etc/nixos/
# and wire the generated hardware-configuration.nix into the host config

REPO="/home/nixos/nixos-config"
TARGET="/mnt/etc/nixos"

echo "=== Step 7: Copy flake to $TARGET ==="

# Back up generated hardware config before we overwrite
echo "Backing up generated hardware-configuration.nix..."
sudo cp "$TARGET/hardware-configuration.nix" "$TARGET/hardware-configuration.nix.generated"

# Copy entire flake
echo "Copying flake..."
sudo cp -r "$REPO"/* "$TARGET/"
sudo cp -r "$REPO"/.git "$TARGET/" 2>/dev/null || true

# Replace the placeholder hardware-configuration.nix with the generated one
echo "Wiring generated hardware config into host..."
sudo cp "$TARGET/hardware-configuration.nix.generated" "$TARGET/modules/hosts/laptop/hardware-configuration.nix"

# TODO: update UUIDs in btrfs-laptop.nix using the generated values
echo ""
echo "REMINDER: Update UUIDs in modules/system/btrfs-laptop.nix"
echo "  Read $TARGET/modules/hosts/laptop/hardware-configuration.nix for device UUIDs."

echo "Run ./08-install.sh after verifying UUIDs."
