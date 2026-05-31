# modules/hosts/laptop/hardware-configuration.nix
# Hardware-specific settings for the Framework Laptop 13 AMD.
#
# NOTE: Filesystem, LUKS, and swap definitions are ALL handled by
# modules/system/disko-laptop.nix (Disko declarative partitioning).
# This file only contains boot/initrd/platform settings.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
