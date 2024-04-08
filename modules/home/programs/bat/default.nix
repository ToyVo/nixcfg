{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.programs.bat;
in
{
  config = lib.mkIf cfg.enable {
    programs.bat.catppuccin = {
      enable = true;
      flavour = config.catppuccin.flavour;
    };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };
    home.shellAliases = {
      cat = "bat -pp";
    };
  };
}
