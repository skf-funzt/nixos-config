# NixOS Install Session Context

> This file preserves knowledge across agent sessions.
> After reboot, `cd ~/nixos-config` in pi to reload this context.

## Current Project

**NixOS 26.05 reinstall on Framework Laptop 13 AMD**
- Disk: 3.7T NVMe (KINGSTON SKC3000D4096G)
- Layout: GPT → EFI (1G) + LUKS + Btrfs subvolumes (@ @home @nix @log @snapshots) + swap (16G)
- Desktop: GNOME + Niri (Wayland compositor)
- Home Manager: Integrated as NixOS module (dendritic pattern)

## Architecture (Dendritic)

```
nixos-config/
├── flake.nix                           # Unified flake: NixOS + home-manager inputs
├── modules/
│   ├── hosts/
│   │   └── laptop/
│   │       ├── default.nix             # Host config: boot, network, audio, packages
│   │       └── hardware-configuration.nix  # Generated during install
│   ├── system/
│   │   └── btrfs-laptop.nix            # Btrfs subvol mounts (UUIDs wired after step 06)
│   ├── users/
│   │   └── stephan.nix                 # User account + home-manager import
│   └── desktop/
│       ├── gnome.nix                   # GNOME desktop environment
│       └── niri.nix                    # Niri Wayland compositor
├── home/
│   ├── stephan.nix                     # Main home-manager config
│   ├── zsh.nix                         # Zsh shell config
│   ├── nixvim.nix                      # Nixvim (neovim) config
│   ├── vscode.nix                      # VS Code wrapper
│   ├── noctalia.nix                    # Noctalia status bar
│   ├── handy-wrapped.nix               # Handy AI tool wrapper
│   ├── gruvbox-rainbow.toml            # Terminal color scheme
│   └── gnome-background.webp           # Wallpaper asset
├── install/
│   ├── install.sh                      # Quick reference
│   ├── scripts/
│   │   ├── 01-unmount.sh               # Close old LUKS containers
│   │   ├── 02-partition.sh             # GPT: EFI + LUKS + swap
│   │   ├── 03-luks.sh                  # LUKS format & open
│   │   ├── 04-btrfs.sh                 # Btrfs filesystem + subvolumes
│   │   ├── 05-mount.sh                 # Mount to /mnt
│   │   ├── 06-generate-hardware.sh     # nixos-generate-config
│   │   ├── 07-copy-config.sh           # Copy flake → /mnt/etc/nixos
│   │   ├── 08-install.sh               # nixos-install --flake
│   │   ├── 09-post-install.sh          # First-boot checklist
│   │   └── run-all.sh                  # Orchestrates 01→08 with pause for UUIDs
│   └── docs/
│       ├── PHASE.md                    # Current install phase
│       └── TODO.md                     # Full task list (BEFORE / AFTER reboot)
└── .pi/
    └── extensions/
        ├── editor.ts                   # Pi extension: /editor command
        └── nixos-install-status.ts     # Pi extension: /status command
```

## Key Decisions

1. **One unified repo**: home-manager merged into nixos-config (not standalone).
   Previously home-manager was a separate repo; now it's modules + home/ inside nixos-config.

2. **Home-manager as NixOS module**: Uses `home-manager.nixosModules.home-manager` in host config.
   Special args (pkgs-unstable, nixgl, khanelivim, etc.) passed via `home-manager.extraSpecialArgs`.

3. **Old files removed**: configuration.nix, hardware-configuration.nix (root), home.nix (broken symlink),
   justfile, .tool-versions, vm.nix, zsh.nix (root), nixos-config.code-workspace.

4. **sdb (1TB) left alone**: Physically disconnected by user. Backup verified complete via rsync.

5. **No server-admin user**: This is a laptop, not the hybrid-pc. Only `stephan` user.

## Install Progress

### BEFORE Reboot (Agent Active)
- [x] Repo restructured to dendritic pattern
- [x] Home-manager configs merged into repo
- [x] Install scripts written (01→09 + run-all.sh)
- [x] Old files cleaned
- [ ] Disk partitioning (user runs `./run-all.sh`)
- [ ] Hardware config generated
- [ ] UUIDs wired into btrfs-laptop.nix
- [ ] nixos-install
- [ ] Reboot

### AFTER Reboot (Agent Gone — User Only)
- [ ] Run `~/nixos-config/install/scripts/09-post-install.sh`
- [ ] Clone repos (already local, but verify)
- [ ] Activate home-manager
- [ ] Restore backup data from sdb1
- [ ] Validate desktop environments (GNOME, Niri)
- [ ] Test audio, Wi-Fi, Bluetooth, suspend
- [ ] Commit any post-install tweaks

## How to Resume This Session After Reboot

```bash
cd ~/nixos-config
# pi will auto-load AGENTS.md and .pi/extensions/
```

If you need to continue install work inside the installer USB (before reboot),
the agent configs are also in this repo under `.pi/`.

## External References

- **Backup verified**: `rsync -ani` showed no diffs between old home and backup-20260527
- **Home-manager standalone repo**: https://github.com/skf-funzt/home-manager (archived / superseded)
- **Original guide**: `~/Downloads/NixOS Multi-DE & Btrfs Architecture Guide.md`
