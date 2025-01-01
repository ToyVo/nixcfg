{
  globals.mapleader = " ";

  keymaps = [
    # Clear search with ESC
    {
      mode = ["n" "i"];
      key = "<esc>";
      action = "<cmd>nohlsearch<cr><esc>";
      options = {
        silent = true;
        desc = "Escape and clear hlsearch";
      };
    }

    # Windows
    {
      mode = "n";
      key = "<C-Up>";
      action = "<C-w>k";
      options.desc = "Move To Window Up";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Move to Window Up";
    }

    {
      mode = "n";
      key = "<C-Down>";
      action = "<C-w>j";
      options.desc = "Move To Window Down";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Move to Window Down";
    }

    {
      mode = "n";
      key = "<C-Left>";
      action = "<C-w>h";
      options.desc = "Move To Window Left";
    }
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Move to Window Left";
    }

    {
      mode = "n";
      key = "<C-Right>";
      action = "<C-w>l";
      options.desc = "Move To Window Right";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Move to Window Right";
    }

    {
      mode = "n";
      key = "<leader>wd";
      action = "<C-W>c";
      options = {
        silent = true;
        desc = "Delete window";
      };
    }

    {
      mode = "n";
      key = "<leader>-";
      action = "<C-W>s";
      options = {
        silent = true;
        desc = "Split window below";
      };
    }

    {
      mode = "n";
      key = "<leader>|";
      action = "<C-W>v";
      options = {
        silent = true;
        desc = "Split window right";
      };
    }

    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }

    {
      mode = "n";
      key = "<C-s>";
      action = "<cmd>w<cr><esc>";
      options = {
        silent = true;
        desc = "Save file";
      };
    }

    # Quit/Session
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>quitall<cr><esc>";
      options = {
        silent = true;
        desc = "Quit all";
      };
    }

    {
      mode = "n";
      key = "<leader>uw";
      action.__raw = "ToggleWrap";
      options = {
        silent = true;
        desc = "Toggle Line Wrap";
      };
    }

    # Move Lines
    {
      mode = "n";
      key = "<A-Up>";
      action = "<cmd>m .-2<cr>==";
      options.desc = "Move line up";
    }

    {
      mode = "v";
      key = "<A-Up>";
      action = ":m '<-2<cr>gv=gv";
      options.desc = "Move line up";
    }

    {
      mode = "n";
      key = "<A-Down>";
      action = "<cmd>m .+1<cr>==";
      options.desc = "Move line down";
    }

    {
      mode = "v";
      key = "<A-Down>";
      action = ":m '>+1<cr>gv=gv";
      options.desc = "Move line Down";
    }

    # Better indenting
    {
      mode = "v";
      key = "<";
      action = "<gv";
    }

    {
      mode = "v";
      key = ">";
      action = ">gv";
    }

    {
      mode = "i";
      key = "<C-a>";
      action = "<cmd> norm! ggVG<cr>";
      options.desc = "Select all lines in buffer";
    }

    {
      mode = "n";
      key = "J";
      action = "mzJ`z";
      options.desc = "Allow cursor to stay in the same place after appending to current line ";
    }

    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
      options.desc = "Allow C-d and C-u to keep the cursor in the middle";
    }

    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options.desc = "Allow C-d and C-u to keep the cursor in the middle";
    }

    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options.desc = "Allow search terms to stay in the middle";
    }

    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options.desc = "Allow search terms to stay in the middle";
    }

    # Paste stuff without saving the deleted word into the buffer
    {
      mode = "x";
      key = "p";
      action = "\"_dP";
      options.desc = "Deletes to void register and paste over";
    }

    # Delete to void register
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>D";
      action = "\"_d";
      options.desc = "Delete to void register";
    }

    {
      mode = "n";
      key = "[d";
      action.__raw = "vim.diagnostic.goto_prev";
      options.desc = "Go to previous [D]iagnostic message";
    }
    {
      mode = "n";
      key = "]d";
      action.__raw = "vim.diagnostic.goto_next";
      options.desc = "Go to next [D]iagnostic message";
    }
    {
      mode = "n";
      key = "<leader>e";
      action.__raw = "vim.diagnostic.open_float";
      options.desc = "Show diagnostic [E]rror messages";
    }
    {
      mode = "n";
      key = "<leader>q";
      action.__raw = "vim.diagnostic.setloclist";
      options.desc = "Open diagnostic [Q]uickfix list";
    }

    {
      mode = "n";
      key = "<leader>sh";
      action.__raw = "require('telescope.builtin').help_tags";
      options.desc = "[S]earch [H]elp";
    }
    {
      mode = "n";
      key = "<leader>sk";
      action.__raw = "require('telescope.builtin').keymaps";
      options.desc = "[S]earch [K]eymaps";
    }
    {
      mode = "n";
      key = "<leader>sf";
      action.__raw = "require('telescope.builtin').find_files";
      options.desc = "[S]earch [F]iles";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action.__raw = "require('telescope.builtin').builtin";
      options.desc = "[S]earch [S]elect Telescope";
    }
    {
      mode = "n";
      key = "<leader>sw";
      action.__raw = "require('telescope.builtin').grep_string";
      options.desc = "[S]earch current [W]ord";
    }
    {
      mode = "n";
      key = "<leader>sg";
      action.__raw = "require('telescope.builtin').live_grep";
      options.desc = "[S]earch by [G]rep";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action.__raw = "require('telescope.builtin').diagnostics";
      options.desc = "[S]earch [D]iagnostics";
    }
    {
      mode = "n";
      key = "<leader>sr";
      action.__raw = "require('telescope.builtin').resume";
      options.desc = "[S]earch [R]esume";
    }
    {
      mode = "n";
      key = "<leader>s.";
      action.__raw = "require('telescope.builtin').oldfiles";
      options.desc = ''[S]earch Recent Files ("." for repeat)'';
    }
    {
      mode = "n";
      key = "<leader><leader>";
      action.__raw = "require('telescope.builtin').buffers";
      options.desc = "[ ] Find existing buffers";
    }
    {
      mode = "n";
      key = "gd";
      action.__raw = "require('telescope.builtin').lsp_definitions";
      options.desc = "LSP: [G]oto [D]efinition";
    }
    {
      mode = "n";
      key = "gr";
      action.__raw = "require('telescope.builtin').lsp_references";
      options.desc = "LSP: [G]oto [R]eferences";
    }
    {
      mode = "n";
      key = "gI";
      action.__raw = "require('telescope.builtin').lsp_implementations";
      options.desc = "LSP: [G]oto [I]mplementation";
    }
    {
      mode = "n";
      key = "<leader>D";
      action.__raw = "require('telescope.builtin').lsp_type_definitions";
      options.desc = "LSP: Type [D]efinition";
    }
    {
      mode = "n";
      key = "<leader>ds";
      action.__raw = "require('telescope.builtin').lsp_document_symbols";
      options.desc = "LSP: [D]ocument [S]ymbols";
    }
    {
      mode = "n";
      key = "<leader>ws";
      action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
      options.desc = "LSP: [W]orkspace [S]ymbols";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action.__raw = "vim.lsp.buf.rename";
      options.desc = "LSP: [R]e[n]ame";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action.__raw = "vim.lsp.buf.code_action";
      options.desc = "LSP: [C]ode [A]ction";
    }
    {
      mode = "n";
      key = "K";
      action.__raw = "vim.lsp.buf.hover";
      options.desc = "LSP: Hover Documentation";
    }
    {
      mode = "n";
      key = "gD";
      action.__raw = "vim.lsp.buf.declaration";
      options.desc = "LSP: [G]oto [D]eclaration";
    }
    {
      mode = "n";
      key = "<leader>/";
      action.__raw = ''
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end
      '';
      options.desc = "[/] Fuzzily search in current buffer";
    }
    {
      mode = "n";
      key = "<leader>s/";
      action.__raw = ''
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end
      '';
      options.desc = "[S]earch [/] in Open Files";
    }
    {
      mode = "n";
      key = "<leader>sn";
      action.__raw = ''
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
        end
      '';
      options.desc = "[S]earch [N]eovim files";
    }
    {
      mode = "n";
      key = "<F1>";
      action.__raw = "require('dap').step_into";
      options.desc = "Debug: Step Into";
    }
    {
      mode = "n";
      key = "<F2>";
      action.__raw = "require('dap').step_over";
      options.desc = "Debug: Step Over";
    }
    {
      mode = "n";
      key = "<F3>";
      action.__raw = "require('dap').step_out";
      options.desc = "Debug: Step Out";
    }
    {
      mode = "n";
      key = "<F5>";
      action.__raw = "require('dap').continue";
      options.desc = "Debug: Start/Continue";
    }
    {
      mode = "n";
      key = "<F7>";
      action.__raw = "require('dapui').toggle";
      options.desc = "Debug: See last session result.";
    }
    {
      mode = "n";
      key = "<leader>b";
      action.__raw = "require('dap').toggle_breakpoint";
      options.desc = "Debug: Toggle Breakpoint";
    }
    {
      mode = "n";
      key = "<leader>B";
      action.__raw = ''
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end
      '';
      options.desc = "Debug: Set Breakpoint";
    }
  ];
}
