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
      colorschemes.catppuccin.enable = true;
      colorschemes.catppuccin.flavour = "frappe";
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
        neovide_transparency = 0.9;
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
    };
  };
}
