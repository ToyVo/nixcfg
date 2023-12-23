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
        package = pkgs.monaspace;
        name = "Monaspace Neon";
        size = 14;
      };
      settings = {
        shell = "${pkgs.zsh}/bin/zsh";
      };
    };
  };
}
