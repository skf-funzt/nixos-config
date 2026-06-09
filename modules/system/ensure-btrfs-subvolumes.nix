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
            description = "Owner (user:group). Null = auto-detect from parent.";
          };
        };
      }
    );
    default = [ ];
    description = "Paths to ensure are btrfs subvolumes on boot. Creates or converts as needed.";
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

          # Already a subvolume? Skip.
          if btrfs subvolume show "$path" &>/dev/null; then
            echo "SKIP: $path (already a subvolume)"
            return 0
          fi

          # Auto-detect owner
          if [ "$owner" = "auto" ]; then
            if [ -d "$path" ]; then
              owner=$(stat -c '%U:%G' "$path")
            else
              owner=$(stat -c '%U:%G' "$(dirname "$path")")
            fi
            echo "AUTO: $path owner=$owner"
          fi

          if [ -d "$path" ]; then
            # Existing directory — convert to subvolume
            local tmp="''${path}.subvol-tmp.$$"
            echo "CONVERT: $path (directory → subvolume)"
            mv "$path" "$tmp" || { echo "ERROR: cannot move $path"; return 1; }
            btrfs subvolume create "$path" || {
              echo "ERROR: subvolume create failed, restoring..."; mv "$tmp" "$path"; return 1;
            }
            cp -a "$tmp"/. "$path"/
            rm -rf "$tmp"
          else
            # Doesn't exist — create as subvolume directly
            echo "CREATE: $path (new subvolume)"
            mkdir -p "$(dirname "$path")"
            btrfs subvolume create "$path" || { echo "ERROR: create failed"; return 1; }
          fi

          [ -n "$owner" ] && chown -R "$owner" "$path"
          echo "DONE: $path"
        }

      '' + lib.concatStringsSep "\n" convertCmds;
    };
  };
}
