{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.fish.enable = lib.mkEnableOption "Enable fish";

  config = lib.mkIf cfg.packages.fish.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
    };
  };
}

