# modules/system/ensure-btrfs-subvolumes.nix
# Reusable NixOS module: ensure specified paths are btrfs subvolumes.
#
# Use case: exclude ephemeral directories (caches, build artifacts, containers)
# from btrfs/snapper snapshots by converting them to subvolumes at boot.
#
# Supports literal paths and glob patterns (expanded at runtime).
# Ownership is auto-detected from parent directory when omitted.
#
# Usage:
#   boot.btrfs.ensureSubvolumes = [
#     { path = "/home/stephan/.cache"; owner = "stephan:users"; }
#     { path = "/home/*/.cache"; }  # auto-detect owner, glob expanded
#   ];
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.boot.btrfs.ensureSubvolumes;
in
{
  options.boot.btrfs.ensureSubvolumes = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          path = lib.mkOption {
            type = lib.types.str;
            example = "/home/stephan/.cache";
            description = ''
              Path to ensure is a btrfs subvolume.
              May contain glob patterns (e.g. "/home/*/.cache") —
              expanded at runtime with `shopt -s nullglob`.
            '';
          };
          owner = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "stephan:users";
            description = ''
              Owner (user:group) for the subvolume.
              If null, auto-detected from the parent directory.
            '';
          };
        };
      }
    );
    default = [ ];
    example = [
      { path = "/home/stephan/.cache"; owner = "stephan:users"; }
      { path = "/home/*/.cache"; }
    ];
    description = ''
      Paths to convert to btrfs subvolumes on boot if they are plain directories.
      Already-existing subvolumes are skipped (idempotent).
      Non-existent paths are skipped (tmpfiles may create them later).

      This is useful for excluding ephemeral directories from btrfs snapshots
      (snapper does not descend into subvolumes of the snapshot root).

      Tip: add matching tmpfiles "v" rules for non-glob paths so they
      stay as subvolumes across rebuilds:
        systemd.tmpfiles.rules = [ "v /home/stephan/.cache 0755 - - -" ];
    '';
  };

  config = lib.mkIf (cfg != [ ]) {
    # ── oneshot: convert existing dirs on every boot ──
    systemd.services.ensure-btrfs-subvolumes = let
      convertCmds = map (entry: ''
        ensure_subvol '${entry.path}' ${if entry.owner != null then "'${entry.owner}'" else "auto"}
      '') cfg;
    in {
      description = "Ensure configured paths are btrfs subvolumes";
      wantedBy = [ "multi-user.target" ];
      before = [ "home-manager-stephan.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ensure_subvol() {
          local path="$1"
          local owner="$2"

          # Resolve globs at runtime
          if [[ "$path" == *"*"* ]]; then
            shopt -s nullglob
            for expanded in $path; do
              ensure_subvol "$expanded" "$owner"
            done
            return
          fi

          # Already a subvolume? Skip.
          if btrfs subvolume show "$path" &>/dev/null; then
            echo "SKIP: $path (already a subvolume)"
            return 0
          fi

          # Doesn't exist? Skip.
          if [ ! -d "$path" ]; then
            echo "SKIP: $path (not a directory yet)"
            return 0
          fi

          # Auto-detect owner from parent dir
          if [ "$owner" = "auto" ]; then
            owner=$(stat -c '%U:%G' "$path")
            echo "AUTO: $path owner=$owner"
          fi

          local tmp="''${path}.subvol-tmp.$$"
          echo "CONVERT: $path → btrfs subvolume"

          mv "$path" "$tmp"
          btrfs subvolume create "$path"
          cp -a "$tmp"/. "$path"/
          rm -rf "$tmp"
          [ -n "$owner" ] && chown -R "$owner" "$path"

          echo "DONE: $path"
        }

      '' + lib.concatStringsSep "\n" convertCmds;
    };
  };
}
