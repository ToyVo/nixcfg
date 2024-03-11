{ lib, config, pkgs, ... }:
let
  cfg = config.programs.volta;
in
{
  options.programs.volta = {
    enable = lib.mkEnableOption "Enable volta";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.volta;
      description = "The volta package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      fish.shellInit = ''
        set PATH $VOLTA_HOME/bin $PATH
      '';
      nushell.envFile.text = ''
        $env.VOLTA_HOME = $'($env.HOME)/.volta'
        $env.PATH = ($env.PATH | prepend $'($env.VOLTA_HOME)/bin')
      '';
    };
    home.packages = [ cfg.package ];
    home.sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
      NODE_ENV = "development";
      RUN_ENV = "local";
    };
    home.sessionPath = [ "$VOLTA_HOME/bin" ];
  };
}

