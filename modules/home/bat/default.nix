{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.bat.enable = lib.mkEnableOption "Enable bat" // {
    default = true;
  };

  config = lib.mkIf cfg.bat.enable {
    programs.bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
    home.shellAliases = {
      cat = "bat -pp";
    };
  };
}
