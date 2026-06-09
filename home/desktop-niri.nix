# home/desktop-niri.nix
# Niri-specific home settings.
# Deploys a minimal niri config with keybindings.
# DMS auto-starts via systemd user service.
{ config, pkgs, lib, ... }:

{
  # Minimal niri config — keybindings, input, layout
  # DMS handles the shell (bars, panels, widgets)
  xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;

  # Kitty terminal with DMS dynamic theming
  programs.kitty = {
    enable = true;
    extraConfig = ''
      include dank-tabs.conf
      include dank-theme.conf
    '';
  };

  # DMS GTK theming — matugen generates GTK CSS matching DMS theme
  # Also enable via DMS Settings → Appearance → "GTK Theming" for runtime toggle
  programs.dank-material-shell.settings = {
    gtkThemingEnabled = true;
  };
}
