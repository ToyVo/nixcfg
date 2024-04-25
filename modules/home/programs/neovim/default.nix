{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.programs.nvim;
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  options.programs.nvim.enable = lib.mkEnableOption "Enable nixvim";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
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
      colorschemes.catppuccin = {
        enable = true;
        settings.flavour = config.catppuccin.flavour;
      };
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
      opts = {
        number = true;
        mouse = "a";
        showmode = false;
        breakindent = true;
        undofile = true;
        ignorecase = true;
        smartcase = true;
        signcolumn = "yes";
        updatetime = 250;
        timeoutlen = 300;
        splitright = true;
        splitbelow = true;
        list = true;
        listchars = "tab:» ,trail:·,nbsp:␣";
        inccommand = "split";
        cursorline = true;
        scrolloff = 10;
        hlsearch = true;
	      foldenable = false;
      };
      autoCmd = [
        {
          event = "TextYankPost";
          command = "silent! lua vim.highlight.on_yank()";
          group = "YankHighlight";
        }
      ];
      autoGroups.YankHighlight.clear = true;
      keymaps = [
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<CR>";
        }
        {
          mode = "n";
          key = "[d";
          action = "vim.diagnostic.goto_prev";
          lua = true;
          options.desc = "Go to previous [D]iagnostic message";
        }
        {
          mode = "n";
          key = "]d";
          action = "vim.diagnostic.goto_next";
          lua = true;
          options.desc = "Go to next [D]iagnostic message";
        }
        {
          mode = "n";
          key = "<leader>e";
          action = "vim.diagnostic.open_float";
          lua = true;
          options.desc = "Show diagnostic [E]rror messages";
        }
        {
          mode = "n";
          key = "<leader>q";
          action = "vim.diagnostic.setloclist";
          lua = true;
          options.desc = "Open diagnostic [Q]uickfix list";
        }
        {
          mode="n";
          key = "<C-h>";
          action = "<C-w><C-h>";
          options.desc = "Move focus to the left window";
        }
        {
          mode="n";
          key = "<C-l>";
          action = "<C-w><C-l>";
          options.desc = "Move focus to the right window";
        }
        {
          mode="n";
          key = "<C-j>";
          action = "<C-w><C-j>";
          options.desc = "Move focus to the lower window";
        }
        {
          mode="n";
          key = "<C-k>";
          action = "<C-w><C-k>";
          options.desc = "Move focus to the upper window";
        }
        {
          mode="t";
          key = "<Esc><Esc>";
          action = "<C-\\><C-n>";
          options.desc = "Exit terminal mode";
        }
        {
          mode = "n";
          key = "<leader>sh";
          action = "require('telescope.builtin').help_tags";
          lua = true;
          options.desc = "[S]earch [H]elp";
        }
        {
          mode = "n";
          key = "<leader>sk";
          action = "require('telescope.builtin').keymaps";
          lua = true;
          options.desc = "[S]earch [K]eymaps";
        }
        {
          mode = "n";
          key = "<leader>sf";
          action = "require('telescope.builtin').find_files";
          lua = true;
          options.desc = "[S]earch [F]iles";
        }
        {
          mode = "n";
          key = "<leader>ss";
          action = "require('telescope.builtin').builtin";
          lua = true;
          options.desc = "[S]earch [S]elect Telescope";
        }
        {
          mode = "n";
          key = "<leader>sw";
          action = "require('telescope.builtin').grep_string";
          lua = true;
          options.desc = "[S]earch current [W]ord";
        }
        {
          mode = "n";
          key = "<leader>sg";
          action = "require('telescope.builtin').live_grep";
          lua = true;
          options.desc = "[S]earch by [G]rep";
        }
        {
          mode = "n";
          key = "<leader>sd";
          action = "require('telescope.builtin').diagnostics";
          lua = true;
          options.desc = "[S]earch [D]iagnostics";
        }
        {
          mode = "n";
          key = "<leader>sr";
          action = "require('telescope.builtin').resume";
          lua = true;
          options.desc = "[S]earch [R]esume";
        }
        {
          mode = "n";
          key = "<leader>s.";
          action = "require('telescope.builtin').oldfiles";
          lua = true;
          options.desc = ''[S]earch Recent Files ("." for repeat)'';
        }
        {
          mode = "n";
          key = "<leader><leader>";
          action = "require('telescope.builtin').buffers";
          lua = true;
          options.desc = "[ ] Find existing buffers";
        }
        {
          mode = "n";
          key = "gd";
          action = "require('telescope.builtin').lsp_definitions";
          lua = true;
          options.desc = "LSP: [G]oto [D]efinition";
        }
        {
          mode = "n";
          key = "gr";
          action = "require('telescope.builtin').lsp_references";
          lua = true;
          options.desc = "LSP: [G]oto [R]eferences";
        }
        {
          mode = "n";
          key = "gI";
          action = "require('telescope.builtin').lsp_implementations";
          lua = true;
          options.desc = "LSP: [G]oto [I]mplementation";
        }
        {
          mode = "n";
          key = "<leader>D";
          action = "require('telescope.builtin').lsp_type_definitions";
          lua = true;
          options.desc = "LSP: Type [D]efinition";
        }
        {
          mode = "n";
          key = "<leader>ds";
          action = "require('telescope.builtin').lsp_document_symbols";
          lua = true;
          options.desc = "LSP: [D]ocument [S]ymbols";
        }
        {
          mode = "n";
          key = "<leader>ws";
          action = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
          lua = true;
          options.desc = "LSP: [W]orkspace [S]ymbols";
        }
        {
          mode = "n";
          key = "<leader>rn";
          action = "vim.lsp.buf.rename";
          lua = true;
          options.desc = "LSP: [R]e[n]ame";
        }
        {
          mode = "n";
          key = "<leader>ca";
          action = "vim.lsp.buf.code_action";
          lua = true;
          options.desc = "LSP: [C]ode [A]ction";
        }
        {
          mode = "n";
          key = "K";
          action = "vim.lsp.buf.hover";
          lua = true;
          options.desc = "LSP: Hover Documentation";
        }
        {
          mode = "n";
          key = "gD";
          action = "vim.lsp.buf.declaration";
          lua = true;
          options.desc = "LSP: [G]oto [D]eclaration";
        }
        {
          mode = "n";
          key = "<leader>/";
          action = ''
            function()
              require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
              })
            end
          '';
          lua = true;
          options.desc = "[/] Fuzzily search in current buffer";
        }
        {
          mode = "n";
          key = "<leader>s/";
          action = ''
            function()
              require('telescope.builtin').live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
              }
            end
          '';
          lua = true;
          options.desc = "[S]earch [/] in Open Files";
        }
        {
          mode = "n";
          key = "<leader>sn";
          action = ''
            function()
              require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
            end
          '';
          lua = true;
          options.desc = "[S]earch [N]eovim files";
        }
        {
          mode = "n";
          key = "<F1>";
          action = "require('dap').step_into";
          lua = true;
          options.desc = "Debug: Step Into";
        }
        {
          mode = "n";
          key = "<F2>";
          action = "require('dap').step_over";
          lua = true;
          options.desc = "Debug: Step Over";
        }
        {
          mode = "n";
          key = "<F3>";
          action = "require('dap').step_out";
          lua = true;
          options.desc = "Debug: Step Out";
        }
        {
          mode = "n";
          key = "<F5>";
          action = "require('dap').continue";
          lua = true;
          options.desc = "Debug: Start/Continue";
        }
        {
          mode = "n";
          key = "<F7>";
          action = "require('dapui').toggle";
          lua = true;
          options.desc = "Debug: See last session result.";
        }
        {
          mode = "n";
          key = "<leader>b";
          action = "require('dap').toggle_breakpoint";
          lua = true;
          options.desc = "Debug: Toggle Breakpoint";
        }
        {
          mode = "n";
          key = "<leader>B";
          action = ''
            function()
              require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
            end
          '';
          lua = true;
          options.desc = "Debug: Set Breakpoint";
        }
      ];
      plugins = {
        comment.enable = true;
        gitsigns = {
          enable = true;
          settings.signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "_";
            topdelete.text = "‾";
            changedelete.text = "~";
          };
        };
        which-key = {
          enable = true;
          registrations = {
            "<leader>c" = { name = "[C]ode"; _ = "which_key_ignore"; };
            "<leader>d" = { name = "[D]ocument"; _ = "which_key_ignore"; };
            "<leader>r" = { name = "[R]ename"; _ = "which_key_ignore"; };
            "<leader>s" = { name = "[S]earch"; _ = "which_key_ignore"; };
            "<leader>w" = { name = "[W]orkspace"; _ = "which_key_ignore"; };
          };
        };
        telescope = {
          enable = true;
          extensions = {
            ui-select = {
              enable = true;
              settings.__raw = ''
                require('telescope.themes').get_dropdown()
              '';
            };
            fzf-native.enable = true;
          };
        };
        conform-nvim = {
          enable = true;
          notifyOnError = false;
          formattersByFt = {
            lua = [ "stylua" ];
            # Conform will run multiple formatters sequentially
            python = [ "isort" "black" ];
            # Use a sub-list to run only the first available formatter
            javascript = [ [ "prettierd" "prettier" ] ];
            # Use the "*" filetype to run formatters on all filetypes.
            "*" = [ "codespell" ];
            # Use the "_" filetype to run formatters on filetypes that don't
            # have other formatters configured.
            "_" = [ "trim_whitespace" ];
          };
        };
        lsp = {
          enable = true;
          capabilities = ''
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
          '';
          servers = {
            lua-ls.enable = true;
          };
          onAttach = ''
            if client and client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
              })
            end
          '';
        };
        cmp = {
          enable = true;
          settings= {
            snippet.expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
            completion.completeopt = "menu,menuone,noinsert";
            mapping = {
              "<C-n>" = "cmp.mapping.select_next_item()";
              "<C-p>" = "cmp.mapping.select_prev_item()";
              "<C-b>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-y>" = "cmp.mapping.confirm { select = true }";
              "<C-Space>" = "cmp.mapping.complete {}";
              "<C-l>" = ''
                cmp.mapping(function()
                  if require('luasnip').expand_or_locally_jumpable() then
                    require('luasnip').expand_or_jump()
                  end
                end, { 'i', 's' })
              '';
              "<C-h>" = ''
                cmp.mapping(function()
                  if require('luasnip').locally_jumpable(-1) then
                    require('luasnip').jump(-1)
                  end
                end, { 'i', 's' })
              '';
            };
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "path"; }
            ];
          };
        };
        todo-comments = {
          enable = true;
          signs = false;
        };
        mini = {
          enable = true;
          modules = {
            ai.n_lines = 500;
            surround = {};
            statusline.use_icons = true;
          };
        };
        treesitter = {
          enable = true;
          indent = true;
          incrementalSelection.enable = true;
          folding = true;
        };
        treesitter-context.enable = true;
        treesitter-textobjects.enable = true;
        treesitter-refactor.enable = true;
        dap = {
          enable = true;
          extensions = {
            dap-ui = {
              enable = true;
              icons = {
                expanded = "▾";
                collapsed = "▸";
                current_frame = "*";
              };
              controls.icons = {
                pause = "⏸";
                play = "▶";
                step_into = "⏎";
                step_over = "⏭";
                step_out = "⏮";
                step_back = "b";
                run_last = "▶▶";
                terminate = "⏹";
                disconnect = "⏏";
              };
            };
            dap-go.enable = true;
            dap-python.enable = true;
            dap-virtual-text.enable = true;
          };
        };
        indent-blankline.enable = true;
        lint = {
          enable = true;
          lintersByFt = {
            markdown = [ "markdownlint" ];
          };
          autoCmd.event = [ "BufEnter" "BufWritePost" "InsertLeave" ];
        };
        sleuth.enable = true;
      };
    };
  };
}
