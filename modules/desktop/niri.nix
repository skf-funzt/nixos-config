# modules/desktop/niri.nix
{ self, ... }: {
  flake.nixosModules.desktop-niri = { config, pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
    };

    # Required for Niri
    hardware.graphics.enable = true;

    # Recommended: greetd display manager for tiling compositors
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri";
          user = "greeter";
        };
      };
    };

    # Prevent GDM from conflicting if both are imported
    services.xserver.displayManager.gdm.enable = lib.mkDefault false;
  };
}
