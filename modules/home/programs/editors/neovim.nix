{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nvim;
in
{
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
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          nix.enable = true;
          rust.enable = true;
          python.enable = true;
          css.enable = true;
          ts.enable = true;
          html.enable = true;
        };
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        binds.whichKey.enable = true;
        git.enable = true;
      };
    };
  };
}
