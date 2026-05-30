#!/usr/bin/env bash
set -euo pipefail

# 09-post-install.sh
# First-boot setup after nixos-install
# Run these AFTER rebooting into the new system

echo "=== Step 9: Post-install (run inside new NixOS) ==="

echo "1. Set password for stephan:"
echo "   sudo passwd stephan"

echo ""
echo "2. Clone repos to /home/stephan:"
echo "   mkdir -p ~/nixos-config ~/home-manager"
echo "   git clone https://github.com/skf-funzt/nixos-config.git ~/nixos-config"
echo "   git clone https://github.com/skf-funzt/home-manager.git ~/home-manager"

echo ""
echo "3. Activate home-manager (standalone):"
echo "   home-manager switch --flake ~/home-manager#stephan"

echo ""
echo "4. Restore data from backup if needed:"
echo "   rsync -avP /mnt/sdb1/backup-20260527/stephan/ /home/stephan/"

echo ""
echo "5. Verify Btrfs layout:"
echo "   btrfs subvolume list /"
echo "   btrfs filesystem df /"

echo ""
echo "6. Enable hibernation resume offset (optional):"
echo "   sudo btrfs inspect-internal map-swapfile -r /swapfile"
echo "   # Then add resume_offset=<value> to boot.kernelParams"
