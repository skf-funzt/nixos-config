# home/programs.nix
# Program configurations managed by Home Manager.
{ config, pkgs, lib, nixgl, ... }:

{
  # ── Home Manager self-management ──
  programs.home-manager.enable = true;
  services.home-manager.autoExpire.enable = true;

  # ── nh (Nix helper) ──
  programs.nh.enable = true;

  # ── nixGL ──
  targets.genericLinux.nixGL.packages = nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";
  targets.genericLinux.nixGL.installScripts = [ "mesa" ];

  # ── Tmux ──
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    clock24 = true;
    plugins = with pkgs; [
      tmuxPlugins.cpu
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60'
        '';
      }
    ];
  };

  # ── Git ──
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Stephan Koglin-Fischer";
        email = "stephan.koglin-fischer@funzt.dev";
      };
    };
  };
  programs.gitui.enable = true;

  # ── direnv ──
  programs.direnv.enable = true;

  # ── Chromium ──
  programs.chromium = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.chromium;
  };

  # ── Noctalia shell / status bar ──
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "compact";
        position = "right";
        showCapsule = false;
        widgets = {
          left = [
            { id = "ControlCenter"; useDistroLogo = true; }
            { id = "Network"; }
            { id = "Bluetooth"; }
          ];
          center = [
            { hideUnoccupied = false; id = "Workspace"; labelMode = "none"; }
          ];
          right = [
            { alwaysShowPercentage = false; id = "Battery"; warningThreshold = 30; }
            { formatHorizontal = "HH:mm"; formatVertical = "HH mm"; id = "Clock"; useMonospacedFont = true; usePrimaryColor = true; }
          ];
        };
      };
      colorSchemes.predefinedScheme = "Monochrome";
      general = {
        avatarImage = "/home/drfoobar/.face";
        radiusRatio = 0.2;
      };
      location = {
        monthBeforeDay = true;
        name = "Marseille, France";
      };
    };
  };
}
