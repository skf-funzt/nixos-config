{
  description = "NixOS Declarative Configuration — Dendritic Multi-Host Flake";

  inputs = {
    # ── Nixpkgs ────────────────────────────────────────────────
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ── Home Manager ───────────────────────────────────────────
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # ── Hardware & Desktop ───────────────────────────────────
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    stylix.url = "github:danth/stylix/release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # ── GPU/OpenGL Wrapper ───────────────────────────────────
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    # ── Neovim / Nixvim ──────────────────────────────────────
    khanelivim = {
      url = "github:khaneliman/khanelivim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── AI / Tools ───────────────────────────────────────────
    handy = {
      url = "github:cjpais/Handy";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # ── Shell / Status Bar ───────────────────────────────────
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, stylix, nixgl, handy, khanelivim, nvf, noctalia, ... }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ ];
        };
      };
    in
    {
      # ── NixOS Modules (reusable across hosts) ──────────────────
      nixosModules = {
        system-btrfs-laptop = ./modules/system/btrfs-laptop.nix;
        desktop-gnome       = ./modules/desktop/gnome.nix;
        desktop-niri        = ./modules/desktop/niri.nix;
        user-stephan        = ./modules/users/stephan.nix;
      };

      # ── Home Manager Modules (reusable across users) ───────────
      homeModules = {
        core          = ./home/core.nix;
        theme         = ./home/theme.nix;
        packages      = ./home/packages.nix;
        programs      = ./home/programs.nix;
        desktop-gnome = ./home/desktop-gnome.nix;
        desktop-niri  = ./home/desktop-niri.nix;
        zsh           = ./home/zsh.nix;
        nixvim        = ./home/nixvim.nix;
      };

      # ── NixOS Configurations ───────────────────────────────────
      nixosConfigurations."framework-stephan" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs-unstable; };
        modules = [
          ./modules/hosts/laptop
        ];
      };
    };
}
