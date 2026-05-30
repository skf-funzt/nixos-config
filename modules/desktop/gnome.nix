# modules/desktop/gnome.nix
{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.espresso
    gnomeExtensions.paperwm
    gnomeExtensions.astra-monitor
    gnomeExtensions.workspace-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.gsconnect
    gnomeExtensions.spotify-tray
    gnomeExtensions.dim-background-windows
    gnomeExtensions.screenshot-window-sizer
    gnomeExtensions.auto-move-windows
    gnomeExtensions.just-perfection
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.custom-accent-colors
    gnomeExtensions.open-bar
  ];
}
