# modules/system/ensure-btrfs-subvolumes.nix
# Reusable NixOS module: ensure specified paths are btrfs subvolumes.
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
            description = "Path to ensure is a btrfs subvolume. May contain globs.";
          };
          owner = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "stephan:users";
            description = "Owner (user:group). Null = auto-detect.";
          };
        };
      }
    );
    default = [ ];
    description = "Paths to convert to btrfs subvolumes on boot.";
  };

  config = lib.mkIf (cfg != [ ]) {
    systemd.services.ensure-btrfs-subvolumes = let
      convertCmds = map (entry: ''
        ensure_subvol '${entry.path}' ${if entry.owner != null then "'${entry.owner}'" else "auto"}
      '') cfg;
    in {
      description = "Ensure configured paths are btrfs subvolumes";
      wantedBy = [ "multi-user.target" ];
      before = [ "home-manager-stephan.service" ];
      path = [ pkgs.btrfs-progs ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ensure_subvol() {
          local path="$1"
          local owner="$2"

          if [[ "$path" == *"*"* ]]; then
            shopt -s nullglob
            for expanded in $path; do
              ensure_subvol "$expanded" "$owner"
            done
            return
          fi

          if btrfs subvolume show "$path" &>/dev/null; then
            echo "SKIP: $path (already a subvolume)"
            return 0
          fi

          if [ ! -d "$path" ]; then
            echo "SKIP: $path (not a directory yet)"
            return 0
          fi

          if [ "$owner" = "auto" ]; then
            owner=$(stat -c '%U:%G' "$path")
            echo "AUTO: $path owner=$owner"
          fi

          local tmp="''${path}.subvol-tmp.$$"
          echo "CONVERT: $path → btrfs subvolume"

          mv "$path" "$tmp" || { echo "ERROR: cannot move $path"; return 1; }
          btrfs subvolume create "$path" || {
            echo "ERROR: subvolume create failed, restoring..."; mv "$tmp" "$path"; return 1;
          }
          cp -a "$tmp"/. "$path"/
          rm -rf "$tmp"
          [ -n "$owner" ] && chown -R "$owner" "$path"
          echo "DONE: $path"
        }

      '' + lib.concatStringsSep "\n" convertCmds;
    };
  };
}
