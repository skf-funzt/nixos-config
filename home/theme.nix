# home/theme.nix
# Stylix, cursor, GTK, and font configuration.
{ config, pkgs, lib, ... }:

{
  # ── Cursor ───────────────────────────────────────────────────
  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 22;
  };

  # ── GTK ──────────────────────────────────────────────────────
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

  # ── Stylix ───────────────────────────────────────────────────
  stylix.enable = false;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/eighties.yaml";
  stylix.image = pkgs.fetchurl {
    url = "https://zebreus.github.io/all-gnome-backgrounds/images/keys-d-65e33e56cb91fc3b79d997399d2b660fbad42c84.webp";
    hash = "sha256-2cGDxBwObirDJQ4bizAZPqak7xm0kuSaFL0QRw7uDlc=";
  };
  stylix.cursor.name = "Bibata-Modern-Classic";
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.size = 22;
  stylix.icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    light = "Papirus-Light";
    dark = "Papirus-Dark";
  };
  stylix.polarity = "dark";
  stylix.fonts = {
    serif = { package = pkgs.noto-fonts; name = "Noto Serif"; };
    sansSerif = { package = pkgs.noto-fonts; name = "Noto Sans"; };
    monospace = { package = pkgs.hackgen-nf-font; name = "Hack Nerd Font"; };
    emoji = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
  };
}
