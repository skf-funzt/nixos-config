#!/usr/bin/env bash
set -euo pipefail

# 09-post-install.sh
# First-boot setup and validation checklist.
# Run this AFTER rebooting into the new NixOS system.
# This script is self-contained — it does NOT need the agent.

echo "=========================================="
echo "  NixOS Post-Install Checklist"
echo "  Run this INSIDE the new NixOS system"
echo "=========================================="

# ── 1. Basic System Verification ──
echo ""
echo "--- 1. Filesystem Verification ---"
echo "Btrfs subvolumes:"
btrfs subvolume list /
echo ""
echo "Mount points:"
findmnt -R /
echo ""
echo "Swap:"
swapon --show || true

# ── 2. Network ──
echo ""
echo "--- 2. Network Test ---"
ping -c 3 -W 5 nixos.org && echo "Network OK" || echo "Network FAILED — check NetworkManager"

# ── 3. Ensure Repo is Local ──
echo ""
echo "--- 3. Ensure nixos-config repo is present ---"
if [[ ! -d ~/nixos-config/.git ]]; then
    echo "Cloning nixos-config repo..."
    git clone https://github.com/skf-funzt/nixos-config.git ~/nixos-config || echo "Clone failed or repo already exists"
else
    echo "Repo already present at ~/nixos-config"
fi

# ── 4. Home Manager ──
echo ""
echo "--- 4. Home Manager ---"
echo "Home Manager is integrated into the NixOS system flake."
echo "After editing configs, rebuild with:"
echo "  sudo nixos-rebuild switch --flake ~/nixos-config#framework-stephan"
echo ""

# ── 5. Restore Backup Data ──
echo ""
echo "--- 5. Restore from Backup ---"
echo "If you have the backup drive (sdb1) with backup-20260527, run:"
echo ""
echo "  sudo mkdir -p /mnt/backup"
echo "  sudo mount /dev/sdb1 /mnt/backup"
echo "  rsync -avP /mnt/backup/backup-20260527/stephan/ /home/stephan/"
echo ""
read -r -p "Do you want to run the restore now? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy] ]]; then
    sudo mkdir -p /mnt/backup
    sudo mount /dev/sdb1 /mnt/backup
    rsync -avP /mnt/backup/backup-20260527/stephan/ /home/stephan/
    echo "Restore complete."
fi

# ── 6. Fix Permissions ──
echo ""
echo "--- 6. Fix Sensitive Directory Permissions ---"
for dir in ~/.ssh ~/.gnupg; do
    if [[ -d "$dir" ]]; then
        chmod 700 "$dir"
        echo "  chmod 700 $dir"
    fi
done

# ── 7. Test NixOS Rebuild ──
echo ""
echo "--- 7. Test nixos-rebuild ---"
read -r -p "Run 'nixos-rebuild switch' to verify flake works? [Y/n] " REPLY
if [[ -z "$REPLY" || "$REPLY" =~ ^[Yy] ]]; then
    sudo nixos-rebuild switch --flake ~/nixos-config#framework-stephan
fi

# ── 8. Btrfs Snapshot Demo ──
echo ""
echo "--- 8. Test Btrfs Snapshot ---"
read -r -p "Create a snapshot of / ? [Y/n] " REPLY
if [[ -z "$REPLY" || "$REPLY" =~ ^[Yy] ]]; then
    sudo mkdir -p /snapshots
    SNAP="/snapshots/$(date +%Y%m%d-%H%M%S)-post-install"
    sudo btrfs subvolume snapshot / "$SNAP"
    echo "Created: $SNAP"
fi

# ── 9. Desktop Validation Prompts ──
echo ""
echo "--- 9. Desktop Environment Tests ---"
echo "Manual tests you should do:"
echo "  [ ] Log out, select GNOME at login screen"
echo "  [ ] Log out, select Niri at login screen"
echo "  [ ] Test audio: run 'pactl info' and play something"
echo "  [ ] Test Wi-Fi: 'nmcli dev wifi list' and connect"
echo "  [ ] Test Bluetooth: 'bluetoothctl scan on' and pair"
echo "  [ ] Test suspend: close lid, open, verify unlock"

# ── 10. Git Commit Reminder ──
echo ""
echo "--- 10. Repo Maintenance ---"
echo "If you changed any config, commit and push:"
echo ""
echo "  cd ~/nixos-config"
echo "  git add -A && git commit -m 'post-install: tune from live system'"
echo "  git push origin main"

echo ""
echo "=========================================="
echo "  Post-install checklist complete!"
echo "=========================================="
