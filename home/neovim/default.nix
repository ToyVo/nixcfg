{pkgs, lib, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      lua-language-server
      nil
      rust-analyzer
      nodePackages.eslint
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      impatient-nvim
      lualine-lsp-progress
      nvim-treesitter-textobjects
      nvim-ts-context-commentstring
      undotree
      vim-fugitive
      vim-sleuth
      vim-bbye
      vim-illuminate
      nvim-web-devicons
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lua
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      cmp-copilot
      copilot-vim
      luasnip
      friendly-snippets
      nvim-ts-autotag
      plenary-nvim
      sqlite-lua
      nvim-dap
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
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
        '';
      }
      {
        plugin = gruvbox-nvim;
        type = "lua";
        config = ''
          vim.cmd.colorscheme('gruvbox');
        '';
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = lib.fileContents ./treesitter.lua;
      }
      {
        plugin = nvim-treesitter-context;
        type = "lua";
        config = ''
          require('treesitter-context').setup();
        '';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup();
        '';
      }
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require('Comment').setup();
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = lib.fileContents ./lsp.lua;
      }
      {
        plugin = nvim-cmp;
        type = "lua";
        config = lib.fileContents ./cmp.lua;
      }
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          require('nvim-tree').setup();
        '';
      }
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = ''
          local rt = require('rust-tools')
          rt.setup({
            server = {
              on_attach = function(_, bufnr)
                -- Hover actions
                vim.keymap.set('n', '<C-space>', rt.hover_actions.hover_actions, { buffer = bufnr })
                -- Code action groups
                vim.keymap.set('n', '<leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
              end,
            },
          })
        '';
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require('nvim-autopairs').setup({
            check_ts = true,
            fast_wrap = {},
          });
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          require('telescope').setup();
        '';
      }
      {
        plugin = telescope-ui-select-nvim;
        type = "lua";
        config = ''
          require('telescope').load_extension('ui-select');
        '';
      }
      {
        plugin = telescope-frecency-nvim;
        type = "lua";
        config = ''
          require('telescope').load_extension('frecency');
        '';
      }
      {
        plugin = telescope-dap-nvim;
        type = "lua";
        config = ''
          require('telescope').load_extension('dap');
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
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
        '';
      }
    ];
    extraLuaConfig = lib.fileContents ./init.lua;
  };
}
