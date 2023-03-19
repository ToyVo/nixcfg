require('impatient');

-- Options
vim.cmd.colorscheme('gruvbox');
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
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.keymap.set("n", "<leader>u", "<cmd>UndoTreeToggle<CR>")
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
vim.keymap.set('n', '<S-r>', '<cmd>bprevious<cr>');
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>');
vim.keymap.set('n', '<C-h>', '<C-w>h');
vim.keymap.set('n', '<C-j>', '<C-w>j');
vim.keymap.set('n', '<C-k>', '<C-w>k');
vim.keymap.set('n', '<C-l>', '<C-w>l');
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set("v", "p", '"_dP')

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- plugins
require('gitsigns').setup();
require('Comment').setup();
require('treesitter-context').setup();

require('which-key').setup({
  plugins = {
    spelling = {
      enabled = true,
    },
  },
  window = {
    border = 'rounded',
  },
});

require('nvim-tree').setup();

require('lualine').setup({
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename', 'lsp_progress' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  tabline = {
    lualine_a = { 'buffers' },
  },
});

require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = true,
    },
    swap = {
      enable = true,
      swap_next = {
            ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
            ["<leader>A"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
      },
      goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
      },
      goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
      },
    },
    lsp_interop = {
      enable = true,
      border = 'none',
      peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dF"] = "@class.outer",
      },
    },
  },
});

local telescope = require('telescope');
telescope.setup();
telescope.load_extension('ui-select');
telescope.load_extension('frecency');
telescope.load_extension('dap');

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig');

local servers = { 'nil_ls', 'rust_analyzer', 'eslint', 'tsserver', 'jsonls' };
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    capabilities = capabilities,
    on_attach = on_attach,
  });
end
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
});

local luasnip = require('luasnip');
local cmp = require('cmp');

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
        ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'copilot' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim_lua' },
  })
})

cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },
    { name = 'buffer' },
  })
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
    { name = 'cmdline' },
  })
})

require('nvim-autopairs').setup({
  check_ts = true,
  fast_wrap = {},
});
cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done());

local rt = require("rust-tools")
rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})
