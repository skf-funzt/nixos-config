# NixOS Dendritic Config — Agent Context

> This file preserves knowledge across agent sessions.
> After reboot, `cd /etc/nixos` in pi to reload this context.

## Current Project

**NixOS 26.05 on Framework Laptop 13 AMD**
- Desktop: GNOME + Niri (Wayland compositor) + DMS (DankMaterialShell)
- Home Manager: Integrated as NixOS module (dendritic pattern)
- Flake: Unified flake with NixOS + home-manager + custom inputs

## Architecture (Dendritic)

```
nixos-config/
├── flake.nix                           # Flake: all inputs + outputs
├── flake.lock                          # Pinned inputs
├── AGENTS.md                           # This file — session context
├── modules/
│   ├── hosts/
│   │   └── laptop/
│   │       ├── default.nix             # Host config: boot, DMS, packages, home-manager
│   │       └── hardware-configuration.nix
│   ├── system/
│   │   └── disko-laptop.nix            # Declarative disk partitioning
│   ├── users/
│   │   └── stephan.nix                 # User + home-manager import
│   └── desktop/
│       ├── gnome.nix                   # GNOME desktop
│       └── niri.nix                    # Niri compositor + greetd
├── home/
│   ├── stephan.nix                     # Home-manager entry point (imports all home modules)
│   ├── core.nix                        # Base: user info, xdg, session vars
│   ├── theme.nix                       # Stylix, cursor, GTK, fonts
│   ├── packages.nix                    # User-level packages
│   ├── programs.nix                    # Generic program configs (tmux, git, chromium)
│   ├── desktop-niri.nix                # Niri-specific home config (niri config.kdl, kitty DMS theme)
│   ├── desktop-gnome.nix               # GNOME-specific home config
│   ├── niri-config.kdl                 # Niri compositor config file
│   ├── zsh.nix                         # Zsh shell
│   ├── nixvim.nix                      # Nixvim (currently disabled)
│   ├── vscode.nix                      # VS Code wrapper
│   ├── handy-wrapped.nix               # Handy AI tool wrapper
│   └── gruvbox-rainbow.toml            # Terminal color scheme
├── install/
│   ├── scripts/                        # Install scripts (01–09)
│   ├── docs/
│   │   ├── PHASE.md
│   │   └── TODO.md
└── .pi/
    ├── patterns.yaml                   # Pi strict-mode whitelist
    └── extensions/                     # Pi extensions (editor, etc.)
```

## Key Decisions

1. **One unified repo**: home-manager merged into nixos-config (not standalone).
   Special args passed via `home-manager.extraSpecialArgs`.

2. **Home-manager as NixOS module**: Uses `home-manager.nixosModules.home-manager`.
   User config lives in `home/stephan.nix` with focused sub-modules.

3. **Desktop-shell separation**: 
   - Niri is the compositor (window management, workspaces)
   - DMS (DankMaterialShell) is the desktop shell (bars, panels, widgets)
   - DMS auto-starts via `systemd.enable = true` (not via niri spawn)
   - DMS NixOS module: `inputs.dms.nixosModules.dank-material-shell`
   - DMS home-manager module: `inputs.dms.homeModules.dank-material-shell` (sharedModules)

4. **Desktop-specific home configs**: `home/desktop-niri.nix` holds niri config + DMS-themed kitty.
   Not in `programs.nix` — keeps generic and desktop-specific concerns separated.

5. **No Noctalia**: Replaced by DMS. All noctalia references removed from config.

6. **Greetd with niri-session**: `tuigreet --cmd niri-session` starts the proper systemd target
   so user services (like DMS) auto-start.

7. **sdb (1TB) left alone**: Physically disconnected. Backup via rsync.

## Dendritic Pattern Rules (from experience)

1. **Host config** (`modules/hosts/laptop/default.nix`): System-level settings, packages, NixOS module imports, DMS enable, home-manager extraSpecialArgs + sharedModules
2. **Desktop modules** (`modules/desktop/`): Compositor/greeter config, one per DE
3. **User module** (`modules/users/stephan.nix`): User account + home-manager entry point
4. **Home modules** (`home/*.nix`): Each file = one concern domain (shell, programs, theme, etc.)
5. **Desktop-specific home config**: Goes in `home/desktop-*.nix`, not in generic modules
6. **DMS settings**: NixOS module for system-wide install; home-manager module (sharedModules) for per-user settings, plugins, niri integration
7. **Program config with DMS dependency**: Lives alongside DMS config (desktop-niri.nix), not in programs.nix

## Session State

- DMS installed and running with interactive styling (settings not managed by Nix — yet)
- Minimal niri config deployed via xdg.configFile (keybindings: Mod+T→kitty, Mod+D→DMS spotlight)
- Kitty configured with DMS dynamic theming
- Rebuild: `nh os switch /etc/nixos -H $(uname -n)` (host-agnostic)
- Git: changes must be committed to be seen by flake evaluation

## How to Resume This Session After Reboot

```bash
cd /etc/nixos
# pi will auto-load AGENTS.md and .pi/extensions/
```

## External References

- DMS docs: https://danklinux.com/docs/dankmaterialshell/
- Niri docs: https://niri-wm.github.io/niri/
- Noctalia (removed): was at github:noctalia-dev/noctalia-shell
- Old home-manager repo: https://github.com/skf-funzt/home-manager (archived)
