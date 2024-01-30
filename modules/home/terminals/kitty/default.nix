{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.kitty.enable = lib.mkEnableOption "Enable kitty";

  config = lib.mkIf cfg.packages.kitty.enable {
    programs.kitty = {
      enable = true;
      theme = "Gruvbox Dark";
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
