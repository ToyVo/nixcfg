{
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  cfg = config.programs.alacritty;
in
{
  config = lib.mkIf cfg.enable {
    catppuccin.alacritty = {
      enable = true;
      flavor = config.catppuccin.flavor;
    };
    programs.alacritty = {
      settings = {
        shell = {
          program = "${pkgs.bashInteractive}/bin/bash";
          args = [ "-l" ];
        };
      };
    };
  };
}
