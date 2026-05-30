# NixOS Declarative Configuration — Dendritic Multi-Host Flake

Unified NixOS + Home Manager flake for multiple machines, following a modular dendritic architecture.

## Hosts

| Host | Machine | Path | Desktop | Storage |
|------|---------|------|---------|---------|
| `framework-stephan` | Framework Laptop 13 AMD | `modules/hosts/laptop/` | GNOME + Niri | Btrfs + LUKS |

## Architecture

```
.
├── flake.nix                           # Entry point: all flake inputs & outputs
├── modules/
│   ├── hosts/
│   │   └── laptop/
│   │       ├── default.nix             # Host: bootloader, kernel, network, audio, packages
│   │       └── hardware-configuration.nix  # Auto-generated (nixos-generate-config)
│   ├── system/
│   │   └── btrfs-laptop.nix            # Btrfs subvolume layout & mount options
│   ├── users/
│   │   └── stephan.nix                 # User account + home-manager module import
│   └── desktop/
│       ├── gnome.nix                   # GNOME DE
│       └── niri.nix                    # Niri Wayland compositor
├── home/                               # Home Manager configurations (merged from old standalone repo)
│   ├── stephan.nix                     # Entry point
│   ├── zsh.nix
│   ├── nixvim.nix
│   ├── vscode.nix
│   ├── noctalia.nix
│   ├── handy-wrapped.nix
│   ├── gruvbox-rainbow.toml
│   └── gnome-background.webp
├── install/                            # Reproducible install scripts
│   ├── install.sh                      # Quick reference / banner
│   ├── scripts/
│   │   ├── 01-unmount.sh              # Unmount old LUKS containers
│   │   ├── 02-partition.sh            # GPT layout: EFI + LUKS + swap
│   │   ├── 03-luks.sh                 # LUKS format & open
│   │   ├── 04-btrfs.sh                # Btrfs filesystem + subvolumes
│   │   ├── 05-mount.sh                # Mount subvolumes to /mnt
│   │   ├── 06-generate-hardware.sh    # nixos-generate-config
│   │   ├── 07-copy-config.sh           # Copy flake → /mnt/etc/nixos
│   │   ├── 08-install.sh              # nixos-install --flake
│   │   ├── 09-post-install.sh         # First-boot checklist (run after reboot)
│   │   └── run-all.sh                 # Orchestrates 01→08, pauses for UUID wiring
│   └── docs/
│       ├── PHASE.md                   # Current install phase
│       └── TODO.md                    # Full task tracker (before/after reboot)
├── AGENTS.md                          # Session context for pi agent
└── .pi/
    └── extensions/                    # Pi agent extensions (editor, status)
```

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | NixOS 26.05 |
| `nixpkgs-unstable` | Latest packages (ollama, etc.) |
| `home-manager` | User environment management |
| `nixos-hardware` | Framework 13 AMD modules |
| `stylix` | Theming |
| `nixgl` | OpenGL wrapper for non-NixOS (legacy) |
| `khanelivim` | Neovim distribution |
| `nvf` | Neovim configuration framework |
| `noctalia` | Status bar / shell |
| `handy` | Speech-to-text |

## Quick Start (New Install from USB)

Boot the NixOS installer USB and run:

```bash
# Option A:全自动 (stops after hardware generation for UUID update)
git clone https://github.com/skf-funzt/nixos-config.git /home/nixos/nixos-config
cd /home/nixos/nixos-config/install/scripts
./run-all.sh

# When it pauses after step 06, the agent reads hardware-configuration.nix
# and wires UUIDs into modules/system/btrfs-laptop.nix.
# Then you press Enter to continue.
```

### Option B: Step by step

```bash
cd /home/nixos/nixos-config/install/scripts
./01-unmount.sh
./02-partition.sh
./03-luks.sh
./04-btrfs.sh
./05-mount.sh
./06-generate-hardware.sh
# <agent wires UUIDs>
./07-copy-config.sh
./08-install.sh
# reboot
./09-post-install.sh   # run inside the new system
```

## Disk Layout

| Partition | Size | Purpose |
|-----------|------|---------|
| `/dev/nvme0n1p1` | 1 GiB | EFI System Partition (FAT32) |
| `/dev/nvme0n1p2` | ~3.6T | LUKS-encrypted Btrfs root |
| `/dev/nvme0n1p3` | 16 GiB | Swap |

### Btrfs Subvolumes

| Subvol | Mount | Options |
|--------|-------|---------|
| `@` | `/` | `compress=zstd:1,noatime` |
| `@home` | `/home` | `compress=zstd:1,noatime` |
| `@nix` | `/nix` | `compress=zstd:1,noatime` |
| `@log` | `/var/log` | `compress=zstd:1,noatime` |
| `@snapshots` | (optional) | snapshots root |

## Home Manager

Home Manager is **integrated as a NixOS module**, not standalone.

The host config (`modules/hosts/laptop/default.nix`) imports:
```nix
inputs.home-manager.nixosModules.home-manager
```

And passes special args via:
```nix
home-manager.extraSpecialArgs = {
  inherit inputs pkgs-unstable;
  nixgl = inputs.nixgl;
  handy = inputs.handy;
  khanelivim = inputs.khanelivim;
  gpuType = "amd";
  noctalia = inputs.noctalia;
};
```

User configuration lives in `home/stephan.nix` and is imported by `modules/users/stephan.nix`.

### Legacy standalone repo

The previous standalone home-manager flake at `github.com/skf-funzt/home-manager` is **archived**.
All configurations have been merged into this unified repo under `home/`.

## State Versions

- **NixOS:** `26.05`
- **Home Manager:** `26.05`

## Agent Session Persistence

This repo contains a `.pi/` directory with extensions and an `AGENTS.md` context file.
After reboot, `cd ~/nixos-config` inside pi to resume the session with full context.

## License

MIT
