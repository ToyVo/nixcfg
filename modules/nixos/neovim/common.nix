{ pkgs, config, lib, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.neovim.enable = lib.mkEnableOption "Custom Neovim";

  config = lib.mkIf cfg.packages.neovim.enable {
    programs.nixvim = {
      enable = true;
      enableMan = false;
      luaLoader.enable = true;
      viAlias = true;
      vimAlias = true;
      wrapRc = true;
      clipboard.register = "unnamedplus";
      colorschemes.gruvbox.enable = true;
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
      };
      options = {
        cursorline = true;
        autoread = true;
        tabstop = 2;
        shiftwidth = 2;
        shiftround = true;
        expandtab = true;
        termguicolors = true;
      };
      plugins = {
        # Flie Tree
        neo-tree = {
          enable = true;
          closeIfLastWindow = true;
        };

        # Status Line
        lualine = {
          enable = true;
          sections.lualine_a = [{
            name = "filename";
            extraConfig.path = 1;
          }];
        };

        treesitter = {
          enable = true;
        };
        telescope = {
          enable = true;
        };
        copilot-lua = {
          suggestion.enabled = false;
          panel.enabled = false;
        };
        which-key = {
          enable = true;
        };
        
        # Completion
        nvim-cmp = {
          enable = true;
          sources = [
            {
              name = "nvim_lsp";
            }
            {
              name = "vsnip";
            }
            {
              name = "buffer";
            }
            {
              name = "git";
            }
            {
              name = "cmdline";
            }
            {
              name = "crates";
            }
            {
              name = "npm";
            }
            {
              name = "dap";
            }
            {
              name = "emoji";
            }
            {
              name = "copilot";
            }
          ];
        };
      };
      autoGroups = {
      };
      autoCmd = [
      ];
      keymaps = [
        { mode = "n"; key = "<leader>H"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear Highlight"; }
        { mode = "n"; key = "<leader>t"; action = "<cmd>Neotree toggle<cr>"; options.desc = "Toggle neo-tree"; }
        { mode = "n"; key = "<leader><space>"; action = "<cmd>Telescope oldfiles<cr>"; options.desc = "Open recent files"; }
        # Helix inspired keybindings
        { mode = "n"; key = "<leader>f"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Open file picker"; }
        { mode = "n"; key = "<leader>F"; action = ""; options.desc = "Open file picker at current working directory"; }
        { mode = "n"; key = "<leader>b"; action = ""; options.desc = "Open buffer picker"; }
        { mode = "n"; key = "<leader>j"; action = ""; options.desc = "Open jumplist picker"; }
        { mode = "n"; key = "<leader>g"; action = ""; options.desc = "Debug (experimental)"; }
        { mode = "n"; key = "<leader>k"; action = ""; options.desc = "Show documentation for item under cursor in a popup (LSP)"; }
        { mode = "n"; key = "<leader>s"; action = ""; options.desc = "Open document symbol picker (LSP)"; }
        { mode = "n"; key = "<leader>S"; action = ""; options.desc = "Open workspace symbol picker (LSP)"; }
        { mode = "n"; key = "<leader>d"; action = ""; options.desc = "Open document diagnostics picker (LSP)"; }
        { mode = "n"; key = "<leader>D"; action = ""; options.desc = "Open workspace diagnostics picker (LSP)"; }
        { mode = "n"; key = "<leader>r"; action = ""; options.desc = "Rename symbol (LSP)"; }
        { mode = "n"; key = "<leader>a"; action = ""; options.desc = "Apply code action (LSP)"; }
        { mode = "n"; key = "<leader>h"; action = ""; options.desc = "Select symbol references (LSP)"; }
        { mode = "n"; key = "<leader>'"; action = ""; options.desc = "Open last fuzzy picker"; }
        { mode = "n"; key = "<leader>w"; action = ""; options.desc = "Enter window mode"; }
        { mode = "n"; key = "<leader>p"; action = ""; options.desc = "Paste system clipboard after selections"; }
        { mode = "n"; key = "<leader>P"; action = ""; options.desc = "Paste system clipboard before selections"; }
        { mode = "n"; key = "<leader>y"; action = ""; options.desc = "Yank selections to clipboard"; }
        { mode = "n"; key = "<leader>Y"; action = ""; options.desc = "Yank main selection to clipboard"; }
        { mode = "n"; key = "<leader>R"; action = ""; options.desc = "Replace selections by clipboard contents"; }
        { mode = "n"; key = "<leader>/"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Global search in workspace folder"; }
        { mode = "n"; key = "<leader>?"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Open command palette"; }
      ];
      extraPlugins = with pkgs.vimPlugins; [
      ];
      extraConfigLua = ''
      '';
    };
  };
}
