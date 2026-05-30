# NixOS Multi-DE & Btrfs Reinstall TODO

## ⚠️ CRITICAL: This agent is EPHEMERAL
> Once the laptop reboots, this install environment (and this agent) is **gone forever**.
> Everything after reboot must be either:
> - **Automated** in the NixOS configuration itself, OR
> - **Documented** in standalone scripts the user runs without the agent

---

## Phase 1: BEFORE Reboot (Agent Active — DO NOW)

### 1.1 Discovery & Decisions ✅
- [x] Machine: Framework Laptop 13 AMD
- [x] Existing OS on nvme0n1: Full wipe
- [x] sdb (1TB): Backup-only, disconnected — leave alone
- [x] Backup: rsync verified complete (no diff output)
- [x] No LUKS passphrase needed — backup is the source of truth

### 1.2 Repo Architecture ✅
- [x] Restructure `nixos-config` to modular flake: `modules/{hosts,system,users,desktop}`
- [x] Port `configuration.nix` settings into `modules/hosts/laptop/default.nix`
- [x] Keep `home-manager` as standalone flake (don't integrate into NixOS yet)
- [x] Add `nixos-hardware` input for Framework 13 AMD 7040
- [x] Update to NixOS 26.05 / home-manager release-26.05
- [x] Write `install/scripts/{01..09}.sh` — reproducible, versioned shell scripts
- [x] Write `install/scripts/run-all.sh` orchestrator
- [x] Commit and push to GitHub

### 1.3 Disk Setup ⏳ PENDING — USER ACTION REQUIRED
> Run: `cd /home/nixos/nixos-config/install/scripts && ./run-all.sh`
> It stops after step 06 for UUID update.

- [ ] Unmount old LUKS and close crypt containers (`01-unmount.sh`)
- [ ] Partition nvme0n1: EFI (1G) + LUKS root (~3.6T) + swap (16G) (`02-partition.sh`)
- [ ] Create LUKS on nvme0n1p2, open as cryptroot (`03-luks.sh`)
- [ ] Create Btrfs filesystem + subvolumes: @ @home @nix @log @snapshots (`04-btrfs.sh`)
- [ ] Mount subvolumes to /mnt (`05-mount.sh`)
- [ ] Generate `hardware-configuration.nix` (`06-generate-hardware.sh`)

### 1.4 Config Wiring ⏳ PENDING — AGENT ACTION AFTER STEP 06
> After `06-generate-hardware.sh` completes, tell the agent "done".
> The agent will:

- [ ] Read generated `hardware-configuration.nix` from `/mnt/etc/nixos/`
- [ ] Extract Btrfs device UUID and swap UUID
- [ ] Update `modules/system/btrfs-laptop.nix` with real UUIDs
- [ ] Ensure `modules/hosts/laptop/default.nix` imports hardware-config correctly
- [ ] Copy flake to `/mnt/etc/nixos/` (`07-copy-config.sh`)
- [ ] Run `nixos-install --flake /mnt/etc/nixos#framework-stephan` (`08-install.sh`)

### 1.5 Final Pre-Reboot
- [ ] Set root password when `nixos-install` prompts
- [ ] Verify `/mnt/etc/nixos/` contains the full flake with correct UUIDs
- [ ] Unmount /mnt (optional, installer does this on reboot)
- [ ] **REBOOT** — agent will be gone after this

---

## Phase 2: AFTER Reboot (Agent GONE — User runs scripts/checklists)

### 2.1 First Boot Checklist
> Run: `~/nixos-config/install/scripts/09-post-install.sh`

- [ ] System boots into LUKS password prompt → enter passphrase
- [ ] systemd-boot shows NixOS entry
- [ ] Log in as `stephan` (initial password set in `modules/users/stephan.nix`)
- [ ] Verify network: `ping -c 3 nixos.org`
- [ ] Verify Btrfs mounts: `findmnt` and `btrfs subvolume list /`
- [ ] Verify swap: `swapon --show`

### 2.2 Home & Data Setup

- [ ] Clone repos to `/home/stephan/`:
  ```bash
  git clone https://github.com/skf-funzt/nixos-config.git ~/nixos-config
  git clone https://github.com/skf-funzt/home-manager.git ~/.config/home-manager
  ```
- [ ] Activate home-manager:
  ```bash
  home-manager switch --flake ~/.config/home-manager#stephan
  ```
- [ ] Restore personal data from backup drive (sdb1):
  ```bash
  sudo mkdir -p /mnt/backup
  sudo mount /dev/sdb1 /mnt/backup
  rsync -avP /mnt/backup/backup-20260527/stephan/ /home/stephan/
  # Exclude if needed: --exclude='.cache' --exclude='.local/share/Trash'
  ```
- [ ] Verify restored files: `.ssh/`, `.gnupg/`, `.config/`, passwords, tokens
- [ ] Fix permissions: `chmod 700 ~/.ssh ~/.gnupg`

### 2.3 NixOS System Validation

- [ ] Test `nixos-rebuild switch` works:
  ```bash
  sudo nixos-rebuild switch --flake ~/nixos-config#framework-stephan
  ```
- [ ] Verify Btrfs compression: `btrfs filesystem df /`
- [ ] Test snapshot manually:
  ```bash
  sudo btrfs subvolume snapshot / /snapshots/$(date +%Y%m%d)-pre-change
  ```
- [ ] Enable automatic GC and optimise (already in config — verify):
  ```bash
  systemctl status nix-gc.timer
  systemctl status nix-optimise.timer
  ```

### 2.4 Desktop Validation

- [ ] GNOME: log out, select GNOME at login screen, verify works
- [ ] Niri: log out, select Niri at login screen, verify works
- [ ] Audio: `pactl info` → verify PipeWire, test speakers
- [ ] Wi-Fi: `nmcli dev wifi list` → connect to network
- [ ] Bluetooth: `bluetoothctl` → scan, pair device
- [ ] Suspend/resume: close lid, open, verify unlock prompt
- [ ] Hibernation (optional): `systemctl hibernate` → verify resume

### 2.5 Final Repo Maintenance

- [ ] Edit `~/nixos-config/modules/system/btrfs-laptop.nix` if any post-install tuning needed
- [ ] Commit any local changes:
  ```bash
  cd ~/nixos-config
  git add -A && git commit -m "post-install: update from live system"
  git push origin main
  ```
- [ ] Same for `~/.config/home-manager` if any tweaks made

---

## Appendix: If Something Goes Wrong After Reboot

### Can't boot
- Hold Space at boot → systemd-boot menu → select older generation
- Or: boot installer USB, mount system, fix config, `nixos-install --root /mnt`

### Home-manager fails
- Check `home-manager news` for breaking changes in 26.05
- Temporarily disable failing modules in `home.nix`

### Missing files after restore
- sdb1 backup is still intact. Mount it and compare:
  ```bash
  sudo mount /dev/sdb1 /mnt/backup
  diff -qr /mnt/backup/backup-20260527/stephan/ /home/stephan/
  ```
