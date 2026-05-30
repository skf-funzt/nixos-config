# home/stephan.nix
# Entry point for stephan's Home Manager configuration.
# Thin wrapper: delegates to focused modules.
{ config, pkgs, lib, pkgs-unstable, nixgl, handy, nixvim, khanelivim, inputs, gpuType ? "amd", ... }:

{
  imports = [
    ./core.nix          # Base: user info, xdg, nixpkgs config, session vars
    ./theme.nix         # Stylix, cursor, GTK, fonts
    ./packages.nix      # User-level packages
    ./programs.nix      # Program configurations (tmux, git, chromium, noctalia)
    ./zsh.nix           # Zsh shell
    ./nixvim.nix        # Nixvim (currently disabled)
    # NOTE: noctalia is imported via home-manager.sharedModules in the host config
    # Do NOT import it here or it will conflict.
  ];
}
