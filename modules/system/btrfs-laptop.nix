# modules/system/btrfs-laptop.nix
# Single-drive LUKS + Btrfs layout for the Framework Laptop 13.
# Replace <SSD-UUID> with the real Btrfs device UUID after running
# nixos-generate-config (see install/scripts/06-generate-hardware.sh).
{ config, pkgs, lib, ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/<SSD-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/<SSD-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/<SSD-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd:1" "noatime" ];
  };
  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/<SSD-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@log" "compress=zstd:1" "noatime" ];
  };

  # Ephemeral cache exclusions for stephan
  systemd.tmpfiles.rules = [
    "v /home/stephan/.cache        0700 stephan users - -"
    "v /home/stephan/.local/share  0700 stephan users - -"
  ];
}
