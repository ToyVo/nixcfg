{ pkgs, config, lib, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.neovim.enable = lib.mkEnableOption "Custom Neovim";

  config = lib.mkIf cfg.packages.neovim.enable {
    programs.nixvim = {
      enable = true;
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
      };
      autoGroups = {
      };
      autoCmd = [
      ];
      keymaps = [
        { mode = "n"; key = "<leader>h"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear Highlight"; }
        { mode = "n"; key = "<c-n>"; action = "<cmd>Neotree %<cr>"; options.desc = "Open neo-tree"; }
        { mode = "n"; key = "<c-p>"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Open file picker"; }
        { mode = "n"; key = "<leader><space>"; action = "<cmd>Telescope oldfiles<cr>"; options.desc = "Open recent files"; }
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
