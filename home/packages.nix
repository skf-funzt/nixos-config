# home/packages.nix
# User-level packages for stephan.
{
  config,
  pkgs,
  pkgs-unstable,
  nixgl,
  handy,
  khanelivim,
  gpuType ? "amd",
  ...
}:

let
  vscode-wrapped = import ./vscode.nix { inherit pkgs pkgs-unstable; };
  handy-wrapped = import ./handy-wrapped.nix { inherit pkgs handy; };

  ollamaPackage =
    {
      amd = pkgs-unstable.ollama-rocm;
      nvidia = pkgs-unstable.ollama-cuda;
      cpu = pkgs-unstable.ollama;
    }
    .${gpuType};
in
{
  home.packages = [
    # ── Nix tooling ──
    pkgs.nixfmt
    pkgs.nil
    pkgs.nixd
    pkgs.alejandra
    pkgs-unstable.devenv
    pkgs.cachix

    # ── Fonts ──
    pkgs.fira-code
    pkgs.nerd-fonts.fira-code
    pkgs.hackgen-nf-font
    pkgs.powerline-fonts
    pkgs.roboto
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji

    # ── Icons ──
    pkgs.papirus-icon-theme

    # ── Terminal emulators ──
    pkgs.alacritty
    pkgs.kitty

    # ── System tools ──
    pkgs.tldr
    pkgs.powertop
    pkgs.btop-rocm
    pkgs.fastfetch
    pkgs.stress
    pkgs.websocat
    pkgs.gh
    pkgs.yazi

    # ── Conferencing ──
    pkgs.zoom

    # ── Security ──
    pkgs.yubioath-flutter

    # ── Browsers ──
    (config.lib.nixGL.wrap pkgs.firefox)
    pkgs.google-chrome

    # ── Media / Creative ──
    pkgs.spotify
    (config.lib.nixGL.wrap pkgs.vlc)
    (config.lib.nixGL.wrap pkgs.darktable)
    (config.lib.nixGL.wrap pkgs.drawing)
    (config.lib.nixGL.wrap pkgs.gimp3)
    (config.lib.nixGL.wrap pkgs.krita)
    (config.lib.nixGL.wrap pkgs.inkscape)
    (config.lib.nixGL.wrap pkgs.blender)
    (config.lib.nixGL.wrap pkgs.obs-studio)
    pkgs.peek
    (config.lib.nixGL.wrap pkgs.kdePackages.kdenlive)

    # ── Messengers ──
    pkgs.signal-desktop
    pkgs.discord
    pkgs.ferdium

    # ── Virtualisation ──
    pkgs.virtualbox
    pkgs.podman-tui
    pkgs-unstable.podman-desktop

    # ── Development ──
    vscode-wrapped
    ollamaPackage

    # ── CLI tools ──
    pkgs.gemini-cli
    pkgs.github-desktop
    pkgs-unstable.opencode
    pkgs-unstable.github-copilot-cli
    pkgs-unstable.pi-coding-agent
    pkgs.bashInteractive
    pkgs.byobu

    # ── Key / Management ──
    pkgs.infisical
    # pkgs.logseq
    pkgs.zotero
    pkgs-unstable.super-productivity

    # ── Custom khanelivim ──
    (
      let
        customKhanelivimConfig =
          (khanelivim.lib.mkNixvimConfig {
            system = pkgs.system;
            profile = "standard";
          }).extendModules
            {
              modules = [
                {
                  khanelivim.integrations.accountBacked = {
                    enable = true;
                    ai.enable = true;
                    timeTracking.enable = false;
                  };
                }
              ];
            };
      in
      customKhanelivimConfig.config.build.package
    )
  ];
}
