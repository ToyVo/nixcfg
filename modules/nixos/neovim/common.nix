{ pkgs, config, lib, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.neovim.enable = lib.mkEnableOption "Custom Neovim";

  config = lib.mkIf cfg.packages.neovim.enable {
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
        cursorline = true;
        autoread = true;
        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        shiftround = true;
        expandtab = true;
        termguicolors = true;
        number = true;
        relativenumber = true;
      };
      plugins = {
        # Flie Tree
        neo-tree = {
          enable = true;
          closeIfLastWindow = true;
        };

        # Status Line
        lualine = {
          enable = true;
          sections.lualine_c = [{
            name = "filename";
            extraConfig.path = 1;
          }];
        };

        treesitter = {
          enable = true;
          indent = true;
        };
        telescope = {
          enable = true;
        };
        copilot-lua = {
          suggestion.enabled = false;
          panel.enabled = false;
        };
        which-key = {
          enable = true;
        };

        noice.enable = true;

        lsp = {
          enable = true;
          servers = {
            cssls.enable = true;
            eslint.enable = true;
            html.enable = true;
            jsonls.enable = true;
            lua-ls.enable = true;
            nil_ls.enable = true;
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
              "<space>r" = { action = "rename"; desc = "Rename"; };
              "<space>a" = { action = "code_action"; desc = "Code Action"; };
              "gr" = { action = "references"; desc = "Goto References"; };
              "<space>f" = { action = "format"; desc = "Format"; };
              "<space>S" = { action = "workspace_symbol"; desc = "Open workspace symbol picker"; };
            };
          };
        };

        lspkind.enable = true;
        
        # Completion
        nvim-cmp = {
          enable = true;
          mappingPresets = [ "insert" "cmdline" ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = {
              modes = ["i" "s"];
              action = ''
                function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expandable() then
                    luasnip.expand()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  elseif check_backspace() then
                    fallback()
                  else
                    fallback()
                  end
                end
              '';
            };
          };
          sources = [
            {
              name = "nvim_lsp";
            }
            {
              name = "vsnip";
            }
            {
              name = "buffer";
            }
            {
              name = "git";
            }
            {
              name = "cmdline";
            }
            {
              name = "crates";
            }
            {
              name = "npm";
            }
            {
              name = "dap";
            }
            {
              name = "emoji";
            }
            {
              name = "copilot";
            }
          ];
        };
      };
      keymaps = [
        { mode = "n"; key = "<c-h>"; action = "<cmd>wincmd h<cr>"; options.desc = "Window left"; }
        { mode = "n"; key = "<c-j>"; action = "<cmd>wincmd j<cr>"; options.desc = "Window down"; }
        { mode = "n"; key = "<c-k>"; action = "<cmd>wincmd k<cr>"; options.desc = "Window up"; }
        { mode = "n"; key = "<c-l>"; action = "<cmd>wincmd l<cr>"; options.desc = "Window right"; }
        { mode = "n"; key = "<leader>H"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear Highlight"; }
        { mode = "n"; key = "<leader>t"; action = "<cmd>Neotree toggle<cr>"; options.desc = "Toggle neo-tree"; }
        { mode = "n"; key = "<leader><space>"; action = "<cmd>Telescope oldfiles<cr>"; options.desc = "Open recent files"; }
        # Helix inspired keybindings
        { mode = "n"; key = "<leader>f"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Open file picker"; }
        { mode = "n"; key = "<leader>F"; action = "<cmd>Neotree filesystem reveal left"; options.desc = "Open neo-tree at current file"; }
        { mode = "n"; key = "<leader>b"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Open buffer picker"; }
        { mode = "n"; key = "<leader>'"; action = "<cmd>Telescope pickers"; options.desc = "Open last fuzzy picker"; }
        { mode = "n"; key = "<leader>/"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Global search in workspace folder"; }
        { mode = "n"; key = "<leader>?"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Open command palette"; }
      ];
      extraConfigLua = ''
        require("gruvbox").setup({
          transparent_mode = true,
        });
        vim.cmd("colorscheme gruvbox");
      '';
    };
  };
}
