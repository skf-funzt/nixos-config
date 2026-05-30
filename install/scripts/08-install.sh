#!/usr/bin/env bash
set -euo pipefail

# 08-install.sh
# Run nixos-install from the live environment

TARGET="/mnt/etc/nixos"
HOSTNAME="framework-stephan"

echo "=== Step 8: nixos-install ==="
echo "Installing NixOS with flake $TARGET#$HOSTNAME"
echo "This will take a while..."

sudo nixos-install --flake "$TARGET#$HOSTNAME"

echo ""
echo "Install complete!"
echo "Set root password if prompted, then run ./09-post-install.sh"
