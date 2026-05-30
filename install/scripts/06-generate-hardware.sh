#!/usr/bin/env bash
set -euo pipefail

# 06-generate-hardware.sh
# Run nixos-generate-config to create hardware-configuration.nix from the live system

MOUNT="/mnt"

echo "=== Step 6: Generate hardware-configuration.nix ==="

sudo nixos-generate-config --root "$MOUNT"

echo "Generated files:"
ls -la "$MOUNT/etc/nixos/"

echo ""
echo "Next steps:"
echo "  1. Copy your flake to /mnt/etc/nixos/ (run ./07-copy-config.sh)"
echo "  2. Update UUIDs in modules/system/btrfs-laptop.nix"
echo "  3. Ensure hardware-configuration.nix is imported by the host config"
