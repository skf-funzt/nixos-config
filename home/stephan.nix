# ============================================================================
# Home Manager Configuration for stephan
#
# This file is the main entry point for your Home Manager setup.
# It imports other modules (like zsh.nix) and defines global settings,
# packages, and programs to be managed in your user environment.
#
# FILE STRUCTURE OVERVIEW:
#   home.nix      - Main configuration, imports modules, sets up packages, etc.
#   zsh.nix       - Zsh shell configuration (imported below)
#
# For more info, see: https://nix-community.github.io/home-manager/
# ============================================================================
{
  config,
  pkgs,
  lib ? pkgs.lib,
  pkgs-unstable,
  nixgl,
  handy,
  nixvim,
  khanelivim,
  inputs,
  gpuType ? "amd", # "amd" | "nvidia" | "cpu" — passed from flake.nix via extraSpecialArgs
  ...
}:
let
  # Import custom wrapped packages
  vscode-wrapped = import ./vscode.nix {
    inherit pkgs pkgs-unstable;
  };
  handy-wrapped = import ./handy-wrapped.nix {
    inherit pkgs handy;
  };

  # ---------------------------------------------------------------------------
  # GPU-Aware Ollama Package Selection
  # ---------------------------------------------------------------------------
  # Selects the correct Ollama build based on gpuType:
  #   "amd"    → ollama-rocm  (ROCm backend for AMD GPUs)
  #   "nvidia" → ollama-cuda  (CUDA backend for NVIDIA GPUs)
  #   "cpu"    → ollama       (CPU-only, no GPU acceleration)
  ollamaPackage =
    {
      amd = pkgs-unstable.ollama-rocm;
      nvidia = pkgs-unstable.ollama-cuda;
      cpu = pkgs-unstable.ollama;
    }
    .${gpuType};
in
{
  # --------------------------------------------------------------------------
  # Module Imports
  # --------------------------------------------------------------------------
  # Import additional configuration modules. Each module can configure a specific
  # aspect of your environment (e.g., zsh, neovim, etc.).
  imports = [
    ./core.nix          # Base home settings (stateVersion, xdg, session vars)
    ./zsh.nix           # Zsh shell configuration
    ./nixvim.nix        # Nixvim (currently disabled)
    inputs.noctalia.homeModules.default
  ];

  # --------------------------------------------------------------------------
  # Home Manager Options
  # --------------------------------------------------------------------------
  # Enable Home Manager to manage itself and set up auto-expiration for old
  # generations. This helps keep your configuration clean and up-to-date.
  # Note: This is optional and can be disabled if you prefer to manage
  # generations manually.
  services.home-manager.autoExpire.enable = true;

  # --------------------------------------------------------------------------
  # Nixpkgs Configuration
  # --------------------------------------------------------------------------
  # Allow unfree packages (e.g., proprietary software like Google Chrome).
  # Also enables zsh program support in nixpkgs.
  nixpkgs = {
    config = {
      allowUnfree = true;
      programs.zsh.enabled = true;

      # Add myself to the trusted users list for Nixpkgs.
      # extra-substituters = "https://devenv.cachix.org";
      # extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    };
  };

  # --------------------------------------------------------------------------
  # nixGL (OpenGL Wrapper) Configuration
  # --------------------------------------------------------------------------
  # These options help run graphical programs with the correct OpenGL drivers
  # on non-NixOS systems. Only needed if you use GPU-accelerated apps via Nix.
  targets.genericLinux.nixGL.packages = nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";
  # targets.genericLinux.nixGL.offloadWrapper = "mesaPrime";
  targets.genericLinux.nixGL.installScripts = [
    "mesa"
    # "mesaPrime"
  ];
  # ! This setting breaks Gnome 46 completely for X and Wayland
  # targets.genericLinux.nixGL.vulkan.enable = true;

  # --------------------------------------------------------------------------
  # XDG and Linux Target Settings
  # --------------------------------------------------------------------------
  # Enable support for generic Linux and XDG (desktop integration) features.
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  # --------------------------------------------------------------------------
  # (Optional) Activation Hooks
  # --------------------------------------------------------------------------
  # You can run custom commands after activating your configuration.
  # Example: update the desktop database after installing new apps.
  # home.activation = {
  #   linkDesktopApplications = {
  #     after = [ "writeBoundary" "createXdgUserDirectories" ];
  #     before = [ ];
  #     data = "/usr/bin/update-desktop-database";
  #   };
  # };

  # --------------------------------------------------------------------------
  # User Information
  # --------------------------------------------------------------------------
  # Set your username and home directory. Used by other modules.
  home.username = "stephan";
  home.homeDirectory = "/home/stephan";

  # # --------------------------------------------------------------------------
  # # Cursor Theme
  # # --------------------------------------------------------------------------
  # # Configure the mouse cursor theme for GTK applications.
  # # ref: https://github.com/ful1e5/bibata
  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 22;
  };

  # # --------------------------------------------------------------------------
  # # GTK Configuration
  # # --------------------------------------------------------------------------

  gtk = {
    enable = true; # Enable GTK support
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 22;
    };
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
      size = 10; # Default font size
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  # --------------------------------------------------------------------------
  # Stylix Configuration
  # --------------------------------------------------------------------------
  stylix.enable = false; # Enable Stylix for cursor theme management
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
    serif = {
      package = pkgs.noto-fonts;
      name = "Noto Serif";
    };

    sansSerif = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };

    monospace = {
      package = pkgs.hackgen-nf-font;
      name = "Hack Nerd Font";
    };

    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };

  # stylix.targets.firefox.profileNames = [ "default" ];

  # --------------------------------------------------------------------------
  # Home Manager State Version
  # --------------------------------------------------------------------------
  # This value should match the Home Manager release you started with.
  # Only change after reading the release notes!
  home.stateVersion = "26.05";

  # --------------------------------------------------------------------------
  # Packages
  # --------------------------------------------------------------------------
  # List of packages to be installed in your user environment.
  # You can add, remove, or comment out packages as needed.
  home.packages = [
    # Miscellaneous tools
    pkgs.nixfmt-rfc-style
    pkgs.nil
    pkgs.nixd
    pkgs.alejandra
    pkgs-unstable.devenv
    pkgs.cachix

    # Fonts
    pkgs.fira-code
    pkgs.nerd-fonts.fira-code
    pkgs.hackgen-nf-font
    pkgs.powerline-fonts
    pkgs.roboto
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji

    # Icons
    pkgs.papirus-icon-theme

    # Terminal emulator
    (config.lib.nixGL.wrap pkgs.alacritty)
    (config.lib.nixGL.wrap pkgs.kitty)

    # System tools
    pkgs.tldr
    pkgs.powertop
    pkgs.btop-rocm # btop with ROCm support for AMD GPUs
    pkgs.fastfetch
    pkgs.stress
    pkgs.websocat
    pkgs.gh
    pkgs.yazi

    # Conferencing
    pkgs.zoom

    # Security tools
    # pkgs.yubikey-manager-qt  # Deprecated after NixOS 25.11
    pkgs.yubioath-flutter

    # Browsers
    # (config.lib.nixGL.wrap pkgs.google-chrome) # Chrome still crashes with nixGL active
    # pkgs.google-chrome
    (config.lib.nixGL.wrap pkgs.firefox)

    # Media players and editors (OpenGL wrapped)
    pkgs.spotify
    (config.lib.nixGL.wrap pkgs.vlc)
    (config.lib.nixGL.wrap pkgs.darktable)
    (config.lib.nixGL.wrap pkgs.drawing)
    (config.lib.nixGL.wrap pkgs.gimp3)
    (config.lib.nixGL.wrap pkgs.krita)
    (config.lib.nixGL.wrap pkgs.inkscape)
    (config.lib.nixGL.wrap pkgs.blender)
    (config.lib.nixGL.wrap pkgs.obs-studio)

    # Video tools
    pkgs.peek
    # pkgs.obs-studio  # See obs-studio module below
    (config.lib.nixGL.wrap pkgs.kdePackages.kdenlive)

    # Messengers
    pkgs.signal-desktop
    pkgs.discord
    pkgs.ferdium

    # Speech-to-text
    # handy-wrapped

    # Virtualization
    pkgs.virtualbox
    # pkgs.vagrant
    # pkgs.snap
    # pkgs.apparmor
    # pkgs.docker # This is not supported on non-nixos systems and should be done using the systems package manager - ref: https://nixos.wiki/wiki/Docker#:~:text=for%20further%20options-,Running%20the%20docker%20daemon%20from%20nix%2Dthe%2Dpackage%2Dmanager%20%2D%20not%20NixOS,-This%20is%20not
    # pkgs.docker-compose
    # pkgs.kompose
    # pkgs.podman # This is not supported on non-nixos systems and should be done using the systems package manager - ref: https://nixos.wiki/wiki/Docker#:~:text=for%20further%20options-,Running%20the%20docker%20daemon%20from%20nix%2Dthe%2Dpackage%2Dmanager%20%2D%20not%20NixOS,-This%20is%20not
    pkgs.podman-tui
    pkgs-unstable.podman-desktop

    # Development tools
    vscode-wrapped
    # See below for VSCode Insiders example
    # (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
    #   src = (builtins.fetchTarball {
    #     url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
    #     sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    #   });
    #   version = "latest";
    #   buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
    # });

    # Local AI / LLM (GPU-accelerated based on gpuType: ${gpuType})
    # Models managed imperatively: ollama pull gemma4:e2b gemma4:e4b gemma4:26b gemma4:31b
    # Using unstable for latest Ollama (Gemma 4 requires >= 0.13)
    ollamaPackage

    # CLI tools
    pkgs.gemini-cli
    pkgs.github-desktop
    pkgs-unstable.opencode # Currently using a custom version of opencode with config reloading support, see opencode-pr input
    pkgs-unstable.github-copilot-cli
    pkgs-unstable.pi-coding-agent
    pkgs.bashInteractive
    pkgs.byobu

    # Key Tools
    pkgs.infisical

    # Management Tools
    pkgs.logseq
    pkgs.zotero

    # Productivity Tools
    pkgs-unstable.super-productivity

    # Neovim managed by Nixvim module
    # khanelivim.packages.${pkgs.system}.default
    # Custom khanelivim profile
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

  # --------------------------------------------------------------------------
  # Dotfiles and Custom Files
  # --------------------------------------------------------------------------
  # Manage your dotfiles or custom config files here.
  home.file = {
    # Example: link a custom .screenrc file
    # ".screenrc".source = dotfiles/screenrc;
    # Example: set content of gradle.properties
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # --------------------------------------------------------------------------
  # Environment Variables
  # --------------------------------------------------------------------------
  # This block is now added back in to handle the extension's environment
  home.sessionVariables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib # Provides libstdc++.so.6
      pkgs.libuuid # Provides libuuid.so.1
    ];

    # ---- Ollama Settings (common to all GPU types) ----
    # ref: https://github.com/ollama/ollama/blob/main/docs/faq.md
    OLLAMA_CONTEXT_LENGTH = "32768"; # 32K context (balanced memory/capability)
    OLLAMA_FLASH_ATTENTION = "true"; # Reduces KV cache memory significantly
    OLLAMA_KV_CACHE_TYPE = "q8_0"; # Quantized KV cache (~36% less memory)
    OLLAMA_MAX_LOADED_MODELS = "1"; # Single model at a time (memory safety)
    OLLAMA_NUM_PARALLEL = "1"; # Single request at a time (stability)

    # ---- Network Access ----
    # Bind to all interfaces so Ollama is accessible on the local network
    OLLAMA_HOST = "0.0.0.0:11434";
    # Allow requests from any origin (required for LAN clients)
    OLLAMA_ORIGINS = "*";
  }
  # ---- AMD-specific settings ----
  // lib.optionalAttrs (gpuType == "amd") {
    # ROCm override for Radeon 780M iGPU (gfx1103 → gfx1100 compatibility)
    # Required for ollama-rocm GPU acceleration on Phoenix APUs
    # ref: https://github.com/ollama/ollama/issues/15482
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    # Reserve 30% VRAM for system/display (shared memory iGPU)
    # ref: https://github.com/ollama/ollama/issues/12472
    GPU_MAX_ALLOC_PERCENT = "70";
  };

  # --------------------------------------------------------------------------
  # Program and Service Modules
  # --------------------------------------------------------------------------
  # Enable and configure programs managed by Home Manager.
  programs.home-manager.enable = true; # Allow Home Manager to manage itself
  programs.nh.enable = true; # Enable nh (Nix Home) utility
  # programs.vscode.enable = true; # Enable Visual Studio Code

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
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Stephan Koglin-Fischer";
        email = "stephan.koglin-fischer@funzt.dev";
      };
    };
  };
  # programs.gh.enable = true;
  # programs.gh-acy.enable = true; # Does not exists
  # programs.gh-dash.enable = true;
  programs.gitui.enable = true;

  programs.direnv.enable = true; # Enable direnv for project-specific envs

  programs.chromium = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.chromium; # Use the Chromium browser package
  }; # Enable Chromium browser

  programs.noctalia-shell = {
    enable = true;
    settings = {
      # configure noctalia here
      bar = {
        density = "compact";
        position = "right";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
          ];
          center = [
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          right = [
            {
              alwaysShowPercentage = false;
              id = "Battery";
              warningThreshold = 30;
            }
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
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
    # this may also be a string or a path to a JSON file.
  };

  # Later... maybe
  # nvf
  # programs.nvf = {
  #   enable = true;
  #   enableManpages = true;
  #   # your settings need to go into the settings attribute set
  #   # most settings are documented in the appendix
  #   # ref: https://github.com/NotAShelf/nvf/blob/main/configuration.nix
  #   settings = {
  #     config.vim = {
  #       viAlias = true;
  #       vimAlias = true;
  #       debugMode = {
  #         enable = false;
  #         level = 16;
  #         logFile = "/tmp/nvim.log";
  #       };

  #       # vim.opts and vim.options are aliased
  #       opts.expandtab = true;

  #       spellcheck = {
  #         enable = true;
  #         programmingWordlist.enable = true;
  #       };

  #       lsp = {
  #         # This must be enabled for the language modules to hook into
  #         # the LSP API.
  #         enable = true;

  #         formatOnSave = true;
  #         lspkind.enable = false;
  #         lightbulb.enable = true;
  #         lspsaga.enable = false;
  #         trouble.enable = true;
  #         lspSignature.enable = !true; # conflicts with blink in maximal
  #         otter-nvim.enable = true;
  #         nvim-docs-view.enable = true;
  #         presets.harper.enable = true;
  #       };

  #       debugger = {
  #         nvim-dap = {
  #           enable = true;
  #           ui.enable = true;
  #         };
  #       };

  #       # This section does not include a comprehensive list of available language modules.
  #       # To list all available language module options, please visit the nvf manual.
  #       languages = {
  #         enableFormat = true;
  #         enableTreesitter = true;
  #         enableExtraDiagnostics = true;

  #         # Languages that will be supported in default and maximal configurations.
  #         nix.enable = true;
  #         markdown.enable = true;

  #         # Languages that are enabled in the maximal configuration.
  #         bash.enable = true;
  #         clang.enable = true;
  #         cmake.enable = true;
  #         css.enable = true;
  #         scss.enable = true;
  #         html.enable = true;
  #         json.enable = true;
  #         sql.enable = true;
  #         java.enable = true;
  #         kotlin.enable = true;
  #         typescript.enable = true;
  #         go.enable = true;
  #         lua.enable = true;
  #         zig.enable = true;
  #         python.enable = true;
  #         typst.enable = true;
  #         rust = {
  #           enable = true;
  #           extensions.crates-nvim.enable = true;
  #         };
  #         toml.enable = true;
  #         xml.enable = true;
  #         tex.enable = true;

  #         # Language modules that are not as common.
  #         openscad.enable = false;
  #         arduino.enable = false;
  #         assembly.enable = false;
  #         astro.enable = false;
  #         nu.enable = false;
  #         csharp.enable = false;
  #         julia.enable = false;
  #         vala.enable = false;
  #         scala.enable = false;
  #         r.enable = false;
  #         gleam.enable = false;
  #         glsl.enable = false;
  #         dart.enable = false;
  #         ocaml.enable = false;
  #         elixir.enable = false;
  #         haskell.enable = false;
  #         hcl.enable = false;
  #         ruby.enable = false;
  #         fsharp.enable = false;
  #         just.enable = false;
  #         make.enable = false;
  #         qml.enable = false;
  #         jinja.enable = false;
  #         svelte.enable = false;
  #         vue.enable = false;
  #         liquid.enable = false;
  #         tera.enable = false;
  #         twig.enable = false;
  #         gettext.enable = false;
  #         fluent.enable = false;
  #         jq.enable = false;

  #         # Nim LSP is broken on Darwin and therefore
  #         # should be disabled by default. Users may still enable
  #         # `vim.languages.vim` to enable it, this does not restrict
  #         # that.
  #         # See: <https://github.com/PMunch/nimlsp/issues/178#issue-2128106096>
  #         nim.enable = false;
  #       };

  #       visuals = {
  #         nvim-scrollbar.enable = true;
  #         nvim-web-devicons.enable = true;
  #         nvim-cursorline.enable = true;
  #         cinnamon-nvim.enable = true;
  #         fidget-nvim.enable = true;

  #         highlight-undo.enable = true;
  #         blink-indent.enable = true;
  #         indent-blankline.enable = true;

  #         # Fun
  #         cellular-automaton.enable = false;
  #       };

  #       statusline = {
  #         lualine = {
  #           enable = true;
  #           theme = "catppuccin";
  #         };
  #       };

  #       theme = {
  #         enable = true;
  #         name = "catppuccin";
  #         style = "mocha";
  #         transparent = false;
  #       };

  #       autopairs.nvim-autopairs.enable = true;

  #       # nvf provides various autocomplete options. The tried and tested nvim-cmp
  #       # is enabled in default package, because it does not trigger a build. We
  #       # enable blink-cmp in maximal because it needs to build its rust fuzzy
  #       # matcher library.
  #       autocomplete = {
  #         nvim-cmp.enable = !true;
  #         blink-cmp.enable = true;
  #       };

  #       snippets.luasnip.enable = true;

  #       filetree = {
  #         neo-tree = {
  #           enable = true;
  #         };
  #       };

  #       tabline = {
  #         nvimBufferline.enable = true;
  #       };

  #       treesitter.context.enable = true;

  #       binds = {
  #         whichKey.enable = true;
  #         cheatsheet.enable = true;
  #       };

  #       telescope.enable = true;

  #       git = {
  #         enable = true;
  #         gitsigns.enable = true;
  #         gitsigns.codeActions.enable = false; # throws an annoying debug message
  #         neogit.enable = true;
  #       };

  #       minimap = {
  #         minimap-vim.enable = false;
  #         codewindow.enable = true; # lighter, faster, and uses lua for configuration
  #       };

  #       dashboard = {
  #         dashboard-nvim.enable = false;
  #         alpha.enable = true;
  #       };

  #       notify = {
  #         nvim-notify.enable = true;
  #       };

  #       projects = {
  #         project-nvim.enable = true;
  #       };

  #       utility = {
  #         ccc.enable = false;
  #         vim-wakatime.enable = false;
  #         diffview-nvim.enable = true;
  #         yanky-nvim.enable = false;
  #         qmk-nvim.enable = false; # requires hardware specific options
  #         icon-picker.enable = true;
  #         surround.enable = true;
  #         leetcode-nvim.enable = true;
  #         multicursors.enable = true;
  #         smart-splits.enable = true;
  #         undotree.enable = true;
  #         nvim-biscuits.enable = true;
  #         grug-far-nvim.enable = true;

  #         motion = {
  #           hop.enable = true;
  #           leap.enable = true;
  #           precognition.enable = true;
  #         };
  #         images = {
  #           image-nvim.enable = false;
  #           img-clip.enable = true;
  #         };
  #       };

  #       notes = {
  #         neorg.enable = false;
  #         orgmode.enable = false;
  #         mind-nvim.enable = false;
  #         todo-comments.enable = true;
  #       };

  #       terminal = {
  #         toggleterm = {
  #           enable = true;
  #           lazygit.enable = true;
  #         };
  #       };

  #       ui = {
  #         borders.enable = true;
  #         noice.enable = true;
  #         colorizer.enable = true;
  #         modes-nvim.enable = false; # the theme looks terrible with catppuccin
  #         illuminate.enable = true;
  #         breadcrumbs = {
  #           enable = true;
  #           navbuddy.enable = true;
  #         };
  #         smartcolumn = {
  #           enable = true;
  #           setupOpts.custom_colorcolumn = {
  #             # this is a freeform module, it's `buftype = int;` for configuring column position
  #             nix = "110";
  #             ruby = "120";
  #             java = "130";
  #             go = [
  #               "90"
  #               "130"
  #             ];
  #           };
  #         };
  #         fastaction.enable = true;
  #       };

  #       assistant = {
  #         chatgpt.enable = false;
  #         copilot = {
  #           enable = false;
  #           cmp.enable = true;
  #         };
  #         codecompanion-nvim.enable = false;
  #         avante-nvim.enable = false;
  #       };

  #       session = {
  #         nvim-session-manager.enable = false;
  #       };

  #       gestures = {
  #         gesture-nvim.enable = false;
  #       };

  #       comments = {
  #         comment-nvim.enable = true;
  #       };

  #       presence = {
  #         neocord.enable = false;
  #       };
  #     };
  #   };
  # };
  # Disabled for now as it eats up too much system resources
  # Especially the timer set to 15 minutes does not work as it takes longer then 15 minutes to
  # complete this task AND another process will start. This leads to a situation where so many
  # instances are running that the system crashes!
  # --------------------------------------------------------------------------
  # Memsearch Auto-Sync (git commit + push on data changes)
  # --------------------------------------------------------------------------
  # systemd.user.services.memsearch-sync = {
  #   Unit = {
  #     Description = "Memsearch data auto-commit and push";
  #     After = [ "network-online.target" ];
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = toString (
  #       pkgs.writeShellScript "memsearch-sync" ''
  #         set -euo pipefail
  #         MEMSEARCH_DIR="$HOME/.memsearch"
  #         cd "$MEMSEARCH_DIR"
  #
  #         if ! [ -d .git ]; then exit 0; fi
  #
  #         ${pkgs.git}/bin/git add data/ compact-data/ config.toml extract-*.py overnight-pipeline.sh setup.sh 2>/dev/null || true
  #
  #         if ! ${pkgs.git}/bin/git diff --cached --quiet 2>/dev/null; then
  #           ${pkgs.git}/bin/git commit -m "auto-sync: $(date -Is) $(hostname)"
  #           ${pkgs.git}/bin/git push origin main 2>/dev/null || true
  #         fi
  #       ''
  #     );
  #   };
  # };
  #
  # systemd.user.timers.memsearch-sync = {
  #   Unit.Description = "Memsearch auto-sync timer";
  #   Timer = {
  #     OnCalendar = "*:0/15";
  #     Persistent = true;
  #   };
  #   Install.WantedBy = [ "timers.target" ];
  # };
}
