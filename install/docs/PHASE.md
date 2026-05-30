# 🔴 NixOS Install — Current Phase

**Started:** 2026-05-30
**Target:** Framework Laptop 13 AMD — NixOS 26.05 — Btrfs + LUKS

> ⚠️ **AGENT IS EPHEMERAL** — This install environment disappears on reboot.
> All post-reboot work must be scripted or documented for the user to run alone.

---

## Current Phase: 🟡 DISK PREP — Config written. Waiting for YOU to run scripts.

### What the agent (me) does NOW:
- Write/edit NixOS configs under `/home/nixos/nixos-config/`
- Read generated `hardware-configuration.nix` and wire UUIDs
- Update the flake before `nixos-install`
- **After reboot: I AM GONE.** No verification, no fixes.

### What YOU must do NOW (before reboot):
1. Run the disk partitioning scripts
2. Say "done" after `06-generate-hardware.sh` so I can wire UUIDs
3. Run `08-install.sh`
4. Set root password when prompted
5. **REBOOT** — the installer USB environment (and this agent) dies here

### What YOU must do AFTER reboot (agent is dead):
- Run `~/nixos-config/install/scripts/09-post-install.sh` (self-contained)
- Clone repos, activate home-manager, restore backups
- Validate desktop, audio, network, suspend
- Commit any config tweaks back to GitHub

---

## Next Action

```bash
cd /home/nixos/nixos-config/install/scripts
./run-all.sh
```

This runs:
- `01-unmount.sh` — close old LUKS
- `02-partition.sh` — GPT layout
- `03-luks.sh` — format LUKS
- `04-btrfs.sh` — Btrfs subvolumes
- `05-mount.sh` — mount to /mnt
- `06-generate-hardware.sh` — probe hardware

**PAUSES.** You read the generated hardware config, then tell me "done".

I then update UUIDs and you continue with:
- `07-copy-config.sh` — copy flake
- `08-install.sh` — `nixos-install --flake ...`

---

## Files You Can Read Right Now

| File | What it is |
|------|-----------|
| `install/docs/TODO.md` | Full task list, split by BEFORE/AFTER reboot |
| `install/scripts/run-all.sh` | Orchestrator for the whole install |
| `install/scripts/09-post-install.sh` | What you run after reboot (no agent needed) |
| `modules/hosts/laptop/default.nix` | The host configuration |
| `modules/system/btrfs-laptop.nix` | Btrfs mounts (UUIDs updated after step 06) |
| `README.md` | Repo overview and quick-start |

---

## Sudo Commands Waiting

**NONE** — I do not run sudo. Run `./run-all.sh` yourself. Each destructive step asks for `yes` confirmation.
