# modules/hosts/laptop/hardware-configuration.nix
# Hardware-specific settings for the Framework Laptop 13 AMD.
#
# NOTE: Filesystem definitions (fileSystems, swapDevices) are handled by
# modules/system/disko-laptop.nix (Disko declarative partitioning).
# This file only contains boot/initrd/platform settings.
#
# LUKS device uses the partition path directly so reinstalls don't
# require UUID updates. For multi-machine portability, switch to
# /dev/disk/by-partuuid/ after reading the stable PARTUUID.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # LUKS device for the Btrfs root partition (nvme0n1p2)
  # Using partition path for robustness across reinstalls.
  boot.initrd.luks.devices."cryptroot".device = "/dev/nvme0n1p2";

  # Swap partition (nvme0n1p3) — sized to match RAM for hibernation
  swapDevices = [
    { device = "/dev/nvme0n1p3"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
