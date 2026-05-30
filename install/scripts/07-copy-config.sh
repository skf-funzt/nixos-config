#!/usr/bin/env bash
set -euo pipefail

# 07-copy-config.sh
# Copy the modular flake configuration into /mnt/etc/nixos/
# and wire the generated hardware-configuration.nix into the host config.
#
# IMPORTANT: The generated hardware-configuration.nix contains BOTH
# hardware detection (kernel modules, initrd, platform) AND filesystem
# definitions. We intentionally keep ONLY the hardware parts because
# modules/system/btrfs-laptop.nix owns the filesystem layout.

REPO="/home/nixos/nixos-config"
TARGET="/mnt/etc/nixos"

echo "=== Step 7: Copy flake to $TARGET ==="

# Read the generated hardware config and extract only hardware-specific lines
echo "Extracting hardware-specific config from generated file..."
GENERATED="$TARGET/hardware-configuration.nix"
if [[ -f "$GENERATED" ]]; then
    # Create a filtered version without fileSystems and swapDevices
    awk '
        /fileSystems\./ { skip=1; next }
        /swapDevices\./ { skip=1; next }
        skip && /^  };/ { skip=0; next }
        skip { next }
        { print }
    ' "$GENERATED" > "$TARGET/hardware-configuration.nix.filtered"
else
    echo "WARNING: $GENERATED not found. Using placeholder."
fi

# Copy entire flake
echo "Copying flake..."
sudo cp -r "$REPO"/* "$TARGET/"
# Preserve .git so the install target is a proper repo
sudo cp -r "$REPO/.git" "$TARGET/" 2>/dev/null || true

# Replace the placeholder hardware config with the filtered generated one
if [[ -f "$TARGET/hardware-configuration.nix.filtered" ]]; then
    sudo cp "$TARGET/hardware-configuration.nix.filtered" "$TARGET/modules/hosts/laptop/hardware-configuration.nix"
    sudo rm -f "$TARGET/hardware-configuration.nix.filtered"
fi

# Clean up generated files from /mnt/etc/nixos root
sudo rm -f "$TARGET/configuration.nix" "$TARGET/hardware-configuration.nix" "$TARGET/hardware-configuration.nix.generated" 2>/dev/null || true

echo ""
echo "Next: update UUIDs in modules/system/btrfs-laptop.nix"
echo "  Look for the Btrfs device UUID in the filtered hardware config"
echo "  or run: sudo blkid /dev/mapper/cryptroot"
echo ""
echo "Then run ./08-install.sh"
