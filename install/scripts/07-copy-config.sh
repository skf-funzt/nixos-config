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

# Step 1: Back up the generated hardware config before we nuke /mnt/etc/nixos
echo "Preserving generated hardware config..."
GENERATED="$TARGET/hardware-configuration.nix"
GENERATED_BACKUP="/tmp/hardware-configuration.nix.generated"
if [[ -f "$GENERATED" ]]; then
    sudo cp "$GENERATED" "$GENERATED_BACKUP"
else
    echo "WARNING: $GENERATED not found."
fi

# Step 2: Wipe /mnt/etc/nixos clean so old generated files don't leak
echo "Cleaning /mnt/etc/nixos..."
sudo rm -rf "$TARGET"/*
sudo rm -rf "$TARGET"/.* 2>/dev/null || true

# Step 3: Copy the entire repo (including hidden files)
echo "Copying flake from $REPO ..."
# Use tar to preserve hidden files, permissions, and symlinks
sudo tar -C "$REPO" -cf - . | sudo tar -C "$TARGET" -xf -

# Step 4: Filter the generated hardware config to remove fileSystems/swapDevices
if [[ -f "$GENERATED_BACKUP" ]]; then
    echo "Filtering generated hardware config (removing fileSystems/swapDevices)..."
    awk '
        # Skip fileSystems definitions: from "fileSystems." until the matching "};"
        /fileSystems\./ { in_fs=1; next }
        in_fs && /^  \};/ { in_fs=0; next }
        in_fs { next }

        # Skip swapDevices definitions: from "swapDevices" until the matching "];"
        /swapDevices/ { in_swap=1; next }
        in_swap && /^  \];/ { in_swap=0; next }
        in_swap { next }

        # Everything else: print
        { print }
    ' "$GENERATED_BACKUP" | sudo tee "$TARGET/modules/hosts/laptop/hardware-configuration.nix" > /dev/null
    sudo rm -f "$GENERATED_BACKUP"
else
    echo "WARNING: No generated hardware config found. Placeholder left in place."
fi

echo ""
echo "Next: update UUIDs in modules/system/btrfs-laptop.nix"
echo "  Run: sudo blkid /dev/mapper/cryptroot"
echo "  Then edit: $TARGET/modules/system/btrfs-laptop.nix"
echo ""
echo "Then run ./08-install.sh"
