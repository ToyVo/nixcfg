{ config, lib, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.neovim.enable = lib.mkEnableOption "Custom Neovim";

  config = lib.mkIf cfg.packages.neovim.enable {
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
      ];
      autoGroups.YankHighlight.clear = true;

      plugins = {
        barbar.enable = true;

        comment-nvim.enable = true;

        copilot-lua = {
          suggestion.enabled = false;
          panel.enabled = false;
        };


        gitsigns.enable = true;

        illuminate.enable = true;

        lsp = {
          enable = true;
          servers = {
            cssls.enable = true;
            eslint.enable = true;
            html.enable = true;
            jsonls.enable = true;
            lua-ls.enable = true;
            nixd.enable = true;
            rust-analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            tsserver.enable = true;
          };
          keymaps = {
            diagnostic = {
              "[d" = { action = "goto_prev"; desc = "Goto Previous Diagnostic"; };
              "]d" = { action = "goto_next"; desc = "Goto Next Diagnostic"; };
              "<space>d" = { action = "open_float"; desc = "Open Diagnostic Float"; };
            };
            lspBuf = {
              "gD" = { action = "declaration"; desc = "Goto Declaration"; };
              "gd" = { action = "definition"; desc = "Goto Definition"; };
              "K" = { action = "hover"; desc = "Hover"; };
              "gi" = { action = "implementation"; desc = "Goto Implementation"; };
              "<C-k>" = { action = "signature_help"; desc = "Signature Help"; };
              "<space>D" = { action = "type_definition"; desc = "Goto Type Definition"; };
              "<space>rn" = { action = "rename"; desc = "Rename"; };
              "<space>ca" = { action = "code_action"; desc = "Code Action"; };
              "gr" = { action = "references"; desc = "Goto References"; };
              "<space>f" = { action = "format"; desc = "Format"; };
              "<space>S" = { action = "workspace_symbol"; desc = "Open workspace symbol picker"; };
            };
          };
        };

        lspkind = {
          enable = true;
          symbolMap = {
            Copilot = "";
          };
        };

        lualine = {
          enable = true;
          sections.lualine_c = [
            {
              name = "filename";
              extraConfig.path = 1;
            }
            "lsp_progress"
          ];
        };

        neogit.enable = true;

        neo-tree = {
          enable = true;
          closeIfLastWindow = true;
        };

        noice.enable = true;

        none-ls = {
          enable = true;
          sources.formatting.stylua.enable = true;
          sources.formatting.prettier.enable = true;
          sources.formatting.prettier.disableTsServerFormatter = true;
          sources.formatting.nixpkgs_fmt.enable = true;
          sources.formatting.taplo.enable = true;
          sources.diagnostics.eslint.enable = true;
        };

        nvim-autopairs = {
          enable = true;
          checkTs = true;
        };

        nvim-cmp = {
          enable = true;
          #preselect = "None";
          snippet.expand = "luasnip";
          mappingPresets = [ "insert" "cmdline" ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            #"<Tab>" = {
            #  modes = ["i" "s"];
            #  action = ''
            #    function(fallback)
            #      if cmp.visible() then
            #        cmp.select_next_item()
            #      elseif luasnip.expandable() then
            #        luasnip.expand()
            #      elseif luasnip.expand_or_jumpable() then
            #        luasnip.expand_or_jump()
            #      elseif check_backspace() then
            #        fallback()
            #      else
            #        fallback()
            #      end
            #    end
            #  '';
            #};
            #"<CR>" = {
            #  modes = [ "i" "s" "c" ];
            #  action = ''
            #    function(fallback)
            #      if cmp.visible() and cmp.get_active_entry() then
            #        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            #      else
            #        fallback()
            #      end
            #    end
            #  '';
            #};
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "vsnip"; }
            { name = "buffer"; }
            { name = "git"; }
            { name = "cmdline"; }
            { name = "crates"; }
            { name = "npm"; }
            { name = "dap"; }
            { name = "emoji"; }
            { name = "copilot"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "nvim_lua"; }
          ];
        };

        rust-tools.enable = true;

        telescope = {
          enable = true;
          extensions.frecency.enable = true;
        };

        treesitter = {
          enable = true;
          indent = true;
          incrementalSelection.enable = true;
        };

        treesitter-context.enable = true;

        treesitter-textobjects.enable = true;

        trouble.enable = true;

        ts-autotag.enable = true;

        ts-context-commentstring.enable = true;

        undotree.enable = true;

        vim-bbye.enable = true;

        which-key = {
          enable = true;
          plugins.spelling.enabled = true;
        };
      };
      keymaps = [
        # Control hjkl to move between windows including terminal
        { mode = "n"; key = "<c-h>"; action = "<cmd>wincmd h<cr>"; options.desc = "Window left"; }
        { mode = "n"; key = "<c-j>"; action = "<cmd>wincmd j<cr>"; options.desc = "Window down"; }
        { mode = "n"; key = "<c-k>"; action = "<cmd>wincmd k<cr>"; options.desc = "Window up"; }
        { mode = "n"; key = "<c-l>"; action = "<cmd>wincmd l<cr>"; options.desc = "Window right"; }
        { key = "<C-h>"; action = "<C-\\><C-n><C-w>h"; mode = "t"; }
        { key = "<C-j>"; action = "<C-\\><C-n><C-w>j"; mode = "t"; }
        { key = "<C-k>"; action = "<C-\\><C-n><C-w>k"; mode = "t"; }
        { key = "<C-l>"; action = "<C-\\><C-n><C-w>l"; mode = "t"; }

        # Shift HL to change buffers
        { key = "<S-h>"; action = "<cmd>bprevious<cr>"; mode = "n"; }
        { key = "<S-l>"; action = "<cmd>bnext<cr>"; mode = "n"; }

        # Keep centered
        { key = "J"; action = "mzJ`z"; mode = "n"; }
        { key = "<C-d>"; action = "<C-d>zz"; mode = "n"; }
        { key = "<C-u>"; action = "<C-u>zz"; mode = "n"; }
        { key = "n"; action = "nzzzv"; mode = "n"; }
        { key = "N"; action = "Nzzzv"; mode = "n"; }

        # remap U to <C-r> for redo
        { key = "U"; action = "<C-r>"; mode = "n"; }
        { mode = "n"; key = "<leader>H"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear Highlight"; }

        # Overwrite text in visual mode without overwriting the clipboard
        { key = "p"; action = ''"_dP''; mode = "v"; }

        # Move highlighted text
        { key = "J"; action = ":m '>+1<CR>gv=gv"; mode = "v"; }
        { key = "K"; action = ":m '<-2<CR>gv=gv"; mode = "v"; }

        { mode = "n"; key = "<leader>t"; action = "<cmd>Neotree toggle<cr>"; options.desc = "Toggle neo-tree"; }
        { mode = "n"; key = "<leader>F"; action = "<cmd>Neotree filesystem reveal left"; options.desc = "Open neo-tree at current file"; }

        # Finders
        { mode = "n"; key = "<leader><space>"; action = "<cmd>Telescope oldfiles<cr>"; options.desc = "Open recent files"; }
        { mode = "n"; key = "<leader>f"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Open file picker"; }
        { mode = "n"; key = "<leader>b"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Open buffer picker"; }
        { mode = "n"; key = "<leader>'"; action = "<cmd>Telescope pickers"; options.desc = "Open last fuzzy picker"; }
        { mode = "n"; key = "<leader>/"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Global search in workspace folder"; }
        { mode = "n"; key = "<leader>?"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Open command palette"; }
        { key = "<C-p>"; action = "<cmd>Telescope git_files<cr>"; mode = "n"; options.desc = "Git Files"; }
      ];
      extraPlugins = with pkgs.vimPlugins; [
        lualine-lsp-progress
        vim-sleuth
      ];
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
