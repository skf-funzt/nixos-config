---
name: nixos-dendritic
description: NixOS dendritic pattern — modular, layered config structure for flake-based NixOS + home-manager setups
---

# NixOS Dendritic Pattern

A modular, layered approach to structuring NixOS configurations with home-manager as a NixOS module.

## Core Principles

1. **Single flake, unified repo** — NixOS + home-manager in one repo, no standalone home-manager
2. **Home-manager as NixOS module** — via `home-manager.nixosModules.home-manager`
3. **Focused modules** — each file owns one concern domain
4. **Desktop-specific configs** — compositor/shell configs separate from generic program configs
5. **Shared modules for cross-cutting concerns** — Stylix, DMS, etc.

## Directory Layout

```
nixos-config/
├── flake.nix                    # All inputs + outputs
├── modules/
│   ├── hosts/<host>/            # Host-specific config (packages, services, DMS)
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── system/                  # System-level modules (disko, btrfs)
│   ├── users/                   # User accounts + home-manager wiring
│   └── desktop/                 # Compositors (niri.nix, gnome.nix)
└── home/                        # Home-manager modules
    ├── stephan.nix              # Entry point — imports all
    ├── core.nix                 # Base: user info, xdg, session vars
    ├── programs.nix             # Generic programs (git, tmux, chromium)
    ├── desktop-niri.nix         # Niri-specific: niri config, DMS-themed kitty
    ├── desktop-gnome.nix        # GNOME-specific
    └── ...
```

## Rules for Module Placement

| Concern | Goes in |
|---------|---------|
| System-level services, packages, boot | `modules/hosts/<host>/default.nix` |
| Compositor (niri, sway, hyprland) | `modules/desktop/<compositor>.nix` |
| User account + home-manager wiring | `modules/users/<user>.nix` |
| Generic programs (git, tmux, direnv) | `home/programs.nix` |
| Desktop-shell-specific program config | `home/desktop-<de>.nix` (NOT programs.nix) |
| DMS enable + systemd config | `modules/hosts/<host>/default.nix` |
| DMS home-manager module import | `home-manager.sharedModules` in host config |
| Shell, theme, editor | Separate `home/<domain>.nix` |

## DMS Integration Pattern

DMS (DankMaterialShell) is a Wayland desktop shell that runs alongside a compositor (niri).

- **NixOS module**: `inputs.dms.nixosModules.dank-material-shell` — system-wide install
- **Home-manager module**: `inputs.dms.homeModules.dank-material-shell` — per-user settings (via sharedModules)
- **DMS auto-start**: Use `systemd.enable = true` (NOT `niri.enableSpawn`) when managing niri config separately
- **Niri config**: Managed via `xdg.configFile."niri/config.kdl"` in `home/desktop-niri.nix`
- **DMS-themed programs**: Configs that depend on DMS (like kitty theme includes) live alongside DMS config in the desktop-specific module
- **DMS niri module** (`inputs.dms.homeModules.niri`): Designed for niri-flake; NOT compatible with nixpkgs niri module

## Key Gotchas

- **Flakes only see git-tracked files** — `git add` before rebuild or evaluation fails
- **Rebuild command**: `nh os switch /etc/nixos -H $(uname -n)` (host-agnostic, uses `nh`)
- **home-manager as NixOS module**: Use `nh os switch` or `sudo nixos-rebuild switch`, NOT `home-manager switch`
- **`xdg.configFile` vs regular file**: Home-manager creates a symlink; remove any existing regular file first
- **DMS interactive settings**: Not managed by Nix unless `programs.dank-material-shell.settings` is set
