# home/core.nix
# Core home-manager settings for stephan.
{ config, pkgs, lib, ... }:

{
  # ── User Info ────────────────────────────────────────────────
  home.username = "stephan";
  home.homeDirectory = "/home/stephan";
  home.stateVersion = "26.05";

  # ── XDG ──────────────────────────────────────────────────────
  xdg.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  # ── Generic Linux Targets ────────────────────────────────────
  targets.genericLinux.enable = true;

  # ── Session Variables ────────────────────────────────────────
  home.sessionVariables = {
    CARGO_TARGET_DIR = "${config.xdg.cacheHome}/cargo-targets";
    GOCACHE = "${config.xdg.cacheHome}/go-build";
    QT_QPA_PLATFORMTHEME = "qt6ct";  # DMS Qt theming
  };

  # ── Nixpkgs Config ───────────────────────────────────────────
  nixpkgs.config = {
    allowUnfree = true;
    programs.zsh.enabled = true;
  };
}
