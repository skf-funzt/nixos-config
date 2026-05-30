# modules/system/disko-laptop.nix
# Declarative disk partitioning with Disko.
# This replaces the install/scripts/01-09.sh shell scripts.
# Usage (from NixOS installer):
#   nix run 'github:nix-community/disko/latest#disko-install' -- \
#     --flake /path/to/this/repo#framework-stephan \
#     --disk main /dev/nvme0n1
#
# Or manually:
#   nix run 'github:nix-community/disko/latest#disko' -- \
#     --mode destroy,format,mount /path/to/this/file.nix
#
# NOTE: This is NOT imported by default in the host config.
# It is used only during initial installation via Disko.
{ config, pkgs, lib, ... }:

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
              size = "100%";  # Uses remaining space minus swap
              content = {
                type = "luks";
                name = "cryptroot";
                # Ask for password interactively during disko
                settings = {
                  allowDiscards = true;
                };
                # Password is prompted at format time
                passwordFile = "/tmp/luks-password";
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
