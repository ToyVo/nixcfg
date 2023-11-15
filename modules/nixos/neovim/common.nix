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
      keymaps = [
        # Shift HL to change buffers
        { key = "<S-h>"; action = "<cmd>bprevious<cr>"; mode = "n"; }
        { key = "<S-l>"; action = "<cmd>bnext<cr>"; mode = "n"; }
        # Control hjkl to move between windows including terminal
        { key = "<C-h>"; action = "<C-w>h"; mode = "n"; }
        { key = "<C-j>"; action = "<C-w>j"; mode = "n"; }
        { key = "<C-k>"; action = "<C-w>k"; mode = "n"; }
        { key = "<C-l>"; action = "<C-w>l"; mode = "n"; }
        { key = "<leader>h"; action = "<cmd>nohlsearch<cr>"; mode = "n"; options.desc = "Clear highlight"; }
        { key = "<leader>pf"; action = "<cmd>Telescope find_files<cr>"; mode = "n"; options.desc = "Project Files"; }
        { key = "<leader>ps"; action = "<cmd>Telescope live_grep<cr>"; mode = "n"; options.desc = "Project Search"; }
        { key = "<leader>vh"; action = "<cmd>Telescope help_tags<cr>"; mode = "n"; options.desc = "Help Tags"; }
        { key = "<C-p>"; action = "<cmd>Telescope git_files<cr>"; mode = "n"; options.desc = "Git Files"; }
        { key = "<leader>pi"; action = "<cmd>TroubleToggle quickfix<cr>"; mode = "n"; options.desc = "Project Issues"; }
        { key = "<leader>pv"; action = "<cmd>NvimTreeToggle<cr>"; mode = "n"; options.desc = "Project View"; }
        { key = "<leader>u"; action = "<cmd>UndoTreeToggle<cr>"; mode = "n"; options.desc = "UndoTree"; }
        { key = "<leader>gs"; action = "<cmd>Git<cr>"; mode = "n"; options.desc = "Git"; }
        # Keep centered
        { key = "J"; action = "mzJ`z"; mode = "n"; }
        { key = "<C-d>"; action = "<C-d>zz"; mode = "n"; }
        { key = "<C-u>"; action = "<C-u>zz"; mode = "n"; }
        { key = "n"; action = "nzzzv"; mode = "n"; }
        { key = "N"; action = "Nzzzv"; mode = "n"; }
        # Convenience
        { key = "Q"; action = "<nop>"; mode = "n"; }
        # Diagnostics
        { key = "<leader>e"; action = "vim.diagnostic.open_float"; lua = true; mode = "n"; }
        { key = "[d"; action = "vim.diagnostic.goto_prev"; lua = true; mode = "n"; }
        { key = "]d"; action = "vim.diagnostic.goto_next"; lua = true; mode = "n"; }
        { key = "<leader>q"; action = "vim.diagnostic.setloclist"; lua = true; mode = "n"; }
        # remap U to <C-r> for redo
        { key = "U"; action = "<C-r>"; mode = "n"; }
        { key = "<C-c>"; action = "<Esc>"; mode = "i"; }
        # Overwrite text in visual mode without overwriting the clipboard
        { key = "p"; action = ''"_dP''; mode = "v"; }
        # Move highlighted text
        { key = "J"; action = ":m '>+1<CR>gv=gv"; mode = "v"; }
        { key = "K"; action = ":m '<-2<CR>gv=gv"; mode = "v"; }
        { key = "<C-h>"; action = "<C-\\><C-n><C-w>h"; mode = "t"; }
        { key = "<C-j>"; action = "<C-\\><C-n><C-w>j"; mode = "t"; }
        { key = "<C-k>"; action = "<C-\\><C-n><C-w>k"; mode = "t"; }
        { key = "<C-l>"; action = "<C-\\><C-n><C-w>l"; mode = "t"; }
        # default mode is normal-visual-op
        { key = "<space>"; action = "<Nop>"; options.silent = true; }
      ];
      options = {
        number = true;
        relativenumber = true;
        tabstop = 4;
        softtabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        smartindent = true;
        wrap = false;
        swapfile = false;
        backup = false;
        undofile = true;
        termguicolors = true;
        scrolloff = 8;
        sidescrolloff = 8;
        signcolumn = "yes";
        mouse = "a";
        breakindent = true;
        ignorecase = true;
        smartcase = true;
        updatetime = 250;
        colorcolumn = "80,100";
        completeopt = "menu,menuone,noinsert";
        list = true;
        splitbelow = true;
        splitright = true;
        clipboard = "unnamedplus";
        pumheight = 10;
        showmode = false;
        showtabline = 2;
        cursorline = true;
        guifont = "Monaspace Neon:h16";
        guifontwide = "Symbols Nerd Font:h16";
        foldmethod = "expr";
        foldexpr = "nvim_treesitter#foldexpr()";
        foldenable = false;
        timeout = true;
        timeoutlen = 300;
        background = "dark";
        isfname = "@,48-57,/,.,-,_,+,,,#,$,%,~,=,@-@";
        iskeyword = "@,48-57,_,192-255,-";
        listchars = "tab:> ,trail:-,nbsp:+,space:⋅,eol:↴";
        shiftround = true;
      };
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
      };
      autoCmd = [
        {
          event = [ "FileType" ];
          pattern = [ "gitcommit" "markdown" ];
          callback = {
            __raw = ''
              function() 
                vim.opt_local.wrap = true
                vim.opt_local.spell = true
              end
            '';
          };
        }
        {
          event = [ "TextYankPost" ];
          pattern = [ "*" ];
          callback = {
            __raw = ''
              function() 
                vim.highlight.on_yank() 
              end
            '';
          };
          group = "YankHighlight";
        }
        {
          event = [ "LspAttach" ];
          callback = {
            __raw = ''
              function(ev) 
                vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf })
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
                vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf })
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf })
                vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, { buffer = ev.buf })
                vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { buffer = ev.buf })
                vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf })
                vim.keymap.set("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { buffer = ev.buf })
                vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { buffer = ev.buf })
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf })
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf })
                vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf })
                vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { buffer = ev.buf })
                if vim.lsp.buf.range_code_action then
                  vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { buffer = ev.buf })
                  vim.keymap.set("x", "<leader>ca", function() vim.lsp.buf.range_code_action() end, { buffer = ev.buf })
                else
                  vim.keymap.set({ "n", "x" }, "<leader>ca", function() vim.lsp.buf.code_action() end, { buffer = ev.buf })
                end
              end
            '';
          };
          group = "UserLspConfig";
        }
      ];
      autoGroups = {
        YankHighlight.clear = true;
        UserLspConfig.clear = true;
      };
      plugins.harpoon = {
        # enable = true;
        keymaps.addFile = "<leader>a";
        keymaps.toggleQuickMenu = "<C-e>";
        keymaps.navFile = {
          "1" = "<C-1>";
          "2" = "<C-2>";
          "3" = "<C-3>";
          "4" = "<C-4>";
        };
      };
      plugins.which-key = {
        enable = true;
        plugins.spelling.enabled = true;
      };
      plugins.lsp = {
        enable = true;
        servers.tsserver.enable = true;
        servers.eslint.enable = true;
        servers.nil_ls.enable = true;
        servers.cssls.enable = true;
        servers.jsonls.enable = true;
        servers.html.enable = true;
        servers.lua-ls.enable = true;
      };
      plugins.nvim-cmp = {
        enable = true;
        preselect = "None";
        snippet.expand = "luasnip";
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "copilot"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "nvim_lua"; }
          { name = "crates"; }
        ];
        formatting = {
          fields = [ "abbr" "kind" "menu" ];
        };
        mappingPresets = [ "insert" "cmdline" ];
        mapping."<CR>".modes = [ "i" "s" "c" ];
        mapping."<CR>".action = ''
          function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end
        '';
      };
      plugins.lspkind = {
        enable = true;
        cmp.enable = true;
        cmp.maxWidth = 50;
        cmp.ellipsisChar = "...";
        mode = "symbol";
        symbolMap = {
          Copilot = "";
        };
      };
      plugins.telescope = {
        enable = true;
        extensions.frecency.enable = true;
      };
      plugins.lualine = {
        enable = true;
        sections.lualine_b = [ "branch" "diff" "diagnostics" ];
        sections.lualine_c = [ "filename" "lsp_progress" ];
        sections.lualine_x = [ "encoding" "fileformat" "filetype" ];
      };
      plugins.nvim-autopairs = {
        enable = true;
        checkTs = true;
      };
      plugins.none-ls = {
        enable = true;
        sources.formatting.stylua.enable = true;
        sources.formatting.prettier.enable = true;
        sources.formatting.nixpkgs_fmt.enable = true;
        sources.formatting.taplo.enable = true;
        #sources.diagnostics.eslint.enable = true;
        #sources.completion.spell.enable = true;
      };
      plugins.copilot-lua = {
        enable = true;
        suggestion.enabled = false;
        panel.enabled = false;
      };
      plugins.rust-tools.enable = true;
      plugins.gitsigns.enable = true;
      # consider alternative of commentary
      plugins.comment-nvim.enable = true;
      plugins.nvim-tree.enable = true;
      plugins.copilot-cmp.enable = true;
      plugins.treesitter-context.enable = true;
      plugins.ts-context-commentstring.enable = true;
      plugins.barbar.enable = true;

      extraPlugins = with pkgs.vimPlugins; [
        lualine-lsp-progress
        nvim-treesitter-textobjects
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
        lspkind-nvim
        crates-nvim
        trouble-nvim
        luasnip
        friendly-snippets
        nvim-ts-autotag
        plenary-nvim
        sqlite-lua
        nvim-dap
        telescope-ui-select-nvim
        telescope-dap-nvim
        gruvbox-nvim
      ];
      extraConfigLua = ''
        do
          -- When I open neovide from an application launcher, it opens in /, so I change it to ~
          -- this means I can't do `neovide /` in the shell
          local gruvbox = require("gruvbox");
          if vim.g.neovide then
            vim.g.neovide_transparency = 0.9;
            if vim.fn.getcwd() == "/" then
              vim.cmd("cd ~");
            end
            gruvbox.setup();
          else
            gruvbox.setup({
              transparent_mode = true;
            });
          end
          vim.cmd("colorscheme gruvbox")
        end

        do
          local cmp = require("cmp");
          cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
              { name = "cmp_git" },
              { name = "buffer" },
            }),
          });
          cmp.setup.cmdline ({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline (),
            sources = { { name = "buffer" } },
          });
          cmp.setup.cmdline (":", {
            mapping = cmp.mapping.preset.cmdline (),
            sources = cmp.config.sources({
              { name = "path" },
              { name = "cmdline" },
            }),
          });
          cmp.event:on ("confirm_done", require ("nvim-autopairs.completion.cmp").on_confirm_done ())
        end

        do
          require ("telescope").load_extension("ui-select");
          require("telescope").load_extension("dap");
        end

        do
          require("nvim-treesitter.configs").setup({
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
                  ["@parameter.outer"] = "v", -- charwise
                  ["@function.outer"] = "V", -- linewise
                  ["@class.outer"] = "<c-v>", -- blockwise
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
                  ["<leader>sn"] = "@parameter.inner",
                },
                swap_previous = {
                  ["<leader>sp"] = "@parameter.inner",
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
                border = "none",
                peek_definition_code = {
                  ["<leader>df"] = "@function.outer",
                  ["<leader>dF"] = "@class.outer",
                },
              },
            },
          });
        end
      '';
    };
  };
}
