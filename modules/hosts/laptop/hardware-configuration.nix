# modules/hosts/laptop/hardware-configuration.nix
# Hardware-specific settings for the Framework Laptop 13 AMD.
#
# NOTE: Filesystem, LUKS, and swap definitions are ALL handled by
# modules/system/disko-laptop.nix (Disko declarative partitioning).
# This file only contains boot/initrd/platform settings.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # This enables the kernel to load properitary drivers like for the WIFI module by MediaTek
  hardware.enableRedistributableFirmware = true;

  # For Wifi, we need to set the region
  hardware.wirelessRegulatoryDatabase = true; # This should be truned on by 'hardware.enableRedistributableFirmware' as default
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="DE"
  '';
}
