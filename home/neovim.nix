{pkgs, pkgs-unstable, lib, ...}: {
  programs.neovim = {
    enable = true;
    # package = pkgs-unstable.neovim;
    # defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      # lua-language-server
      nil
      rust-analyzer
      nodePackages.eslint
      nodePackages.typescript-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      impatient-nvim
      lualine-nvim
      lualine-lsp-progress
      gruvbox-nvim
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-treesitter-textobjects
      nvim-ts-context-commentstring
      undotree
      vim-fugitive
      vim-sleuth
      vim-bbye
      vim-illuminate
      gitsigns-nvim
      comment-nvim
      # lspsaga-nvim-original
      nvim-lspconfig
      nvim-web-devicons
      nvim-cmp
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lua
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      luasnip
      friendly-snippets
      nvim-tree-lua
      rust-tools-nvim
      nvim-autopairs
      nvim-ts-autotag
      plenary-nvim
      telescope-nvim
      telescope-ui-select-nvim
      telescope-frecency-nvim
      sqlite-lua
      nvim-dap
      telescope-dap-nvim
      which-key-nvim
    ];
    extraLuaConfig = lib.fileContents ./assets/init.lua;
  };
}
