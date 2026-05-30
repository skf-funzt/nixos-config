# modules/desktop/gnome.nix
{ config, pkgs, lib, ... }:

{
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # GNOME extensions known to exist in NixOS 26.05
  # Commented extensions may need manual install or be renamed
  environment.systemPackages = with pkgs; [
    gnomeExtensions.astra-monitor
    gnomeExtensions.workspace-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.gsconnect
    gnomeExtensions.dim-background-windows
    gnomeExtensions.screenshot-window-sizer
    gnomeExtensions.auto-move-windows
    gnomeExtensions.just-perfection
    gnomeExtensions.gnome-40-ui-improvements
    # TODO: not in 26.05 — install manually if needed
    # gnomeExtensions.custom-accent-colors
    # gnomeExtensions.espresso
    # gnomeExtensions.paperwm
    # gnomeExtensions.spotify-tray
    # gnomeExtensions.open-bar
  ];
}
