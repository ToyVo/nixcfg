{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.bat;
in
{
  options.cdcfg.bat.enable = lib.mkEnableOption "Enable bat" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
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
