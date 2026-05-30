# modules/desktop/niri.nix
{ config, pkgs, lib, ... }:

{
  programs.niri = {
    enable = true;
  };

  hardware.graphics.enable = true;

  # greetd for tiling compositors
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
        user = "greeter";
      };
    };
  };

  # Prevent GDM conflict if both desktop modules are imported
  services.xserver.displayManager.gdm.enable = lib.mkDefault false;
}
