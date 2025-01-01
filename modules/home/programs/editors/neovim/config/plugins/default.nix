{
  plugins = {
    lazy.enable = true;
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
    web-devicons.enable = true;
    conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = false;
        formatters_by_ft = {
          lua = [ "stylua" ];
          # Conform will run multiple formatters sequentially
          python = [
            "isort"
            "black"
          ];
          # Use a sub-list to run only the first available formatter
          javascript = [
            [
              "prettierd"
              "prettier"
            ]
          ];
          # Use the "*" filetype to run formatters on all filetypes.
          "*" = [ "codespell" ];
          # Use the "_" filetype to run formatters on filetypes that don't
          # have other formatters configured.
          "_" = [ "trim_whitespace" ];
        };
      };
    };
    lsp = {
      enable = true;
      capabilities = ''
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      '';
      # servers = {
      #   lua-ls.enable = true;
      # };
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
      settings = {
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
      settings.signs = false;
    };
    mini = {
      enable = true;
      modules = {
        ai.n_lines = 500;
        surround = { };
        statusline.use_icons = true;
      };
    };
    treesitter = {
      enable = true;
      settings = {
        indent.enable = true;
        incremental_selection.enable = true;
      };
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
      autoCmd.event = [
        "BufEnter"
        "BufWritePost"
        "InsertLeave"
      ];
    };
    sleuth.enable = true;
  };
}
