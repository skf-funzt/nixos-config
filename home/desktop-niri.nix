# home/desktop-niri.nix
# Niri-specific home settings.
# Deploys a minimal niri config with keybindings.
# DMS auto-starts via systemd user service.
{ config, pkgs, lib, ... }:

{
  # Minimal niri config — keybindings, input, layout
  # DMS handles the shell (bars, panels, widgets)
  xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;
}
