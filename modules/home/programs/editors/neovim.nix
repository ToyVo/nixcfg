{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.nvim;
in {
  options.programs.nvim.enable = lib.mkEnableOption "Enable neovim";

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      defaultEditor = true;
      settings.vim = {
        viAlias = true;
        vimAlias = true;
        lsp = {
          enable = true;
          lightbulb.enable = true;
          trouble.enable = true;
          lspSignature.enable = true;
        };
        theme = {
          enable = true;
          name = "catppuccin";
          style = config.catppuccin.flavor;
          transparent = true;
        };
        languages = {
          enableDAP = true;
          enableExtraDiagnostics = true;
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          bash.enable = true;
          clang.enable = true;
          csharp.enable = true;
          css.enable = true;
          html.enable = true;
          lua.enable = true;
          markdown.enable = true;
          nix.enable = true;
          nu.enable = true;
          python.enable = true;
          rust.enable = true;
          sql.enable = true;
          tailwind.enable = true;
          terraform.enable = true;
          ts.enable = true;
          yaml.enable = true;
        };
        options = {
          tabstop = 2;
          softtabstop = 2;
          shiftwidth = 2;
          expandtab = true;
        };
        utility.sleuth.enable = true;
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        binds.whichKey.enable = true;
        git.enable = true;
      };
    };
  };
}
