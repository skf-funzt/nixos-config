# modules/users/stephan.nix
# User definition and home-manager integration for stephan.
{ config, pkgs, lib, ... }:

{
  users.users.stephan = {
    isNormalUser = true;
    description = "stephan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "podman" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # Home Manager config imported from the unified home/ directory.
  # Core settings + desktop environment modules + shell + editor.
  home-manager.users.stephan = {
    imports = [
      ../../home/stephan.nix
    ];
  };
}
