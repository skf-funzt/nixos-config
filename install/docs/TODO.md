# NixOS Multi-DE & Btrfs Reinstall TODO
<!-- pi-todo-md:schema=1 -->

## Pre-Install: Discovery & Decisions
- [x] **1.1** Confirm which machine this is: Hybrid PC or Framework Laptop? <!-- pi-todo-md:id=1 -->
  - note: DECISION: Framework Laptop 13 AMD. No Hybrid PC.
- [x] **1.2** Decide fate of the existing Manjaro/Arch installation on `nvme0n1` <!-- pi-todo-md:id=2 -->
  - note: LUKS-encrypted ext4 root + swap partition exist
  - note: Option A: Full wipe and reinstall NixOS
  - note: Option B: Shrink existing, dual-boot (complex with LUKS)
  - note: **User must decide before partitioning**
- [x] **1.3** Clarify role of `sdb` (1TB labeled "FRMW 1TB") <!-- pi-todo-md:id=3 -->
  - note: Is this the server-data HDD for the hybrid-pc layout?
  - note: Or an external backup drive to be disconnected after install?
  - note: Contains `backup-20260527` with home directory snapshot
- [x] **1.4** Confirm backup completeness <!-- pi-todo-md:id=4 -->
  - note: Compare `/mnt/sdb1/backup-20260527/stephan/` vs old `/home/stephan` on `nvme0n1p2`
  - note: Identify any missing critical files (SSH keys, passwords, wallet, work)
- [x] **1.5** Extract LUKS passphrase if we need to mount old root during install <!-- pi-todo-md:id=5 -->
  - note: User must provide passphrase for `nvme0n1p2` (UUID: `4ee0041b-b1cf-4371-8dbb-69455fc07cae`)

## Pre-Install: Repo Architecture Setup
- [x] **2.1** Restructure `nixos-config` repo to match the Btrfs Architecture Guide <!-- pi-todo-md:id=6 -->
  - note: Create `modules/hosts/{laptop,hybrid-pc}/`
  - note: Create `modules/system/{btrfs-laptop.nix,btrfs-hybrid.nix}`
  - note: Create `modules/users/{stephan.nix,server-admin.nix}`
  - note: Create `modules/desktop/{gnome.nix,niri.nix}`
  - note: Update `flake.nix` to expose `nixosModules` and `homeModules`
- [x] **2.2** Port existing `configuration.nix` settings into new modular structure <!-- pi-todo-md:id=7 -->
  - note: Preserve: timezone (Europe/Berlin), locale, network, packages, services
  - note: Update from `nixos-24.11` / `nixos-unstable` mix to unified `nixos-26.05` (or stable)
- [x] **2.3** Port `home-manager` repo into the new flake as `homeConfigurations` or nixosModules <!-- pi-todo-md:id=8 -->
  - note: The current home-manager flake is standalone; integrate into nixos-config or keep separate
  - note: Resolve broken `home.nix` symlink in nixos-config repo
- [x] **2.4** Add `nixos-hardware` input for Framework 13 AMD if laptop host is needed <!-- pi-todo-md:id=9 -->
- [x] **2.5** Update `home-manager` to `release-26.05` and match nixpkgs version [focus] <!-- pi-todo-md:id=10 -->

## Disk Preparation: Partitioning & Btrfs
- [ ] **3.1** Unmount all target drives and close LUKS containers [focus] <!-- pi-todo-md:id=11 -->
  - note: `umount /run/media/nixos/7c01f71d-b98c-4afe-8715-81df7c9f97c7`
  - note: `cryptsetup close luks-4ee0041b-b1cf-4371-8dbb-69455fc07cae`
  - note: `cryptsetup close luks-c840e017-1623-4896-a1b9-ed9053eb7d9b`
  - note: `swapoff` if swap is active
- [ ] **3.2** Partition `nvme0n1` (3.7T SSD) <!-- pi-todo-md:id=12 -->
  - note: `nvme0n1p1`: 512M-1G EFI System Partition (FAT32)
  - note: `nvme0n1p2`: Remainder for LUKS + Btrfs (if encryption desired)
  - note: Optional: dedicated swap partition or swapfile on Btrfs
- [ ] **3.3** Set up LUKS on `nvme0n1p2` (optional but recommended — matches old setup) <!-- pi-todo-md:id=13 -->
  - note: `cryptsetup luksFormat /dev/nvme0n1p2`
  - note: `cryptsetup open /dev/nvme0n1p2 cryptroot`
- [ ] **3.4** Create Btrfs filesystem and subvolumes on `nvme0n1p2` (or mapped device) <!-- pi-todo-md:id=14 -->
  - note: `mkfs.btrfs /dev/mapper/cryptroot`
  - note: Subvolumes: `@` (root), `@home`, `@nix`, `@log`, `@snapshots`
- [ ] **3.5** Mount Btrfs subvolumes with correct options <!-- pi-todo-md:id=15 -->
  - note: `compress=zstd:1`, `noatime` for @, @home, @nix
  - note: Mount to `/mnt` for nixos-install
- [ ] **3.6** Prepare `sdb` if it is the server-data HDD <!-- pi-todo-md:id=16 -->
  - note: Reformat to Btrfs with subvolume `@serverdata`
  - note: Mount at `/mnt/server-hdd` in the installer
  - note: Or keep as ext4 if user wants to preserve existing backups
- [ ] **3.7** Generate new `hardware-configuration.nix` from live system <!-- pi-todo-md:id=17 -->
  - note: `nixos-generate-config --root /mnt`
  - note: Capture Btrfs UUIDs, LUKS mappings, swap

## NixOS Installation
- [ ] **4.1** Write the target host configuration to `/mnt/etc/nixos/` <!-- pi-todo-md:id=18 -->
  - note: Copy the restructured flake to `/mnt/etc/nixos/`
  - note: Update UUIDs in `modules/system/btrfs-hybrid.nix` or `btrfs-laptop.nix`
- [ ] **4.2** Ensure `hardware-configuration.nix` is imported and correct <!-- pi-todo-md:id=19 -->
- [ ] **4.3** Set initial passwords and SSH keys for `stephan` and `server-admin` <!-- pi-todo-md:id=20 -->
- [ ] **4.4** Run `nixos-install --flake /mnt/etc/nixos#<hostname>` <!-- pi-todo-md:id=21 -->
  - note: `nixos-install --flake .#hybrid-pc` or `.#laptop`
- [ ] **4.5** Set root password when prompted by installer <!-- pi-todo-md:id=22 -->
- [ ] **4.6** Reboot into new system <!-- pi-todo-md:id=23 -->

## Post-Install: First Boot & Home Manager
- [ ] **5.1** Verify boot: systemd-boot entries, Btrfs mounts, LUKS unlock <!-- pi-todo-md:id=24 -->
- [ ] **5.2** Log in as `stephan`, verify network, basic functionality <!-- pi-todo-md:id=25 -->
- [ ] **5.3** Clone repos to new `/home/stephan/` <!-- pi-todo-md:id=26 -->
  - note: `git clone https://github.com/skf-funzt/nixos-config /home/stephan/nixos-config`
  - note: `git clone https://github.com/skf-funzt/home-manager /home/stephan/home-manager`
- [ ] **5.4** Activate home-manager configuration <!-- pi-todo-md:id=27 -->
  - note: `home-manager switch --flake /home/stephan/home-manager#stephan` (or nixos-integrated)
- [ ] **5.5** Restore personal data from `sdb1` backup <!-- pi-todo-md:id=28 -->
  - note: `rsync -avP /mnt/sdb1/backup-20260527/stephan/ /home/stephan/`
  - note: Exclude: `.cache`, `nix`, large games if reinstallable
- [ ] **5.6** Restore critical dotfiles and secrets selectively <!-- pi-todo-md:id=29 -->
  - note: `.ssh/`, `.gnupg/`, `.config/`, passwords, wallets, tokens
  - note: Verify permissions are correct (700 for private dirs)
- [ ] **5.7** Test specialisations if hybrid-pc <!-- pi-todo-md:id=30 -->
  - note: Reboot into "gaming" specialisation
  - note: Verify GNOME/niri desktops, Steam, server services OFF
  - note: Reboot into base config
  - note: Verify server services ON, graphical OFF

## Cleanup & Validation
- [ ] **6.1** Add `nixos-config` and `home-manager` to `environment.etc` or manage via flake <!-- pi-todo-md:id=31 -->
- [ ] **6.2** Set up automatic GC and optimise store <!-- pi-todo-md:id=32 -->
  - note: `nix.gc.automatic`, `nix.optimise.automatic`
- [ ] **6.3** Verify Btrfs compression and subvolume layout <!-- pi-todo-md:id=33 -->
  - note: `btrfs filesystem df /`, `btrfs subvolume list /`
- [ ] **6.4** Test snapshot capability (e.g., `snapper` or manual `btrfs subvolume snapshot`) <!-- pi-todo-md:id=34 -->
- [ ] **6.5** Document any manual steps needed for next reinstall <!-- pi-todo-md:id=35 -->
- [ ] **6.6** Commit and push updated repo structure back to GitHub <!-- pi-todo-md:id=36 -->
