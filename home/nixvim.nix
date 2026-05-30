# ============================================================================
# Nixvim Configuration Module
#
# This module configures Neovim via Nixvim, a declarative Neovim configuration
# system that allows you to configure Neovim using Nix modules.
#
# For more information, see: https://nix-community.github.io/nixvim/
# ============================================================================
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # --------------------------------------------------------------------------
  # Nixvim Settings
  # --------------------------------------------------------------------------
  # programs.nixvim = {
  #   enable = true;
  #
  #   # Default editor settings
  #   defaultEditor = true;
  #
  #   # Vimdiff configuration
  #   # vimdiff.enable = true;
  #
  #   # --------------------------------------------------------------------------
  #   # Core Settings
  #   # --------------------------------------------------------------------------
  #   opts = {
  #     # Line numbering
  #     number = true;
  #     relativenumber = true;
  #
  #     # Indentation
  #     expandtab = true;
  #     shiftwidth = 2;
  #     softtabstop = 2;
  #     tabstop = 2;
  #     smartindent = true;
  #
  #     # Text wrapping
  #     wrap = false;
  #     textwidth = 100;
  #
  #     # Search and replace
  #     ignorecase = true;
  #     smartcase = true;
  #     hlsearch = true;
  #     incsearch = true;
  #
  #     # Display settings
  #     cursorline = true;
  #     cursorcolumn = false;
  #     showmode = false;
  #     showcmd = true;
  #     cmdheight = 1;
  #     laststatus = 3; # Global statusline
  #     signcolumn = "yes:2"; # Always show sign column
  #
  #     # Whitespace and formatting
  #     list = true;
  #     listchars = {
  #       trail = "⋅";
  #       tab = "▸ ";
  #       eol = "↲";
  #     };
  #
  #     # Undo and backup
  #     undofile = true;
  #     undodir = [
  #       "~/.local/share/nvim/undo"
  #     ];
  #     backupdir = [
  #       "~/.local/share/nvim/backup"
  #     ];
  #     directory = [
  #       "~/.local/share/nvim/swap"
  #     ];
  #
  #     # Completion
  #     completeopt = [
  #       "menu"
  #       "menuone"
  #       "noselect"
  #     ];
  #
  #     # Performance
  #     timeoutlen = 300;
  #     updatetime = 200;
  #
  #     # Splits
  #     splitbelow = true;
  #     splitright = true;
  #
  #     # Mouse support
  #     mouse = "a";
  #
  #     # Scrolling
  #     scrolloff = 8;
  #     sidescrolloff = 8;
  #
  #     # Encoding
  #     encoding = "utf-8";
  #     fileencoding = "utf-8";
  #   };
  #
  #   # --------------------------------------------------------------------------
  #   # Globals
  #   # --------------------------------------------------------------------------
  #   globals = {
  #     mapleader = " ";
  #     maplocalleader = ",";
  #   };
  #
  #   # --------------------------------------------------------------------------
  #   # Key Mappings
  #   # --------------------------------------------------------------------------
  #   keymaps = [
  #     {
  #       mode = "n";
  #       key = "<C-h>";
  #       action = "<C-w>h";
  #       options = {
  #         desc = "Move to left window";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<C-j>";
  #       action = "<C-w>j";
  #       options = {
  #         desc = "Move to bottom window";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<C-k>";
  #       action = "<C-w>k";
  #       options = {
  #         desc = "Move to top window";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<C-l>";
  #       action = "<C-w>l";
  #       options = {
  #         desc = "Move to right window";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>bn";
  #       action = ":bnext<CR>";
  #       options = {
  #         desc = "Next buffer";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>bp";
  #       action = ":bprevious<CR>";
  #       options = {
  #         desc = "Previous buffer";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>bd";
  #       action = ":bdelete<CR>";
  #       options = {
  #         desc = "Delete buffer";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>sv";
  #       action = ":vsplit<CR>";
  #       options = {
  #         desc = "Split vertically";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>sh";
  #       action = ":split<CR>";
  #       options = {
  #         desc = "Split horizontally";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>w";
  #       action = ":write<CR>";
  #       options = {
  #         desc = "Write file";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>q";
  #       action = ":quit<CR>";
  #       options = {
  #         desc = "Quit";
  #       };
  #     }
  #     {
  #       mode = "i";
  #       key = "<C-c>";
  #       action = "<Esc>";
  #       options = {
  #         desc = "Escape insert mode";
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "K";
  #       action = ":lua vim.lsp.buf.hover()<CR>";
  #       options = {
  #         desc = "Show hover documentation";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>ca";
  #       action = ":lua vim.lsp.buf.code_action()<CR>";
  #       options = {
  #         desc = "Code action";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>cr";
  #       action = ":lua vim.lsp.buf.rename()<CR>";
  #       options = {
  #         desc = "Rename symbol";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "gd";
  #       action = ":lua vim.lsp.buf.definition()<CR>";
  #       options = {
  #         desc = "Go to definition";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "gi";
  #       action = ":lua vim.lsp.buf.implementation()<CR>";
  #       options = {
  #         desc = "Go to implementation";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #
  #     # File explorer toggle
  #     {
  #       mode = "n";
  #       key = "<leader>e";
  #       action = ":Neotree toggle<CR>";
  #       options = {
  #         desc = "Toggle file explorer";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #
  #     # Trouble diagnostics panel
  #     {
  #       mode = "n";
  #       key = "<leader>tt";
  #       action = ":Trouble diagnostics toggle<CR>";
  #       options = {
  #         desc = "Toggle diagnostics panel";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>td";
  #       action = ":Trouble diagnostics toggle filter.buf=0<CR>";
  #       options = {
  #         desc = "Toggle buffer diagnostics";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #
  #     # Recent files via telescope
  #     {
  #       mode = "n";
  #       key = "<leader>fr";
  #       action = ":Telescope oldfiles<CR>";
  #       options = {
  #         desc = "Recent files";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #
  #     # Telescope LSP helpers
  #     {
  #       mode = "n";
  #       key = "<leader>fd";
  #       action = ":Telescope diagnostics<CR>";
  #       options = {
  #         desc = "Find diagnostics";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>fs";
  #       action = ":Telescope lsp_document_symbols<CR>";
  #       options = {
  #         desc = "Find symbols in file";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>fk";
  #       action = ":Telescope keymaps<CR>";
  #       options = {
  #         desc = "Find keymaps";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #
  #     # Undo tree
  #     {
  #       mode = "n";
  #       key = "<leader>uu";
  #       action = ":UndotreeToggle<CR>";
  #       options = {
  #         desc = "Toggle undo tree";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #
  #     # Git shortcuts
  #     {
  #       mode = "n";
  #       key = "<leader>gs";
  #       action = ":Telescope git_status<CR>";
  #       options = {
  #         desc = "Git status";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>gc";
  #       action = ":Telescope git_commits<CR>";
  #       options = {
  #         desc = "Git commits";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>gb";
  #       action = ":Telescope git_branches<CR>";
  #       options = {
  #         desc = "Git branches";
  #         noremap = true;
  #         silent = true;
  #       };
  #     }
  #
  #     # Quick buffer switching by number (bufferline)
  #     {
  #       mode = "n";
  #       key = "<leader>1";
  #       action = ":BufferLineGoToBuffer 1<CR>";
  #       options = {
  #         desc = "Go to buffer 1";
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>2";
  #       action = ":BufferLineGoToBuffer 2<CR>";
  #       options = {
  #         desc = "Go to buffer 2";
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>3";
  #       action = ":BufferLineGoToBuffer 3<CR>";
  #       options = {
  #         desc = "Go to buffer 3";
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>4";
  #       action = ":BufferLineGoToBuffer 4<CR>";
  #       options = {
  #         desc = "Go to buffer 4";
  #         silent = true;
  #       };
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>5";
  #       action = ":BufferLineGoToBuffer 5<CR>";
  #       options = {
  #         desc = "Go to buffer 5";
  #         silent = true;
  #       };
  #     }
  #   ];
  #
  #   # --------------------------------------------------------------------------
  #   # Plugins
  #   # --------------------------------------------------------------------------
  #   plugins = {
  #     # UI Enhancements
  #     treesitter = {
  #       enable = true;
  #       ensureInstalled = "all";
  #     };
  #
  #     web-devicons.enable = true;
  #
  #     # File Explorer
  #     neo-tree = {
  #       enable = true;
  #       filesystem = {
  #         filtered_items = {
  #           visible = false;
  #           hide_dotfiles = false;
  #         };
  #       };
  #     };
  #
  #     # Fuzzy Finder
  #     telescope = {
  #       enable = true;
  #       extensions = {
  #         fzf-native = {
  #           enable = true;
  #         };
  #       };
  #       keymaps = {
  #         "<leader>ff" = {
  #           action = "find_files";
  #           options = {
  #             desc = "Find files";
  #           };
  #         };
  #         "<leader>fg" = {
  #           action = "live_grep";
  #           options = {
  #             desc = "Live grep";
  #           };
  #         };
  #         "<leader>fb" = {
  #           action = "buffers";
  #           options = {
  #             desc = "Find buffers";
  #           };
  #         };
  #         "<leader>fh" = {
  #           action = "help_tags";
  #           options = {
  #             desc = "Find help";
  #           };
  #         };
  #       };
  #     };
  #
  #     # Completion
  #     nvim-cmp = {
  #       enable = true;
  #       autoEnableSources = true;
  #       sources = [
  #         {
  #           name = "nvim_lsp";
  #           priority = 100;
  #         }
  #         {
  #           name = "nvim_lua";
  #           priority = 95;
  #         }
  #         {
  #           name = "path";
  #           priority = 90;
  #         }
  #         {
  #           name = "luasnip";
  #           priority = 85;
  #         }
  #         {
  #           name = "buffer";
  #           priority = 80;
  #         }
  #       ];
  #       window = {
  #         documentation = {
  #           border = "rounded";
  #         };
  #       };
  #     };
  #
  #     luasnip.enable = true;
  #
  #     # LSP
  #     lsp = {
  #       enable = true;
  #       servers = {
  #         nil_ls = {
  #           enable = true;
  #           settings = {
  #             nil = {
  #               formatting = {
  #                 command = [ "nixpkgs-fmt" ];
  #               };
  #             };
  #           };
  #         };
  #         lua_ls = {
  #           enable = true;
  #           settings = {
  #             Lua = {
  #               runtime = {
  #                 version = "LuaJIT";
  #               };
  #               diagnostics = {
  #                 globals = [ "vim" ];
  #               };
  #               workspace = {
  #                 library = [
  #                   "$${3rd}/luv/library"
  #                   "$${VIMRUNTIME}/lua"
  #                 ];
  #                 checkThirdParty = false;
  #               };
  #             };
  #           };
  #         };
  #       };
  #     };
  #
  #     # Git integration
  #     gitsigns = {
  #       enable = true;
  #       signs = {
  #         add = {
  #           text = "▎";
  #         };
  #         change = {
  #           text = "▎";
  #         };
  #         changedelete = {
  #           text = "▎";
  #         };
  #         delete = {
  #           text = "▏";
  #         };
  #         topdelete = {
  #           text = "▏";
  #         };
  #         untracked = {
  #           text = "▎";
  #         };
  #       };
  #     };
  #
  #     # Status line
  #     lualine = {
  #       enable = true;
  #       theme = "auto";
  #     };
  #
  #     # Indentation guides
  #     indent-blankline = {
  #       enable = true;
  #       settings = {
  #         indent = {
  #           char = "▏";
  #         };
  #       };
  #     };
  #
  #     # Comments
  #     comment-nvim = {
  #       enable = true;
  #     };
  #
  #     # Surround operations
  #     nvim-surround = {
  #       enable = true;
  #     };
  #
  #     # Autopairs
  #     nvim-autopairs = {
  #       enable = true;
  #     };
  #
  #     # Terminal
  #     toggleterm = {
  #       enable = true;
  #       settings = {
  #         open_mapping = "[[<c-\\>]]";
  #         direction = "float";
  #       };
  #     };
  #
  #     # Undo tree
  #     undotree = {
  #       enable = true;
  #     };
  #
  #     # Better motions
  #     flash = {
  #       enable = true;
  #     };
  #
  #     # Rainbow brackets
  #     rainbow-delimiters = {
  #       enable = true;
  #     };
  #
  #     # Which-key: shows available keybindings as you type
  #     # Press <leader> (Space) and wait to see all available commands
  #     which-key = {
  #       enable = true;
  #       settings = {
  #         delay = 300;
  #         spec = [
  #           {
  #             __unkeyed-1 = "<leader>b";
  #             group = "Buffers";
  #           }
  #           {
  #             __unkeyed-1 = "<leader>c";
  #             group = "Code";
  #           }
  #           {
  #             __unkeyed-1 = "<leader>f";
  #             group = "Find";
  #           }
  #           {
  #             __unkeyed-1 = "<leader>g";
  #             group = "Git";
  #           }
  #           {
  #             __unkeyed-1 = "<leader>s";
  #             group = "Split";
  #           }
  #           {
  #             __unkeyed-1 = "<leader>t";
  #             group = "Trouble / Diagnostics";
  #           }
  #           {
  #             __unkeyed-1 = "<leader>u";
  #             group = "Undo";
  #           }
  #         ];
  #       };
  #     };
  #
  #     # Bufferline: visual tab bar showing all open buffers
  #     bufferline = {
  #       enable = true;
  #       settings.options = {
  #         numbers = "ordinal"; # show buffer numbers so you can jump with <leader>1-9
  #         diagnostics = "nvim_lsp"; # show LSP error/warning icons in tabs
  #         show_buffer_close_icons = true;
  #         show_close_icon = false;
  #         separator_style = "slant";
  #       };
  #     };
  #
  #     # Trouble: a nice panel for LSP diagnostics, errors, and references
  #     trouble = {
  #       enable = true;
  #     };
  #
  #     # Alpha: dashboard shown on startup with quick shortcuts
  #     alpha = {
  #       enable = true;
  #       settings.layout = [
  #         {
  #           type = "padding";
  #           val = 4;
  #         }
  #         {
  #           type = "text";
  #           val = [
  #             "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  "
  #             "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  "
  #             "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  "
  #             "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  "
  #             "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  "
  #             "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  "
  #           ];
  #           opts = {
  #             hl = "Type";
  #             position = "center";
  #           };
  #         }
  #         {
  #           type = "padding";
  #           val = 2;
  #         }
  #         {
  #           type = "group";
  #           val = [
  #             {
  #               type = "button";
  #               val = "  Find File          (Space + f + f)";
  #               on_press.__raw = "function() require('telescope.builtin').find_files() end";
  #               opts = {
  #                 shortcut = "ff";
  #                 hl = "Keyword";
  #                 hl_shortcut = "Number";
  #                 position = "center";
  #               };
  #             }
  #             {
  #               type = "button";
  #               val = "  Recent Files       (Space + f + r)";
  #               on_press.__raw = "function() require('telescope.builtin').oldfiles() end";
  #               opts = {
  #                 shortcut = "fr";
  #                 hl = "Keyword";
  #                 hl_shortcut = "Number";
  #                 position = "center";
  #               };
  #             }
  #             {
  #               type = "button";
  #               val = "  Find Text          (Space + f + g)";
  #               on_press.__raw = "function() require('telescope.builtin').live_grep() end";
  #               opts = {
  #                 shortcut = "fg";
  #                 hl = "Keyword";
  #                 hl_shortcut = "Number";
  #                 position = "center";
  #               };
  #             }
  #             {
  #               type = "button";
  #               val = "  File Explorer      (Space + e)";
  #               on_press.__raw = "function() require('neo-tree.command').execute({ toggle = true }) end";
  #               opts = {
  #                 shortcut = "e";
  #                 hl = "Keyword";
  #                 hl_shortcut = "Number";
  #                 position = "center";
  #               };
  #             }
  #             {
  #               type = "button";
  #               val = "  Show Keybindings   (Space → wait)";
  #               on_press.__raw = "function() require('which-key').show() end";
  #               opts = {
  #                 shortcut = "?";
  #                 hl = "Keyword";
  #                 hl_shortcut = "Number";
  #                 position = "center";
  #               };
  #             }
  #             {
  #               type = "button";
  #               val = "  Quit               (Space + q)";
  #               on_press.__raw = "function() vim.cmd('quit') end";
  #               opts = {
  #                 shortcut = "q";
  #                 hl = "Keyword";
  #                 hl_shortcut = "Number";
  #                 position = "center";
  #               };
  #             }
  #           ];
  #         }
  #         {
  #           type = "padding";
  #           val = 2;
  #         }
  #         {
  #           type = "text";
  #           val = "Tip: Press <Space> and wait to see all keybindings";
  #           opts = {
  #             hl = "Comment";
  #             position = "center";
  #           };
  #         }
  #       ];
  #     };
  #
  #     # Noice: better UI for messages, command line and popup menus
  #     noice = {
  #       enable = true;
  #       settings = {
  #         lsp.override = {
  #           "vim.lsp.util.convert_input_to_markdown_lines" = true;
  #           "vim.lsp.util.stylize_markdown" = true;
  #           "cmp.entry.get_documentation" = true;
  #         };
  #         presets = {
  #           bottom_search = true;
  #           command_palette = true;
  #           long_message_to_split = true;
  #           inc_rename = false;
  #           lsp_doc_border = true;
  #         };
  #       };
  #     };
  #
  #     # Notify: nicer notification popups (used by noice)
  #     notify = {
  #       enable = true;
  #       settings = {
  #         timeout = 3000;
  #         render = "compact";
  #       };
  #     };
  #   };
  #
  #   # --------------------------------------------------------------------------
  #   # Colorscheme
  #   # --------------------------------------------------------------------------
  #   colorschemes.gruvbox = {
  #     enable = true;
  #     settings = {
  #       bold = true;
  #       italic = {
  #         strings = false;
  #         emphasis = true;
  #         comments = true;
  #       };
  #       contrast = "hard";
  #     };
  #   };
  #
  #   # --------------------------------------------------------------------------
  #   # Lua Configuration
  #   # --------------------------------------------------------------------------
  #   extraConfigLua = ''
  #     -- Auto-create undo/backup/swap directories if they don't exist
  #     local undodir = os.getenv("HOME") .. "/.local/share/nvim/undo"
  #     local backupdir = os.getenv("HOME") .. "/.local/share/nvim/backup"
  #     local swapdir = os.getenv("HOME") .. "/.local/share/nvim/swap"
  #
  #     for _, dir in ipairs({undodir, backupdir, swapdir}) do
  #       vim.fn.mkdir(dir, "p")
  #     end
  #   '';
  # };
}
