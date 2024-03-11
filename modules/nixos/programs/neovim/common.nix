{ config, lib, pkgs, ... }:
let
  cfg = config.programs.nvim;
in
{
  options.programs.nvim.enable = lib.mkEnableOption "Enable nixvim";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nixd
      nixpkgs-fmt
    ];
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
        autoread = true;
        background = "dark";
        backup = false;
        breakindent = true;
        completeopt = "menu,menuone,noinsert,noselect,preview";
        colorcolumn = "80,100";
        cursorline = true;
        expandtab = true;
        guifont = "MonaspiceNe Nerd Font:h16";
        ignorecase = true;
        list = true;
        mouse = "a";
        number = true;
        relativenumber = true;
        scrolloff = 8;
        shiftround = true;
        shiftwidth = 2;
        showmode = false;
        showtabline = 2;
        sidescrolloff = 8;
        signcolumn = "yes";
        smartcase = true;
        smartindent = true;
        softtabstop = 2;
        splitbelow = true;
        splitright = true;
        swapfile = false;
        tabstop = 2;
        termguicolors = true;
        timeoutlen = 300;
        undofile = true;
        updatetime = 250;
      };

      autoCmd = [
        {
          event = "TextYankPost";
          command = "silent! lua vim.highlight.on_yank()";
          group = "YankHighlight";
        }
        {
          event = "BufWritePre";
          command = "%s/\\s\\+$//e";
          group = "FixUp";
        }
      ];
      autoGroups.YankHighlight.clear = true;
      autoGroups.FixUp.clear = true;

      extraConfigLua = ''
        if vim.g.neovide then
          vim.g.neovide_transparency = 0.9;
          -- When I open neovide from an application launcher, it opens in /, so I change it to ~
          -- this means I can't do `neovide /` in the shell
          if vim.fn.getcwd() == "/" then
            vim.cmd("cd ~");
          end
        else
          require("gruvbox").setup({
            transparent_mode = true,
          });
          vim.cmd("colorscheme gruvbox");
        end
      '';
    };
  };
}
