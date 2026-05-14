{
  pkgs,
  lib,
  neovim,
  writeTextDir,
  # Runtime tools
  git,
  ripgrep,
  fd,
  inputs,
  ...
}:

let
  configDir = writeTextDir "nvim/init.lua" ''
    -- ToyVo's portable Neovim config
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    -- Options
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.cursorline = true
    vim.opt.mouse = "a"
    vim.opt.scrolloff = 10
    vim.opt.signcolumn = "yes"
    vim.opt.splitbelow = true
    vim.opt.splitright = true
    vim.opt.confirm = true
    vim.opt.updatetime = 250
    vim.opt.timeoutlen = 300
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
    vim.opt.list = true

    -- Yank highlight
    vim.api.nvim_create_autocmd('TextYankPost', {
      desc = 'Highlight when yanking text',
      group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
      callback = function()
        vim.highlight.on_yank()
      end,
    })

    -- Window navigation
    vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to left window' })
    vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to lower window' })
    vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to upper window' })
    vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to right window' })

    -- Clear search
    vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

    -- Terminal escape
    vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

    -- Minimal statusline
    vim.opt.statusline = "%f %y %m%r%=%l:%c %P"
  '';
  nvfConfig = inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    {
      config.vim = {
        # Enable custom theming options
        theme.enable = true;

        # Enable Treesitter
        treesitter.enable = true;

        # Other options will go here. Refer to the config
        # reference in Appendix B of the nvf manual.
        # ...
      };
    }
  ];
};
in

lib.mkWrappedProgram pkgs {
  name = "toyvo-neovim";
  package = nvfConfig.neovim;
  binaryName = "nvim";
  inherit configDir;
  runtimeDeps = [
    git
    ripgrep
    fd
  ];
  extraBinaries = [
    "vi"
    "vim"
  ];
}
