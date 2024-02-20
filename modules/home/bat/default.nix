{ lib, config, pkgs, ... }:
let
  cfg = config.programs.bat;
in
{
  config = lib.mkIf cfg.enable {
    programs.bat = {
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
