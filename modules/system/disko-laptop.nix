# modules/system/disko-laptop.nix
# Declarative disk partitioning with Disko.
# This is a STANDALONE disko configuration (not a NixOS module).
# It is imported by the host config via `inputs.disko.nixosModules.disko`.
#
# INSTALL WORKFLOW with Disko:
#   1. Boot NixOS installer USB
#   2. Set LUKS password:  echo -n "your-password" > /tmp/luks-password
#   3. Run:  nix run 'github:nix-community/disko/latest#disko' -- \
#              --mode destroy,format,mount ./modules/system/disko-laptop.nix
#   4. Run nixos-install
#
# DEVICE: /dev/nvme0n1 (3.7T NVMe)
# LAYOUT:
#   p1  EFI      1G   vfat   /boot
#   p2  LUKS     rest-96G  Btrfs subvolumes: @ @home @nix @log @snapshots
#   p3  swap     96G  swap   hibernation resume

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
              size = "100%";
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
              size = "96G";
              type = "8200";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
  };
}
