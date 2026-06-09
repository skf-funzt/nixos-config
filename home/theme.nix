# home/theme.nix
# GTK, cursor, and font configuration.
# Color theming is handled by DMS (matugen) — not Stylix.
{ config, pkgs, lib, ... }:

{
  # ── Cursor (let DMS manage via its Settings UI) ──────────────
  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 22;
  };

  # ── GTK (colors handled by DMS matugen at runtime) ───────────
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 22;
    };
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
      size = 10;
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  # ── Stylix (disabled — DMS handles color theming) ───────────
  stylix.enable = false;
}
