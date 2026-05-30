# 🔴 NixOS Install — Current Phase

**Started:** 2026-05-30
**Target:** Framework Laptop 13 AMD — NixOS 26.05 — Btrfs + LUKS

## Current Phase: 🟡 DISK PREP — Config written. Waiting for YOU to unmount & partition nvme0n1

### What I (the agent) am doing:
- Writing / editing NixOS configuration files under `/home/nixos/nixos-config/`
- Planning partition layouts and commands
- Updating TODO.md and this PHASE.md

### What YOU (the user) must do:
- Run any `sudo` commands I provide in copy-paste blocks
- Make decisions when I ask

### Last Action:
- Created modular flake architecture in `/home/nixos/nixos-config/modules/`

### Next Action (pending your go-ahead):
1. Unmount old LUKS partitions and close crypt containers
2. Partition `nvme0n1` with GPT: EFI + LUKS + swap
3. Create LUKS container, Btrfs filesystem, subvolumes
4. Mount to `/mnt` and generate `hardware-configuration.nix`

### Commands for YOU to run:
```bash
# Step 1: Unmount and close old LUKS
sudo umount /run/media/nixos/7c01f71d-b98c-4afe-8715-81df7c9f97c7
sudo cryptsetup close luks-4ee0041b-b1cf-4371-8dbb-69455fc07cae
sudo cryptsetup close luks-c840e017-1623-4896-a1b9-ed9053eb7d9b

# Step 2: Wipe and partition nvme0n1
sudo wipefs -a /dev/nvme0n1
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 1GiB -16GiB   # LUKS root
sudo parted /dev/nvme0n1 -- mkpart primary -16GiB 100%    # swap

# Step 3: Format EFI
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1

# Step 4: LUKS on main partition
sudo cryptsetup luksFormat /dev/nvme0n1p2
sudo cryptsetup open /dev/nvme0n1p2 cryptroot

# Step 5: Btrfs with subvolumes
sudo mkfs.btrfs -L nixos /dev/mapper/cryptroot
sudo mount /dev/mapper/cryptroot /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@log
sudo btrfs subvolume create /mnt/@snapshots
sudo umount /mnt

# Step 6: Mount subvolumes
sudo mount -o subvol=@,compress=zstd:1,noatime /dev/mapper/cryptroot /mnt
sudo mkdir -p /mnt/{home,nix,var/log,boot}
sudo mount -o subvol=@home,compress=zstd:1,noatime /dev/mapper/cryptroot /mnt/home
sudo mount -o subvol=@nix,compress=zstd:1,noatime /dev/mapper/cryptroot /mnt/nix
sudo mount -o subvol=@log,compress=zstd:1,noatime /dev/mapper/cryptroot /mnt/var/log
sudo mount /dev/nvme0n1p1 /mnt/boot

# Step 7: Swap
sudo mkswap -L swap /dev/nvme0n1p3
sudo swapon /dev/nvme0n1p3

# Step 8: Generate hardware config
sudo nixos-generate-config --root /mnt
```

After these complete, tell me "done" and I will:
- Read the generated `hardware-configuration.nix`
- Update the flake UUIDs
- Run `nixos-install` (which also requires sudo — I'll give you the command)

---
## How to see progress
1. **In pi:** type `/status` — shows current phase inline
2. **In pi:** type `/todo` — opens TODO.md in your editor
3. **In pi:** type `/editor <file>` — opens any file in nano/vim
4. **In shell:** `cat /home/nixos/PHASE.md` or `cat /home/nixos/TODO.md`

---
## Sudo Commands Waiting
**NONE** — I will not run sudo. I will only show you the exact commands to copy-paste.
