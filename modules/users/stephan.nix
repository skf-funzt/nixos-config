# modules/users/stephan.nix
{ self, ... }: {
  flake.nixosModules.user-stephan = { config, pkgs, ... }: {
    users.users.stephan = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "podman" ];
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;

    # Home Manager integration (minimal — full config applied after install)
    home-manager.users.stephan = {
      home.stateVersion = "26.05";
      xdg.enable = true;

      home.sessionVariables = {
        CARGO_TARGET_DIR = "${config.home-manager.users.stephan.xdg.cacheHome}/cargo-targets";
        GOCACHE = "${config.home-manager.users.stephan.xdg.cacheHome}/go-build";
      };
    };
  };
}
