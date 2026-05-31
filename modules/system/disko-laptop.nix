# modules/system/disko-laptop.nix
# Declarative disk partitioning with Disko.
# Imported by the host config so the layout is part of the system declaration.
# During installation, Disko reads this config to partition/format/mount.
#
# INSTALL WORKFLOW with Disko:
#   1. Boot NixOS installer USB
#   2. Set LUKS password:  echo -n "your-password" > /tmp/luks-password
#   3. Run:  nix run 'github:nix-community/disko/latest#disko-install' -- \
#              --flake .#framework-stephan --disk main /dev/nvme0n1
#   4. Reboot
#
# DEVICE: /dev/nvme0n1 (3.7T NVMe)
# LAYOUT:
#   p1  EFI      1G   vfat   /boot
#   p2  LUKS     rest-96G  Btrfs subvolumes: @ @home @nix @log @snapshots
#   p3  swap     96G  swap   hibernation resume

{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # ── EFI System Partition ──
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            # ── LUKS root partition ──
            luks = {
              size = "100%";  # Takes remaining space after swap reservation
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/luks-password";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-L" "nixos" "-f" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@snapshots" = {
                      mountpoint = "/snapshots";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                  };
                };
              };
            };

            # ── Swap partition ──
            swap = {
              size = "96G";  # Match RAM for hibernation
              type = "8200";
              content = {
                type = "swap";
                resumeDevice = true;  # Enable hibernation resume
              };
            };
          };
        };
      };
    };
  };
}
