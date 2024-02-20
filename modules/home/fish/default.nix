{ lib, config, pkgs, ... }:
let
  cfg = config.programs.fish;
in
{
  config = lib.mkIf cfg.enable {
    programs.fish = {
      interactiveShellInit = ''
        set fish_greeting
      '';
    };
  };
}

