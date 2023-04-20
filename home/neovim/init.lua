-- this init.lua comes first in the actual init.lua, and impatient.nvim should be loaded at the top
require('impatient');

-- Options
vim.opt.number = true;
vim.opt.relativenumber = true;
vim.opt.tabstop = 2;
vim.opt.softtabstop = 2;
vim.opt.shiftwidth = 2;
vim.opt.expandtab = true;
vim.opt.smartindent = true;
vim.opt.wrap = false;
vim.opt.swapfile = false;
vim.opt.backup = false;
vim.opt.undofile = true;
vim.opt.termguicolors = true;
vim.opt.scrolloff = 8;
vim.opt.sidescrolloff = 8;
vim.opt.signcolumn = 'yes';
vim.opt.isfname:append('@-@');
vim.opt.iskeyword:append('-');
vim.opt.mouse = 'a';
vim.opt.breakindent = true;
vim.opt.ignorecase = true;
vim.opt.smartcase = true;
vim.opt.updatetime = 250;
vim.opt.colorcolumn = '80,100';
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' };
vim.opt.list = true;
vim.opt.listchars:append('space:⋅');
vim.opt.listchars:append('eol:↴');
vim.opt.splitbelow = true;
vim.opt.splitright = true;
vim.opt.clipboard = 'unnamedplus';
vim.opt.pumheight = 10;
vim.opt.showmode = false;
vim.opt.showtabline = 2;
vim.opt.cursorline = true;
vim.opt.guifont = 'FiraCode Nerd Font:h16';
vim.opt.foldmethod = 'expr';
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()';
vim.opt.foldenable = false;
vim.opt.timeout = true;
vim.opt.timeoutlen = 300;
vim.keymap.set('', '<space>', '<Nop>', { silent = true });
vim.g.mapleader = ' ';
vim.g.maplocalleader = ' ';
vim.g.loaded_netrw = 1;
vim.g.loaded_netrwPlugin = 1;

-- Set wrap and spell in markdown and gitcommit
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true;
    vim.opt_local.spell = true;
  end,
});

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true });
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank();
  end,
  group = highlight_group,
  pattern = '*',
});

-- Shift HL to change buffers
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>');
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>');

-- Control hjkl to move between windows including terminal
vim.keymap.set('n', '<C-h>', '<C-w>h');
vim.keymap.set('n', '<C-j>', '<C-w>j');
vim.keymap.set('n', '<C-k>', '<C-w>k');
vim.keymap.set('n', '<C-l>', '<C-w>l');
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h');
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j');
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k');
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l');

-- Overwrite text in visual mode without overwriting the clipboard
vim.keymap.set('v', 'p', '"_dP');

vim.keymap.set('n', '<leader>pf', '<cmd>Telescope find_files<cr>', { desc = 'Project Files'});
vim.keymap.set('n', '<leader>ps', '<cmd>Telescope live_grep<cr>', { desc = 'Project Search'});
vim.keymap.set('n', '<leader>pv', '<cmd>NvimTreeToggle<CR>', { desc = 'Project View' });
vim.keymap.set('n', '<C-p>', '<cmd>Telescope git_files<cr>', { desc = 'Git Files'});
vim.keymap.set('n', '<leader>u', '<cmd>UndoTreeToggle<CR>', { desc = 'UndoTree' });

local opts = { noremap = true, silent = true };
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, opts);
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts);
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts);
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts);

-- When I open neovide from an application launcher, it opens in /, so I change it to ~
-- this means I can't do `neovide /` in the shell
if vim.g.neovide then
  vim.g.neovide_transparency = 0.9;
  if vim.fn.getcwd() == '/' then
    vim.cmd('cd ~');
  end
end

