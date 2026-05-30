# modules/system/btrfs-laptop.nix
# Single-drive LUKS + Btrfs layout for the Framework Laptop 13.
{ config, pkgs, lib, ... }:

{
  # The LUKS device is opened by boot.initrd.luks.devices (set in hardware-configuration.nix).
  # All Btrfs subvolumes mount from the decrypted mapper device.
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" ];
  };
  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" ];
  };
  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd:1" "noatime" ];
  };
  fileSystems."/var/log" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@log" "compress=zstd:1" "noatime" ];
  };

  # Ephemeral cache exclusions for stephan
  systemd.tmpfiles.rules = [
    "v /home/stephan/.cache        0700 stephan users - -"
    "v /home/stephan/.local/share  0700 stephan users - -"
  ];
}
