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
      # Disable kitty defaults that collide with byobu F-key bindings
      map ctrl+shift+f2 no_op     # byobu: new window
      map ctrl+shift+f3 no_op     # byobu: swap window left
      map ctrl+shift+f5 no_op     # byobu: select profile
      map ctrl+shift+f8 no_op     # byobu: save layout
    '';
  };

  # DMS GTK theming: enable via DMS Settings → Appearance → "GTK Theming"
  # This makes matugen generate GTK CSS from the current DMS theme,
  # giving GTK apps the same look as the DMS shell and niri borders.
}
