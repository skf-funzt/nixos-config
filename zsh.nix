# ============================================================================
# Zsh Shell Configuration Module for Home Manager
#
# This file configures your Zsh shell environment using Home Manager.
# It is imported from home.nix and manages plugins, aliases, prompt, and more.
#
# FILE STRUCTURE OVERVIEW:
#   zsh.nix   - Zsh shell configuration (plugins, aliases, prompt, etc.)
#
# For more info, see: https://nix-community.github.io/home-manager/options.html
# ============================================================================
{
  config,
  pkgs,
  lib,
  ...
}: {
  # --------------------------------------------------------------------------
  # Zsh Program Settings
  # --------------------------------------------------------------------------
  programs.zsh = {
    enable = true; # Enable Zsh as a managed shell

    # -------------------
    # History Settings
    # -------------------
    # Configure shell history file, size, and behavior.
    history = {
      path = "${config.home.homeDirectory}/.histfile";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
      append = true;
    };

    # -------------------
    # Shell Options
    # -------------------
    autocd = true; # Change directory by typing its name
    dotDir = ".config/zsh"; # Where Zsh stores its config files

    # -------------------
    # Plugin Management
    # -------------------
    # Enable built-in Home Manager Zsh plugins
    autosuggestion.enable = true; # Suggest completions as you type
    enableCompletion = true; # Enable tab completion
    syntaxHighlighting.enable = true; # Syntax highlighting in prompt
    historySubstringSearch.enable = true; # Search history by substring

    # -------------------
    # Shell Aliases
    # -------------------
    shellAliases = {
      adhu = "~/Android/Sdk/extras/google/auto/desktop-head-unit"; # Example alias
      reload = "source ~/.zshrc && zsh"; # Reload Zsh config
    };

    # -------------------
    # oh-my-zsh Integration
    # -------------------
    # Use oh-my-zsh plugins for extra features and completions.
    oh-my-zsh = {
      enable = true;
      plugins = [
        "archlinux"
        "git"
        "git-extras"
        "git-flow"
        "gradle"
        "history"
        "npm"
        "yarn"
        "emoji"
        "flutter"
        "gitignore"
        "systemd"
        "colored-man-pages"
        "command-not-found"
        "zsh-interactive-cd"
      ];
    };

    # -------------------
    # Additional External Plugins
    # -------------------
    # Add plugins not available in oh-my-zsh or Home Manager by default.
    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.34.0"; # Plugin version
          sha256 = "sha256-qSobM4PRXjfsvoXY6ENqJGI9NEAaFFzlij6MPeTfT0o=";
        };
      }
      {
        name = "nix-zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "nix-community";
          repo = "nix-zsh-completions";
          rev = "0.5.0";
          sha256 = "sha256-DKvCpjAeCiUwD5l6PUW7WlEvM0cNZEOk41IiVXoh9D8=";
        };
      }
      {
        name = "docker-aliases";
        src = pkgs.fetchFromGitHub {
          owner = "webyneter";
          repo = "docker-aliases";
          rev = "master"; # Use a specific tag/version if possible
          sha256 = "sha256-Lh+JtPYRY6GraIBnal9MqWGxhJ4+b6aowSDJkTl1wVE=";
        };
      }
    ];

    # -------------------
    # Extra Environment Variables
    # -------------------
    # You can set extra environment variables here (uncomment as needed).
    envExtra = ''
      # # Go configuration
      # export GOPATH=$HOME/go
      # export GOBIN=$GOPATH/bin

      # # Node.js configuration
      # export npm_config_prefix=$HOME/.node_modules

      # # Java configuration
      # export JAVA_HOME=/usr/lib/jvm/default

      # # Flutter Chrome executable path
      # export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
    '';

    # -------------------
    # Shell Initialization Content
    # -------------------
    # Add custom shell commands to run at shell startup.
    initContent = ''
      # Set key bindings
      bindkey -e

      # Enable completion cache
      zstyle ':completion:*' use-cache on

      # oh-my-zsh update style
      zstyle ':omz:update' mode auto

      # # Support for dot command (uncomment if needed)
      # export PATH=".:$PATH"

      # # Skip words with CTRL+arrow (uncomment if needed)
      # bindkey '^[[1;5C' forward-word
      # bindkey '^[[1;5D' backward-word

      # # ASDF configuration (uncomment if you use asdf)
      export PATH="${config.home.homeDirectory}/.asdf/shims:$PATH"
      mkdir -p "${config.home.homeDirectory}/.asdf/completions"
      if command -v asdf &> /dev/null; then
        asdf completion zsh > "${config.home.homeDirectory}/.asdf/completions/_asdf"
      fi

      # # Load ASDF Java home (uncomment if you use asdf-java)
      # if [ -f ${config.home.homeDirectory}/.asdf/plugins/java/set-java-home.zsh ]; then
      #   source ${config.home.homeDirectory}/.asdf/plugins/java/set-java-home.zsh
      # fi

      # # Load p10k configuration (uncomment if you use Powerlevel10k)
      # if [ -f ${config.home.homeDirectory}/.p10k.zsh ]; then
      #   source ${config.home.homeDirectory}/.p10k.zsh
      # fi

      # # bun completions (uncomment if you use bun)
      # if [ -s "${config.home.homeDirectory}/.bun/_bun" ]; then
      #   source "${config.home.homeDirectory}/.bun/_bun"
      # fi

      # # tmux shell settings (should be in tmux config, not zsh)
      # if [ -n "$TMUX" ]; then
      #   set -g default-command /bin/zsh
      #   set -g default-shell /bin/zsh
      # fi

      # Add a reload function to reload zsh config easily
      function reload() {
        source ~/.zshrc && zsh
      }
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # This line forces the gruvbox rainbow theme
    # Some references:
    # https://github.com/nix-community/home-manager/issues/4658#issuecomment-2658516367
    # https://nix.dev/manual/nix/2.18/language/builtins#builtins-fromTOML
    # https://starship.rs/presets/gruvbox-rainbow
    # https://starship.rs/installing/#nix
    #
    #
    settings =
      lib.mkForce
      (builtins.fromTOML (
        builtins.readFile "${pkgs.starship}/share/starship/presets/gruvbox-rainbow.toml"
      ));
  };

  programs.zoxide = {
    enable = true; # Enable zoxide (better cd)
    enableZshIntegration = true;
  };

  # --------------------------------------------------------------------------
  # PATH Configuration
  # --------------------------------------------------------------------------
  # Add custom directories to your PATH here (uncomment as needed).
  home.sessionPath = [
    # "$HOME/flutter/bin"
    # "$HOME/go/bin"
    # "$HOME/.node_modules/bin"
    # "$HOME/.yarn/bin"
    # "/root/.gem/ruby/2.6.0/bin"
    # "$HOME/.gem/ruby/2.6.0/bin"
    # "$HOME/.pub-cache/bin"
    # "$HOME/.config/composer/vendor/bin"
    # "$HOME/flutter/.pub-cache/bin"
    # "/opt/anaconda/bin"
    # "$HOME/Library/Android/sdk/platform-tools"
    # "$HOME/Library/Android/sdk/emulator"
    # "$HOME/Android/Sdk/platform-tools"
    # "$HOME/Android/Sdk/emulator"
    # "$JAVA_HOME/bin"
    # "$HOME/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin"
    # "$HOME/projects/github/AnnePro2-Tools/target/release"
  ];
}
