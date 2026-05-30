#!/usr/bin/env bash
set -euo pipefail

# install.sh — NixOS Reinstall Orchestrator
# Framework Laptop 13 AMD — Btrfs + LUKS — NixOS 26.05
#
# USAGE:
#   cd /home/nixos/nixos-config/install/scripts
#   ./01-unmount.sh
#   ./02-partition.sh
#   ./03-luks.sh
#   ./04-btrfs.sh
#   ./05-mount.sh
#   ./06-generate-hardware.sh
#   ./07-copy-config.sh
#   # <update UUIDs in modules/system/btrfs-laptop.nix>
#   ./08-install.sh
#   # reboot
#   ./09-post-install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$SCRIPT_DIR/scripts"

cat <<'BANNER'
┌─────────────────────────────────────────────────────────────┐
│  NixOS 26.05 Reinstall — Framework Laptop 13 AMD            │
│  Btrfs subvolumes (@ @home @nix @log @snapshots)            │
│  LUKS encryption + systemd-boot                             │
└─────────────────────────────────────────────────────────────┘
BANNER

echo "Available steps:"
ls -1 "$SCRIPTS"/[0-9]*.sh | while read -r f; do
    name=$(basename "$f")
    echo "  $name"
done
echo "  run-all.sh           (orchestrates all numbered scripts)"

echo ""
echo "Quick start:"
echo "  ./scripts/run-all.sh"
echo ""
echo "Or run each step in order. Every script asks for confirmation before destructive actions."
