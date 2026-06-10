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
#   5. BEFORE FIRST REBOOT: set up keyfile to avoid a second password prompt at boot.
#      In chroot (/mnt):
#        dd if=/dev/urandom of=/mnt/etc/cryptswap.key bs=512 count=8
#        chmod 600 /mnt/etc/cryptswap.key
#        nixos-enter -- cryptsetup luksAddKey /dev/nvme0n1p2 /etc/cryptswap.key
#      Or after first boot, run: ./install/scripts/convert-swap-to-luks.sh
#
# DEVICE: /dev/nvme0n1 (3.7T NVMe)
# LAYOUT (both swap and root use same LUKS passphrase at install time):
#   p1  EFI      1G   vfat   /boot
#   p2  swap     96G  LUKS  hibernation resume → /dev/mapper/cryptswap
#   p3  LUKS     rest  Btrfs subvolumes: @ @home @nix @log @snapshots → /dev/mapper/cryptroot
#
# HIBERNATION: Swap is LUKS-encrypted. initrd unlocks cryptroot (password), then
# reads /sysroot/etc/cryptswap.key from root to unlock cryptswap — single prompt.
# On fresh install (keyfile missing) → fallback password prompt for swap.

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

            # ── Swap partition (LUKS-encrypted for hibernation security) ──
            # Matches cryptroot passphrase (same /tmp/luks-password at install).
            # After install, register a keyfile on root to avoid second password at boot
            # (see POST-INSTALL in header).
            swap = {
              size = "96G";
              type = "8200";
              content = {
                type = "luks";
                name = "cryptswap";
                passwordFile = "/tmp/luks-password";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
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
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd:1"
                        "noatime"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd:1"
                        "noatime"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd:1"
                        "noatime"
                      ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "compress=zstd:1"
                        "noatime"
                      ];
                    };
                    "@snapshots" = {
                      mountpoint = "/snapshots";
                      mountOptions = [
                        "compress=zstd:1"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
