# home/core.nix
# Core home-manager settings for stephan.
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "26.05";
  xdg.enable = true;

  home.username = "stephan";
  home.homeDirectory = "/home/stephan";

  home.sessionVariables = {
    CARGO_TARGET_DIR = "${config.xdg.cacheHome}/cargo-targets";
    GOCACHE = "${config.xdg.cacheHome}/go-build";
  };

  # services.home-manager.autoExpire.enable = true;
}
