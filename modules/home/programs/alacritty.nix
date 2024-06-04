{ config, lib, pkgs, system, ... }:
let
  cfg = config.programs.alacritty;
in
{
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      catppuccin = {
        enable = true;
        flavor = config.catppuccin.flavor;
      };
      settings = {
        shell = {
          program = "${pkgs.bashInteractive}/bin/bash";
          args = [ "-l" ];
        };
      };
    };
  };
}
