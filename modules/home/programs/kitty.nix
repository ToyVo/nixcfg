{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kitty;
in
{
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      catppuccin = {
        enable = true;
        flavor = config.catppuccin.flavor;
      };
      font = {
        name = "MonaspiceNe Nerd Font Mono Regular";
        size = 14;
      };
      settings = {
        shell = "${pkgs.zsh}/bin/zsh";
      };
      extraConfig = ''
        font_features MonaspiceNeNFM-Regular +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +calt +dlig
      '';
    };
  };
}
