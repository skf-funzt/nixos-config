default:
  @just --choose

# nixpks-version:="24.11"
nixpks-version:="unstable"

clear-result:
  rm -rf result
  rm -rf nixos.qcow2
  nix-collect-garbage

vm-build:
  nix-build '<nixpkgs/nixos>' \
    -A config.system.build.vm \
    -I nixpkgs=channel:nixos-{{nixpks-version}} \
    -I virtualisation.vmVariant.virtualisation.memorySize=16384 \
    -I virtualisation.vmVariant.virtualisation.cores=8 \
    -I nixos-config=./configuration.nix

vm-run: vm-build
  ./result/bin/run-nixos-vm

vm-reset: clear-result vm-build vm-run

# Nix channels

add-home-manager-channel:
  nix-channel --add https://github.com/nix-community/home-manager/archive/release{{nixpks-version}}.tar.gz home-manager
  nix-channel --update

add-channels: add-home-manager-channel