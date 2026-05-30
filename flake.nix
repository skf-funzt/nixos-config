{
  description = "NixOS Declarative Configuration — Framework Laptop 13 AMD";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, stylix, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # ── NixOS Modules ──────────────────────────────────────────
      nixosModules = {
        system-btrfs-laptop = import ./modules/system/btrfs-laptop.nix;
        desktop-gnome       = import ./modules/desktop/gnome.nix;
        desktop-niri        = import ./modules/desktop/niri.nix;
        user-stephan        = import ./modules/users/stephan.nix;
      };

      # ── Home Manager Modules ───────────────────────────────────
      homeModules = {
        desktop-gnome = { };
        desktop-niri  = { };
      };

      # ── NixOS Configurations ───────────────────────────────────
      nixosConfigurations."framework-stephan" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          ./modules/hosts/laptop
        ];
      };
    };
}
