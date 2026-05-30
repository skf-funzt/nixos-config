# Disko Integration Guide

> Disko is a **declarative disk partitioning tool** for NixOS.
> It replaces manual partitioning, formatting, and mounting with pure Nix config.
>
> This doc describes how Disko could be integrated into our flake
> for future installs. The current install used shell scripts under
> `install/scripts/` for historical reasons.

## What Disko Does

Instead of:
```bash
./01-unmount.sh
./02-partition.sh
./03-luks.sh
./04-btrfs.sh
./05-mount.sh
./06-generate-hardware.sh
./07-copy-config.sh
./08-install.sh
```

Disko enables a **single command**:
```bash
nix run 'github:nix-community/disko/latest#disko-install' -- \
  --flake .#framework-stephan \
  --disk main /dev/nvme0n1
```

This one command:
1. Partitions the disk
2. Formats partitions (LUKS, Btrfs, FAT32, swap)
3. Creates Btrfs subvolumes
4. Mounts everything to `/mnt`
5. Runs `nixos-install`

## Our Disko Config

The declarative layout is in `modules/system/disko-laptop.nix`:

```
nvme0n1 (GPT)
├── p1: EFI  (1G, vfat, mounted at /boot)
├── p2: LUKS (remainder, Btrfs subvols: @ @home @nix @log @snapshots)
└── p3: swap (96G, matches RAM for hibernation)
```

## How to Use (Next Install)

1. **Boot NixOS installer USB**

2. **Set LUKS password** (Disko reads from a file):
   ```bash
   read -s -p "LUKS password: " LUKS_PASS
   echo "$LUKS_PASS" > /tmp/luks-password
   ```

3. **Run Disko** (partitions, formats, mounts, installs):
   ```bash
   git clone https://github.com/skf-funzt/nixos-config.git /home/nixos/nixos-config
   cd /home/nixos/nixos-config
   
   nix run 'github:nix-community/disko/latest#disko-install' -- \
     --flake .#framework-stephan \
     --disk main /dev/nvme0n1
   ```

4. **Reboot**

## Advantages Over Shell Scripts

| Shell Scripts | Disko |
|-------------|-------|
| 9 steps, manual confirmations | 1 command, fully declarative |
| Prone to partial failures | Atomic: either fully succeeds or no-op |
| Hardcoded device names | Device names in one config file |
| No rollback on failure | Built-in `--dry-run` and `--destroy` modes |
| Re-partitioning is manual | Re-run same command, idempotent |

## Current Status

- [x] Disko config written: `modules/system/disko-laptop.nix`
- [ ] Not yet imported into host config (intentional — Disko is an install-time tool)
- [ ] Not yet tested on real hardware
- [ ] Shell scripts remain as fallback

## References

- [Disko repo](https://github.com/nix-community/disko)
- [Disko Quickstart](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
- [Disko Examples](https://github.com/nix-community/disko/tree/master/example)
- [LUKS + Btrfs example](https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix)
